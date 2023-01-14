module Replicated.Codec exposing (..)

{-|


# Serialization

You have three options when encoding data. You can represent the data either as json, bytes, or a string.
Here's some advice when choosing:

  - If performance is important, use `encodeToJson` and `decodeFromJson`
  - If space efficiency is important, use `encodeToBytes` and `decodeFromBytes`\*
  - `encodeToString` and `decodeFromString` are good for URL safe strings but otherwise one of the other choices is probably better.

\*`encodeToJson` is more compact when encoding integers with 6 or fewer digits. You may want to try both `encodeToBytes` and `encodeToJson` and see which is better for your use case.

@docs encodeToJson, decodeFromJson, encodeToBytes, decodeFromBytes, encodeToString, decodeFromURLSafeByteString


# Definition

@docs Codec, Error


# Primitives

@docs string, bool, float, int, unit, bytes, byte


# Data Structures

@docs maybe, primitiveList, array, dict, set, pair, triple, result, enum


# Records

@docs RecordCodec, record, field, finishRecord


# Custom Types

@docs CustomTypeCodec, customType, variant0, variant1, variant2, variant3, variant4, variant5, variant6, variant7, variant8, finishCustomType, VariantEncoder


# Mapping

@docs map, mapValid, mapError


# Stack unsafe

@docs lazy

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
import ID exposing (ID)
import Json.Decode as JD
import Json.Encode as JE
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Maybe.Extra
import Regex exposing (Regex)
import Replicated.Change as Change exposing (Change(..), ChangeAtom(..), Changer, MaybeSkippableChange(..), ObjectChange, Parent(..), Pointer(..), changeToChangePayload, genesisPointer)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Object as Object exposing (I, Object, Placeholder)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.OpID as OpID exposing (InCounter, ObjectID, OpID, OutCounter)
import Replicated.Reducer.Register as Reg exposing (..)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict, RepDictEntry(..))
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Replicated.Reducer.RepStore as RepStore exposing (RepStore)
import Set exposing (Set)
import SmartTime.Moment as Moment exposing (Moment)
import Toop exposing (T4(..), T5(..), T6(..), T7(..), T8(..))



-- CODEC DEFINITIONS


{-| Like a normal codec, but can have references instead of values, so must be passed the entire Replica so that some decoders may search elsewhere.
-}
type Codec e s a
    = Codec
        { bytesEncoder : a -> BE.Encoder
        , bytesDecoder : BD.Decoder (Result (Error e) a)
        , jsonEncoder : a -> JE.Value
        , jsonDecoder : JD.Decoder (Result (Error e) a)
        , nodeEncoder : NodeEncoder a
        , nodeDecoder : NodeDecoder e a
        , init : Initializer s a
        }


type alias FlatCodec e a =
    Codec e a a


type alias SkelCodec e a =
    Codec e Skel a


type alias WrappedOrSkelCodec e s a =
    Codec e (s -> List Change) a


type alias WrappedCodec e a =
    Codec e (Changer a) a


type alias WrappedSeededCodec e s a =
    Codec e ( s, Changer a ) a


type alias Initializer i a =
    InitializerInputs i -> a


type alias InitializerInputs seed =
    { parent : Pointer
    , position : Nonempty Change.SiblingIndex
    , seed : seed
    }



-- RON DEFINITIONS


type alias NodeEncoderInputs a =
    { node : Node
    , mode : ChangesToGenerate
    , thingToEncode : ThingToEncode a
    , parent : Change.Pointer
    , position : Nonempty Change.SiblingIndex
    }


type ThingToEncode fieldType
    = EncodeThis fieldType
    | EncodeObjectOrThis (Nonempty ObjectID) fieldType -- so that naked registers have something to fall back on


type alias NodeEncoderInputsNoVariable =
    -- TODO make unnecessary, by currying NodeEncoderInputs
    { node : Node
    , mode : ChangesToGenerate
    , parent : Change.Pointer
    , position : Nonempty Change.SiblingIndex
    }


type alias ChangesToGenerate =
    { initializeUnusedObjects : Bool
    , setDefaultsExplicitly : Bool
    , generateSnapshot : Bool
    , cloneOldOps : Bool
    }


defaultEncodeMode : ChangesToGenerate
defaultEncodeMode =
    { initializeUnusedObjects = False, setDefaultsExplicitly = False, generateSnapshot = False, cloneOldOps = False }


type alias NodeEncoder a =
    NodeEncoderInputs a -> Change.MaybeSkippableChange


type alias NodeDecoder e a =
    -- For now we just reuse Json Decoders
    NodeDecoderInputs -> JD.Decoder (Result (Error e) a)


type alias NodeDecoderInputs =
    { node : Node
    , parent : Change.Pointer
    , position : Nonempty Change.SiblingIndex
    , cutoff : Maybe Moment
    }


type alias RegisterFieldEncoder full =
    RegisterFieldEncoderInputs full -> RegisterFieldEncoderOutput


{-| Inputs to a node Field encoder.

No "position" because it's already in the parent, and field index can be determined by record counter

-}
type alias RegisterFieldEncoderInputs field =
    { node : Node
    , mode : ChangesToGenerate
    , history : FieldHistoryDict
    , parentPointer : Pointer
    , updateRegisterAfterChildInit : Change.PotentialPayload -> Change
    , existingValMaybe : Maybe field
    }


type alias RegisterFieldDecoder e remaining =
    RegisterFieldDecoderInputs -> ( Maybe remaining, List (Error e) )


type alias RegisterFieldInitializer parentSeed remaining =
    parentSeed -> Pointer -> remaining


type alias RegisterFieldDecoderInputs =
    { node : Node
    , pointer : Pointer
    , history : FieldHistoryDict
    , cutoff : Maybe Moment
    }


type alias SmartJsonFieldEncoder full =
    ( String, full -> JE.Value )



-- ERROR HANDLING


{-| Possible errors that can occur when decoding.
-}
type Error e
    = CustomError e
    | DataCorrupted
    | SerializerOutOfDate
    | ObjectNotFound OpID
    | FailedToDecodeRoot String
    | JDError JD.Error


version : Int
version =
    1



-- DECODE


{-| Pass in the codec for the root object.
-}
decodeFromNode : WrappedOrSkelCodec e s root -> Node -> Result (Error e) root
decodeFromNode rootCodec node =
    let
        rootEncoded =
            node.root
                -- TODO we need to get rid of those quotes, but JD.string expects them for now
                |> Maybe.map (\i -> "[\"" ++ OpID.toString i ++ "\"]")
                |> Maybe.withDefault "\"[]\""
    in
    case JD.decodeString (getNodeDecoder rootCodec { node = node, parent = Change.genesisPointer, cutoff = Nothing, position = Nonempty.singleton "nodeRoot" }) (prepDecoder rootEncoded) of
        Ok value ->
            value

        Err jdError ->
            Err (FailedToDecodeRoot <| JD.errorToString jdError)


{-| Pass in the codec for the root object.
-}
forceDecodeFromNode : SkelCodec e root -> Node -> ( root, Maybe (Error e) )
forceDecodeFromNode rootCodec node =
    let
        rootEncoded =
            node.root
                -- TODO we need to get rid of those quotes, but JD.string expects them for now
                |> Maybe.map (\i -> "[\"" ++ OpID.toString i ++ "\"]")
                |> Maybe.withDefault "\"[]\""

        fromScratch =
            new rootCodec (ParentContext Change.genesisPointer)
    in
    case JD.decodeString (getNodeDecoder rootCodec { node = node, parent = Change.genesisPointer, cutoff = Nothing, position = Nonempty.singleton "nodeRoot" }) (prepDecoder rootEncoded) of
        Ok (Ok success) ->
            ( success, Nothing )

        Err jdError ->
            ( fromScratch, Just (FailedToDecodeRoot <| JD.errorToString jdError) )

        Ok (Err err) ->
            ( fromScratch, Debug.todo "nested error - come up with nicer presentation" )


new : Codec e (s -> List Change) repType -> Parent -> repType
new (Codec codecDetails) (ParentContext parentPointer) =
    codecDetails.init { parent = parentPointer, position = Nonempty.singleton "new", seed = nonChanger }


newWithChanges : WrappedCodec e repType -> Parent -> Changer repType -> repType
newWithChanges (Codec codecDetails) (ParentContext parentPointer) changer =
    -- TODO change argument order
    codecDetails.init { parent = parentPointer, position = Nonempty.singleton "newWithChanges", seed = changer }


seededNew : Codec e s repType -> Parent -> s -> repType
seededNew (Codec codecDetails) (ParentContext parentPointer) seed =
    codecDetails.init { parent = parentPointer, position = Nonempty.singleton "seededNew", seed = seed }


seededNewWithChanges : Codec e ( s, Changer repType ) repType -> Parent -> s -> Changer repType -> repType
seededNewWithChanges (Codec codecDetails) (ParentContext parentPointer) seed changer =
    codecDetails.init { parent = parentPointer, position = Nonempty.singleton "seededNewWithChanges", seed = ( seed, changer ) }


nonChanger _ =
    []


getInitializer : Codec e i repType -> Initializer i repType
getInitializer (Codec codecDetails) inputs =
    codecDetails.init
        { parent = inputs.parent
        , position = inputs.position
        , seed = inputs.seed
        }


endian : Bytes.Endianness
endian =
    Bytes.BE


{-| Extracts the `Decoder` contained inside the `Codec`.
-}
getBytesDecoder : Codec e s a -> BD.Decoder (Result (Error e) a)
getBytesDecoder (Codec m) =
    m.bytesDecoder


{-| Extracts the json `Decoder` contained inside the `Codec`.
-}
getJsonDecoder : Codec e s a -> JD.Decoder (Result (Error e) a)
getJsonDecoder (Codec m) =
    m.jsonDecoder


{-| Extracts the ron decoder contained inside the `Codec`.
-}
getNodeDecoder : Codec e i a -> NodeDecoder e a
getNodeDecoder (Codec m) =
    m.nodeDecoder


{-| Run a `Codec` to turn a sequence of bytes into an Elm value.
-}
decodeFromBytes : FlatCodec e a -> Bytes.Bytes -> Result (Error e) a
decodeFromBytes codec bytes_ =
    let
        decoder =
            BD.unsignedInt8
                |> BD.andThen
                    (\value ->
                        if value <= 0 then
                            Err DataCorrupted |> BD.succeed

                        else if value == version then
                            getBytesDecoder codec

                        else
                            Err SerializerOutOfDate |> BD.succeed
                    )
    in
    case BD.decode decoder bytes_ of
        Just value ->
            value

        Nothing ->
            Err DataCorrupted


{-| Run a `Codec` to turn a String encoded with `encodeToString` into an Elm value.
-}
decodeFromURLSafeByteString : FlatCodec e a -> String -> Result (Error e) a
decodeFromURLSafeByteString codec base64 =
    case decodeStringToBytes base64 of
        Just bytes_ ->
            decodeFromBytes codec bytes_

        Nothing ->
            Err DataCorrupted


{-| Run a `Codec` to turn a json value encoded with `encodeToJson` into an Elm value.
-}
decodeFromJson : Codec e s a -> JE.Value -> Result (Error e) a
decodeFromJson codec json =
    let
        decoder =
            JD.index 0 JD.int
                |> JD.andThen
                    (\value ->
                        if value <= 0 then
                            Err DataCorrupted |> JD.succeed

                        else if value == version then
                            JD.index 1 (getJsonDecoder codec)

                        else
                            Err SerializerOutOfDate |> JD.succeed
                    )
    in
    case JD.decodeValue decoder json of
        Ok value ->
            value

        Err _ ->
            Err DataCorrupted


decodeStringToBytes : String -> Maybe Bytes.Bytes
decodeStringToBytes base64text =
    let
        replaceChar rematch =
            case rematch.match of
                "-" ->
                    "+"

                _ ->
                    "/"

        strlen =
            String.length base64text
    in
    if strlen == 0 then
        BE.encode (BE.sequence []) |> Just

    else
        let
            hanging =
                modBy 4 strlen

            ilen =
                if hanging == 0 then
                    0

                else
                    4 - hanging
        in
        Regex.replace replaceFromUrl replaceChar (base64text ++ String.repeat ilen "=") |> Base64.toBytes


replaceFromUrl : Regex
replaceFromUrl =
    Regex.fromString "[-_]" |> Maybe.withDefault Regex.never



-- ENCODE


{-| Extracts the encoding function contained inside the `Codec`.
-}
getBytesEncoder : Codec e s a -> a -> BE.Encoder
getBytesEncoder (Codec m) =
    m.bytesEncoder


{-| Extracts the replica encoding function contained inside the `Codec`.
-}
getNodeEncoder : Codec e s a -> NodeEncoder a
getNodeEncoder (Codec m) inputs =
    m.nodeEncoder inputs


{-| Extracts the json encoding function contained inside the `Codec`.
-}
getJsonEncoder : Codec e s a -> a -> JE.Value
getJsonEncoder (Codec m) =
    m.jsonEncoder


{-| Convert an Elm value into a sequence of bytes.
-}
encodeToBytes : Codec e s a -> a -> Bytes.Bytes
encodeToBytes codec value =
    BE.sequence
        [ BE.unsignedInt8 version
        , value |> getBytesEncoder codec
        ]
        |> BE.encode


{-| Convert an Elm value into a string. This string contains only url safe characters, so you can do the following:

    import Serlialize as S

    myUrl =
        "www.mywebsite.com/?data=" ++ S.encodeToString S.float 1234

and not risk generating an invalid url.

-}
encodeToURLSafeByteString : Codec e s a -> a -> String
encodeToURLSafeByteString codec =
    encodeToBytes codec >> replaceBase64Chars


{-| Gives you the raw string, for debugging
-}
encodeToJsonString : Codec e s a -> a -> String
encodeToJsonString codec value =
    JE.encode 0 (getJsonEncoder codec value)


{-| Convert an Elm value into json data.
-}
encodeToJson : Codec e s a -> a -> JE.Value
encodeToJson codec value =
    JE.list
        identity
        [ JE.int version
        , value |> getJsonEncoder codec
        ]


replaceBase64Chars : Bytes.Bytes -> String
replaceBase64Chars =
    let
        replaceChar rematch =
            case rematch.match of
                "+" ->
                    "-"

                "/" ->
                    "_"

                _ ->
                    ""
    in
    Base64.fromBytes >> Maybe.withDefault "" >> Regex.replace replaceForUrl replaceChar


replaceForUrl : Regex
replaceForUrl =
    Regex.fromString "[\\+/=]" |> Maybe.withDefault Regex.never


{-| Generates naked Changes from a Codec's default values. These are all the values that would normally be skipped, not encoded to Changes.
Useful for spitting out test data, and seeing the whole heirarchy of your types.
-}
encodeDefaults : Node -> WrappedOrSkelCodec e s a -> Change
encodeDefaults node rootCodec =
    let
        changePayload =
            getNodeEncoder rootCodec
                { node = node
                , mode = { defaultEncodeMode | setDefaultsExplicitly = True }
                , thingToEncode = EncodeThis <| new rootCodec (ParentContext Change.genesisPointer)
                , parent = Change.genesisPointer
                , position = Nonempty.singleton "encodeDefaults"
                }

        bogusChange =
            Change.ChangeSet { target = Change.genesisPointer, objectChanges = [], externalUpdates = [] }
    in
    case Change.unwrapSkippability changePayload of
        Nonempty (Change.QuoteNestedObject change) [] ->
            change

        _ ->
            bogusChange


{-| Generates naked Changes from a Codec's default values. Passes in a test node, not for production
-}
encodeDefaultsForTesting : WrappedOrSkelCodec e s a -> Change
encodeDefaultsForTesting rootCodec =
    encodeDefaults Node.testNode rootCodec



-- BASE
-- buildUnnestableCodec :
--     (a -> BE.Encoder)
--     -> BD.Decoder (Result (Error e) a)
--     -> (a -> JE.Value)
--     -> JD.Decoder (Result (Error e) a)
--     -> FlatCodec e a
-- buildUnnestableCodec encoder_ decoder_ jsonEncoder jsonDecoder =
--     Codec
--         { bytesEncoder = encoder_
--         , bytesDecoder = decoder_
--         , jsonEncoder = jsonEncoder
--         , jsonDecoder = jsonDecoder
--         , nodeEncoder = Nothing
--         , nodeDecoder = Nothing
--         , init = flatInit
--         }


buildNestableCodec :
    (a -> BE.Encoder)
    -> BD.Decoder (Result (Error e) a)
    -> (a -> JE.Value)
    -> JD.Decoder (Result (Error e) a)
    -> NodeEncoder a
    -> NodeDecoder e a
    -> Codec e a a
buildNestableCodec encoder_ decoder_ jsonEncoder jsonDecoder ronEncoder ronDecoder =
    Codec
        { bytesEncoder = encoder_
        , bytesDecoder = decoder_
        , jsonEncoder = jsonEncoder
        , jsonDecoder = jsonDecoder
        , nodeEncoder = ronEncoder
        , nodeDecoder = ronDecoder
        , init = flatInit
        }


flatInit : Initializer a a
flatInit { seed } =
    seed


getEncodedPrimitive : ThingToEncode a -> a
getEncodedPrimitive thingToEncode =
    case thingToEncode of
        EncodeThis thing ->
            thing

        EncodeObjectOrThis _ thing ->
            Log.crashInDev "primitive encoder was passed an objectID to encode?" thing


{-| Codec for serializing a `String`
-}
string : FlatCodec e String
string =
    Codec
        { bytesEncoder =
            \text ->
                BE.sequence
                    [ BE.unsignedInt32 endian (BE.getStringWidth text)
                    , BE.string text
                    ]
        , bytesDecoder =
            BD.unsignedInt32 endian
                |> BD.andThen
                    (\charCount -> BD.string charCount |> BD.map Ok)
        , jsonEncoder = JE.string
        , jsonDecoder = JD.string |> JD.map Ok
        , nodeEncoder =
            \inputs -> Necessary <| Nonempty.singleton <| Change.RonAtom <| Op.StringAtom <| getEncodedPrimitive inputs.thingToEncode
        , nodeDecoder = \_ -> JD.string |> JD.map Ok
        , init = flatInit
        }


id : FlatCodec e (ID userType)
id =
    let
        toObjectID givenID =
            case ID.read givenID of
                ExistingObjectPointer objectID _ ->
                    objectID

                placeholderPointer ->
                    -- Log.crashInDev ("ID should always be ObjectID before serializing. Tried to serialize the ID for pointer " ++ Log.dump placeholderPointer)
                    OpID.fromStringForced ("Uninitialized! " ++ Log.dump placeholderPointer)

        toChangeAtom givenID =
            case ID.read givenID of
                ExistingObjectPointer objectID _ ->
                    Change.RonAtom <| Op.IDPointerAtom objectID

                PlaceholderPointer pendingID _ ->
                    Change.PendingObjectReferenceAtom pendingID

        toString givenID =
            OpID.toString (toObjectID givenID)

        fromString asString =
            ID.tag (ExistingObjectPointer (OpID.fromStringForced asString) identity)
    in
    Codec
        { bytesEncoder =
            \i ->
                BE.sequence
                    [ BE.unsignedInt32 endian (BE.getStringWidth (toString i))
                    , BE.string (toString i)
                    ]
        , bytesDecoder =
            BD.unsignedInt32 endian
                |> BD.andThen
                    (\charCount -> BD.string charCount |> BD.map (fromString >> Ok))
        , jsonEncoder = toString >> JE.string
        , jsonDecoder = JD.string |> JD.map (fromString >> Ok)
        , nodeEncoder =
            \inputs ->
                Necessary <| Nonempty.singleton <| toChangeAtom (getEncodedPrimitive inputs.thingToEncode)
        , nodeDecoder = \_ -> JD.string |> JD.map (fromString >> Ok)
        , init = flatInit
        }


{-| Codec for serializing a `Bool`
-}
bool : FlatCodec e Bool
bool =
    let
        boolNodeEncoder : NodeEncoder Bool
        boolNodeEncoder { thingToEncode } =
            if getEncodedPrimitive thingToEncode then
                Necessary <| Nonempty.singleton <| Change.RonAtom <| Op.NakedStringAtom "true"

            else
                Necessary <| Nonempty.singleton <| Change.RonAtom <| Op.NakedStringAtom "false"

        boolNodeDecoder : NodeDecoder e Bool
        boolNodeDecoder _ =
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

                _ ->
                    JD.succeed (Err DataCorrupted)
    in
    buildNestableCodec
        (\value ->
            case value of
                True ->
                    BE.unsignedInt8 1

                False ->
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

                        _ ->
                            Err DataCorrupted
                )
        )
        JE.bool
        (JD.bool |> JD.map Ok)
        boolNodeEncoder
        boolNodeDecoder


