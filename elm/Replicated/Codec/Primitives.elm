module Replicated.Codec.Primitives exposing (bool, byte, bytes, char, float, id, int, quickEnum, string, todo, unit)

{-| Codecs for "primitive" types, which in our case just means types that aren't some sort of collection.
-}

import Array exposing (Array)
import Base64
import Bytes
import Bytes.Decode as BD
import Bytes.Encode as BE
import Console
import Css exposing (None)
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Html exposing (input, th)
import ID exposing (ID)
import Json.Decode as JD
import Json.Encode as JE
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Maybe.Extra
import Regex exposing (Regex)
import Replicated.Change as Change exposing (Change, ChangeSet(..), Changer, ComplexAtom(..), Context, ObjectChange, Parent(..), Pointer(..))
import Replicated.Change.Location as Location exposing (Location)
import Replicated.Codec.Base as Base exposing (Codec(..), PrimitiveCodec, SelfSeededCodec)
import Replicated.Codec.Bytes.Decoder as BytesDecoder exposing (BytesDecoder)
import Replicated.Codec.Bytes.Encoder as BytesEncoder exposing (BytesEncoder)
import Replicated.Codec.Error as Error exposing (RepDecodeError(..))
import Replicated.Codec.Initializer as Initializer exposing (Initializer)
import Replicated.Codec.Json.Decoder as JsonDecoder exposing (JsonDecoder)
import Replicated.Codec.Json.Encoder exposing (JsonEncoder)
import Replicated.Codec.Node.Decoder as NodeDecoder exposing (Inputs, NodeDecoder)
import Replicated.Codec.Node.Encoder as NodeEncoder exposing (NodeEncoder)
import Replicated.Codec.RonPayloadDecoder as RonPayloadDecoder exposing (RonPayloadDecoder(..))
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Object as Object exposing (Object)
import Replicated.Op.ID as OpID exposing (InCounter, ObjectID, OpID, OutCounter)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Reducer.Register as Reg exposing (..)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict, RepDictEntry(..))
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Replicated.Reducer.RepStore as RepStore exposing (RepStore)
import Set exposing (Set)
import SmartTime.Moment as Moment exposing (Moment)
import Toop exposing (T4(..), T5(..), T6(..), T7(..), T8(..))



-- HELPERS


{-| TODO: Eliminate this, record syntax is clearer
-}
buildCodec :
    BytesEncoder a
    -> BytesDecoder a
    -> JsonEncoder a
    -> JsonDecoder a
    -> NodeEncoder a o
    -> NodeDecoder a
    -> SelfSeededCodec o a
buildCodec encoder_ decoder_ jsonEncoder jsonDecoder ronEncoder ronDecoder =
    Codec
        { bytesEncoder = encoder_
        , bytesDecoder = decoder_
        , jsonEncoder = jsonEncoder
        , jsonDecoder = jsonDecoder
        , nodeEncoder = ronEncoder
        , nodeDecoder = ronDecoder
        , nodePlaceholder = Initializer.flatInit
        }



-- CODECS


string : PrimitiveCodec String
string =
    let
        nodeEncoder : NodeEncoder.Inputs String -> NodeEncoder.PrimitiveOutput
        nodeEncoder inputs =
            NodeEncoder.singlePrimitiveOut <| Change.StringAtom <| NodeEncoder.getEncodedPrimitive inputs.thingToEncode
    in
    Codec
        { bytesEncoder =
            \text ->
                BE.sequence
                    [ BE.unsignedInt32 BytesEncoder.endian (BE.getStringWidth text)
                    , BE.string text
                    ]
        , bytesDecoder =
            BD.unsignedInt32 BytesEncoder.endian
                |> BD.andThen
                    (\charCount -> BD.string charCount |> BD.map Ok)
        , jsonEncoder = JE.string
        , jsonDecoder = JD.string |> JD.map Ok
        , nodeEncoder = nodeEncoder
        , nodeDecoder = \_ -> JD.string |> JD.map Ok
        , nodePlaceholder = Initializer.flatInit
        }