{-| Codec for serializing an `Int`
-}
int : FlatCodec e Int
int =
    buildNestableCodec
        (toFloat >> BE.float64 endian)
        (BD.float64 endian |> BD.map (round >> Ok))
        JE.int
        (JD.int |> JD.map Ok)
        (\{ thingToEncode } ->
            Necessary <| Nonempty.singleton <| Change.RonAtom <| Op.IntegerAtom <| getEncodedPrimitive thingToEncode
        )
        (\_ -> JD.int |> JD.map Ok)


{-| Codec for serializing a `Float`
-}
float : FlatCodec e Float
float =
    buildNestableCodec
        (BE.float64 endian)
        (BD.float64 endian |> BD.map Ok)
        JE.float
        (JD.float |> JD.map Ok)
        (\{ thingToEncode } ->
            Necessary <| Nonempty.singleton <| Change.RonAtom <| Op.FloatAtom <| getEncodedPrimitive thingToEncode
        )
        (\_ -> JD.float |> JD.map Ok)


{-| Codec for serializing a `Char`
-}
char : FlatCodec e Char
char =
    let
        charEncode text =
            BE.sequence
                [ BE.unsignedInt32 endian (String.length text)
                , BE.string text
                ]
    in
    buildNestableCodec
        (String.fromChar >> charEncode)
        (BD.unsignedInt32 endian
            |> BD.andThen (\charCount -> BD.string charCount)
            |> BD.map
                (\text ->
                    case String.toList text |> List.head of
                        Just char_ ->
                            Ok char_

                        Nothing ->
                            Err DataCorrupted
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
                            Err DataCorrupted
                )
        )
        (\{ thingToEncode } -> Necessary <| Nonempty.singleton <| Change.RonAtom <| Op.StringAtom <| String.fromChar <| getEncodedPrimitive thingToEncode)
        (\_ ->
            JD.string
                |> JD.map
                    (\text ->
                        case String.toList text |> List.head of
                            Just char_ ->
                                Ok char_

                            Nothing ->
                                Err DataCorrupted
                    )
        )



-- DATA STRUCTURES


{-| Codec for serializing a `Maybe`

import Serialize as S

maybeIntCodec : S.Codec e (Maybe Int)
maybeIntCodec =
S.maybe S.int

-}
maybe : Codec e s a -> Codec e (Maybe a) (Maybe a)
maybe justCodec =
    customType
        (\nothingEncoder justEncoder value ->
            case value of
                Nothing ->
                    nothingEncoder

                Just value_ ->
                    justEncoder value_
        )
        |> variant0 ( 0, "Nothing" ) Nothing
        |> variant1 ( 1, "Just" ) Just justCodec
        |> finishCustomType


{-| A replicated list
-}
repList : Codec e memberSeed memberType -> WrappedCodec e (RepList memberType)
repList memberCodec =
    let
        normalJsonDecoder =
            JD.fail "no replist"

        jsonEncoder : RepList memberType -> JE.Value
        jsonEncoder input =
            JE.list (getJsonEncoder memberCodec) (RepList.listValues input)

        bytesEncoder : RepList memberType -> BE.Encoder
        bytesEncoder input =
            listEncode (getBytesEncoder memberCodec) (RepList.listValues input)

        memberChanger : { node : Node, modeMaybe : Maybe ChangesToGenerate, parent : Change.Pointer } -> Change.SiblingIndex -> memberType -> Maybe OpID -> Change.ObjectChange
        memberChanger { node, modeMaybe, parent } memberIndex newMemberValue newRefMaybe =
            let
                memberNodeEncoded : Change.PotentialPayload
                memberNodeEncoded =
                    Change.unwrapSkippability <|
                        -- because we have to track it even if it's default
                        getNodeEncoder memberCodec
                            { mode = Maybe.withDefault defaultEncodeMode modeMaybe
                            , node = node
                            , thingToEncode = EncodeThis newMemberValue
                            , parent = parent
                            , position = Nonempty.singleton ("repList item #" ++ memberIndex)
                            }
            in
            case newRefMaybe of
                Just givenRef ->
                    Change.NewPayloadWithRef { payload = memberNodeEncoded, ref = givenRef }

                Nothing ->
                    Change.NewPayload memberNodeEncoded

        memberRonDecoder : { node : Node, parent : Pointer, cutoff : Maybe Moment } -> JE.Value -> Maybe memberType
        memberRonDecoder { node, parent, cutoff } encodedMember =
            case JD.decodeValue (getNodeDecoder memberCodec { node = node, parent = parent, position = Nonempty.singleton "repListContainer", cutoff = cutoff }) encodedMember of
                Ok (Ok member) ->
                    Just member

                _ ->
                    Nothing

        repListRonDecoder : NodeDecoder e (RepList memberType)
        repListRonDecoder { node, parent, cutoff, position } =
            let
                repListBuilder foundObjectIDs =
                    let
                        object =
                            Node.getObject { node = node, cutoff = cutoff, foundIDs = foundObjectIDs, parent = parent, reducer = RepList.reducerID, position = position }

                        repListPointer =
                            Object.getPointer object

                        finalMemberChanger =
                            memberChanger { node = node, modeMaybe = Nothing, parent = repListPointer }

                        finalPayloadToMember =
                            memberRonDecoder { node = node, parent = repListPointer, cutoff = cutoff }
                    in
                    Ok <| RepList.buildFromReplicaDb object finalPayloadToMember finalMemberChanger nonChanger
            in
            JD.map repListBuilder concurrentObjectIDsDecoder

        repListRonEncoder : NodeEncoder (RepList memberType)
        repListRonEncoder ({ node, thingToEncode, mode, parent, position } as details) =
            case thingToEncode of
                EncodeThis existingRepList ->
                    let
                        ( allObjectChanges, externalChanges ) =
                            extractInitChanges (RepList.getPointer existingRepList) (RepList.getInit existingRepList)
                    in
                    Necessary <|
                        changeToChangePayload <|
                            ChangeSet
                                { target = RepList.getPointer existingRepList
                                , objectChanges = allObjectChanges
                                , externalUpdates = externalChanges
                                }

                _ ->
                    let
                        repListPointer =
                            Change.newPointer { parent = parent, position = position, reducerID = RepList.reducerID }
                    in
                    Skippable <|
                        changeToChangePayload <|
                            ChangeSet
                                { target = repListPointer
                                , objectChanges = []
                                , externalUpdates = []
                                }

        initializer : Initializer (Changer (RepList memberType)) (RepList memberType)
        initializer { parent, position, seed } =
            let
                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], position = position, reducer = RepList.reducerID, parent = parent }

                finalMemberChanger =
                    memberChanger { node = Node.testNode, modeMaybe = Nothing, parent = Object.getPointer object }

                finalPayloadToMember =
                    memberRonDecoder { node = Node.testNode, parent = Object.getPointer object, cutoff = Nothing }

                repListBuilder =
                    RepList.buildFromReplicaDb object finalPayloadToMember finalMemberChanger seed
            in
            repListBuilder
    in
    Codec
        { bytesEncoder = bytesEncoder
        , bytesDecoder =
            BD.fail
        , jsonEncoder = jsonEncoder
        , jsonDecoder = normalJsonDecoder
        , nodeEncoder = repListRonEncoder
        , nodeDecoder = repListRonDecoder
        , init = initializer
        }


{-| Codec for an elm `List` primitive. Not sync-safe.
You will not be able to change the contents without replacing the entire list, and such changes will not merge nicely with concurrent changes, so consider using a `RepList` instead!
That said, useful for one-off lists, or Json serialization.
-}
primitiveList : FlatCodec e a -> FlatCodec e (List a)
primitiveList codec =
    let
        normalJsonDecoder =
            JD.list (getJsonDecoder codec)
                |> JD.map
                    (List.foldr
                        (\value state ->
                            case ( value, state ) of
                                ( Ok ok, Ok okState ) ->
                                    ok :: okState |> Ok

                                ( _, Err _ ) ->
                                    state

                                ( Err error, Ok _ ) ->
                                    Err error
                        )
                        (Ok [])
                    )

        nodeEncoder : NodeEncoder (List a)
        nodeEncoder inputs =
            case getEncodedPrimitive inputs.thingToEncode of
                [] ->
                    Necessary <| Nonempty.singleton <| Change.RonAtom <| Op.NakedStringAtom "[]"

                headItem :: moreItems ->
                    let
                        memberNodeEncoded : Int -> a -> Change.PotentialPayload
                        memberNodeEncoded index item =
                            Change.unwrapSkippability <|
                                -- because we have to track it even if it's default
                                getNodeEncoder codec
                                    { mode = inputs.mode
                                    , node = inputs.node
                                    , thingToEncode = EncodeThis item
                                    , parent = inputs.parent
                                    , position = Nonempty.singleton ("primitiveList item #" ++ String.fromInt index)
                                    }
                    in
                    Necessary <| Nonempty.concat <| Nonempty.indexedMap memberNodeEncoded (Nonempty headItem moreItems)

        nodeDecoder : NodeDecoderInputs -> JD.Decoder (Result (Error e) (List a))
        nodeDecoder _ =
            JD.oneOf
                [ JD.andThen
                    (\v ->
                        -- TODO what if someone encodes a list like ["[]"]
                        if v == "[]" then
                            JD.succeed (Ok [])

                        else
                            JD.fail "Not empty"
                    )
                    JD.string
                , normalJsonDecoder
                ]
    in
    Codec
        { bytesEncoder = listEncode (getBytesEncoder codec)
        , bytesDecoder =
            BD.unsignedInt32 endian
                |> BD.andThen
                    (\length -> BD.loop ( length, [] ) (listStep (getBytesDecoder codec)))
        , jsonEncoder = JE.list (getJsonEncoder codec)
        , jsonDecoder = normalJsonDecoder
        , nodeEncoder = nodeEncoder
        , nodeDecoder = nodeDecoder
        , init = \{ seed } -> seed
        }


primitiveNonempty : FlatCodec String userType -> FlatCodec String (Nonempty userType)
primitiveNonempty wrappedCodec =
    let
        nonEmptyFromList list =
            Result.fromMaybe "the list was not supposed to be empty" <| Nonempty.fromList list
    in
    mapValid nonEmptyFromList Nonempty.toList (primitiveList wrappedCodec)


listEncode : (a -> BE.Encoder) -> List a -> BE.Encoder
listEncode encoder_ list_ =
    list_
        |> List.map encoder_
        |> (::) (BE.unsignedInt32 endian (List.length list_))
        |> BE.sequence


listStep : BD.Decoder (Result (Error e) a) -> ( Int, List a ) -> BD.Decoder (BD.Step ( Int, List a ) (Result (Error e) (List a)))
listStep decoder_ ( n, xs ) =
    if n <= 0 then
        BD.succeed (BD.Done (xs |> List.reverse |> Ok))

    else
        BD.map
            (\x ->
                case x of
                    Ok ok ->
                        BD.Loop ( n - 1, ok :: xs )

                    Err err ->
                        BD.Done (Err err)
            )
            decoder_


{-| Codec for serializing an `Array`
-}
array : FlatCodec e a -> FlatCodec e (Array a)
array codec =
    primitiveList codec |> mapHelper (Result.map Array.fromList) Array.toList


{-| A replicated set specifically for reptype members, with dictionary features such as getting a member by ID.
-}
repDb : Codec e s memberType -> WrappedCodec e (RepDb memberType)
repDb memberCodec =
    let
        memberChanger : { node : Node, modeMaybe : Maybe ChangesToGenerate, parent : Pointer } -> memberType -> Change.ObjectChange
        memberChanger { node, modeMaybe, parent } newValue =
            getNodeEncoder memberCodec
                { mode = Maybe.withDefault defaultEncodeMode modeMaybe
                , node = node
                , thingToEncode = EncodeThis newValue
                , parent = parent
                , position = Nonempty.singleton "repDbContainer"
                }
                |> Change.unwrapSkippability
                -- because we have to track it even if it's default
                |> Change.NewPayload

        memberRonDecoder : { node : Node, parent : Pointer, cutoff : Maybe Moment } -> JE.Value -> Maybe memberType
        memberRonDecoder { node, parent, cutoff } encodedMember =
            case JD.decodeValue (getNodeDecoder memberCodec { node = node, parent = parent, position = Nonempty.singleton "repDbMember", cutoff = cutoff }) encodedMember of
                Ok (Ok member) ->
                    Just member

                _ ->
                    Nothing

        repDbNodeDecoder : NodeDecoder e (RepDb memberType)
        repDbNodeDecoder { node, parent, position, cutoff } =
            let
                repDbBuilder foundObjectIDs =
                    let
                        object =
                            Node.getObject { node = node, cutoff = Nothing, foundIDs = foundObjectIDs, parent = parent, reducer = RepDb.reducerID, position = position }

                        repDbPointer =
                            Object.getPointer object
                    in
                    Ok <| RepDb.buildFromReplicaDb object (memberRonDecoder { node = node, parent = repDbPointer, cutoff = cutoff }) (memberChanger { node = node, modeMaybe = Nothing, parent = repDbPointer }) nonChanger
            in
            JD.map repDbBuilder concurrentObjectIDsDecoder

        repDbNodeEncoder : NodeEncoder (RepDb memberType)
        repDbNodeEncoder ({ node, thingToEncode, mode, parent, position } as details) =
            case thingToEncode of
                EncodeThis existingRepDb ->
                    let
                        ( allObjectChanges, externalChanges ) =
                            extractInitChanges (RepDb.getPointer existingRepDb) (RepDb.getInit existingRepDb)
                    in
                    Necessary <|
                        changeToChangePayload <|
                            ChangeSet
                                { target = RepDb.getPointer existingRepDb
                                , objectChanges = allObjectChanges
                                , externalUpdates = externalChanges
                                }

                _ ->
                    let
                        placeholderPointer =
                            Change.newPointer { parent = parent, position = position, reducerID = RepDb.reducerID }
                    in
                    Skippable <|
                        changeToChangePayload <|
                            ChangeSet
                                { target = placeholderPointer
                                , objectChanges = []
                                , externalUpdates = []
                                }

        initializer : InitializerInputs (Changer (RepDb memberType)) -> RepDb memberType
        initializer { parent, position, seed } =
            let
                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], position = position, reducer = RepDb.reducerID, parent = parent }

                repDbPointer =
                    Object.getPointer object

                finalMemberChanger =
                    memberChanger { node = Node.testNode, modeMaybe = Nothing, parent = repDbPointer }

                finalPayloadToMember =
                    memberRonDecoder { node = Node.testNode, parent = repDbPointer, cutoff = Nothing }
            in
            RepDb.buildFromReplicaDb object finalPayloadToMember finalMemberChanger seed
    in
    Codec
        { bytesEncoder = \input -> listEncode (getBytesEncoder memberCodec) (RepDb.listValues input)
        , bytesDecoder = BD.fail
        , jsonEncoder = \input -> JE.list (getJsonEncoder memberCodec) (RepDb.listValues input)
        , jsonDecoder = JD.fail "no repdb"
        , nodeEncoder = repDbNodeEncoder
        , nodeDecoder = repDbNodeDecoder
        , init = initializer
        }


{-| A replicated dictionary.
-}
repDict : Codec e ki k -> Codec e vi v -> WrappedCodec e (RepDict k v)
repDict keyCodec valueCodec =
    let
        -- We use the json-encoded form as the dict key, since it's always comparable!
        keyToString key =
            JE.encode 0 (getJsonEncoder keyCodec key)

        flatDictListCodec =
            primitiveList (pair keyCodec valueCodec)

        jsonEncoder : RepDict k v -> JE.Value
        jsonEncoder input =
            getJsonEncoder flatDictListCodec (RepDict.list input)

        bytesEncoder : RepDict k v -> BE.Encoder
        bytesEncoder input =
            getBytesEncoder flatDictListCodec (RepDict.list input)

        entryRonEncoder : Node -> Maybe ChangesToGenerate -> Pointer -> Change.SiblingIndex -> RepDict.RepDictEntry k v -> Change.PotentialPayload
        entryRonEncoder node encodeModeMaybe parent entryPosition newEntry =
            let
                keyEncoder givenKey =
                    Change.unwrapSkippability <|
                        -- keys can never be "default" anyway
                        getNodeEncoder keyCodec
                            { mode = Maybe.withDefault defaultEncodeMode encodeModeMaybe
                            , node = node
                            , thingToEncode = EncodeThis givenKey
                            , parent = parent
                            , position = Nonempty entryPosition [ "key" ]
                            }

                valueEncoder givenValue =
                    Change.unwrapSkippability <|
                        -- because we have to track it even if it's default
                        getNodeEncoder valueCodec
                            { mode = Maybe.withDefault defaultEncodeMode encodeModeMaybe
                            , node = node
                            , thingToEncode = EncodeThis givenValue
                            , parent = parent
                            , position = Nonempty entryPosition [ "value" ]
                            }
            in
            case newEntry of
                RepDict.Cleared key ->
                    keyEncoder key

                RepDict.Present key value ->
                    Nonempty.append (keyEncoder key) (valueEncoder value)

        entryChanger node encodeModeMaybe parent entryPosition newEntry =
            Change.NewPayload (entryRonEncoder node encodeModeMaybe parent entryPosition newEntry)

        entryRonDecoder : Node -> Pointer -> Maybe Moment -> JE.Value -> Maybe (RepDictEntry k v)
        entryRonDecoder node parent cutoff encodedEntry =
            let
                decodeKey encodedKey =
                    JD.decodeValue (getNodeDecoder keyCodec { node = node, position = Nonempty.singleton "key", parent = parent, cutoff = cutoff }) encodedKey

                decodeValue encodedValue =
                    JD.decodeValue (getNodeDecoder valueCodec { node = node, position = Nonempty.singleton "value", parent = parent, cutoff = cutoff }) encodedValue
            in
            case JD.decodeValue (JD.list JD.value) encodedEntry of
                Ok (keyEncoded :: [ valueEncoded ]) ->
                    case ( decodeKey keyEncoded, decodeValue valueEncoded ) of
                        ( Ok (Ok key), Ok (Ok value) ) ->
                            Just (Present key value)

                        _ ->
                            Log.crashInDev "entryRonDecoder : found key and value but not able to decode them?" Nothing

                Ok [ keyEncoded ] ->
                    case decodeKey keyEncoded of
                        Ok (Ok key) ->
                            Just (Cleared key)

                        _ ->
                            Log.crashInDev "entryRonDecoder : found just key alone but not able to decode it" Nothing

                other ->
                    Log.crashInDev "entryRonDecoder : the dict entry wasn't in the expected shape" Nothing

        repDictRonDecoder : NodeDecoder e (RepDict k v)
        repDictRonDecoder ({ node, parent, position, cutoff } as details) =
            let
                object foundObjectIDs =
                    Node.getObject { node = node, cutoff = cutoff, foundIDs = foundObjectIDs, parent = parent, reducer = RepDict.reducerID, position = position }

                repDictBuilder foundObjects =
                    let
                        repDictObject =
                            object foundObjects

                        repDictPointer =
                            Object.getPointer repDictObject
                    in
                    Ok <| RepDict.buildFromReplicaDb repDictObject (entryRonDecoder node repDictPointer cutoff) (entryChanger node Nothing repDictPointer) keyToString (\_ -> [])
            in
            JD.map repDictBuilder concurrentObjectIDsDecoder

        repDictRonEncoder : NodeEncoder (RepDict k v)
        repDictRonEncoder ({ node, thingToEncode, mode, parent, position } as details) =
            case thingToEncode of
                EncodeThis existingRepDict ->
                    let
                        ( allObjectChanges, externalChanges ) =
                            extractInitChanges (RepDict.getPointer existingRepDict) (RepDict.getInit existingRepDict)
                    in
                    Necessary <|
                        changeToChangePayload <|
                            ChangeSet
                                { target = RepDict.getPointer existingRepDict
                                , objectChanges = allObjectChanges
                                , externalUpdates = externalChanges
                                }

                _ ->
                    Skippable <|
                        changeToChangePayload <|
                            ChangeSet
                                { target = Change.newPointer { parent = parent, position = position, reducerID = RepDict.reducerID }
                                , objectChanges = []
                                , externalUpdates = []
                                }

        initializer : InitializerInputs (Changer (RepDict k v)) -> RepDict k v
        initializer { parent, position, seed } =
            let
                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], parent = parent, reducer = RepDb.reducerID, position = position }

                repDbPointer =
                    Object.getPointer object
            in
            RepDict.buildFromReplicaDb object (entryRonDecoder Node.testNode repDbPointer Nothing) (entryChanger Node.testNode Nothing repDbPointer) keyToString seed
    in
    Codec
        { bytesEncoder = bytesEncoder
        , bytesDecoder = BD.fail
        , jsonEncoder = jsonEncoder
        , jsonDecoder = JD.fail "no repdict"
        , nodeEncoder = repDictRonEncoder
        , nodeDecoder = repDictRonDecoder
        , init = initializer
        }


{-| Codec for a replicated store. Accepts a key codec and a value codec.

  - By design, the store only accepts values with seedless codecs.

-}
repStore : Codec e ki k -> Codec e (s -> List Change) v -> WrappedCodec e (RepStore k v)
repStore keyCodec valueCodec =
    let
        -- We use the json-encoded form as the dict key, since it's always comparable!
        keyToString key =
            JE.encode 0 (getJsonEncoder keyCodec key)

        flatDictListCodec =
            primitiveList (pair keyCodec valueCodec)

        jsonEncoder : RepStore k v -> JE.Value
        jsonEncoder input =
            getJsonEncoder flatDictListCodec (RepStore.listModified input)

        bytesEncoder : RepStore k v -> BE.Encoder
        bytesEncoder input =
            getBytesEncoder flatDictListCodec (RepStore.listModified input)

        entryNodeEncodeWrapper : Node -> Maybe ChangesToGenerate -> Pointer -> Change.SiblingIndex -> k -> Change -> Change.PotentialPayload
        entryNodeEncodeWrapper node encodeModeMaybe parent entryPosition keyToSet childValueChange =
            let
                keyEncoder givenKey =
                    Change.unwrapSkippability <|
                        -- because we have to track it even if it's default
                        getNodeEncoder keyCodec
                            { mode = Maybe.withDefault defaultEncodeMode encodeModeMaybe
                            , node = node
                            , thingToEncode = EncodeThis givenKey
                            , parent = parent
                            , position = Nonempty entryPosition [ "key" ] -- value encoder uses 2
                            }
            in
            Nonempty.append (keyEncoder keyToSet) (changeToChangePayload childValueChange)

        entryNodeDecoder : Node -> Pointer -> Maybe Moment -> JE.Value -> Maybe (RepStore.RepStoreEntry k v)
        entryNodeDecoder node parent cutoff encodedEntry =
            let
                decodeKey encodedKey =
                    JD.decodeValue (getNodeDecoder keyCodec { node = node, position = Nonempty.singleton "key", parent = parent, cutoff = cutoff }) encodedKey

                decodeValue encodedValue =
                    JD.decodeValue
                        (getNodeDecoder valueCodec
                            { node = node
                            , position = Nonempty.singleton "value"
                            , parent = parent -- no need to wrap child changes as decoding entries means they already exist
                            , cutoff = cutoff
                            }
                        )
                        encodedValue
            in
            case JD.decodeValue (JD.list JD.value) encodedEntry of
                Ok (keyEncoded :: [ valueEncoded ]) ->
                    case ( decodeKey keyEncoded, decodeValue valueEncoded ) of
                        ( Ok (Ok key), Ok (Ok value) ) ->
                            Just (RepStore.RepStoreEntry key value)

                        _ ->
                            Log.crashInDev "storeEntryNodeDecoder : found key and value but not able to decode them?" Nothing

                _ ->
                    Log.crashInDev "storeEntryNodeDecoder : the store entry wasn't in the expected shape" Nothing

        repStoreNodeDecoder : NodeDecoder e (RepStore k v)
        repStoreNodeDecoder details =
            JD.map (repStoreBuilder details nonChanger >> Ok) concurrentObjectIDsDecoder

        repStoreBuilder { node, parent, position, cutoff } changer foundObjects =
            let
                object foundObjectIDs =
                    Node.getObject { node = node, cutoff = cutoff, foundIDs = foundObjectIDs, parent = parent, reducer = RepDict.reducerID, position = position }

                repStoreObject =
                    object foundObjects

                repStorePointer =
                    Object.getPointer repStoreObject

                allEntries =
                    List.filterMap (\event -> entryNodeDecoder node repStorePointer Nothing (Object.eventPayloadAsJson event)) (AnyDict.values (Object.getEvents repStoreObject))

                entriesDict =
                    List.foldl (\(RepStore.RepStoreEntry k v) dictSoFar -> AnyDict.update k (updateEntry v) dictSoFar) (AnyDict.empty keyToString) allEntries

                updateEntry newVal oldValMaybe =
                    case oldValMaybe of
                        Nothing ->
                            Just [ newVal ]

                        Just [] ->
                            Just [ newVal ]

                        Just prevEntries ->
                            Just (newVal :: prevEntries)

                fetcher key =
                    AnyDict.get key entriesDict
                        |> Maybe.andThen List.head
                        |> Maybe.withDefault (createObjectAt key)

                createObjectAt key =
                    new valueCodec (ParentContext (parentWithNotifier key))

                parentWithNotifier key =
                    Change.updateChildChangeWrapper parent (wrapNewChildValue key)

                wrapNewChildValue key changeToWrap =
                    Change.ChangeSet
                        { target = parent
                        , objectChanges =
                            [ Change.NewPayload (entryNodeEncodeWrapper node Nothing parent "value" key changeToWrap) ]
                        , externalUpdates = []
                        }
            in
            RepStore.buildFromReplicaDb { object = repStoreObject, fetcher = fetcher, start = changer }

        repStoreNodeEncoder : NodeEncoder (RepStore k v)
        repStoreNodeEncoder ({ node, thingToEncode, mode, parent, position } as details) =
            case thingToEncode of
                EncodeThis existingRepStore ->
                    let
                        ( allObjectChanges, externalChanges ) =
                            extractInitChanges (RepStore.getPointer existingRepStore) (RepStore.getInit existingRepStore)
                    in
                    Necessary <|
                        changeToChangePayload <|
                            ChangeSet
                                { target = RepStore.getPointer existingRepStore
                                , objectChanges = allObjectChanges
                                , externalUpdates = externalChanges
                                }

                _ ->
                    Skippable <|
                        changeToChangePayload <|
                            ChangeSet
                                { target = Change.newPointer { parent = parent, position = position, reducerID = RepDict.reducerID }
                                , objectChanges = []
                                , externalUpdates = []
                                }

        initializer : InitializerInputs (Changer (RepStore k v)) -> RepStore k v
        initializer { parent, position, seed } =
            repStoreBuilder { node = Node.testNode, parent = parent, position = position, cutoff = Nothing } seed []
    in
    Codec
        { bytesEncoder = bytesEncoder
        , bytesDecoder = BD.fail
        , jsonEncoder = jsonEncoder
        , jsonDecoder = JD.fail "no repstore"
        , nodeEncoder = repStoreNodeEncoder
        , nodeDecoder = repStoreNodeDecoder
        , init = initializer
        }


{-| Codec for serializing a `Dict`

    import Serialize as S

    type alias Name =
        String

    peoplesAgeCodec : S.Codec e (Dict Name Int)
    peoplesAgeCodec =
        S.dict S.string S.int

-}
primitiveDict : FlatCodec e comparable -> FlatCodec e a -> FlatCodec e (Dict comparable a)
primitiveDict keyCodec valueCodec =
    primitiveList (pair keyCodec valueCodec)
        |> mapHelper (Result.map Dict.fromList) Dict.toList


{-| Codec for serializing a `Set`
-}
primitiveSet : FlatCodec e comparable -> FlatCodec e (Set comparable)
primitiveSet codec =
    primitiveList codec |> mapHelper (Result.map Set.fromList) Set.toList


{-| Codec for serializing `()` (aka `Unit`).
-}
unit : FlatCodec e ()
unit =
    buildNestableCodec
        (always (BE.sequence []))
        (BD.succeed (Ok ()))
        (\_ -> JE.int 0)
        (JD.succeed (Ok ()))
        (\_ -> Necessary <| Nonempty.singleton <| Change.RonAtom <| Op.IntegerAtom 0)
        (\_ -> JD.succeed (Ok ()))


{-| Codec for serializing a tuple with 2 elements

    import Codec exposing (Codec)

    pointCodec : Codec e ( Float, Float ) ( Float, Float )
    pointCodec =
        Codec.tuple Codec.float Codec.float

-}
pair : Codec e ia a -> Codec e ib b -> Codec e ( a, b ) ( a, b )
pair codecFirst codecSecond =
    -- Used to be:
    -- fragileRecord Tuple.pair
    --     |> fixedField Tuple.first codecFirst
    --     |> fixedField Tuple.second codecSecond
    --     |> finishFragileRecord
    customType
        (\pairEncoder ( a, b ) ->
            pairEncoder a b
        )
        |> variant2 ( 2, "Pair" ) Tuple.pair codecFirst codecSecond
        |> finishCustomType


seedlessPair : WrappedOrSkelCodec e s1 a -> WrappedOrSkelCodec e s2 b -> SkelCodec e ( a, b )
seedlessPair codecFirst codecSecond =
    record Tuple.pair
        |> fieldReg ( 1, "first" ) Tuple.first codecFirst
        |> fieldReg ( 2, "second" ) Tuple.second codecSecond
        |> finishRecord


{-| Codec for serializing a tuple with 3 elements

    import Serialize as S

    pointCodec : S.Codec e ( Float, Float, Float )
    pointCodec =
        S.tuple S.float S.float S.float

-}
triple : Codec e ia a -> Codec e ib b -> Codec e ic c -> Codec e ( a, b, c ) ( a, b, c )
triple codecFirst codecSecond codecThird =
    -- fragileRecord (\a b c -> ( a, b, c ))
    --     |> fixedField (\( a, _, _ ) -> a) codecFirst
    --     |> fixedField (\( _, b, _ ) -> b) codecSecond
    --     |> fixedField (\( _, _, c ) -> c) codecThird
    --     |> finishFragileRecord
    customType
        (\tripleEncoder ( a, b, c ) ->
            tripleEncoder a b c
        )
        |> variant3 ( 3, "Triple" ) (\a b c -> ( a, b, c )) codecFirst codecSecond codecThird
        |> finishCustomType


{-| Codec for serializing a `Result`
-}
result : FlatCodec e error -> FlatCodec e value -> FlatCodec e (Result error value)
result errorCodec valueCodec =
    customType
        (\errEncoder okEncoder value ->
            case value of
                Err err ->
                    errEncoder err

                Ok ok ->
                    okEncoder ok
        )
        |> variant1 ( 0, "Err" ) Err errorCodec
        |> variant1 ( 1, "Ok" ) Ok valueCodec
        |> finishCustomType