id : PrimitiveCodec (ID userType)
id =
    let
        toObjectID givenID =
            case ID.getObjectID givenID of
                Just objectID ->
                    objectID

                Nothing ->
                    Log.crashInDev ("ID should always be ObjectID before serializing. Tried to serialize the ID " ++ Log.dump givenID)
                        OpID.fromStringForced
                        ("Uninitialized! " ++ Log.dump givenID)

        idToChangeAtom givenID =
            case ID.toPointer "bogus reducer unused" givenID of
                ExistingObjectPointer existingID ->
                    Change.ExistingObjectReferenceAtom existingID.object

                PlaceholderPointer pendingID _ ->
                    Change.PendingObjectReferenceAtom pendingID

        idToPrimitiveAtom givenID =
            case ID.toPointer "bogus reducer unused" givenID of
                ExistingObjectPointer existingID ->
                    Change.StringAtom (OpID.toString existingID.object)

                PlaceholderPointer pendingID _ ->
                    -- can't crash here because primitive mode is always calculated even if unused
                    -- Log.crashInDev ("Tried to primitive-serialize an ID that was pending. Pending ID: " ++ Log.dump pendingID) <|
                    Change.StringAtom "pendingID"

        toString givenID =
            OpID.toString (toObjectID givenID)

        fromString nodeMaybe asString =
            let
                opID =
                    case OpID.fromRonPointerString asString of
                        Just goodOpID ->
                            goodOpID

                        Nothing ->
                            Log.crashInDev ("Failed to sucessfully un-serialize OpID " ++ asString ++ ", is it in ron pointer form?") OpID.fromStringForced asString

                finalPointer reducerID =
                    ID.fromPointer (ExistingObjectPointer (Change.ExistingID reducerID opID))
            in
            case nodeMaybe of
                Nothing ->
                    -- TODO should only happen with other serialization types
                    finalPointer ""

                Just node ->
                    case Node.lookupObject node opID of
                        Nothing ->
                            Log.crashInDev
                                ("Un-serializing an ID " ++ asString ++ " but I couldn't find the object referenced in the node!")
                                ID.fromPointer
                                (ExistingObjectPointer (Change.ExistingID "error" opID))

                        Just ( reducerID, objectID ) ->
                            -- TODO should we use the OpID instead? For versioning?
                            -- Or is this better to switch to canonical ObjectIDs
                            ID.fromPointer (ExistingObjectPointer (Change.ExistingID reducerID objectID))

        nodeEncoder : NodeEncoder.Inputs (ID userType) -> NodeEncoder.PrimitiveOutput
        nodeEncoder inputs =
            { complex = Nonempty.singleton <| idToChangeAtom (NodeEncoder.getEncodedPrimitive inputs.thingToEncode)
            , primitive = Nonempty.singleton <| idToPrimitiveAtom (NodeEncoder.getEncodedPrimitive inputs.thingToEncode)
            }
    in
    Codec
        { bytesEncoder =
            \i ->
                BE.sequence
                    [ BE.unsignedInt32 BytesEncoder.endian (BE.getStringWidth (toString i))
                    , BE.string (toString i)
                    ]
        , bytesDecoder =
            BD.unsignedInt32 BytesEncoder.endian
                |> BD.andThen
                    (\charCount -> BD.string charCount |> BD.map (fromString Nothing >> Ok))
        , jsonEncoder = toString >> JE.string
        , jsonDecoder = JD.string |> JD.map (fromString Nothing >> Ok)
        , nodeEncoder = nodeEncoder
        , nodeDecoder = \inputs -> JD.string |> JD.map (fromString (Just inputs.node) >> Ok)
        , nodePlaceholder = Initializer.flatInit
        }