{-| Codec for serializing [`Bytes`](https://package.elm-lang.org/packages/elm/bytes/latest/).
This is useful in combination with `mapValid` for encoding and decoding data using some specialized format.

    import Image exposing (Image)
    import Serialize as S

    imageCodec : S.Codec String Image
    imageCodec =
        S.bytes
            |> S.mapValid
                (Image.decode >> Result.fromMaybe "Failed to decode PNG image.")
                Image.toPng

-}
bytes : FlatCodec e Bytes.Bytes
bytes =
    buildNestableCodec
        (\bytes_ ->
            BE.sequence
                [ BE.unsignedInt32 endian (Bytes.width bytes_)
                , BE.bytes bytes_
                ]
        )
        (BD.unsignedInt32 endian |> BD.andThen (\length -> BD.bytes length |> BD.map Ok))
        (replaceBase64Chars >> JE.string)
        (JD.string
            |> JD.map
                (\text ->
                    case decodeStringToBytes text of
                        Just bytes_ ->
                            Ok bytes_

                        Nothing ->
                            Err DataCorrupted
                )
        )
        (\inputs -> Necessary <| Nonempty.singleton <| Change.RonAtom <| Op.StringAtom <| replaceBase64Chars <| getEncodedPrimitive inputs.thingToEncode)
        (\_ ->
            JD.string
                |> JD.map
                    (\text ->
                        case decodeStringToBytes text of
                            Just bytes_ ->
                                Ok bytes_

                            Nothing ->
                                Err DataCorrupted
                    )
        )


{-| Codec for serializing an integer ranging from 0 to 255.
This is useful if you have a small integer you want to serialize and not use up a lot of space.

    import Serialize as S

    type alias Color =
        { red : Int
        , green : Int
        , blue : Int
        }

    color : S.Codec e Color
    color =
        Color.record Color
            |> S.field .red byte
            |> S.field .green byte
            |> S.field .blue byte
            |> S.finishRecord

**Warning:** values greater than 255 or less than 0 will wrap around.
So if you encode -1 you'll get back 255 and if you encode 257 you'll get back 2.

-}
byte : FlatCodec e Int
byte =
    buildNestableCodec
        BE.unsignedInt8
        (BD.unsignedInt8 |> BD.map Ok)
        (modBy 256 >> JE.int)
        (JD.int |> JD.map Ok)
        (\{ thingToEncode } -> Necessary <| Nonempty.singleton <| Change.RonAtom <| Op.IntegerAtom <| modBy 256 <| getEncodedPrimitive thingToEncode)
        (\_ -> JD.int |> JD.map Ok)


{-| A fragile^ codec for serializing an item from a list of possible items.
Great for Custom Types where each variant has no arguments.

  - If you try to encode an item that isn't in the list then the first item is defaulted to.
  - The "quick" version will not serialize with human-readable tags
  - Only add new items to the end of the list.
  - ^Inserting new items in the middle of the list will corrupt old data.
  - ^Removing items will corrupt old data.
  - Prefer `enum` for a codec without these limitations.

```
type DaysOfWeek
    = Monday
    | Tuesday
    | Wednesday
    | Thursday
    | Friday
    | Saturday
    | Sunday

daysOfWeekCodec : S.Codec e DaysOfWeek
daysOfWeekCodec =
    Codec.quickEnum Monday [ Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday ]
```

-}
quickEnum : a -> List a -> FlatCodec e a
quickEnum defaultItem items =
    let
        getIndex value =
            items
                |> findIndex ((==) value)
                |> Maybe.withDefault -1
                |> (+) 1

        getItem index =
            if index < 0 then
                Err DataCorrupted

            else if index > List.length items then
                Err DataCorrupted

            else
                getAt (index - 1) items |> Maybe.withDefault defaultItem |> Ok

        intNodeEncoder : NodeEncoder a
        intNodeEncoder { thingToEncode } =
            Necessary <| Nonempty.singleton <| Change.RonAtom <| Op.IntegerAtom <| getIndex <| getEncodedPrimitive <| thingToEncode
    in
    buildNestableCodec
        (getIndex >> BE.unsignedInt32 endian)
        (BD.unsignedInt32 endian |> BD.map getItem)
        (getIndex >> JE.int)
        (JD.int |> JD.map getItem)
        intNodeEncoder
        (\_ -> JD.int |> JD.map getItem)


getAt : Int -> List a -> Maybe a
getAt idx xs =
    if idx < 0 then
        Nothing

    else
        List.head <| List.drop idx xs


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



-- OBJECTS
-- SMART RECORDS


type alias FieldIdentifier =
    ( FieldSlot, FieldName )


type alias FieldName =
    String


type alias FieldSlot =
    Int


type alias FieldValue =
    String


type FieldFallback parentSeed fieldSeed fieldType
    = HardcodedDefault fieldType
    | HardcodedSeed fieldSeed
    | InitWithParentSeed (parentSeed -> fieldSeed)
    | DefaultFromParentSeed (parentSeed -> fieldType)
    | DefaultAndInitWithParentSeed fieldType (parentSeed -> fieldSeed)


{-| A partially built Codec for a smart record.
-}
type PartialRegister errs s full remaining
    = PartialRegister
        { bytesEncoder : full -> List BE.Encoder
        , bytesDecoder : BD.Decoder (Result (Error errs) remaining)
        , jsonEncoders : List (SmartJsonFieldEncoder full)
        , jsonArrayDecoder : JD.Decoder (Result (Error errs) remaining)
        , fieldIndex : Int
        , nodeEncoders : List (RegisterFieldEncoder full)
        , nodeDecoder : RegisterFieldDecoder errs remaining
        , nodeInitializer : RegisterFieldInitializer s remaining
        }


{-| Start the record codec for a Register.
Be sure to finish it off with a finisher function.
-}
record : remaining -> PartialRegister errs i full remaining
record remainingConstructor =
    PartialRegister
        { bytesEncoder = \_ -> []
        , bytesDecoder = BD.succeed (Ok remainingConstructor)
        , jsonEncoders = []
        , jsonArrayDecoder = JD.succeed (Ok remainingConstructor)
        , fieldIndex = 0
        , nodeEncoders = []
        , nodeDecoder = \_ -> ( Just remainingConstructor, [] )
        , nodeInitializer = \_ _ -> remainingConstructor
        }


fieldDefaultMaybe : FieldFallback parentSeed fieldSeed fieldType -> Maybe fieldType
fieldDefaultMaybe fallback =
    case fallback of
        HardcodedDefault default ->
            Just default

        DefaultAndInitWithParentSeed default _ ->
            -- TODO used anywhere?
            Just default

        InitWithParentSeed _ ->
            Nothing

        HardcodedSeed seed ->
            Nothing

        DefaultFromParentSeed _ ->
            Nothing


{-| Not exposed - for all `readable` functions
-}
readableHelper : FieldIdentifier -> (full -> fieldType) -> Codec errs fieldSeed fieldType -> FieldFallback parentSeed fieldSeed fieldType -> PartialRegister errs parentSeed full (fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
readableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec fallback (PartialRegister recordCodecSoFar) =
    let
        newFieldIndex =
            recordCodecSoFar.fieldIndex + 1

        jsonObjectFieldKey =
            -- For now, just stick number and name together.
            fieldName ++ String.fromInt fieldSlot

        addToPartialBytesEncoderList existingRecord =
            -- Tack on the new encoder to the big list of all the encoders
            (getBytesEncoder fieldCodec <| fieldGetter existingRecord) :: recordCodecSoFar.bytesEncoder existingRecord

        addToPartialJsonEncoderList =
            -- Tack on the new encoder to the big list of all the encoders
            ( jsonObjectFieldKey, getJsonEncoder fieldCodec << fieldGetter ) :: recordCodecSoFar.jsonEncoders

        nodeDecoder : RegisterFieldDecoder errs remaining
        nodeDecoder inputs =
            let
                ( thisFieldValueMaybe, thisFieldErrors ) =
                    registerReadOnlyFieldDecoder newFieldIndex ( fieldSlot, fieldName ) fallback fieldCodec inputs

                ( remainingRecordConstructorMaybe, soFarErrors ) =
                    recordCodecSoFar.nodeDecoder inputs

                updatedConstructorMaybe =
                    case ( thisFieldValueMaybe, remainingRecordConstructorMaybe ) of
                        ( Just thisFieldValue, Just remainingRecordConstructor ) ->
                            Just <| remainingRecordConstructor thisFieldValue

                        ( Nothing, _ ) ->
                            Log.crashInDev ("Codec.readableHelper.nodeDecoder: " ++ fieldName ++ " field decoded to nothing.. error was " ++ Debug.toString thisFieldErrors) Nothing

                        ( _, Nothing ) ->
                            Log.crashInDev ("Codec.readableHelper.nodeDecoder: " ++ fieldName ++ " field was missing prior constructor, error was " ++ Debug.toString thisFieldErrors) Nothing
            in
            ( updatedConstructorMaybe, soFarErrors ++ thisFieldErrors )

        nodeInitializer : RegisterFieldInitializer parentSeed remaining
        nodeInitializer parentSeed regPointerWithoutNotifier =
            let
                regPointerWithNotifier =
                    Change.updateChildChangeWrapper regPointerWithoutNotifier (updateRegisterPostChildInit regPointerWithoutNotifier ( fieldSlot, fieldName ))

                applyToRemaining =
                    -- regPointerWithoutNotifier because each field will re-wrap it
                    recordCodecSoFar.nodeInitializer parentSeed regPointerWithoutNotifier

                fieldInit : fieldSeed -> fieldType
                fieldInit fieldSeed =
                    getInitializer fieldCodec { parent = regPointerWithNotifier, position = Nonempty.singleton (String.fromInt newFieldIndex ++ "." ++ fieldName ++ "_" ++ String.fromInt fieldSlot), seed = fieldSeed }

                fieldValue : fieldType
                fieldValue =
                    case fallback of
                        HardcodedDefault fieldType ->
                            fieldType

                        HardcodedSeed fieldSeed ->
                            fieldInit fieldSeed

                        InitWithParentSeed parentSeedToFieldSeed ->
                            fieldInit (parentSeedToFieldSeed parentSeed)

                        DefaultFromParentSeed parentSeedToFieldDefault ->
                            parentSeedToFieldDefault parentSeed

                        DefaultAndInitWithParentSeed default parentSeedToFieldSeed ->
                            fieldInit (parentSeedToFieldSeed parentSeed)
            in
            applyToRemaining fieldValue

        nodeEncoderEntry inputs =
            let
                inputsWithSpecificFieldValue : RegisterFieldEncoderInputs fieldType
                inputsWithSpecificFieldValue =
                    { node = inputs.node
                    , history = inputs.history
                    , mode = inputs.mode
                    , parentPointer = inputs.parentPointer
                    , updateRegisterAfterChildInit = inputs.updateRegisterAfterChildInit
                    , existingValMaybe = Maybe.map fieldGetter inputs.existingValMaybe
                    }
            in
            newRegisterFieldEncoderEntry newFieldIndex ( fieldSlot, fieldName ) fallback fieldCodec inputsWithSpecificFieldValue
    in
    PartialRegister
        { bytesEncoder = addToPartialBytesEncoderList
        , bytesDecoder =
            BD.map2
                combineIfBothSucceed
                recordCodecSoFar.bytesDecoder
                (getBytesDecoder fieldCodec)
        , jsonEncoders = addToPartialJsonEncoderList
        , jsonArrayDecoder =
            JD.map2
                combineIfBothSucceed
                -- the previous decoder layers, functions stacked on top of each other
                recordCodecSoFar.jsonArrayDecoder
                -- and now we're wrapping it in yet another layer, this field's decoder
                (JD.index recordCodecSoFar.fieldIndex (getJsonDecoder fieldCodec))
        , fieldIndex = newFieldIndex
        , nodeEncoders = nodeEncoderEntry :: recordCodecSoFar.nodeEncoders
        , nodeDecoder = nodeDecoder
        , nodeInitializer = nodeInitializer
        }


{-| Not exposed - for all `writable` functions
-}
writableHelper : FieldIdentifier -> (full -> RW fieldType) -> Codec errs fieldSeed fieldType -> FieldFallback parentSeed fieldSeed fieldType -> PartialRegister errs parentSeed full (RW fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
writableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec fallback (PartialRegister recordCodecSoFar) =
    let
        newFieldIndex =
            recordCodecSoFar.fieldIndex + 1

        jsonObjectFieldKey =
            -- For now, just stick number and name together.
            fieldName ++ String.fromInt fieldSlot

        addToPartialBytesEncoderList existingRecord =
            -- Tack on the new encoder to the big list of all the encoders
            (getBytesEncoder fieldCodec <| .get (fieldGetter existingRecord)) :: recordCodecSoFar.bytesEncoder existingRecord

        addToPartialJsonEncoderList =
            -- Tack on the new encoder to the big list of all the encoders
            ( jsonObjectFieldKey, getJsonEncoder fieldCodec << (.get << fieldGetter) ) :: recordCodecSoFar.jsonEncoders

        nodeDecoder : RegisterFieldDecoder errs remaining
        nodeDecoder inputs =
            let
                ( thisFieldValueMaybe, thisFieldErrors ) =
                    registerWritableFieldDecoder newFieldIndex ( fieldSlot, fieldName ) fallback fieldCodec inputs

                ( remainingRecordConstructorMaybe, soFarErrors ) =
                    recordCodecSoFar.nodeDecoder inputs

                updatedConstructorMaybe =
                    case ( thisFieldValueMaybe, remainingRecordConstructorMaybe ) of
                        ( Just thisFieldValue, Just remainingRecordConstructor ) ->
                            Just <| remainingRecordConstructor thisFieldValue

                        ( Nothing, _ ) ->
                            Log.crashInDev ("Codec.writableHelper.nodeDecoder:" ++ fieldName ++ " field decoded to nothing...") Nothing

                        ( _, Nothing ) ->
                            Log.crashInDev ("Codec.writableHelper.nodeDecoder:" ++ fieldName ++ " field was missing prior constructor..") Nothing
            in
            ( updatedConstructorMaybe, soFarErrors ++ thisFieldErrors )

        nodeInitializer : RegisterFieldInitializer parentSeed remaining
        nodeInitializer parentSeed regPointerWithoutNotifier =
            let
                regPointerWithNotifier =
                    Change.updateChildChangeWrapper regPointerWithoutNotifier (updateRegisterPostChildInit regPointerWithoutNotifier ( fieldSlot, fieldName ))

                applyToRemaining =
                    -- regPointerWithoutNotifier because each field will re-wrap it
                    recordCodecSoFar.nodeInitializer parentSeed regPointerWithoutNotifier

                fieldInit : fieldSeed -> fieldType
                fieldInit seed =
                    getInitializer fieldCodec { parent = regPointerWithNotifier, position = Nonempty.singleton (String.fromInt newFieldIndex ++ "." ++ fieldName ++ "_" ++ String.fromInt fieldSlot), seed = seed }

                fieldValue : fieldType
                fieldValue =
                    case fallback of
                        HardcodedDefault fieldType ->
                            fieldType

                        HardcodedSeed fieldSeed ->
                            fieldInit fieldSeed

                        InitWithParentSeed parentSeedToFieldSeed ->
                            fieldInit (parentSeedToFieldSeed parentSeed)

                        DefaultFromParentSeed parentSeedToFieldDefault ->
                            parentSeedToFieldDefault parentSeed

                        DefaultAndInitWithParentSeed default parentSeedToFieldSeed ->
                            fieldInit (parentSeedToFieldSeed parentSeed)

                wrapRW : fieldType -> RW fieldType
                wrapRW head =
                    buildRW regPointerWithoutNotifier ( fieldSlot, fieldName ) fieldEncoder head

                fieldEncoder newValue =
                    getNodeEncoder fieldCodec
                        { node = Node.testNode
                        , mode = defaultEncodeMode
                        , thingToEncode = EncodeThis newValue
                        , parent = regPointerWithNotifier
                        , position = Nonempty.singleton (String.fromInt newFieldIndex ++ "." ++ fieldName ++ "_" ++ String.fromInt fieldSlot)
                        }
            in
            applyToRemaining (wrapRW fieldValue)

        nodeEncoderEntry inputs =
            let
                inputsWithSpecificFieldValue : RegisterFieldEncoderInputs fieldType
                inputsWithSpecificFieldValue =
                    { node = inputs.node
                    , history = inputs.history
                    , mode = inputs.mode
                    , parentPointer = inputs.parentPointer
                    , updateRegisterAfterChildInit = inputs.updateRegisterAfterChildInit
                    , existingValMaybe = Maybe.map (fieldGetter >> .get) inputs.existingValMaybe
                    }
            in
            newRegisterFieldEncoderEntry newFieldIndex ( fieldSlot, fieldName ) fallback fieldCodec inputsWithSpecificFieldValue
    in
    PartialRegister
        { bytesEncoder = addToPartialBytesEncoderList
        , bytesDecoder = BD.fail
        , jsonEncoders = addToPartialJsonEncoderList
        , jsonArrayDecoder = JD.fail "Can't use RW wrapper with JSON decoding"
        , fieldIndex = newFieldIndex
        , nodeEncoders = nodeEncoderEntry :: recordCodecSoFar.nodeEncoders
        , nodeDecoder = nodeDecoder
        , nodeInitializer = nodeInitializer
        }


{-| Read a record field.
The last argument specifies a default value, which is used when initializing the record for the first time.

  - Your code will not be able to make changes to this field, only read the value set by other sources. Consider "writable" if you want a read+write field. You will need to prefix your field's type with `RW`.
  - Consider setting the default to the "most popular" value (e.g. "scaling factor" set to 1.0), as it will be omitted from the serialized data, saving space and bandwidth.
  - Consider setting the default to the "safest" value, as missing fields will be parsed as the default.
  - If you can't come up with a sensible default value (e.g. date of birth), consider wrapping the field in `Maybe` or `Result`, with e.g. `Nothing` or `Err Unset` as the default.
  - If there's no sensible default and this record is not useful with missing data unless you add another validation step ("Parse, Don't Validate"!), consider `readableRequired` as a last resort.

-}
field : FieldIdentifier -> (full -> fieldType) -> Codec errs fieldType fieldType -> fieldType -> PartialRegister errs i full (fieldType -> remaining) -> PartialRegister errs i full remaining
field ( fieldSlot, fieldName ) fieldGetter fieldCodec fieldDefault soFar =
    readableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec (HardcodedDefault fieldDefault) soFar


{-| Read a field containing a nested register, using an auto-generated default.

  - This field is read-only, which is good because you can use the nested register's native way of writing changes. For example, a nested record can have `RW` fields, you can `Change` it that way.
  - Auto-generating a default only works for seedless codecs - make sure your codec is of type `SkelCodec e MyType`, aka the seed is `()`. If you have a seeded object to put here, see `seededR` instead.

-}
fieldReg : FieldIdentifier -> (full -> fieldType) -> WrappedOrSkelCodec errs s fieldType -> PartialRegister errs i full (fieldType -> remaining) -> PartialRegister errs i full remaining
fieldReg ( fieldSlot, fieldName ) fieldGetter fieldCodec soFar =
    readableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec (HardcodedSeed (\_ -> [])) soFar


{-| Read a field containing a nested record, using an auto-generated default.

  - This field is read-only, which is good because you can use the nested register's native way of writing changes. For example, a nested record can have `RW` fields, you can `Change` it that way.
  - Naked records "skeletons" can only be initialized this way, or using full record literal syntax.

-}
fieldRec : FieldIdentifier -> (full -> fieldType) -> SkelCodec errs fieldType -> PartialRegister errs i full (fieldType -> remaining) -> PartialRegister errs i full remaining
fieldRec ( fieldSlot, fieldName ) fieldGetter fieldCodec soFar =
    readableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec (HardcodedSeed (\_ -> [])) soFar


{-| Read a `Maybe something` field without adding the `maybe` codec. Default is Nothing.

  - If your field will more often be set to something else (e.g. `Just 0`), consider using `readable` with your `maybe`-wrapped codec instead and using the common value as the default. This will save space and bandwidth.

-}
maybeR : FieldIdentifier -> (full -> Maybe justFieldType) -> Codec errs fieldSeed justFieldType -> PartialRegister errs i full (Maybe justFieldType -> remaining) -> PartialRegister errs i full remaining
maybeR fieldID fieldGetter fieldCodec recordBuilt =
    readableHelper fieldID fieldGetter (maybe fieldCodec) (HardcodedDefault Nothing) recordBuilt


{-| Read a `RepList` field without adding the `repList` codec. Default is an empty `RepList`.

  - Will not work with primitive `List` fields. For that, use the `immutableList` codec with `field`.
  - Default is an empty RepList. Want a different default? Use `field` with the `repList` codec.
  - If any items in the RepList are corrupted, they will be silently excluded.
  - If your field is not a `RepList` but a type that wraps one (or more), you will need to use `field` or `fieldRW` with the `repList` codec instead.

-}
fieldList : FieldIdentifier -> (full -> RepList memberType) -> Codec errs memberSeed memberType -> PartialRegister errs i full (RepList memberType -> remaining) -> PartialRegister errs i full remaining
fieldList fieldID fieldGetter fieldCodec recordBuilt =
    readableHelper fieldID fieldGetter (repList fieldCodec) (HardcodedSeed nonChanger) recordBuilt


{-| Read a `RepDict` field without adding the `repDict` codec. Default is an empty `RepDict`. Instead of supplying a single codec for members, you provide a pair of codec in a tuple, e.g. `(string, bool)`.

  - Will not yet work with primitive `Dict` fields. For that, use the `immutableList` codec with `field`.
  - Default is an empty RepDict. Want a different default? Use `field` with the `repDict` codec.
  - If any items in the RepDict are corrupted, they will be silently excluded.
  - If your field is not a `RepDict` but a type that wraps one (or more), you will need to use `field` or `fieldRW` with the `repDict` codec instead.

-}
fieldDict : FieldIdentifier -> (full -> RepDict keyType valueType) -> ( Codec errs keyInit keyType, Codec errs valInit valueType ) -> PartialRegister errs i full (RepDict keyType valueType -> remaining) -> PartialRegister errs i full remaining
fieldDict fieldID fieldGetter ( keyCodec, valueCodec ) recordBuilt =
    readableHelper fieldID fieldGetter (repDict keyCodec valueCodec) (HardcodedSeed nonChanger) recordBuilt


{-| Read a `RepDb` field without adding the `repDb` codec. Default is an empty `RepDb`.

  - If any items in the RepDb are corrupted, they will be silently excluded.
  - If your field is not a `RepDb` but a type that wraps one (or more), you will need to use `field` or `fieldRW` with the `repDb` codec instead.

-}
fieldDb : FieldIdentifier -> (full -> RepDb memberType) -> Codec errs memberSeed memberType -> PartialRegister errs i full (RepDb memberType -> remaining) -> PartialRegister errs i full remaining
fieldDb fieldID fieldGetter fieldCodec recordBuilt =
    readableHelper fieldID fieldGetter (repDb fieldCodec) (HardcodedSeed nonChanger) recordBuilt


{-| Read a record field wrapped with `RW`. This makes the field writable.
The last argument specifies a default value, which is used when initializing the record for the first time.

  - Due to the RW wrapper, you will need to add `.get` to the output whenever you want to access the field's latest value as usual. Read-only fields do not require this.
  - Thanks to the RW wrapper, you can add `.set` to the output anywhere in your program to produce a `Change`. These changes can then be saved, updating the stored value.
  - Consider setting the default to the "most popular" value (e.g. "scaling factor" set to 1.0), as it will be omitted from the serialized data, saving space and bandwidth.
  - Consider setting the default to the "safest" value, as missing fields will be parsed as the default.
  - If you can't come up with a sensible default value (e.g. date of birth), consider wrapping the field in `Maybe` or `Result`, with e.g. `Nothing` or `Err Unset` as the default.
  - If there's no sensible default and this record is not useful with missing data unless you add another validation step ("Parse, Don't Validate"!), consider `readableRequired` as a last resort.

-}
maybeRW : FieldIdentifier -> (full -> RW (Maybe fieldType)) -> Codec errs fieldSeed fieldType -> PartialRegister errs i full (RW (Maybe fieldType) -> remaining) -> PartialRegister errs i full remaining
maybeRW fieldIdentifier fieldGetter fieldCodec soFar =
    writableHelper fieldIdentifier fieldGetter (maybe fieldCodec) (HardcodedDefault Nothing) soFar


{-| Read a `Maybe` record field wrapped with `RW`. This makes the field writable.
The last argument specifies a default value, which is used when initializing the record for the first time.

  - Due to the RW wrapper, you will need to add `.get` to the output whenever you want to access the field's latest value as usual. Read-only fields do not require this.
  - Thanks to the RW wrapper, you can add `.set` to the output anywhere in your program to produce a `Change`. These changes can then be saved, updating the stored value.
  - Consider setting the default to the "most popular" value (e.g. "scaling factor" set to 1.0), as it will be omitted from the serialized data, saving space and bandwidth.
  - Consider setting the default to the "safest" value, as missing fields will be parsed as the default.
  - If you can't come up with a sensible default value (e.g. date of birth), consider wrapping the field in `Maybe` or `Result`, with e.g. `Nothing` or `Err Unset` as the default.
  - If there's no sensible default and this record is not useful with missing data unless you add another validation step ("Parse, Don't Validate"!), consider `readableRequired` as a last resort.

-}
fieldRW : FieldIdentifier -> (full -> RW fieldType) -> Codec errs fieldType fieldType -> fieldType -> PartialRegister errs i full (RW fieldType -> remaining) -> PartialRegister errs i full remaining
fieldRW fieldIdentifier fieldGetter fieldCodec fieldDefault soFar =
    writableHelper fieldIdentifier fieldGetter fieldCodec (HardcodedDefault fieldDefault) soFar


{-| Read a field that is required, yet has no sensible default. Use sparingly.

  - Only add required fields BEFORE using in production for the first time.
  - NEVER add required fields after that, or old data may be seen as corrupt.
  - Useful for "Parse, Don't Validate" as you can use this to avoid extra validation later, e.g. `Maybe` wrappers on fields that should never be missing.
  - Will it be essential forever? Once you require a field, you can't make it optional later - omitted values from new clients will be seen as corrupt by old ones!
  - Consider if this field being set upfront is essential to this record. For graceful degradation, records missing essential fields will be omitted from any containing collections. If the field is in your root object, it may fail to parse entirely. (And that's exactly what you would want, if this field were truly essential.)

-}
coreR : FieldIdentifier -> (full -> fieldType) -> Codec errs fieldSeed fieldType -> (parentSeed -> fieldSeed) -> PartialRegister errs parentSeed full (fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
coreR fieldID fieldGetter fieldCodec seeder recordBuilt =
    readableHelper fieldID fieldGetter fieldCodec (InitWithParentSeed seeder) recordBuilt


{-| Read and Write a core field. A core field is both required, AND has no sensible default. Prefer non-core fields when possible.

Including any core fields in your register will force you to pass in a "seed" any time you initialize it. The seed value contains whatever you need to initialize all the core fields. Registers that do not need seeds are more robust to serialization!

  - If this field is truly unique to the register upon initialization, does it really need to be writable? Consider using `coreR` instead, so your code can initialize the field with a seed but not accidentally modify it later.

-}
coreRW : FieldIdentifier -> (full -> RW fieldType) -> Codec errs fieldSeed fieldType -> (parentSeed -> fieldSeed) -> PartialRegister errs parentSeed full (RW fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
coreRW fieldID fieldGetter fieldCodec seeder recordBuilt =
    writableHelper fieldID fieldGetter fieldCodec (InitWithParentSeed seeder) recordBuilt


{-| Read a field that needs a seed.
Pass in a `(\parentSeed -> fieldSeed)` function, which gives you access to the parent's seed, if it has one. Otherwise, that's just `()` The return value will be used to seed the field.

  - Does your field actually need to be available as soon as the parent exists? If not, consider wrapping it in something like `Maybe` so you can give a it a default of `Nothing` and seed it when you actually need it. Then you don't need a seed from the parent.
  - You can use this to seed the field with a constant, ignoring the parent seed like `(\_ -> [1,2,3])` if you need that for some reason. But if a constant works, your field's type can probably be made seedless anyway. You can also just use a field default, rather than seeding, so your parent register can be seedless.

-}
seededR : FieldIdentifier -> (full -> fieldType) -> Codec errs fieldSeed fieldType -> fieldType -> (parentSeed -> fieldSeed) -> PartialRegister errs parentSeed full (fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
seededR fieldID fieldGetter fieldCodec default seeder recordBuilt =
    readableHelper fieldID fieldGetter fieldCodec (DefaultAndInitWithParentSeed default seeder) recordBuilt


{-| Read/Write a field that needs a seed.
Pass in a `(\parentSeed -> fieldSeed)` function, which gives you access to the parent's seed, if it has one. Otherwise, that's just `()` The return value will be used to seed the field.

  - Does your field actually need to be available as soon as the parent exists? If not, consider wrapping it in something like `Maybe` so you can give a it a default of `Nothing` and seed it when you actually need it. Then you don't need a seed from the parent.
  - You can use this to seed the field with a constant, ignoring the parent seed like `(\_ -> [1,2,3])` if you need that for some reason. But if a constant works, your field's type can probably be made seedless anyway. You can also just use a field default, rather than seeding, so your parent register can be seedless.

-}
seededRW : FieldIdentifier -> (full -> RW fieldType) -> Codec errs fieldSeed fieldType -> fieldType -> (parentSeed -> fieldSeed) -> PartialRegister errs parentSeed full (RW fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
seededRW fieldID fieldGetter fieldCodec default seeder recordBuilt =
    writableHelper fieldID fieldGetter fieldCodec (DefaultAndInitWithParentSeed default seeder) recordBuilt


{-| Helper for mapping over 2 decoders, since they contain Results. If one fails, the combined decoder fails.
-}
combineIfBothSucceed : Result (Error e) (fieldType -> remaining) -> Result (Error e) fieldType -> Result (Error e) remaining
combineIfBothSucceed decoderA decoderB =
    case ( decoderA, decoderB ) of
        ( Ok aDecodedValue, Ok bDecodedValue ) ->
            -- a is being applied to b
            Ok (aDecodedValue bDecodedValue)

        ( Err a_error, _ ) ->
            Err a_error

        ( _, Err b_error ) ->
            Err b_error


{-| Same as JD.map2, but with RegisterFieldDecoderInputs argument built in
-}
mapRegisterNodeDecoder :
    (a -> b -> value)
    -> (RegisterFieldDecoderInputs -> JD.Decoder a)
    -> (RegisterFieldDecoderInputs -> JD.Decoder b)
    -> RegisterFieldDecoderInputs
    -> JD.Decoder value
mapRegisterNodeDecoder twoArgFunction nestableDecoderA nestableDecoderB inputs =
    let
        -- typevars a and b contain the Result blob
        decoderA : JD.Decoder a
        decoderA =
            nestableDecoderA inputs

        decoderB : JD.Decoder b
        decoderB =
            nestableDecoderB inputs
    in
    JD.map2 twoArgFunction decoderA decoderB


{-| Internal helper to wrap child changes in parent changes when the parent is still a placeholder.
-}
updateRegisterPostChildInit : Pointer -> FieldIdentifier -> Change -> Change
updateRegisterPostChildInit parentPointer fieldIdentifier ((ChangeSet deets) as changeToWrap) =
    Change.ChangeSet
        { target = parentPointer
        , objectChanges =
            [ Change.NewPayload (encodeFieldPayloadAsObjectPayload fieldIdentifier (changeToChangePayload changeToWrap)) ]
        , externalUpdates = []
        }


{-| RON what to do when decoding a (potentially nested!) object field.
-}
registerReadOnlyFieldDecoder : Int -> ( FieldSlot, FieldName ) -> FieldFallback parentSeed fieldSeed fieldType -> Codec e fieldSeed fieldType -> RegisterFieldDecoderInputs -> ( Maybe fieldType, List (Error e) )
registerReadOnlyFieldDecoder index (( fieldSlot, fieldName ) as fieldIdentifier) fallback fieldCodec inputs =
    let
        regPointer =
            Change.updateChildChangeWrapper inputs.pointer installer

        installer =
            updateRegisterPostChildInit inputs.pointer fieldIdentifier

        position =
            Nonempty.singleton (String.fromInt index ++ "." ++ fieldName ++ "_" ++ String.fromInt fieldSlot)

        runFieldDecoder thingToDecode =
            JD.decodeValue
                (getNodeDecoder fieldCodec
                    { node = inputs.node, position = position, parent = regPointer, cutoff = inputs.cutoff }
                )
                thingToDecode

        generatedDefaultMaybe =
            case fallback of
                HardcodedSeed fieldSeed ->
                    Just <| getInitializer fieldCodec { parent = regPointer, seed = fieldSeed, position = position }

                _ ->
                    Nothing

        default =
            Maybe.Extra.or (fieldDefaultMaybe fallback) generatedDefaultMaybe
    in
    case getFieldLatestOnly inputs.history fieldIdentifier of
        Nothing ->
            -- field was never set - fall back to default
            case default of
                Just _ ->
                    ( default, [] )

                Nothing ->
                    Log.crashInDev ("registerReadOnlyFieldDecoder: Failed to decode a field (" ++ fieldName ++ ") that should always decode (required missing, or nested should return defaults), there's no default to fall back to")
                        ( default, [ DataCorrupted ] )

        Just foundField ->
            -- field was set before
            case runFieldDecoder (Op.payloadToJsonValue foundField) of
                Ok (Ok goodValue) ->
                    ( Just goodValue, [] )

                Ok (Err problem) ->
                    ( default, [ problem ] )

                Err jsonDecodeError ->
                    ( default, [ JDError jsonDecodeError ] )


registerWritableFieldDecoder : Int -> ( FieldSlot, FieldName ) -> FieldFallback parentSeed fieldSeed fieldType -> Codec e fieldSeed fieldType -> RegisterFieldDecoderInputs -> ( Maybe (RW fieldType), List (Error e) )
registerWritableFieldDecoder index (( fieldSlot, fieldName ) as fieldIdentifier) fallback fieldCodec inputs =
    let
        fieldEncoder newValue =
            getNodeEncoder fieldCodec
                { node = inputs.node
                , mode = defaultEncodeMode
                , thingToEncode = EncodeThis newValue
                , parent = Change.updateChildChangeWrapper inputs.pointer (updateRegisterPostChildInit inputs.pointer fieldIdentifier)
                , position = Nonempty.singleton (String.fromInt index ++ "." ++ fieldName ++ "_" ++ String.fromInt fieldSlot)
                }

        wrapRW : Change.Pointer -> fieldType -> RW fieldType
        wrapRW targetObject head =
            buildRW targetObject fieldIdentifier fieldEncoder head
    in
    case registerReadOnlyFieldDecoder index fieldIdentifier fallback fieldCodec inputs of
        ( Just thingToWrap, errorsSoFar ) ->
            ( Just (wrapRW inputs.pointer thingToWrap), errorsSoFar )

        ( previousShowstopper, errorsSoFar ) ->
            ( Nothing, errorsSoFar )


prepDecoder : String -> String
prepDecoder inputString =
    case String.startsWith ">" inputString of
        True ->
            "\"" ++ String.dropLeft 1 (String.dropRight 1 inputString) ++ "\""

        False ->
            inputString


concurrentObjectIDsDecoder : JD.Decoder (List OpID.ObjectID)
concurrentObjectIDsDecoder =
    let
        try givenString =
            case OpID.fromString (unquoteObjectID givenString) of
                Just opID ->
                    JD.succeed opID

                Nothing ->
                    Log.log ("Codec.concurrentObjectIDsDecoder warning: got bad opID: " ++ givenString) <|
                        JD.fail (givenString ++ " is not a valid OpID...")

        unquoteObjectID quoted =
            case String.startsWith ">" quoted of
                True ->
                    String.dropLeft 1 quoted

                False ->
                    quoted

        quotedObjectDecoder =
            JD.andThen try JD.string
    in
    JD.oneOf
        [ JD.list quotedObjectDecoder
        , JD.map List.singleton quotedObjectDecoder
        , JD.succeed [] -- TODO this may swallow errors.. currently needed to allow blank objects to initialize
        ]


type alias Skel =
    () -> List Change


{-| Finish creating a codec for a naked Register.
This is a Register, stripped of its wrapper.
Upgrade to a fully wrapped Register for features such as versioning and time travel.
-}
finishRecord : PartialRegister errs () full full -> Codec errs Skel full
finishRecord ((PartialRegister allFieldsCodec) as partial) =
    let
        encodeAsJsonObject nakedRecord =
            let
                fullRecord =
                    nakedRecord

                passFullRecordToFieldEncoder ( fieldKey, fieldEncoder ) =
                    ( fieldKey, fieldEncoder fullRecord )
            in
            JE.object (List.map passFullRecordToFieldEncoder allFieldsCodec.jsonEncoders)

        encodeAsDictList fullRecord =
            JE.list (encodeEntryInDictList fullRecord) allFieldsCodec.jsonEncoders

        encodeEntryInDictList fullRecord ( fieldKey, entryValueEncoder ) =
            JE.list identity [ JE.string fieldKey, entryValueEncoder fullRecord ]

        nodeDecoder : NodeDecoder errs full
        nodeDecoder { node, parent, position, cutoff } =
            let
                nakedRegisterDecoder : List ObjectID -> JD.Decoder (Result (Error errs) full)
                nakedRegisterDecoder objectIDs =
                    let
                        object =
                            Node.getObject { node = node, cutoff = cutoff, foundIDs = objectIDs, parent = parent, reducer = registerReducerID, position = position }

                        history =
                            buildRegisterFieldDictionary object

                        regToRecordByDecodingMaybe =
                            case
                                allFieldsCodec.nodeDecoder { node = node, pointer = Object.getPointer object, cutoff = cutoff, history = history }
                            of
                                ( success, [] ) ->
                                    success

                                ( recovered, errors ) ->
                                    Log.crashInDev ("regToRecordByDecoding returned errors!" ++ Log.dump errors) recovered

                        regToRecordByInit =
                            allFieldsCodec.nodeInitializer

                        finalRecord =
                            case regToRecordByDecodingMaybe of
                                Just recordDecoded ->
                                    recordDecoded

                                Nothing ->
                                    Log.crashInDev "nakedRegisterDecoder decoded nothing!" <|
                                        regToRecordByInit () parent
                    in
                    JD.succeed <| Ok <| finalRecord
            in
            JD.andThen nakedRegisterDecoder concurrentObjectIDsDecoder

        nodeEncoder : NodeEncoder full
        nodeEncoder inputs =
            recordNodeEncoder partial inputs

        emptyRegister : Initializer Skel full
        emptyRegister { parent, position } =
            let
                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], parent = parent, reducer = registerReducerID, position = position }
            in
            allFieldsCodec.nodeInitializer () (Object.getPointer object)

        bytesDecoder : BD.Decoder (Result (Error errs) full)
        bytesDecoder =
            allFieldsCodec.bytesDecoder

        jsonDecoder : JD.Decoder (Result (Error errs) full)
        jsonDecoder =
            allFieldsCodec.jsonArrayDecoder
    in
    Codec
        { nodeEncoder =  nodeEncoder
        , nodeDecoder =  nodeDecoder
        , bytesEncoder = allFieldsCodec.bytesEncoder >> List.reverse >> BE.sequence
        , bytesDecoder = bytesDecoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = jsonDecoder
        , init = emptyRegister
        }


{-| Finish creating a codec for a naked Register.
This is a Register, stripped of its wrapper.
-}
finishSeededRecord : PartialRegister errs s full full -> Codec errs s full
finishSeededRecord ((PartialRegister allFieldsCodec) as partial) =
    let
        encodeAsJsonObject nakedRecord =
            let
                fullRecord =
                    nakedRecord

                passFullRecordToFieldEncoder ( fieldKey, fieldEncoder ) =
                    ( fieldKey, fieldEncoder fullRecord )
            in
            JE.object (List.map passFullRecordToFieldEncoder allFieldsCodec.jsonEncoders)

        encodeAsDictList fullRecord =
            JE.list (encodeEntryInDictList fullRecord) allFieldsCodec.jsonEncoders

        encodeEntryInDictList fullRecord ( fieldKey, entryValueEncoder ) =
            JE.list identity [ JE.string fieldKey, entryValueEncoder fullRecord ]

        nodeDecoder : NodeDecoder errs full
        nodeDecoder { node, parent, position, cutoff } =
            let
                nakedRegisterDecoder : List ObjectID -> JD.Decoder (Result (Error errs) full)
                nakedRegisterDecoder objectIDs =
                    let
                        object =
                            Node.getObject { node = node, cutoff = cutoff, foundIDs = objectIDs, parent = parent, reducer = registerReducerID, position = position }

                        history =
                            buildRegisterFieldDictionary object

                        regToRecordByDecoding givenCutoff =
                            case
                                allFieldsCodec.nodeDecoder { node = node, pointer = Object.getPointer object, cutoff = givenCutoff, history = history }
                            of
                                ( success, [] ) ->
                                    success

                                ( recovered, errors ) ->
                                    Log.crashInDev ("regToRecordByDecoding returned errors!" ++ Log.dump errors) recovered

                        wrongCutoffRegToRecordByDecoding =
                            case
                                allFieldsCodec.nodeDecoder { node = node, pointer = Object.getPointer object, cutoff = Nothing, history = history }
                            of
                                ( success, [] ) ->
                                    success

                                ( recovered, errors ) ->
                                    Log.crashInDev ("regToRecordByDecoding returned errors!" ++ Log.dump errors) recovered

                        regToRecord regCanBeBuilt givenCutoff =
                            case regToRecordByDecoding givenCutoff of
                                Just recordDecoded ->
                                    recordDecoded

                                Nothing ->
                                    -- if it was decodable when built, but not with the given cutoff, ignore the cutoff. Should not matter, as we will provide defaults no matter what cutoff is given.
                                    regCanBeBuilt
                    in
                    case wrongCutoffRegToRecordByDecoding of
                        Just regCanBeBuilt ->
                            JD.succeed <| Ok <| regToRecord regCanBeBuilt Nothing

                        Nothing ->
                            JD.succeed <| Err DataCorrupted
            in
            JD.andThen nakedRegisterDecoder concurrentObjectIDsDecoder

        nodeEncoder : NodeEncoder full
        nodeEncoder inputs =
            recordNodeEncoder partial inputs

        emptyRegister : Initializer s full
        emptyRegister { parent, position, seed } =
            let
                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], parent = parent, reducer = registerReducerID, position = position }

                history =
                    buildRegisterFieldDictionary object
            in
            allFieldsCodec.nodeInitializer seed (Object.getPointer object)

        bytesDecoder : BD.Decoder (Result (Error errs) full)
        bytesDecoder =
            allFieldsCodec.bytesDecoder

        jsonDecoder : JD.Decoder (Result (Error errs) full)
        jsonDecoder =
            allFieldsCodec.jsonArrayDecoder
    in
    Codec
        { nodeEncoder =  nodeEncoder
        , nodeDecoder =  nodeDecoder
        , bytesEncoder = allFieldsCodec.bytesEncoder >> List.reverse >> BE.sequence
        , bytesDecoder = bytesDecoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = jsonDecoder
        , init = emptyRegister
        }


{-| Finish creating a codec for a register.
-}
finishRegister : PartialRegister errs () full full -> WrappedCodec errs (Reg full)
finishRegister ((PartialRegister allFieldsCodec) as partialRegister) =
    let
        encodeAsJsonObject (Register regDetails) =
            let
                fullRecord =
                    regDetails.toRecord Nothing

                passFullRecordToFieldEncoder ( fieldKey, fieldEncoder ) =
                    ( fieldKey, fieldEncoder fullRecord )
            in
            JE.object (List.map passFullRecordToFieldEncoder allFieldsCodec.jsonEncoders)

        encodeAsDictList fullRecord =
            JE.list (encodeEntryInDictList fullRecord) allFieldsCodec.jsonEncoders

        encodeEntryInDictList fullRecord ( fieldKey, entryValueEncoder ) =
            JE.list identity [ JE.string fieldKey, entryValueEncoder fullRecord ]

        nodeDecoder : NodeDecoder errs (Reg full)
        nodeDecoder { node, parent, position, cutoff } =
            let
                registerDecoder : List ObjectID -> JD.Decoder (Result (Error errs) (Reg full))
                registerDecoder objectIDs =
                    let
                        object =
                            Node.getObject { node = node, cutoff = cutoff, foundIDs = objectIDs, parent = parent, reducer = registerReducerID, position = position }

                        history =
                            buildRegisterFieldDictionary object

                        regToRecordByDecoding givenCutoff =
                            case
                                allFieldsCodec.nodeDecoder { node = node, pointer = Object.getPointer object, cutoff = givenCutoff, history = history }
                            of
                                ( success, [] ) ->
                                    success

                                ( recovered, errors ) ->
                                    Log.crashInDev ("regToRecordByDecoding returned errors!" ++ Log.dump errors) recovered

                        regToRecordByInit =
                            allFieldsCodec.nodeInitializer

                        regToRecord givenCutoff =
                            case regToRecordByDecoding givenCutoff of
                                Just recordDecoded ->
                                    recordDecoded

                                Nothing ->
                                    regToRecordByInit () parent
                    in
                    JD.succeed <| Ok <| Register { pointer = Object.getPointer object, included = Object.All, toRecord = regToRecord, history = history, init = nonChanger }
            in
            JD.andThen registerDecoder concurrentObjectIDsDecoder

        nodeEncoder : NodeEncoder (Reg full)
        nodeEncoder inputs =
            registerNodeEncoder partialRegister
                { thingToEncode = inputs.thingToEncode
                , mode = inputs.mode
                , node = inputs.node
                , parent = inputs.parent
                , position = inputs.position
                }

        emptyRegister { parent, position, seed } =
            let
                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], parent = parent, reducer = registerReducerID, position = position }

                history =
                    buildRegisterFieldDictionary object

                regToRecord cutoff =
                    allFieldsCodec.nodeInitializer () (Object.getPointer object)
            in
            Register { pointer = Object.getPointer object, included = Object.All, toRecord = regToRecord, history = history, init = seed }

        tempEmpty =
            emptyRegister { parent = Change.genesisPointer, seed = nonChanger, position = Nonempty.singleton "flatTodo" }

        bytesDecoder : BD.Decoder (Result (Error errs) (Reg full))
        bytesDecoder =
            -- TODO use allFieldsCodec.bytesDecoder
            BD.succeed <| Ok <| tempEmpty

        jsonDecoder : JD.Decoder (Result (Error errs) (Reg full))
        jsonDecoder =
            -- TODO use allFieldsCodec.jsonArrayDecoder
            JD.succeed <| Ok <| tempEmpty
    in
    Codec
        { nodeEncoder =  nodeEncoder
        , nodeDecoder =  nodeDecoder
        , bytesEncoder = \(Register regDetails) -> (allFieldsCodec.bytesEncoder >> List.reverse >> BE.sequence) (regDetails.toRecord Nothing)
        , bytesDecoder = bytesDecoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = jsonDecoder
        , init = emptyRegister
        }


{-| Finish creating a codec for a register that needs a seed.
-}
finishSeededRegister : PartialRegister errs s full full -> Codec errs ( s, Changer (Reg full) ) (Reg full)
finishSeededRegister ((PartialRegister allFieldsCodec) as partialRegister) =
    let
        encodeAsJsonObject (Register regDetails) =
            let
                fullRecord =
                    regDetails.toRecord Nothing

                passFullRecordToFieldEncoder ( fieldKey, fieldEncoder ) =
                    ( fieldKey, fieldEncoder fullRecord )
            in
            JE.object (List.map passFullRecordToFieldEncoder allFieldsCodec.jsonEncoders)

        encodeAsDictList fullRecord =
            JE.list (encodeEntryInDictList fullRecord) allFieldsCodec.jsonEncoders

        encodeEntryInDictList fullRecord ( fieldKey, entryValueEncoder ) =
            JE.list identity [ JE.string fieldKey, entryValueEncoder fullRecord ]

        nodeDecoder : NodeDecoder errs (Reg full)
        nodeDecoder { node, parent, position, cutoff } =
            let
                registerDecoder : List ObjectID -> JD.Decoder (Result (Error errs) (Reg full))
                registerDecoder objectIDs =
                    let
                        object =
                            Node.getObject { node = node, cutoff = cutoff, foundIDs = objectIDs, parent = parent, reducer = registerReducerID, position = position }

                        history =
                            buildRegisterFieldDictionary object

                        regToRecordByDecoding givenCutoff =
                            allFieldsCodec.nodeDecoder { node = node, pointer = Object.getPointer object, cutoff = givenCutoff, history = history }
                                -- TODO currently ignoring errors
                                |> Tuple.first

                        wrongCutoffRegToRecordByDecoding =
                            allFieldsCodec.nodeDecoder { node = node, pointer = Object.getPointer object, cutoff = Nothing, history = history }
                                -- TODO currently ignoring errors
                                |> Tuple.first

                        regToRecord regCanBeBuilt givenCutoff =
                            case regToRecordByDecoding givenCutoff of
                                Just recordDecoded ->
                                    recordDecoded

                                Nothing ->
                                    -- if it was decodable when built, but not with the given cutoff, ignore the cutoff. Should not matter, as we will provide defaults no matter what cutoff is given.
                                    regCanBeBuilt
                    in
                    case wrongCutoffRegToRecordByDecoding of
                        Just regCanBeBuilt ->
                            JD.succeed <| Ok <| Register { pointer = Object.getPointer object, included = Object.All, toRecord = regToRecord regCanBeBuilt, history = history, init = nonChanger }

                        Nothing ->
                            JD.succeed <| Err DataCorrupted
            in
            JD.andThen registerDecoder concurrentObjectIDsDecoder

        nodeEncoder : NodeEncoder (Reg full)
        nodeEncoder inputs =
            registerNodeEncoder partialRegister
                { thingToEncode = inputs.thingToEncode
                , mode = inputs.mode
                , node = inputs.node
                , parent = inputs.parent
                , position = inputs.position
                }

        emptyRegister { parent, position, seed } =
            let
                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], parent = parent, reducer = registerReducerID, position = position }

                history =
                    buildRegisterFieldDictionary object

                regToRecord cutoff =
                    allFieldsCodec.nodeInitializer (Tuple.first seed) (Object.getPointer object)
            in
            Register { pointer = Object.getPointer object, included = Object.All, toRecord = regToRecord, history = history, init = Tuple.second seed }

        bytesDecoder : BD.Decoder (Result (Error errs) (Reg full))
        bytesDecoder =
            -- TODO use allFieldsCodec.bytesDecoder
            BD.fail

        jsonDecoder : JD.Decoder (Result (Error errs) (Reg full))
        jsonDecoder =
            -- TODO use allFieldsCodec.jsonArrayDecoder
            JD.fail "Need to add decoder to reptype"
    in
    Codec
        { nodeEncoder =  nodeEncoder
        , nodeDecoder =  nodeDecoder
        , bytesEncoder = \(Register regDetails) -> (allFieldsCodec.bytesEncoder >> List.reverse >> BE.sequence) (regDetails.toRecord Nothing)
        , bytesDecoder = bytesDecoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = jsonDecoder
        , init = emptyRegister
        }


buildRegisterFieldDictionary : Object -> FieldHistoryDict
buildRegisterFieldDictionary object =
    let
        addFieldEntry : OpID -> Object.Event -> Dict FieldSlot FieldHistoryBackwards -> Dict FieldSlot FieldHistoryBackwards
        addFieldEntry eventID event buildingDict =
            case extractFieldEventFromObjectPayload (Object.eventPayload event) of
                Ok ( ( fieldSlot, fieldName ), fieldPayload ) ->
                    let
                        logMsg =
                            "Adding to " ++ Console.underline fieldName ++ " field history"
                    in
                    Dict.update fieldSlot (addUpdate ( eventID, fieldPayload )) buildingDict

                Err problem ->
                    Log.logSeparate ("WARNING " ++ problem) (Object.eventPayload event) buildingDict

        addUpdate : ( OpID, FieldPayload ) -> Maybe FieldHistoryBackwards -> Maybe FieldHistoryBackwards
        addUpdate newUpdate existingUpdatesMaybe =
            Just
                (Nonempty newUpdate
                    (Maybe.withDefault []
                        (Maybe.map Nonempty.toList existingUpdatesMaybe)
                    )
                )
    in
    -- object.events is a dict, so always ID order, so always oldest to newest.
    -- we want newest to oldest list, but folding reverses the list, so stick with foldL
    -- (warn: foldL/foldR applies the arguments in opposite order to the folding function)
    AnyDict.foldl addFieldEntry Dict.empty (Object.getEvents object)