bool : PrimitiveCodec Bool
bool =
    let
        boolNodeEncoder : NodeEncoder Bool NodeEncoder.Primitive
        boolNodeEncoder { thingToEncode } =
            if NodeEncoder.getEncodedPrimitive thingToEncode then
                NodeEncoder.singlePrimitiveOut <| Change.NakedStringAtom "true"

            else
                NodeEncoder.singlePrimitiveOut <| Change.NakedStringAtom "false"

        boolNodeDecoder : NodeDecoder Bool
        boolNodeDecoder _ =
            NodeDecoder.primitive <|
                JD.oneOf [ JD.bool |> JD.map Ok, JD.string |> JD.andThen stringToBool ]

        stringToBool givenString =
            case givenString of
                "true" ->
                    JD.succeed (Ok True)

                "false" ->
                    JD.succeed (Ok False)

                "True" ->
                    JD.succeed (Ok True)

                "False" ->
                    JD.succeed (Ok False)

                other ->
                    JD.succeed (Err (BadBoolean other))
    in
    buildCodec
        (\value ->
            if value then
                BE.unsignedInt8 1

            else
                BE.unsignedInt8 0
        )
        (BD.unsignedInt8
            |> BD.map
                (\value ->
                    case value of
                        0 ->
                            Ok False

                        1 ->
                            Ok True

                        other ->
                            Err (BadBoolean (String.fromInt value))
                )
        )
        JE.bool
        (JD.bool |> JD.map Ok)
        boolNodeEncoder
        boolNodeDecoder


int : PrimitiveCodec Int
int =
    buildCodec
        (toFloat >> BE.float64 BytesEncoder.endian)
        (BD.float64 BytesEncoder.endian |> BD.map (round >> Ok))
        JE.int
        (JD.int |> JD.map Ok)
        (\{ thingToEncode } ->
            NodeEncoder.singlePrimitiveOut <| Change.IntegerAtom <| NodeEncoder.getEncodedPrimitive thingToEncode
        )
        (\_ -> JD.int |> JD.map Ok)


float : PrimitiveCodec Float
float =
    buildCodec
        (BE.float64 BytesEncoder.endian)
        (BD.float64 BytesEncoder.endian |> BD.map Ok)
        JE.float
        (JD.float |> JD.map Ok)
        (\{ thingToEncode } ->
            NodeEncoder.singlePrimitiveOut <| Change.FloatAtom <| NodeEncoder.getEncodedPrimitive thingToEncode
        )
        (\_ -> JD.float |> JD.map Ok)


char : PrimitiveCodec Char
char =
    let
        charEncode text =
            BE.sequence
                [ BE.unsignedInt32 BytesEncoder.endian (String.length text)
                , BE.string text
                ]
    in
    buildCodec
        (String.fromChar >> charEncode)
        (BD.unsignedInt32 BytesEncoder.endian
            |> BD.andThen (\charCount -> BD.string charCount)
            |> BD.map
                (\text ->
                    case String.toList text |> List.head of
                        Just char_ ->
                            Ok char_

                        Nothing ->
                            Err (BadChar text)
                )
        )
        (String.fromChar >> JE.string)
        (JD.string
            |> JD.map
                (\text ->
                    case String.toList text |> List.head of
                        Just char_ ->
                            Ok char_

                        Nothing ->
                            Err (BadChar text)
                )
        )
        (\{ thingToEncode } -> NodeEncoder.singlePrimitiveOut <| Change.StringAtom <| String.fromChar <| NodeEncoder.getEncodedPrimitive thingToEncode)
        (\_ ->
            JD.string
                |> JD.map
                    (\text ->
                        case String.toList text |> List.head of
                            Just char_ ->
                                Ok char_

                            Nothing ->
                                Err (BadChar text)
                    )
        )


unit : PrimitiveCodec ()
unit =
    buildCodec
        (always (BE.sequence []))
        (BD.succeed (Ok ()))
        (\_ -> JE.int 0)
        (JD.succeed (Ok ()))
        (\_ -> NodeEncoder.singlePrimitiveOut <| Change.IntegerAtom 0)
        (\_ -> JD.succeed (Ok ()))