extractFieldEventFromObjectPayload : Object.EventPayload -> Result String ( FieldIdentifier, FieldPayload )
extractFieldEventFromObjectPayload payload =
    case payload of
        (Op.IntegerAtom fieldSlot) :: (Op.NakedStringAtom fieldName) :: rest ->
            case rest of
                [] ->
                    Err <| "Register: Missing payload for field " ++ fieldName

                head :: tail ->
                    Ok ( ( fieldSlot, fieldName ), Nonempty head tail )

        badList ->
            Err ("Register: Failed to extract field slot, field name, event payload from the given op payload because the value list is supposed to have 3+ elements and I found " ++ String.fromInt (List.length badList))


encodeFieldPayloadAsObjectPayload : FieldIdentifier -> Change.PotentialPayload -> Change.PotentialPayload
encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) fieldPayload =
    Nonempty.append
        (Nonempty (Change.RonAtom (Op.IntegerAtom fieldSlot)) [ Change.RonAtom (Op.NakedStringAtom fieldName) ])
        fieldPayload


{-| Register field fetch - will combine nested objectIDs if found
-}
getFieldLatestOnly : FieldHistoryDict -> FieldIdentifier -> Maybe FieldPayload
getFieldLatestOnly fields ( fieldSlot, name ) =
    case Dict.get fieldSlot fields of
        Nothing ->
            Nothing

        Just ((Nonempty ( firstOpID, Nonempty (Op.IDPointerAtom objectID) anyMoreAtoms ) anyMoreOps) as history) ->
            -- nested object will be in this specific form, an objectID as its first (usually only) atom
            -- can't just detect objectIDs present because it could be a custom type wrapping one
            -- stick together all objectIDs found ever
            Just <| Nonempty.concatMap Tuple.second history

        Just historyNonempty ->
            -- first one didn't begin with an ObjectID atom, go back to normal
            Just <| Tuple.second (Nonempty.head historyNonempty)


getFieldHistory : FieldHistoryDict -> FieldIdentifier -> List ( OpID, FieldPayload )
getFieldHistory fields ( desiredFieldSlot, name ) =
    Dict.get desiredFieldSlot fields
        |> Maybe.map Nonempty.toList
        |> Maybe.withDefault []


getFieldHistoryValues : FieldHistoryDict -> FieldIdentifier -> List FieldPayload
getFieldHistoryValues fields givenField =
    List.map Tuple.second (getFieldHistory fields givenField)


buildRW : Change.Pointer -> FieldIdentifier -> (fieldVal -> Change.MaybeSkippableChange) -> fieldVal -> RW fieldVal
buildRW targetObject ( fieldSlot, fieldName ) nestedRonEncoder latestValue =
    let
        nestedChange newValue =
            encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName )
                (Change.unwrapSkippability (nestedRonEncoder newValue))

        -- since we're asked to write it, whether it's skippable or not
        setter setValue =
            Change.ChangeSet
                { target = targetObject
                , objectChanges = [ Change.NewPayload (nestedChange setValue) ]
                , externalUpdates = []
                }
    in
    { get = latestValue
    , set = setter
    }


buildRWH : Change.Pointer -> FieldIdentifier -> (fieldVal -> Change.MaybeSkippableChange) -> fieldVal -> List ( OpID, fieldVal ) -> RWH fieldVal
buildRWH targetObject ( fieldSlot, fieldName ) nestedRonEncoder latestValue rest =
    let
        nestedChange newValue =
            encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName )
                (Change.unwrapSkippability (nestedRonEncoder newValue))

        -- since we're asked to write it, whether it's skippable or not
    in
    { get = latestValue
    , set = \newValue -> Change.ChangeSet { target = targetObject, objectChanges = [ Change.NewPayload (nestedChange newValue) ], externalUpdates = [] }
    , history = rest
    }


{-| Helper function to separate out the init changes that actually belong to an object, vs. tagalongs that were given as well that affect some other object.
-}
extractInitChanges : Pointer -> List Change -> ( List ObjectChange, List Change )
extractInitChanges givenPointer initChanges =
    let
        extractObjectChange : Change -> ( List ObjectChange, List Change ) -> ( List ObjectChange, List Change )
        extractObjectChange givenChange ( sameObjectChanges, externalChanges ) =
            case givenChange of
                ChangeSet { target, objectChanges } ->
                    if Change.equalPointers target givenPointer then
                        -- collect ObjectChanges that belong to this object
                        ( sameObjectChanges ++ objectChanges, externalChanges )

                    else
                        -- collect external changes that need to go elsewhere
                        ( sameObjectChanges, externalChanges ++ [ givenChange ] )

        ( allLocal, allExternal ) =
            List.foldl extractObjectChange ( [], [] ) initChanges
    in
    ( allLocal, allExternal )


{-| Encodes an register as a list of Changes (which generate Ops):
-- The Op encoding the register comes last in the list, as the preceding Ops create registers that it depends on.
For each field:
-- if it's a normal value (no nodeEncoder) just encode it, return a Change
-- if it's a nested register that does not yet exist in the tree, assign a placeholder ID for it, then proceed with the following.
-- if it's a nested register that does exist, run its registerNodeEncoder and put its requisite ops above us.

Also returns the ObjectID so that parent registers can refer to it.

Why not create missing Objects in the encoder? Because if it already exists, we'd need to pass the existing ObjectID in anyway. Might as well pass in a guaranteed-existing Register (pre-created if needed)

JK: Updated thinking is this doesn't work anyway - a custom type could contain a register, that doesn't get initialized until set to a different variant. (e.g. `No | Yes a`.) So we have to be ready for on-demand initialization anyway.

-}
registerNodeEncoder : PartialRegister errs i full full -> NodeEncoderInputs (Reg full) -> Change.MaybeSkippableChange
registerNodeEncoder (PartialRegister allFieldsCodec) { node, thingToEncode, mode, parent, position } =
    let
        fallbackObject foundIDs =
            Node.getObject { node = node, cutoff = Nothing, foundIDs = foundIDs, parent = parent, reducer = registerReducerID, position = position }

        ( regMaybe, recordMaybe ) =
            case thingToEncode of
                EncodeThis reg ->
                    ( Just reg, Just <| Reg.latest reg )

                EncodeObjectOrThis objectIDs reg ->
                    ( Just reg, Just <| Reg.latest reg )

        ( registerPointer, history, initChanges ) =
            case regMaybe of
                Just ((Register regDetails) as reg) ->
                    ( regDetails.pointer, regDetails.history, regDetails.init reg )

                Nothing ->
                    ( Object.getPointer (fallbackObject []), Dict.empty, [] )

        updateMePostChildInit fieldChangedPayload =
            Change.ChangeSet
                { target = registerPointer
                , objectChanges = [ Change.NewPayload fieldChangedPayload ]
                , externalUpdates = []
                }

        ( extractedInitChanges, externalInitChanges ) =
            extractInitChanges registerPointer initChanges

        subChanges : List Change.ObjectChange
        subChanges =
            let
                runSubEncoder : (RegisterFieldEncoderInputs full -> RegisterFieldEncoderOutput) -> Maybe Change.ObjectChange
                runSubEncoder subEncoderFunction =
                    subEncoderFunction
                        { node = node
                        , history = history
                        , mode = mode
                        , parentPointer = registerPointer
                        , updateRegisterAfterChildInit = updateMePostChildInit -- wraps overall object change, but field encoders wrap specific field payload subchanges
                        , existingValMaybe = recordMaybe
                        }
                        |> asObjectChanges

                asObjectChanges : RegisterFieldEncoderOutput -> Maybe Change.ObjectChange
                asObjectChanges subEncoderOutput =
                    case subEncoderOutput of
                        EncodeThisField objChange ->
                            Just objChange

                        SkipThisField ->
                            Nothing
            in
            allFieldsCodec.nodeEncoders
                |> List.map runSubEncoder
                |> List.filterMap identity

        allObjectChanges =
            subChanges ++ extractedInitChanges

        isSkippable =
            if List.isEmpty allObjectChanges then
                Skippable

            else
                Necessary
    in
    isSkippable <|
        Nonempty.singleton
            (Change.QuoteNestedObject
                (ChangeSet
                    { target = registerPointer
                    , objectChanges = allObjectChanges
                    , externalUpdates = externalInitChanges
                    }
                )
            )


{-| Encodes a naked record
-}
recordNodeEncoder : PartialRegister errs i full full -> NodeEncoderInputs full -> Change.MaybeSkippableChange
recordNodeEncoder (PartialRegister allFieldsCodec) { node, thingToEncode, mode, parent, position } =
    let
        fallbackObject foundIDs =
            Node.getObject { node = node, cutoff = Nothing, foundIDs = foundIDs, parent = parent, reducer = registerReducerID, position = position }

        ( recordMaybe, object ) =
            case thingToEncode of
                EncodeThis nakedRecord ->
                    ( Just nakedRecord, fallbackObject [] )

                EncodeObjectOrThis objectIDs nakedRecord ->
                    ( Just nakedRecord, fallbackObject (Nonempty.toList objectIDs) )

        updateMePostChildInit fieldChangedPayload =
            Change.ChangeSet
                { target = Object.getPointer object
                , objectChanges = [ Change.NewPayload fieldChangedPayload ]
                , externalUpdates = []
                }

        subChanges : List Change.ObjectChange
        subChanges =
            let
                runSubEncoder : (RegisterFieldEncoderInputs full -> RegisterFieldEncoderOutput) -> Maybe Change.ObjectChange
                runSubEncoder subEncoderFunction =
                    subEncoderFunction
                        { node = node
                        , history = buildRegisterFieldDictionary object
                        , mode = mode
                        , parentPointer = Object.getPointer object
                        , updateRegisterAfterChildInit = updateMePostChildInit -- wraps overall object change, but field encoders wrap specific field payload subchanges
                        , existingValMaybe = recordMaybe
                        }
                        |> asObjectChanges

                asObjectChanges : RegisterFieldEncoderOutput -> Maybe Change.ObjectChange
                asObjectChanges subEncoderOutput =
                    case subEncoderOutput of
                        EncodeThisField objChange ->
                            Just objChange

                        SkipThisField ->
                            Nothing
            in
            allFieldsCodec.nodeEncoders
                |> List.map runSubEncoder
                |> List.filterMap identity

        isSkippable =
            if List.isEmpty subChanges then
                Skippable

            else
                Necessary
    in
    isSkippable <|
        Nonempty.singleton
            (Change.QuoteNestedObject
                (ChangeSet
                    { target = Object.getPointer object
                    , objectChanges = subChanges
                    , externalUpdates = []
                    }
                )
            )


{-| Does nothing but remind you not to reuse historical slots
-}
obsolete : List FieldIdentifier -> anything -> anything
obsolete reservedList input =
    input


{-| Whether we will be encoding this field, or skipping it. specific to registers. Used to do this for all encoder output, but it made everything harder.
-}
type RegisterFieldEncoderOutput
    = EncodeThisField Change.ObjectChange
    | SkipThisField


{-| Adds an item to the list of replica encoders, for encoding a single Register field into an Op, if applicable. This field may contain further nested fields which also are encoded.
-}
newRegisterFieldEncoderEntry : Int -> FieldIdentifier -> FieldFallback parentSeed fieldSeed fieldType -> Codec e fieldSeed fieldType -> (RegisterFieldEncoderInputs fieldType -> RegisterFieldEncoderOutput)
newRegisterFieldEncoderEntry index ( fieldSlot, fieldName ) fieldFallback ((Codec codecDetails) as fieldCodec) { mode, node, updateRegisterAfterChildInit, parentPointer, history, existingValMaybe } =
    let
        runFieldNodeEncoder valueToEncode =
            let
                parent =
                    -- Unneeded, parent already has notifier
                    Change.updateChildChangeWrapper parentPointer finishChildWrapper

                finishChildWrapper changeToWrap =
                    updateRegisterAfterChildInit
                        (encodeFieldPayloadAsObjectPayload
                            ( fieldSlot, fieldName )
                            (changeToChangePayload changeToWrap)
                        )
            in
            getNodeEncoder fieldCodec
                { mode = mode
                , node = node
                , thingToEncode = valueToEncode
                , parent = parentPointer
                , position = Nonempty.singleton (String.fromInt index ++ "." ++ fieldName ++ "_" ++ String.fromInt fieldSlot)
                }

        getPayloadIfSet =
            getFieldLatestOnly history ( fieldSlot, fieldName )

        fieldDecodedMaybe payload =
            -- even though we're in an encoder, we must run the decoder to get the value out of the register's memory. This is borrowed from registerReadOnlyFieldDecoder
            let
                run =
                    JD.decodeValue
                        (getNodeDecoder fieldCodec
                            { node = node
                            , position = Nonempty.singleton (String.fromInt index ++ "." ++ fieldName ++ "_" ++ String.fromInt fieldSlot)
                            , parent = Change.updateChildChangeWrapper parentPointer (updateRegisterPostChildInit parentPointer ( fieldSlot, fieldName ))
                            , cutoff = Nothing
                            }
                        )
                        (Op.payloadToJsonValue payload)
            in
            case run of
                Ok (Ok fieldValue) ->
                    Just fieldValue

                _ ->
                    Nothing

        explicitDefaultIfNeeded val =
            case ( mode.setDefaultsExplicitly, encodedDefault val ) of
                ( _, Necessary defaultVal ) ->
                    -- field encoder said it's necessary to encode now
                    EncodeThisField <| Change.NewPayload defaultVal

                ( True, Skippable defaultVal ) ->
                    -- unnecessary but we were asked to encode all defaults
                    EncodeThisField <| Change.NewPayload defaultVal

                ( False, Skippable _ ) ->
                    -- field encoder said we can skip this one
                    SkipThisField

        encodedDefault : fieldType -> Change.MaybeSkippableChange
        encodedDefault val =
            let
                wrapper =
                    Change.mapSkippability
                        (encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ))
            in
            -- EncodeThis because this only gets used on default value
            wrapper (runFieldNodeEncoder (EncodeThis val))
    in
    case Maybe.Extra.or existingValMaybe (fieldDefaultMaybe fieldFallback) of
        Just valToEncode ->
            -- Okay we have a default to fall back to
            -- has the value been set?
            case getPayloadIfSet of
                Nothing ->
                    -- never been set before, encode default if requested by mode, or just skip
                    explicitDefaultIfNeeded valToEncode

                Just foundPreviousValue ->
                    -- it's been set before. even if set to default (e.g. Nothing) we will honor this
                    EncodeThisField <| Change.NewPayload <| Nonempty.map Change.RonAtom foundPreviousValue

        Nothing ->
            -- we have no default to fall back to, this is for nested objects or core fields
            case getPayloadIfSet of
                Nothing ->
                    -- no default, no seed, no pre-existing object.. can't encode defaults even if we wanted to. Should only occur with naked records
                    SkipThisField

                Just latestPayload ->
                    -- it was set before, can we decode it?
                    case fieldDecodedMaybe latestPayload of
                        Nothing ->
                            -- give up! spit back out what we already had in the register.
                            EncodeThisField <| Change.NewPayload <|  Nonempty.map Change.RonAtom latestPayload

                        Just fieldValue ->
                            -- object acquired! make sure we don't miss the opportunity to pass objectID info to naked subcodecs
                            case extractQuotedObjects (Nonempty.toList latestPayload) of
                                [] ->
                                    -- give up! spit back out what we already had in the register.
                                    EncodeThisField <| Change.NewPayload <|  Nonempty.map Change.RonAtom latestPayload

                                firstFoundObjectID :: moreFoundObjectIDs ->
                                    let
                                        runNestedEncoder =
                                            EncodeObjectOrThis (Nonempty firstFoundObjectID moreFoundObjectIDs) fieldValue
                                                |> runFieldNodeEncoder
                                    in
                                    -- encode not only this field (set to this object), but also grab any encoder output from that object
                                    EncodeThisField <| Change.NewPayload (Change.unwrapSkippability runNestedEncoder)


{-| For getting the list of pointers out of the stored ops - perhaps even a bunch of ops, whose atoms can be concatenated (to merge all concurrent inits)
-}
extractQuotedObjects : List Op.OpPayloadAtom -> List ObjectID
extractQuotedObjects atomList =
    let
        keepUUIDs atom =
            case atom of
                Op.IDPointerAtom opID ->
                    Just opID

                _ ->
                    Nothing
    in
    List.filterMap keepUUIDs atomList



--Nothing
---- MAPPING