bytes : PrimitiveCodec Bytes.Bytes
bytes =
    buildCodec
        (\bytes_ ->
            BE.sequence
                [ BE.unsignedInt32 BytesEncoder.endian (Bytes.width bytes_)
                , BE.bytes bytes_
                ]
        )
        (BD.unsignedInt32 BytesEncoder.endian |> BD.andThen (\length -> BD.bytes length |> BD.map Ok))
        (BytesEncoder.replaceBase64Chars >> JE.string)
        (JD.string
            |> JD.map
                (\text ->
                    case BytesDecoder.decodeStringToBytes text of
                        Just bytes_ ->
                            Ok bytes_

                        Nothing ->
                            Err (BadByteString text)
                )
        )
        (\inputs -> NodeEncoder.singlePrimitiveOut <| Change.StringAtom <| BytesEncoder.replaceBase64Chars <| NodeEncoder.getEncodedPrimitive inputs.thingToEncode)
        (\_ ->
            JD.string
                |> JD.map
                    (\text ->
                        case BytesDecoder.decodeStringToBytes text of
                            Just bytes_ ->
                                Ok bytes_

                            Nothing ->
                                Err (BadByteString text)
                    )
        )


byte : PrimitiveCodec Int
byte =
    buildCodec
        BE.unsignedInt8
        (BD.unsignedInt8 |> BD.map Ok)
        (modBy 256 >> JE.int)
        (JD.int |> JD.map Ok)
        (\{ thingToEncode } -> NodeEncoder.singlePrimitiveOut <| Change.IntegerAtom <| modBy 256 <| NodeEncoder.getEncodedPrimitive thingToEncode)
        (\_ -> JD.int |> JD.map Ok)


quickEnum : a -> List a -> PrimitiveCodec a
quickEnum defaultItem items =
    let
        getAt : Int -> List a -> Maybe a
        getAt idx xs =
            if idx < 0 then
                Nothing

            else
                List.head <| List.drop idx xs

        getIndex value =
            items
                |> findIndex ((==) value)
                |> Maybe.withDefault -1
                |> (+) 1

        getItem index =
            if index < 0 then
                Err (BadIndex index)

            else if index > List.length items then
                Err (BadIndex index)

            else
                getAt (index - 1) items |> Maybe.withDefault defaultItem |> Ok

        intNodeEncoder : NodeEncoder a NodeEncoder.Primitive
        intNodeEncoder { thingToEncode } =
            NodeEncoder.singlePrimitiveOut <| Change.IntegerAtom <| getIndex <| NodeEncoder.getEncodedPrimitive <| thingToEncode
    in
    buildCodec
        (getIndex >> BE.unsignedInt32 BytesEncoder.endian)
        (BD.unsignedInt32 BytesEncoder.endian |> BD.map getItem)
        (getIndex >> JE.int)
        (JD.int |> JD.map getItem)
        intNodeEncoder
        (\_ -> JD.int |> JD.map getItem)


{-| <https://github.com/elm-community/list-extra/blob/f9faf1cfa1cec24f977313b1b63e2a1064c36eed/src/List/Extra.elm#L620>
-}
findIndex : (a -> Bool) -> List a -> Maybe Int
findIndex =
    findIndexHelp 0


{-| <https://github.com/elm-community/list-extra/blob/f9faf1cfa1cec24f977313b1b63e2a1064c36eed/src/List/Extra.elm#L625>
-}
findIndexHelp : Int -> (a -> Bool) -> List a -> Maybe Int
findIndexHelp index predicate list_ =
    case list_ of
        [] ->
            Nothing

        x :: xs ->
            if predicate x then
                Just index

            else
                findIndexHelp (index + 1) predicate xs


todo : a -> PrimitiveCodec a
todo bogusValue =
    Codec
        { bytesEncoder = \_ -> BE.unsignedInt8 9
        , bytesDecoder = BD.fail
        , jsonEncoder = \_ -> JE.null
        , jsonDecoder = JD.fail "TODO"
        , nodeEncoder = \_ -> NodeEncoder.singlePrimitiveOut <| Change.StringAtom "TODO"
        , nodeDecoder = \_ -> JD.fail "TODO"
        , nodePlaceholder = \_ -> bogusValue
        }