{-| Map from one codec to another codec

    import Serialize as S

    type UserId
        = UserId Int

    userIdCodec : S.Codec e UserId
    userIdCodec =
        S.int |> S.map UserId (\(UserId id) -> id)

Note that there's nothing preventing you from encoding Elm values that will map to some different value when you decode them.
I recommend writing tests for Codecs that use `map` to make sure you get back the same Elm value you put in.
[Here's some helper functions to get you started.](https://github.com/MartinSStewart/elm-geometry-serialize/blob/6f2244c28631ede1b864cb43541d1573dc628904/tests/Tests.elm#L49-L74)

-}
map : (a -> b) -> (b -> a) -> FlatCodec e a -> FlatCodec e b
map fromBytes_ toBytes_ codec =
    mapHelper
        (\value ->
            case value of
                Ok ok ->
                    fromBytes_ ok |> Ok

                Err err ->
                    Err err
        )
        toBytes_
        codec


mapHelper : (Result (Error e) a -> Result (Error e) b) -> (b -> a) -> FlatCodec e a -> FlatCodec e b
mapHelper fromBytes_ toBytes_ codec =
    let
        wrappedNodeDecoder : NodeDecoderInputs -> JD.Decoder (Result (Error e) b)
        wrappedNodeDecoder inputs =
            getNodeDecoder codec inputs |> JD.map fromBytes_

        mapNodeEncoderInputs : NodeEncoderInputs b -> NodeEncoderInputs a
        mapNodeEncoderInputs inputs =
            NodeEncoderInputs inputs.node inputs.mode (mapThingToEncode inputs.thingToEncode) inputs.parent inputs.position

        mapThingToEncode : ThingToEncode b -> ThingToEncode a
        mapThingToEncode original =
            case original of
                EncodeThis a ->
                    EncodeThis (toBytes_ a)

                EncodeObjectOrThis objectIDs fieldVal ->
                    EncodeObjectOrThis objectIDs (toBytes_ fieldVal)
    in
    buildNestableCodec
        (\v -> toBytes_ v |> getBytesEncoder codec)
        (getBytesDecoder codec |> BD.map fromBytes_)
        (\v -> toBytes_ v |> getJsonEncoder codec)
        (getJsonDecoder codec |> JD.map fromBytes_)
        ( (\inputs -> mapNodeEncoderInputs inputs |> getNodeEncoder codec))
        ( wrappedNodeDecoder)


{-| Map from one codec to another codec in a way that can potentially fail when decoding.

    -- Email module is from https://package.elm-lang.org/packages/tricycle/elm-email/1.0.2/


    import Email
    import Serialize as S

    emailCodec : S.Codec String Float
    emailCodec =
        S.string
            |> S.mapValid
                (\text ->
                    case Email.fromString text of
                        Just email ->
                            Ok email

                        Nothing ->
                            Err "Invalid email"
                )
                Email.toString

Note that there's nothing preventing you from encoding Elm values that will produce Err when you decode them.
I recommend writing tests for Codecs that use `mapValid` to make sure you get back the same Elm value you put in.
[Here's some helper functions to get you started.](https://github.com/MartinSStewart/elm-geometry-serialize/blob/6f2244c28631ede1b864cb43541d1573dc628904/tests/Tests.elm#L49-L74)

-}
mapValid : (a -> Result e b) -> (b -> a) -> FlatCodec e a -> FlatCodec e b
mapValid fromBytes_ toBytes_ codec =
    let
        wrappedNodeDecoder : NodeDecoderInputs -> JD.Decoder (Result (Error e) b)
        wrappedNodeDecoder inputs =
            getNodeDecoder codec inputs |> JD.map wrapCustomError

        mapNodeEncoderInputs : NodeEncoderInputs b -> NodeEncoderInputs a
        mapNodeEncoderInputs inputs =
            NodeEncoderInputs inputs.node inputs.mode (mapThingToEncode inputs.thingToEncode) inputs.parent inputs.position

        mapThingToEncode : ThingToEncode b -> ThingToEncode a
        mapThingToEncode original =
            case original of
                EncodeThis a ->
                    EncodeThis (toBytes_ a)

                EncodeObjectOrThis objectIDs fieldVal ->
                    EncodeObjectOrThis objectIDs (toBytes_ fieldVal)

        wrapCustomError value =
            case value of
                Ok ok ->
                    fromBytes_ ok |> Result.mapError CustomError

                Err err ->
                    Err err
    in
    buildNestableCodec
        (\v -> toBytes_ v |> getBytesEncoder codec)
        (getBytesDecoder codec
            |> BD.map wrapCustomError
        )
        (\v -> toBytes_ v |> getJsonEncoder codec)
        (getJsonDecoder codec
            |> JD.map wrapCustomError
        )
        ( (\inputs -> mapNodeEncoderInputs inputs |> getNodeEncoder codec))
        ( wrappedNodeDecoder)


{-| Map errors generated by `mapValid`.
-}
mapError : (e1 -> e2) -> FlatCodec e1 a -> FlatCodec e2 a
mapError mapFunc codec =
    let
        wrappedNodeDecoder : NodeDecoderInputs -> JD.Decoder (Result (Error e2) a)
        wrappedNodeDecoder inputs =
            getNodeDecoder codec inputs |> JD.map (mapErrorHelper mapFunc)
    in
    buildNestableCodec
        (getBytesEncoder codec)
        (getBytesDecoder codec |> BD.map (mapErrorHelper mapFunc))
        (getJsonEncoder codec)
        (getJsonDecoder codec |> JD.map (mapErrorHelper mapFunc))
        ( (getNodeEncoder codec))
        ( wrappedNodeDecoder)


mapErrorHelper : (e -> a) -> Result (Error e) b -> Result (Error a) b
mapErrorHelper mapFunc =
    Result.mapError
        (\error ->
            case error of
                CustomError custom ->
                    mapFunc custom |> CustomError

                DataCorrupted ->
                    DataCorrupted

                SerializerOutOfDate ->
                    SerializerOutOfDate

                ObjectNotFound opID ->
                    ObjectNotFound opID

                FailedToDecodeRoot reason ->
                    FailedToDecodeRoot reason

                JDError jsonDecodeError ->
                    JDError jsonDecodeError
        )



-- STACK UNSAFE


{-| Handle situations where you need to define a codec in terms of itself.

    type Peano
        = Peano (Maybe Peano)

    {-| The compiler will complain that this function causes an infinite loop.
    -}
    badPeanoCodec : Codec e Peano
    badPeanoCodec =
        maybe badPeanoCodec |> map Peano (\(Peano a) -> a)

    {-| Now the compiler is happy!
    -}
    goodPeanoCodec : Codec e Peano
    goodPeanoCodec =
        maybe (lazy (\() -> goodPeanoCodec)) |> map Peano (\(Peano a) -> a)

**Warning:** This is not stack safe.

In general if you have a type that contains itself, like with our the Peano example, then you're at risk of a stack overflow while decoding.
Even if you're translating your nested data into a list before encoding, you're at risk, because the function translating back after decoding can cause a stack overflow if the original value was nested deeply enough.
Be careful here, and test your codecs using elm-test with larger inputs than you ever expect to see in real life.

-}
lazy : (() -> Codec e s a) -> Codec e s a
lazy f =
    let
        lazyNodeDecoder : NodeDecoderInputs -> JD.Decoder (Result (Error e) a)
        lazyNodeDecoder inputs =
            JD.succeed () |> JD.andThen (\() -> getNodeDecoder (f ()) inputs)

        lazyNodeEncoder : NodeEncoder a
        lazyNodeEncoder inputs =
            getNodeEncoder (f ()) inputs
    in
    Codec
        { bytesEncoder = \value -> getBytesEncoder (f ()) value
        , bytesDecoder = BD.succeed () |> BD.andThen (\() -> getBytesDecoder (f ()))
        , jsonEncoder = \value -> getJsonEncoder (f ()) value
        , jsonDecoder = JD.succeed () |> JD.andThen (\() -> getJsonDecoder (f ()))
        , nodeEncoder =  lazyNodeEncoder
        , nodeDecoder =  lazyNodeDecoder
        , init = \inputs -> getInitializer (f ()) inputs
        }


{-| When you haven't gotten to writing a Codec for this yet.
-}
todo : a -> Codec e s a
todo bogusValue =
    Codec
        { bytesEncoder = \_ -> BE.unsignedInt8 9
        , bytesDecoder = BD.fail
        , jsonEncoder = \_ -> JE.null
        , jsonDecoder = JD.fail "TODO"
        , nodeEncoder = \_ -> Skippable <| Nonempty.singleton <| Change.RonAtom <| Op.IntegerAtom 0
        , nodeDecoder = \_ -> JD.fail "TODO"
        , init = \_ -> bogusValue
        }



-- CUSTOM


type alias VariantTag =
    ( Int, String )


{-| A partially built codec for a custom type.
-}
type CustomTypeCodec a e matcher v
    = CustomTypeCodec
        { bytesMatcher : matcher
        , jsonMatcher : matcher
        , nodeMatcher : matcher
        , bytesDecoder : Int -> BD.Decoder (Result (Error e) v) -> BD.Decoder (Result (Error e) v)
        , jsonDecoder : Int -> JD.Decoder (Result (Error e) v) -> JD.Decoder (Result (Error e) v)
        , nodeDecoder : Int -> NodeDecoder e v -> NodeDecoder e v
        , idCounter : Int
        }


{-| Starts building a `Codec` for a custom type.
You need to pass a pattern matchering function, see the FAQ for details.

    import Serialize as S

    type Semaphore
        = Red Int String Bool
        | Yellow Float
        | Green

    semaphoreCodec : Codec e Semaphore
    semaphoreCodec =
        Codec.customType
            (\redEncoder yellowEncoder greenEncoder value ->
                case value of
                    Red i s b ->
                        redEncoder i s b

                    Yellow f ->
                        yellowEncoder f

                    Green ->
                        greenEncoder
            )
            |> Codec.variant3 ( 1, "Red" ) Red S.int S.string S.bool
            |> Codec.variant1 ( 2, "Yellow" ) Yellow S.float
            |> Codec.variant0 ( 3, "Green" ) Green
            |> Codec.finishCustomType

-}
customType : matcher -> CustomTypeCodec { youNeedAtLeastOneVariant : () } e matcher value
customType matcher =
    let
        noMatchFound givenTagNum orElse =
            -- all the variantBuilder decoders have been run, but none of them matched the given tag
            orElse
    in
    CustomTypeCodec
        { bytesMatcher = matcher
        , jsonMatcher = matcher
        , nodeMatcher = matcher

        -- the
        , bytesDecoder = noMatchFound
        , jsonDecoder = noMatchFound
        , nodeDecoder = noMatchFound
        , idCounter = 0
        }


{-| -}
type VariantEncoder
    = VariantEncoder
        { bytes : BE.Encoder
        , json : JE.Value
        , node : VariantNodeEncoder
        }


{-| Normal Node encoders spit out NodeENcoderOutput, but since we need to iteratively build up a variant encoder from scratch, we modify encoders to just produce a list which can be empty. The "from scratch" actually starts with []
-}
type alias VariantNodeEncoder =
    NodeEncoderInputsNoVariable -> Change.PotentialPayload


variantBuilder :
    VariantTag
    -> ((List BE.Encoder -> VariantEncoder) -> finalWrappedValue)
    -> ((List JE.Value -> VariantEncoder) -> finalWrappedValue)
    -> ((List VariantNodeEncoder -> VariantEncoder) -> finalWrappedValue)
    -> BD.Decoder (Result (Error error) v)
    -> JD.Decoder (Result (Error error) v)
    -> NodeDecoder error v
    -> CustomTypeCodec z error (finalWrappedValue -> b) v
    -> CustomTypeCodec () error b v
variantBuilder ( tagNum, tagName ) piecesBytesEncoder piecesJsonEncoder piecesNodeEncoder piecesBytesDecoder piecesJsonDecoder piecesNodeDecoder (CustomTypeCodec priorVariants) =
    let
        -- for the input encoder functions: they're expecting to be handed one of the wrappers below, but otherwise they're just the piecewise encoders of all the variant's pieces (in one big final encoder) needing only to be wrapped (e.g. add the `Just`).
        -- for these wrapper functions: input list is individual encoders of the variant's sub-pieces. The variant's tag is prepended and the output is effectively an encoder of the entire variantBuilder at once. It then gets combined below with the other variantBuilder encoders to form the encoder of the whole custom type.
        wrapBE : List BE.Encoder -> VariantEncoder
        wrapBE variantPieces =
            VariantEncoder
                { bytes = BE.unsignedInt16 endian tagNum :: variantPieces |> BE.sequence
                , json = JE.null
                , node = \_ -> Nonempty.singleton (Change.NestedAtoms (Nonempty.singleton nodeTag))
                }

        wrapJE : List JE.Value -> VariantEncoder
        wrapJE variantPieces =
            VariantEncoder
                { bytes = BE.sequence []
                , json = JE.string (String.fromInt tagNum ++ "_" ++ tagName) :: variantPieces |> JE.list identity
                , node = \_ -> Nonempty.singleton (Change.NestedAtoms (Nonempty.singleton nodeTag))
                }

        wrapNE : List VariantNodeEncoder -> VariantEncoder
        wrapNE variantEncoders =
            let
                piecesApplied inputs =
                    List.indexedMap (applyIndexedInputs inputs) variantEncoders
                        |> List.concatMap Nonempty.toList

                applyIndexedInputs inputs index encoderFunction =
                    encoderFunction
                        { inputs | parent = Change.newPointer { parent = inputs.parent, position = Nonempty.cons (String.fromInt index ++ "." ++ tagName ++ "_" ++ String.fromInt tagNum) inputs.position, reducerID = "variant" } }
            in
            VariantEncoder
                { bytes = BE.sequence []
                , json = JE.null
                , node = \inputs -> Nonempty.singleton (Change.NestedAtoms (Nonempty nodeTag (piecesApplied inputs)))
                }

        nodeTag =
             Change.RonAtom <| Op.NakedStringAtom <| tagName ++ "_" ++ String.fromInt tagNum

        unwrapBD : Int -> BD.Decoder (Result (Error error) v) -> BD.Decoder (Result (Error error) v)
        unwrapBD tagNumToDecode orElse =
            if tagNumToDecode == tagNum then
                -- variantBuilder match! now decode the pieces
                piecesBytesDecoder

            else
                -- not this variantBuilder, pass along to other variantBuilder decoders
                priorVariants.bytesDecoder tagNumToDecode orElse

        unwrapJD : Int -> JD.Decoder (Result (Error error) v) -> JD.Decoder (Result (Error error) v)
        unwrapJD tagNumToDecode orElse =
            if tagNumToDecode == tagNum then
                -- variantBuilder match! now decode the pieces
                piecesJsonDecoder

            else
                -- not this variantBuilder, pass along to other variantBuilder decoders
                priorVariants.jsonDecoder tagNumToDecode orElse

        unwrapND : Int -> NodeDecoder error v -> NodeDecoder error v
        unwrapND tagNumToDecode orElse =
            if tagNumToDecode == tagNum then
                -- variantBuilder match! now decode the pieces
                piecesNodeDecoder

            else
                -- not this variantBuilder, pass along to other variantBuilder decoders
                priorVariants.nodeDecoder tagNumToDecode orElse
    in
    CustomTypeCodec
        { bytesMatcher = priorVariants.bytesMatcher <| piecesBytesEncoder wrapBE
        , jsonMatcher = priorVariants.jsonMatcher <| piecesJsonEncoder wrapJE
        , nodeMatcher = priorVariants.nodeMatcher <| piecesNodeEncoder wrapNE
        , bytesDecoder = unwrapBD
        , jsonDecoder = unwrapJD
        , nodeDecoder = unwrapND
        , idCounter = priorVariants.idCounter + 1
        }


{-| Define a variantBuilder with 0 parameters for a custom type.
-}
variant0 : VariantTag -> v -> CustomTypeCodec z e (VariantEncoder -> a) v -> CustomTypeCodec () e a v
variant0 tag ctor =
    variantBuilder tag
        (\wrapper -> wrapper [])
        (\wrapper -> wrapper [])
        (\wrapper -> wrapper [])
        (BD.succeed (Ok ctor))
        (JD.succeed (Ok ctor))
        (\_ -> JD.succeed (Ok ctor))


passNDInputs : Int -> NodeDecoderInputs -> NodeDecoderInputs
passNDInputs pieceNum inputsND =
    { inputsND | parent = Change.newPointer { parent = inputsND.parent, position = Nonempty.cons (String.fromInt pieceNum) inputsND.position, reducerID = "variant" } }


{-| Define a variantBuilder with 1 parameters for a custom type.
-}
variant1 :
    VariantTag
    -> (a -> v)
    -> Codec error ia a
    -> CustomTypeCodec z error ((a -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () error partial v
variant1 tag ctor codec1 =
    variantBuilder tag
        (\wrapper v ->
            wrapper
                [ getBytesEncoder codec1 v
                ]
        )
        (\wrapper v ->
            wrapper
                [ getJsonEncoder codec1 v
                ]
        )
        (\wrapper v ->
            wrapper
                [ getNodeEncoderModifiedForVariants codec1 v
                ]
        )
        (BD.map (result1 ctor) (getBytesDecoder codec1))
        (JD.map (result1 ctor) (JD.index 1 (getJsonDecoder codec1)))
        (\inputsND ->
            JD.map (result1 ctor) (JD.index 1 (getNodeDecoder codec1 (passNDInputs 1 inputsND)))
        )


result1 :
    (value -> a)
    -> Result error value
    -> Result error a
result1 ctor value =
    case value of
        Ok ok ->
            ctor ok |> Ok

        Err err ->
            Err err


{-| Define a variantBuilder with 2 parameters for a custom type.
-}
variant2 :
    VariantTag
    -> (a -> b -> v)
    -> Codec error ia a
    -> Codec error ib b
    -> CustomTypeCodec z error ((a -> b -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () error partial v
variant2 tag ctor codec1 codec2 =
    variantBuilder tag
        (\wrapper v1 v2 ->
            [ getBytesEncoder codec1 v1
            , getBytesEncoder codec2 v2
            ]
                |> wrapper
        )
        (\wrapper v1 v2 ->
            [ getJsonEncoder codec1 v1
            , getJsonEncoder codec2 v2
            ]
                |> wrapper
        )
        (\wrapper v1 v2 ->
            wrapper
                [ getNodeEncoderModifiedForVariants codec1 v1
                , getNodeEncoderModifiedForVariants codec2 v2
                ]
        )
        (BD.map2
            (result2 ctor)
            (getBytesDecoder codec1)
            (getBytesDecoder codec2)
        )
        (JD.map2
            (result2 ctor)
            (JD.index 1 (getJsonDecoder codec1))
            (JD.index 2 (getJsonDecoder codec2))
        )
        (\inputsND ->
            JD.map2
                (result2 ctor)
                (JD.index 1 (getNodeDecoder codec1 (passNDInputs 1 inputsND)))
                (JD.index 2 (getNodeDecoder codec2 (passNDInputs 2 inputsND)))
        )


result2 :
    (value -> a -> b)
    -> Result error value
    -> Result error a
    -> Result error b
result2 ctor v1 v2 =
    case ( v1, v2 ) of
        ( Ok ok1, Ok ok2 ) ->
            ctor ok1 ok2 |> Ok

        ( Err err, _ ) ->
            Err err

        ( _, Err err ) ->
            Err err


{-| Define a variantBuilder with 3 parameters for a custom type.
-}
variant3 :
    VariantTag
    -> (a -> b -> c -> v)
    -> Codec error ia a
    -> Codec error ib b
    -> Codec error ic c
    -> CustomTypeCodec z error ((a -> b -> c -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () error partial v
variant3 tag ctor codec1 codec2 codec3 =
    variantBuilder tag
        (\wrapper v1 v2 v3 ->
            [ getBytesEncoder codec1 v1
            , getBytesEncoder codec2 v2
            , getBytesEncoder codec3 v3
            ]
                |> wrapper
        )
        (\wrapper v1 v2 v3 ->
            [ getJsonEncoder codec1 v1
            , getJsonEncoder codec2 v2
            , getJsonEncoder codec3 v3
            ]
                |> wrapper
        )
        (\wrapper v1 v2 v3 ->
            wrapper
                [ getNodeEncoderModifiedForVariants codec1 v1
                , getNodeEncoderModifiedForVariants codec2 v2
                , getNodeEncoderModifiedForVariants codec3 v3
                ]
        )
        (BD.map3
            (result3 ctor)
            (getBytesDecoder codec1)
            (getBytesDecoder codec2)
            (getBytesDecoder codec3)
        )
        (JD.map3
            (result3 ctor)
            (JD.index 1 (getJsonDecoder codec1))
            (JD.index 2 (getJsonDecoder codec2))
            (JD.index 3 (getJsonDecoder codec3))
        )
        (\inputsND ->
            JD.map3
                (result3 ctor)
                (JD.index 1 (getNodeDecoder codec1 (passNDInputs 1 inputsND)))
                (JD.index 2 (getNodeDecoder codec2 (passNDInputs 2 inputsND)))
                (JD.index 3 (getNodeDecoder codec3 (passNDInputs 3 inputsND)))
        )


result3 :
    (value -> a -> b -> c)
    -> Result error value
    -> Result error a
    -> Result error b
    -> Result error c
result3 ctor v1 v2 v3 =
    case ( v1, v2, v3 ) of
        ( Ok ok1, Ok ok2, Ok ok3 ) ->
            ctor ok1 ok2 ok3 |> Ok

        ( Err err, _, _ ) ->
            Err err

        ( _, Err err, _ ) ->
            Err err

        ( _, _, Err err ) ->
            Err err


{-| Define a variantBuilder with 4 parameters for a custom type.
-}
variant4 :
    VariantTag
    -> (a -> b -> c -> d -> v)
    -> Codec error ia a
    -> Codec error ib b
    -> Codec error ic c
    -> Codec error id d
    -> CustomTypeCodec z error ((a -> b -> c -> d -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () error partial v
variant4 tag ctor codec1 codec2 codec3 codec4 =
    variantBuilder tag
        (\wrapper v1 v2 v3 v4 ->
            [ getBytesEncoder codec1 v1
            , getBytesEncoder codec2 v2
            , getBytesEncoder codec3 v3
            , getBytesEncoder codec4 v4
            ]
                |> wrapper
        )
        (\wrapper v1 v2 v3 v4 ->
            [ getJsonEncoder codec1 v1
            , getJsonEncoder codec2 v2
            , getJsonEncoder codec3 v3
            , getJsonEncoder codec4 v4
            ]
                |> wrapper
        )
        (\wrapper v1 v2 v3 v4 ->
            wrapper
                [ getNodeEncoderModifiedForVariants codec1 v1
                , getNodeEncoderModifiedForVariants codec2 v2
                , getNodeEncoderModifiedForVariants codec3 v3
                , getNodeEncoderModifiedForVariants codec4 v4
                ]
        )
        (BD.map4
            (result4 ctor)
            (getBytesDecoder codec1)
            (getBytesDecoder codec2)
            (getBytesDecoder codec3)
            (getBytesDecoder codec4)
        )
        (JD.map4
            (result4 ctor)
            (JD.index 1 (getJsonDecoder codec1))
            (JD.index 2 (getJsonDecoder codec2))
            (JD.index 3 (getJsonDecoder codec3))
            (JD.index 4 (getJsonDecoder codec4))
        )
        (\inputsND ->
            JD.map4
                (result4 ctor)
                (JD.index 1 (getNodeDecoder codec1 (passNDInputs 1 inputsND)))
                (JD.index 2 (getNodeDecoder codec2 (passNDInputs 2 inputsND)))
                (JD.index 3 (getNodeDecoder codec3 (passNDInputs 3 inputsND)))
                (JD.index 4 (getNodeDecoder codec4 (passNDInputs 4 inputsND)))
        )


result4 :
    (value -> a -> b -> c -> d)
    -> Result error value
    -> Result error a
    -> Result error b
    -> Result error c
    -> Result error d
result4 ctor v1 v2 v3 v4 =
    case T4 v1 v2 v3 v4 of
        T4 (Ok ok1) (Ok ok2) (Ok ok3) (Ok ok4) ->
            ctor ok1 ok2 ok3 ok4 |> Ok

        T4 (Err err) _ _ _ ->
            Err err

        T4 _ (Err err) _ _ ->
            Err err

        T4 _ _ (Err err) _ ->
            Err err

        T4 _ _ _ (Err err) ->
            Err err


{-| Define a variantBuilder with 5 parameters for a custom type.
-}
variant5 :
    VariantTag
    -> (a -> b -> c -> d -> e -> v)
    -> Codec error ia a
    -> Codec error ib b
    -> Codec error ic c
    -> Codec error id d
    -> Codec error ie e
    -> CustomTypeCodec z error ((a -> b -> c -> d -> e -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () error partial v
variant5 tag ctor codec1 codec2 codec3 codec4 codec5 =
    variantBuilder tag
        (\wrapper v1 v2 v3 v4 v5 ->
            [ getBytesEncoder codec1 v1
            , getBytesEncoder codec2 v2
            , getBytesEncoder codec3 v3
            , getBytesEncoder codec4 v4
            , getBytesEncoder codec5 v5
            ]
                |> wrapper
        )
        (\wrapper v1 v2 v3 v4 v5 ->
            [ getJsonEncoder codec1 v1
            , getJsonEncoder codec2 v2
            , getJsonEncoder codec3 v3
            , getJsonEncoder codec4 v4
            , getJsonEncoder codec5 v5
            ]
                |> wrapper
        )
        (\wrapper v1 v2 v3 v4 v5 ->
            wrapper
                [ getNodeEncoderModifiedForVariants codec1 v1
                , getNodeEncoderModifiedForVariants codec2 v2
                , getNodeEncoderModifiedForVariants codec3 v3
                , getNodeEncoderModifiedForVariants codec4 v4
                , getNodeEncoderModifiedForVariants codec5 v5
                ]
        )
        (BD.map5
            (result5 ctor)
            (getBytesDecoder codec1)
            (getBytesDecoder codec2)
            (getBytesDecoder codec3)
            (getBytesDecoder codec4)
            (getBytesDecoder codec5)
        )
        (JD.map5
            (result5 ctor)
            (JD.index 1 (getJsonDecoder codec1))
            (JD.index 2 (getJsonDecoder codec2))
            (JD.index 3 (getJsonDecoder codec3))
            (JD.index 4 (getJsonDecoder codec4))
            (JD.index 5 (getJsonDecoder codec5))
        )
        (\inputsND ->
            JD.map5
                (result5 ctor)
                (JD.index 1 (getNodeDecoder codec1 (passNDInputs 1 inputsND)))
                (JD.index 2 (getNodeDecoder codec2 (passNDInputs 2 inputsND)))
                (JD.index 3 (getNodeDecoder codec3 (passNDInputs 3 inputsND)))
                (JD.index 4 (getNodeDecoder codec4 (passNDInputs 4 inputsND)))
                (JD.index 5 (getNodeDecoder codec5 (passNDInputs 5 inputsND)))
        )


result5 :
    (value -> a -> b -> c -> d -> e)
    -> Result error value
    -> Result error a
    -> Result error b
    -> Result error c
    -> Result error d
    -> Result error e
result5 ctor v1 v2 v3 v4 v5 =
    case T5 v1 v2 v3 v4 v5 of
        T5 (Ok ok1) (Ok ok2) (Ok ok3) (Ok ok4) (Ok ok5) ->
            ctor ok1 ok2 ok3 ok4 ok5 |> Ok

        T5 (Err err) _ _ _ _ ->
            Err err

        T5 _ (Err err) _ _ _ ->
            Err err

        T5 _ _ (Err err) _ _ ->
            Err err

        T5 _ _ _ (Err err) _ ->
            Err err

        T5 _ _ _ _ (Err err) ->
            Err err


{-| Define a variantBuilder with 6 parameters for a custom type.
-}
variant6 :
    VariantTag
    -> (a -> b -> c -> d -> e -> f -> v)
    -> Codec error ia a
    -> Codec error ib b
    -> Codec error ic c
    -> Codec error id d
    -> Codec error ie e
    -> Codec error if_ f
    -> CustomTypeCodec z error ((a -> b -> c -> d -> e -> f -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () error partial v
variant6 tag ctor codec1 codec2 codec3 codec4 codec5 codec6 =
    variantBuilder tag
        (\wrapper v1 v2 v3 v4 v5 v6 ->
            [ getBytesEncoder codec1 v1
            , getBytesEncoder codec2 v2
            , getBytesEncoder codec3 v3
            , getBytesEncoder codec4 v4
            , getBytesEncoder codec5 v5
            , getBytesEncoder codec6 v6
            ]
                |> wrapper
        )
        (\wrapper v1 v2 v3 v4 v5 v6 ->
            [ getJsonEncoder codec1 v1
            , getJsonEncoder codec2 v2
            , getJsonEncoder codec3 v3
            , getJsonEncoder codec4 v4
            , getJsonEncoder codec5 v5
            , getJsonEncoder codec6 v6
            ]
                |> wrapper
        )
        (\wrapper v1 v2 v3 v4 v5 v6 ->
            wrapper
                [ getNodeEncoderModifiedForVariants codec1 v1
                , getNodeEncoderModifiedForVariants codec2 v2
                , getNodeEncoderModifiedForVariants codec3 v3
                , getNodeEncoderModifiedForVariants codec4 v4
                , getNodeEncoderModifiedForVariants codec5 v5
                , getNodeEncoderModifiedForVariants codec6 v6
                ]
        )
        (BD.map5
            (result6 ctor)
            (getBytesDecoder codec1)
            (getBytesDecoder codec2)
            (getBytesDecoder codec3)
            (getBytesDecoder codec4)
            (BD.map2 Tuple.pair
                (getBytesDecoder codec5)
                (getBytesDecoder codec6)
            )
        )
        (JD.map5
            (result6 ctor)
            (JD.index 1 (getJsonDecoder codec1))
            (JD.index 2 (getJsonDecoder codec2))
            (JD.index 3 (getJsonDecoder codec3))
            (JD.index 4 (getJsonDecoder codec4))
            (JD.map2 Tuple.pair
                (JD.index 5 (getJsonDecoder codec5))
                (JD.index 6 (getJsonDecoder codec6))
            )
        )
        (\inputsND ->
            JD.map5
                (result6 ctor)
                (JD.index 1 (getNodeDecoder codec1 (passNDInputs 1 inputsND)))
                (JD.index 2 (getNodeDecoder codec2 (passNDInputs 2 inputsND)))
                (JD.index 3 (getNodeDecoder codec3 (passNDInputs 3 inputsND)))
                (JD.index 4 (getNodeDecoder codec4 (passNDInputs 4 inputsND)))
                (JD.map2 Tuple.pair
                    (JD.index 5 (getNodeDecoder codec5 (passNDInputs 5 inputsND)))
                    (JD.index 6 (getNodeDecoder codec6 (passNDInputs 6 inputsND)))
                )
        )


result6 :
    (value -> a -> b -> c -> d -> e -> f)
    -> Result error value
    -> Result error a
    -> Result error b
    -> Result error c
    -> ( Result error d, Result error e )
    -> Result error f
result6 ctor v1 v2 v3 v4 ( v5, v6 ) =
    case T6 v1 v2 v3 v4 v5 v6 of
        T6 (Ok ok1) (Ok ok2) (Ok ok3) (Ok ok4) (Ok ok5) (Ok ok6) ->
            ctor ok1 ok2 ok3 ok4 ok5 ok6 |> Ok

        T6 (Err err) _ _ _ _ _ ->
            Err err

        T6 _ (Err err) _ _ _ _ ->
            Err err

        T6 _ _ (Err err) _ _ _ ->
            Err err

        T6 _ _ _ (Err err) _ _ ->
            Err err

        T6 _ _ _ _ (Err err) _ ->
            Err err

        T6 _ _ _ _ _ (Err err) ->
            Err err


{-| Define a variantBuilder with 7 parameters for a custom type.
-}
variant7 :
    VariantTag
    -> (a -> b -> c -> d -> e -> f -> g -> v)
    -> Codec error ia a
    -> Codec error ib b
    -> Codec error ic c
    -> Codec error id d
    -> Codec error ie e
    -> Codec error if_ f
    -> Codec error ig g
    -> CustomTypeCodec z error ((a -> b -> c -> d -> e -> f -> g -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () error partial v
variant7 tag ctor codec1 codec2 codec3 codec4 codec5 codec6 codec7 =
    variantBuilder tag
        (\wrapper v1 v2 v3 v4 v5 v6 v7 ->
            [ getBytesEncoder codec1 v1
            , getBytesEncoder codec2 v2
            , getBytesEncoder codec3 v3
            , getBytesEncoder codec4 v4
            , getBytesEncoder codec5 v5
            , getBytesEncoder codec6 v6
            , getBytesEncoder codec7 v7
            ]
                |> wrapper
        )
        (\wrapper v1 v2 v3 v4 v5 v6 v7 ->
            [ getJsonEncoder codec1 v1
            , getJsonEncoder codec2 v2
            , getJsonEncoder codec3 v3
            , getJsonEncoder codec4 v4
            , getJsonEncoder codec5 v5
            , getJsonEncoder codec6 v6
            , getJsonEncoder codec7 v7
            ]
                |> wrapper
        )
        (\wrapper v1 v2 v3 v4 v5 v6 v7 ->
            wrapper
                [ getNodeEncoderModifiedForVariants codec1 v1
                , getNodeEncoderModifiedForVariants codec2 v2
                , getNodeEncoderModifiedForVariants codec3 v3
                , getNodeEncoderModifiedForVariants codec4 v4
                , getNodeEncoderModifiedForVariants codec5 v5
                , getNodeEncoderModifiedForVariants codec6 v6
                , getNodeEncoderModifiedForVariants codec7 v7
                ]
        )
        (BD.map5
            (result7 ctor)
            (getBytesDecoder codec1)
            (getBytesDecoder codec2)
            (getBytesDecoder codec3)
            (BD.map2 Tuple.pair
                (getBytesDecoder codec4)
                (getBytesDecoder codec5)
            )
            (BD.map2 Tuple.pair
                (getBytesDecoder codec6)
                (getBytesDecoder codec7)
            )
        )
        (JD.map5
            (result7 ctor)
            (JD.index 1 (getJsonDecoder codec1))
            (JD.index 2 (getJsonDecoder codec2))
            (JD.index 3 (getJsonDecoder codec3))
            (JD.map2 Tuple.pair
                (JD.index 4 (getJsonDecoder codec4))
                (JD.index 5 (getJsonDecoder codec5))
            )
            (JD.map2 Tuple.pair
                (JD.index 6 (getJsonDecoder codec6))
                (JD.index 7 (getJsonDecoder codec7))
            )
        )
        (\inputsND ->
            JD.map5
                (result7 ctor)
                (JD.index 1 (getNodeDecoder codec1 (passNDInputs 1 inputsND)))
                (JD.index 2 (getNodeDecoder codec2 (passNDInputs 2 inputsND)))
                (JD.index 3 (getNodeDecoder codec3 (passNDInputs 3 inputsND)))
                (JD.map2 Tuple.pair
                    (JD.index 4 (getNodeDecoder codec4 (passNDInputs 4 inputsND)))
                    (JD.index 5 (getNodeDecoder codec5 (passNDInputs 5 inputsND)))
                )
                (JD.map2 Tuple.pair
                    (JD.index 6 (getNodeDecoder codec6 (passNDInputs 6 inputsND)))
                    (JD.index 7 (getNodeDecoder codec7 (passNDInputs 7 inputsND)))
                )
        )


result7 :
    (value -> a -> b -> c -> d -> e -> f -> g)
    -> Result error value
    -> Result error a
    -> Result error b
    -> ( Result error c, Result error d )
    -> ( Result error e, Result error f )
    -> Result error g
result7 ctor v1 v2 v3 ( v4, v5 ) ( v6, v7 ) =
    case T7 v1 v2 v3 v4 v5 v6 v7 of
        T7 (Ok ok1) (Ok ok2) (Ok ok3) (Ok ok4) (Ok ok5) (Ok ok6) (Ok ok7) ->
            ctor ok1 ok2 ok3 ok4 ok5 ok6 ok7 |> Ok

        T7 (Err err) _ _ _ _ _ _ ->
            Err err

        T7 _ (Err err) _ _ _ _ _ ->
            Err err

        T7 _ _ (Err err) _ _ _ _ ->
            Err err

        T7 _ _ _ (Err err) _ _ _ ->
            Err err

        T7 _ _ _ _ (Err err) _ _ ->
            Err err

        T7 _ _ _ _ _ (Err err) _ ->
            Err err

        T7 _ _ _ _ _ _ (Err err) ->
            Err err


{-| Define a variantBuilder with 8 parameters for a custom type.
-}
variant8 :
    VariantTag
    -> (a -> b -> c -> d -> e -> f -> g -> h -> v)
    -> Codec error ia a
    -> Codec error ib b
    -> Codec error ic c
    -> Codec error id d
    -> Codec error ie e
    -> Codec error if_ f
    -> Codec error ig g
    -> Codec error ih h
    -> CustomTypeCodec z error ((a -> b -> c -> d -> e -> f -> g -> h -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () error partial v
variant8 tag ctor codec1 codec2 codec3 codec4 codec5 codec6 codec7 codec8 =
    variantBuilder tag
        (\wrapper v1 v2 v3 v4 v5 v6 v7 v8 ->
            [ getBytesEncoder codec1 v1
            , getBytesEncoder codec2 v2
            , getBytesEncoder codec3 v3
            , getBytesEncoder codec4 v4
            , getBytesEncoder codec5 v5
            , getBytesEncoder codec6 v6
            , getBytesEncoder codec7 v7
            , getBytesEncoder codec8 v8
            ]
                |> wrapper
        )
        (\wrapper v1 v2 v3 v4 v5 v6 v7 v8 ->
            [ getJsonEncoder codec1 v1
            , getJsonEncoder codec2 v2
            , getJsonEncoder codec3 v3
            , getJsonEncoder codec4 v4
            , getJsonEncoder codec5 v5
            , getJsonEncoder codec6 v6
            , getJsonEncoder codec7 v7
            , getJsonEncoder codec8 v8
            ]
                |> wrapper
        )
        (\wrapper v1 v2 v3 v4 v5 v6 v7 v8 ->
            wrapper
                [ getNodeEncoderModifiedForVariants codec1 v1
                , getNodeEncoderModifiedForVariants codec2 v2
                , getNodeEncoderModifiedForVariants codec3 v3
                , getNodeEncoderModifiedForVariants codec4 v4
                , getNodeEncoderModifiedForVariants codec5 v5
                , getNodeEncoderModifiedForVariants codec6 v6
                , getNodeEncoderModifiedForVariants codec7 v7
                , getNodeEncoderModifiedForVariants codec8 v8
                ]
        )
        (BD.map5
            (result8 ctor)
            (getBytesDecoder codec1)
            (getBytesDecoder codec2)
            (BD.map2 Tuple.pair
                (getBytesDecoder codec3)
                (getBytesDecoder codec4)
            )
            (BD.map2 Tuple.pair
                (getBytesDecoder codec5)
                (getBytesDecoder codec6)
            )
            (BD.map2 Tuple.pair
                (getBytesDecoder codec7)
                (getBytesDecoder codec8)
            )
        )
        (JD.map5
            (result8 ctor)
            (JD.index 1 (getJsonDecoder codec1))
            (JD.index 2 (getJsonDecoder codec2))
            (JD.map2 Tuple.pair
                (JD.index 3 (getJsonDecoder codec3))
                (JD.index 4 (getJsonDecoder codec4))
            )
            (JD.map2 Tuple.pair
                (JD.index 5 (getJsonDecoder codec5))
                (JD.index 6 (getJsonDecoder codec6))
            )
            (JD.map2 Tuple.pair
                (JD.index 7 (getJsonDecoder codec7))
                (JD.index 8 (getJsonDecoder codec8))
            )
        )
        (\inputsND ->
            JD.map5
                (result8 ctor)
                (JD.index 1 (getNodeDecoder codec1 (passNDInputs 1 inputsND)))
                (JD.index 2 (getNodeDecoder codec2 (passNDInputs 2 inputsND)))
                (JD.map2 Tuple.pair
                    (JD.index 3 (getNodeDecoder codec3 (passNDInputs 3 inputsND)))
                    (JD.index 4 (getNodeDecoder codec4 (passNDInputs 4 inputsND)))
                )
                (JD.map2 Tuple.pair
                    (JD.index 5 (getNodeDecoder codec5 (passNDInputs 5 inputsND)))
                    (JD.index 6 (getNodeDecoder codec6 (passNDInputs 6 inputsND)))
                )
                (JD.map2 Tuple.pair
                    (JD.index 7 (getNodeDecoder codec7 (passNDInputs 7 inputsND)))
                    (JD.index 8 (getNodeDecoder codec8 (passNDInputs 8 inputsND)))
                )
        )


result8 :
    (value -> a -> b -> c -> d -> e -> f -> g -> h)
    -> Result error value
    -> Result error a
    -> ( Result error b, Result error c )
    -> ( Result error d, Result error e )
    -> ( Result error f, Result error g )
    -> Result error h
result8 ctor v1 v2 ( v3, v4 ) ( v5, v6 ) ( v7, v8 ) =
    case T8 v1 v2 v3 v4 v5 v6 v7 v8 of
        T8 (Ok ok1) (Ok ok2) (Ok ok3) (Ok ok4) (Ok ok5) (Ok ok6) (Ok ok7) (Ok ok8) ->
            ctor ok1 ok2 ok3 ok4 ok5 ok6 ok7 ok8 |> Ok

        T8 (Err err) _ _ _ _ _ _ _ ->
            Err err

        T8 _ (Err err) _ _ _ _ _ _ ->
            Err err

        T8 _ _ (Err err) _ _ _ _ _ ->
            Err err

        T8 _ _ _ (Err err) _ _ _ _ ->
            Err err

        T8 _ _ _ _ (Err err) _ _ _ ->
            Err err

        T8 _ _ _ _ _ (Err err) _ _ ->
            Err err

        T8 _ _ _ _ _ _ (Err err) _ ->
            Err err

        T8 _ _ _ _ _ _ _ (Err err) ->
            Err err


{-| Finish creating a codec for a custom type.
-}
finishCustomType : CustomTypeCodec () e (a -> VariantEncoder) a -> Codec e a a
finishCustomType (CustomTypeCodec priorVariants) =
    let
        nodeEncoder : NodeEncoder a
        nodeEncoder nodeEncoderInputs =
            let
                newInputs : NodeEncoderInputsNoVariable
                newInputs =
                    { node = nodeEncoderInputs.node
                    , mode = nodeEncoderInputs.mode
                    , position = nodeEncoderInputs.position
                    , parent = nodeEncoderInputs.parent
                    }

                nodeMatcher : VariantEncoder
                nodeMatcher =
                    priorVariants.nodeMatcher (getEncodedPrimitive nodeEncoderInputs.thingToEncode)

                getNodeVariantEncoder (VariantEncoder encoders) =
                    encoders.node newInputs
            in
            -- Variants must necessarily be encoded
            Necessary <| getNodeVariantEncoder nodeMatcher

        nodeDecoder : NodeDecoder e a
        nodeDecoder inputs =
            let
                getTagNum tag =
                    String.split "_" tag
                        |> List.Extra.last
                        |> Maybe.andThen String.toInt
                        |> Maybe.withDefault -1

                checkTag tag =
                    priorVariants.nodeDecoder (getTagNum tag) (\_ -> JD.succeed (Err DataCorrupted)) inputs
            in
            -- allow non-array input for variant0s
            JD.oneOf [ JD.index 0 JD.string |> JD.andThen checkTag, JD.string |> JD.andThen checkTag ]
    in
    buildNestableCodec
        (priorVariants.bytesMatcher >> (\(VariantEncoder encoders) -> encoders.bytes))
        (BD.unsignedInt16 endian
            |> BD.andThen
                (\tag ->
                    priorVariants.bytesDecoder tag (BD.succeed (Err DataCorrupted))
                )
        )
        (priorVariants.jsonMatcher >> (\(VariantEncoder encoders) -> encoders.json))
        (JD.index 0 JD.int
            |> JD.andThen
                (\tag ->
                    priorVariants.jsonDecoder tag (JD.succeed (Err DataCorrupted))
                )
        )
        ( nodeEncoder)
        ( nodeDecoder)


{-| Specifically for variant encoders, we must
a) strip out the type variable from NodeEncoderInputs
b) return a normal list of change atoms so we can use normal list functions to build up the variant encoder's output.

Hence, inputs are modified to NodeEncoderInputsNoVariable and outputs are just List Change.Atom.
The input type variable is taken care of early on, and the output type is converted to NodeENcoderOutput in the last mile.

-}
getNodeEncoderModifiedForVariants : Codec e ia a -> a -> VariantNodeEncoder
getNodeEncoderModifiedForVariants codec thingToEncode =
    let
        finishInputs : NodeEncoderInputsNoVariable -> NodeEncoderInputs a
        finishInputs modifiedEncoder =
            { node = modifiedEncoder.node
            , mode = modifiedEncoder.mode
            , thingToEncode = EncodeThis thingToEncode
            , position = modifiedEncoder.position
            , parent = modifiedEncoder.parent
            }
    in
    -- Skippable or not, we have to have something to wrap
    \altInputs -> Change.unwrapSkippability <| getNodeEncoder codec (finishInputs altInputs)
