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

@docs maybe, immutableList, array, dict, set, tuple, triple, result, enum


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
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Maybe.Extra
import Regex exposing (Regex)
import Replicated.Change as Change exposing (Change(..), Pointer(..), changeToChangePayload)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Object as Object exposing (Object)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.OpID as OpID exposing (InCounter, ObjectID, OpID, OutCounter)
import Replicated.Reducer.Register as Register exposing (RW, Register(..))
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Set exposing (Set)
import Toop exposing (T4(..), T5(..), T6(..), T7(..), T8(..))



-- CODEC DEFINITIONS


{-| Like a normal codec, but can have references instead of values, so must be passed the entire Replica so that some decoders may search elsewhere.
-}
type Codec e a
    = Codec
        { bytesEncoder : a -> BE.Encoder
        , bytesDecoder : BD.Decoder (Result (Error e) a)
        , jsonEncoder : a -> JE.Value
        , jsonDecoder : JD.Decoder (Result (Error e) a)
        , nodeEncoder : Maybe (NodeEncoder a)
        , nodeDecoder : Maybe (NodeDecoder e a)
        }



-- RON DEFINITIONS


type alias NodeEncoderInputs a =
    { node : Node
    , mode : ChangesToGenerate
    , thingToEncode : ThingToEncode a
    , pendingCounter : Change.PendingCounter
    , parentNotifier : Change -> Change
    }


type ThingToEncode a
    = EncodeThisFlat a
    | EncodeRegisterFieldLookupInstead Register
    | JustEncodeDefaultsIfNeeded


type alias NodeEncoderInputsNoVariable =
    { node : Node
    , mode : ChangesToGenerate
    , pendingCounter : Change.PendingCounter
    , parentNotifier : Change -> Change
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
    NodeEncoderInputs a -> Change.PotentialPayload


type alias NodeDecoder e a =
    -- For now we just reuse Json Decoders
    NodeDecoderInputs -> JD.Decoder (Result (Error e) a)


type alias NodeDecoderInputs =
    { node : Node
    , pendingCounter : Change.PendingCounter
    , parentNotifier : Change -> Change
    }


type alias RegisterFieldEncoder =
    RegisterFieldEncoderInputs -> RegisterFieldEncoderOutput


{-| Inputs to a node Field decoder.

Why is Register a Maybe?
First launch ever, Register would not exist, can't create it during decode phase either. Yet we need the record to be filled, which is why we have field defaults. It would be created as soon as the first field is set to a non-default value.

-}
type alias RegisterFieldEncoderInputs =
    { node : Node
    , registerMaybe : Maybe Register
    , mode : ChangesToGenerate
    , updateRegisterAfterChildInit : Change.PotentialPayload -> Change
    , pendingCounter : Change.PendingCounter
    }


type alias RegisterFieldDecoder e a =
    -- For now we just reuse Json Decoders
    RegisterFieldDecoderInputs -> JD.Decoder (Result (Error e) a)


type alias RegisterFieldDecoderInputs =
    { node : Node
    , pendingCounter : Change.PendingCounter
    , parent : FieldParent
    , parentNotifier : Change -> Change
    }


type FieldParent
    = ExistingRegister Register.Register
    | PendingRegister Change.PendingID


type alias SmartJsonFieldEncoder full =
    ( String, full -> JE.Value )



-- ERROR HANDLING


{-| Possible errors that can occur when decoding.

  - `CustomError` - An error caused by `andThen` returning an Err value.
  - `DataCorrupted` - This most likely will occur if you make breaking changes to your codec and try to decode old data\*. Have a look at `How do I change my codecs and still be able to decode old data?` in the readme for how to avoid introducing breaking changes.
  - `SerializerOutOfDate` - When encoding, this package will include a version number. This makes it possible for me to make improvements to how data gets encoded without introducing breaking changes to your codecs. This error then, says that you're trying to decode data encoded with a newer version of elm-serialize.

\*It's possible for corrupted data to still succeed in decoding (but with nonsense Elm values).
This is because internally we're just encoding Elm values and not storing any kind of structural information.
So if you encoded an Int and then a Float, and then tried decoding it as a Float and then an Int, there's no way for the decoder to know it read the data in the wrong order.

-}
type Error e
    = CustomError e
    | DataCorrupted
    | SerializerOutOfDate
    | ObjectNotFound OpID
    | FailedToDecodeRoot String


version : Int
version =
    1



-- DECODE


{-| Pass in the codec for the root object.
-}
decodeFromNode : Codec e profile -> Node -> Result (Error e) profile
decodeFromNode profileCodec node =
    let
        -- oldDecoder =
        --     JD.index 0 JD.int
        --         |> JD.andThen
        --             (\value ->
        --                 if value <= 0 then
        --                     Err DataCorrupted |> JD.succeed
        --
        --                 else if value == version then
        --                     JD.index 1 (getJsonDecoder profileCodec)
        --
        --                 else
        --                     Err SerializerOutOfDate |> JD.succeed
        --             )
        rootEncoded =
            node.root
                -- TODO we need to get rid of those quotes, but JD.string expects them for now
                |> Maybe.map (\i -> "[\"" ++ OpID.toString i ++ "\"]")
                |> Maybe.withDefault "\"[]\""
    in
    case getNodeDecoder profileCodec of
        nodeDecoder ->
            case JD.decodeString (nodeDecoder { node = node, pendingCounter = Change.firstPendingCounter, parentNotifier = identity }) (prepDecoder rootEncoded) of
                Ok value ->
                    value

                Err jdError ->
                    Err (FailedToDecodeRoot <| JD.errorToString jdError)


endian : Bytes.Endianness
endian =
    Bytes.BE


{-| Extracts the `Decoder` contained inside the `Codec`.
-}
getBytesDecoder : Codec e a -> BD.Decoder (Result (Error e) a)
getBytesDecoder (Codec m) =
    m.bytesDecoder


{-| Extracts the json `Decoder` contained inside the `Codec`.
-}
getJsonDecoder : Codec e a -> JD.Decoder (Result (Error e) a)
getJsonDecoder (Codec m) =
    m.jsonDecoder


{-| Extracts the ron decoder contained inside the `Codec`.
-}
getNodeDecoder : Codec e a -> NodeDecoder e a
getNodeDecoder (Codec m) =
    let
        -- TODO this is only because we still sometimes wrap values in double quotes
        unwrapString : String -> JD.Decoder (Result (Error e) a)
        unwrapString givenJson =
            case JD.decodeString m.jsonDecoder givenJson of
                Ok good ->
                    JD.succeed good

                Err bad ->
                    JD.fail "nope"

        --JD.succeed (Err DataCorrupted)
    in
    case m.nodeDecoder of
        Nothing ->
            -- formerly JD.oneOf [ m.jsonDecoder, JD.string |> JD.andThen unwrapString ]
            \_ -> m.jsonDecoder

        Just nodeDecoder ->
            nodeDecoder


{-| Run a `Codec` to turn a sequence of bytes into an Elm value.
-}
decodeFromBytes : Codec e a -> Bytes.Bytes -> Result (Error e) a
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
decodeFromURLSafeByteString : Codec e a -> String -> Result (Error e) a
decodeFromURLSafeByteString codec base64 =
    case decodeStringToBytes base64 of
        Just bytes_ ->
            decodeFromBytes codec bytes_

        Nothing ->
            Err DataCorrupted


{-| Run a `Codec` to turn a json value encoded with `encodeToJson` into an Elm value.
-}
decodeFromJson : Codec e a -> JE.Value -> Result (Error e) a
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
getBytesEncoder : Codec e a -> a -> BE.Encoder
getBytesEncoder (Codec m) =
    m.bytesEncoder


{-| Extracts the replica encoding function contained inside the `Codec`.
-}
getNodeEncoder : Codec e a -> NodeEncoder a
getNodeEncoder (Codec m) inputs =
    case m.nodeEncoder of
        Just nativeRonEncoder ->
            nativeRonEncoder inputs

        Nothing ->
            case inputs.thingToEncode of
                EncodeThisFlat thing ->
                    List.singleton <| Change.JsonValueAtom <| m.jsonEncoder thing

                JustEncodeDefaultsIfNeeded ->
                    -- no need to encode defaults for primitive encoders
                    []

                EncodeRegisterFieldLookupInstead _ ->
                    Debug.todo "getNodeEncoder: wanted me to encode a register, but this codec has no node encoder?"


{-| Extracts the json encoding function contained inside the `Codec`.
-}
getJsonEncoder : Codec e a -> a -> JE.Value
getJsonEncoder (Codec m) =
    m.jsonEncoder


{-| Convert an Elm value into a sequence of bytes.
-}
encodeToBytes : Codec e a -> a -> Bytes.Bytes
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
encodeToURLSafeByteString : Codec e a -> a -> String
encodeToURLSafeByteString codec =
    encodeToBytes codec >> replaceBase64Chars


{-| Gives you the raw string, for debugging
-}
encodeToJsonString : Codec e a -> a -> String
encodeToJsonString codec value =
    JE.encode 0 (getJsonEncoder codec value)


{-| Convert an Elm value into json data.
-}
encodeToJson : Codec e a -> a -> JE.Value
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


{-| Get values from the Node into a Change.
Pass the codec of the root object.
-}
encodeNodeToChanges : Node -> Codec e profile -> Change.PotentialPayload
encodeNodeToChanges node profileCodec =
    let
        thingToEncode =
            case Maybe.map (Register.build node) <| Node.getObjectIfExists node <| List.filterMap identity [ node.root ] of
                Just foundRootObject ->
                    EncodeRegisterFieldLookupInstead foundRootObject

                Nothing ->
                    JustEncodeDefaultsIfNeeded
    in
    getNodeEncoder profileCodec
        { node = node
        , mode = defaultEncodeMode
        , thingToEncode = thingToEncode
        , parentNotifier = identity
        , pendingCounter = Change.firstPendingCounter
        }


{-| Generates naked Changes from a Codec's default values.
-}
encodeDefaults : Codec e a -> Change
encodeDefaults rootCodec =
    let
        ronPayload =
            getNodeEncoder rootCodec
                { node = Node.testNode
                , mode = { defaultEncodeMode | setDefaultsExplicitly = True }
                , thingToEncode = JustEncodeDefaultsIfNeeded
                , parentNotifier = identity
                , pendingCounter = Change.firstPendingCounter
                }

        bogusChange =
            Change.Chunk { target = Change.PlaceholderPointer "dummy" (Change.usePendingCounter 0 Change.firstPendingCounter).id identity, objectChanges = [] }
    in
    case ronPayload of
        [ Change.QuoteNestedObject change ] ->
            change

        _ ->
            bogusChange



-- BASE


buildUnnestableCodec :
    (a -> BE.Encoder)
    -> BD.Decoder (Result (Error e) a)
    -> (a -> JE.Value)
    -> JD.Decoder (Result (Error e) a)
    -> Codec e a
buildUnnestableCodec encoder_ decoder_ jsonEncoder jsonDecoder =
    Codec
        { bytesEncoder = encoder_
        , bytesDecoder = decoder_
        , jsonEncoder = jsonEncoder
        , jsonDecoder = jsonDecoder
        , nodeEncoder = Nothing
        , nodeDecoder = Nothing
        }


buildNestableCodec :
    (a -> BE.Encoder)
    -> BD.Decoder (Result (Error e) a)
    -> (a -> JE.Value)
    -> JD.Decoder (Result (Error e) a)
    -> Maybe (NodeEncoder a)
    -> Maybe (NodeDecoder e a)
    -> Codec e a
buildNestableCodec encoder_ decoder_ jsonEncoder jsonDecoder ronEncoderMaybe ronDecoderMaybe =
    Codec
        { bytesEncoder = encoder_
        , bytesDecoder = decoder_
        , jsonEncoder = jsonEncoder
        , jsonDecoder = jsonDecoder
        , nodeEncoder = ronEncoderMaybe
        , nodeDecoder = ronDecoderMaybe
        }


{-| Codec for serializing a `String`
-}
string : Codec e String
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
            Just <|
                \inputs ->
                    case inputs.thingToEncode of
                        EncodeThisFlat stringToEncode ->
                            -- TODO eliminate quotes and decode without them
                            List.singleton <| Change.RonAtom <| Op.StringAtom stringToEncode

                        _ ->
                            Log.crashInDev "tried to node-encode with string encoder but not passed a flat string value" []
        , nodeDecoder = Nothing
        }


{-| Codec for serializing a `Bool`
-}
bool : Codec e Bool
bool =
    let
        boolNodeEncoder : NodeEncoder Bool
        boolNodeEncoder { thingToEncode } =
            case thingToEncode of
                EncodeThisFlat True ->
                    [ Change.RonAtom <| Op.NakedStringAtom "true" ]

                EncodeThisFlat False ->
                    [ Change.RonAtom <| Op.NakedStringAtom "false" ]

                EncodeRegisterFieldLookupInstead register ->
                    []

                JustEncodeDefaultsIfNeeded ->
                    []

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
        (Just boolNodeEncoder)
        (Just boolNodeDecoder)


{-| Codec for serializing an `Int`
-}
int : Codec e Int
int =
    let
        intNodeEncoder : NodeEncoder Int
        intNodeEncoder { thingToEncode } =
            case thingToEncode of
                EncodeThisFlat givenInt ->
                    [ Change.RonAtom <| Op.IntegerAtom givenInt ]

                EncodeRegisterFieldLookupInstead register ->
                    []

                JustEncodeDefaultsIfNeeded ->
                    []
    in
    buildNestableCodec
        (toFloat >> BE.float64 endian)
        (BD.float64 endian |> BD.map (round >> Ok))
        JE.int
        (JD.int |> JD.map Ok)
        (Just intNodeEncoder)
        Nothing


{-| Codec for serializing a `Float`
-}
float : Codec e Float
float =
    buildUnnestableCodec
        (BE.float64 endian)
        (BD.float64 endian |> BD.map Ok)
        JE.float
        (JD.float |> JD.map Ok)


{-| Codec for serializing a `Char`
-}
char : Codec e Char
char =
    let
        charEncode text =
            BE.sequence
                [ BE.unsignedInt32 endian (String.length text)
                , BE.string text
                ]
    in
    buildUnnestableCodec
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



-- DATA STRUCTURES


{-| Codec for serializing a `Maybe`

import Serialize as S

maybeIntCodec : S.Codec e (Maybe Int)
maybeIntCodec =
S.maybe S.int

-}
maybe : Codec e a -> Codec e (Maybe a)
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
repList : Codec e memberType -> Codec e (RepList memberType)
repList memberCodec =
    let
        normalJsonDecoder =
            JD.fail "no replist"

        jsonEncoder : RepList memberType -> JE.Value
        jsonEncoder input =
            JE.list (getJsonEncoder memberCodec) (RepList.list input)

        bytesEncoder : RepList memberType -> BE.Encoder
        bytesEncoder input =
            listEncode (getBytesEncoder memberCodec) (RepList.list input)

        memberRonEncoder : Node -> Maybe ChangesToGenerate -> Change.ParentNotifier -> memberType -> Change.PotentialPayload
        memberRonEncoder node encodeModeMaybe parentNotifier newValue =
            getNodeEncoder memberCodec
                { mode = Maybe.withDefault defaultEncodeMode encodeModeMaybe
                , node = node
                , thingToEncode = EncodeThisFlat newValue
                , parentNotifier = parentNotifier
                , pendingCounter = Change.unmatchableCounter
                }

        memberChanger node encodeModeMaybe parentNotifier newMemberValue newRefMaybe =
            case newRefMaybe of
                Just givenRef ->
                    Change.NewPayloadWithRef { payload = memberRonEncoder node encodeModeMaybe parentNotifier newMemberValue, ref = givenRef }

                Nothing ->
                    Change.NewPayload (memberRonEncoder node encodeModeMaybe parentNotifier newMemberValue)

        memberRonDecoder : Node -> Change.PendingCounter -> JE.Value -> Maybe memberType
        memberRonDecoder node childPendingCounter encodedMember =
            case JD.decodeValue (getNodeDecoder memberCodec { node = node, pendingCounter = childPendingCounter, parentNotifier = identity }) encodedMember of
                Ok (Ok member) ->
                    Just member

                _ ->
                    Nothing

        repListRonDecoder : NodeDecoder e (RepList memberType)
        repListRonDecoder ({ node, pendingCounter, parentNotifier } as details) =
            let
                pending =
                    Change.usePendingCounter 0 pendingCounter

                target foundObjects =
                    case Node.getObjectIfExists node foundObjects of
                        Just objectFound ->
                            Change.ExistingObjectPointer objectFound.creation

                        Nothing ->
                            Change.PlaceholderPointer RepList.reducerID pending.id parentNotifier

                foundOrGeneratedRepList foundObjects =
                    Ok <| RepList.buildFromReplicaDb node (target foundObjects) (memberRonDecoder node pending.passToChild) (memberChanger node Nothing parentNotifier)
            in
            JD.map foundOrGeneratedRepList concurrentObjectIDsDecoder

        repListRonEncoder : NodeEncoder (RepList memberType)
        repListRonEncoder ({ node, thingToEncode, mode, parentNotifier, pendingCounter } as details) =
            case thingToEncode of
                EncodeThisFlat existingRepList ->
                    changeToChangePayload <|
                        Chunk
                            { target = RepList.getID existingRepList
                            , objectChanges = [] -- TODO should this be blank
                            }

                _ ->
                    changeToChangePayload <|
                        Chunk
                            { target = Change.PlaceholderPointer RepList.reducerID (Change.usePendingCounter 0 pendingCounter).id identity
                            , objectChanges = []
                            }
    in
    Codec
        { bytesEncoder = bytesEncoder
        , bytesDecoder =
            BD.fail
        , jsonEncoder = jsonEncoder
        , jsonDecoder = normalJsonDecoder
        , nodeEncoder = Just repListRonEncoder
        , nodeDecoder = Just repListRonDecoder
        }


{-| A list
-}
immutableList : Codec e a -> Codec e (List a)
immutableList codec =
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
    in
    Codec
        { bytesEncoder = listEncode (getBytesEncoder codec)
        , bytesDecoder =
            BD.unsignedInt32 endian
                |> BD.andThen
                    (\length -> BD.loop ( length, [] ) (listStep (getBytesDecoder codec)))
        , jsonEncoder = JE.list (getJsonEncoder codec)
        , jsonDecoder = normalJsonDecoder
        , nodeEncoder = Nothing
        , nodeDecoder = Nothing
        }


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
array : Codec e a -> Codec e (Array a)
array codec =
    immutableList codec |> mapHelper (Result.map Array.fromList) Array.toList


{-| Codec for serializing a `Dict`

    import Serialize as S

    type alias Name =
        String

    peoplesAgeCodec : S.Codec e (Dict Name Int)
    peoplesAgeCodec =
        S.dict S.string S.int

-}
dict : Codec e comparable -> Codec e a -> Codec e (Dict comparable a)
dict keyCodec valueCodec =
    immutableList (tuple keyCodec valueCodec)
        |> mapHelper (Result.map Dict.fromList) Dict.toList


{-| Codec for serializing a `Set`
-}
set : Codec e comparable -> Codec e (Set comparable)
set codec =
    immutableList codec |> mapHelper (Result.map Set.fromList) Set.toList


{-| Codec for serializing `()` (aka `Unit`).
-}
unit : Codec e ()
unit =
    buildUnnestableCodec
        (always (BE.sequence []))
        (BD.succeed (Ok ()))
        (\_ -> JE.int 0)
        (JD.succeed (Ok ()))


{-| Codec for serializing a tuple with 2 elements

    import Serialize as S

    pointCodec : S.Codec e ( Float, Float )
    pointCodec =
        S.tuple S.float S.float

-}
tuple : Codec e a -> Codec e b -> Codec e ( a, b )
tuple codecFirst codecSecond =
    fragileRecord Tuple.pair
        |> fixedField Tuple.first codecFirst
        |> fixedField Tuple.second codecSecond
        |> finishFragileRecord


{-| Codec for serializing a tuple with 3 elements

    import Serialize as S

    pointCodec : S.Codec e ( Float, Float, Float )
    pointCodec =
        S.tuple S.float S.float S.float

-}
triple : Codec e a -> Codec e b -> Codec e c -> Codec e ( a, b, c )
triple codecFirst codecSecond codecThird =
    fragileRecord (\a b c -> ( a, b, c ))
        |> fixedField (\( a, _, _ ) -> a) codecFirst
        |> fixedField (\( _, b, _ ) -> b) codecSecond
        |> fixedField (\( _, _, c ) -> c) codecThird
        |> finishFragileRecord


{-| Codec for serializing a `Result`
-}
result : Codec e error -> Codec e value -> Codec e (Result error value)
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
bytes : Codec e Bytes.Bytes
bytes =
    buildUnnestableCodec
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
byte : Codec e Int
byte =
    buildUnnestableCodec
        BE.unsignedInt8
        (BD.unsignedInt8 |> BD.map Ok)
        (modBy 256 >> JE.int)
        (JD.int |> JD.map Ok)


{-| A codec for serializing an item from a list of possible items.
If you try to encode an item that isn't in the list then the first item is defaulted to.

    import Serialize as S

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
        S.enum Monday [ Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday ]

Note that inserting new items in the middle of the list or removing items is a breaking change.
It's safe to add items to the end of the list though.

-}
fragileEnum : a -> List a -> Codec e a
fragileEnum defaultItem items =
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
            case thingToEncode of
                EncodeThisFlat givenInt ->
                    [ Change.RonAtom <| Op.IntegerAtom (getIndex givenInt) ]

                _ ->
                    []
    in
    buildNestableCodec
        (getIndex >> BE.unsignedInt32 endian)
        (BD.unsignedInt32 endian |> BD.map getItem)
        (getIndex >> JE.int)
        (JD.int |> JD.map getItem)
        (Just intNodeEncoder)
        Nothing


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


{-| A partially built Codec for a record.
-}
type FragileRecordCodec e a b
    = FragileRecordCodec
        { bytesEncoder : a -> List BE.Encoder
        , bytesDecoder : BD.Decoder (Result (Error e) b)
        , jsonEncoder : a -> List JE.Value
        , jsonDecoder : JD.Decoder (Result (Error e) b)
        , fieldIndex : Int
        }


{-| Start creating an un-reorderable codec for a record.

    import Serialize as S

    type alias Point =
        { x : Int
        , y : Int
        }

    pointCodec : S.Codec e Point
    pointCodec =
        S.record Point
            -- Note that adding, removing, or reordering fields will prevent you from decoding any data you've previously encoded.
            |> S.field .x S.int
            |> S.field .y S.int
            |> S.finishRecord

-}
fragileRecord : b -> FragileRecordCodec e a b
fragileRecord ctor =
    FragileRecordCodec
        { bytesEncoder = \_ -> []
        , bytesDecoder = BD.succeed (Ok ctor)
        , jsonEncoder = \_ -> []
        , jsonDecoder = JD.succeed (Ok ctor)
        , fieldIndex = 0
        }


{-| Add an un-reorderable field to the record we are creating a codec for.
-}
fixedField : (a -> f) -> Codec e f -> FragileRecordCodec e a (f -> b) -> FragileRecordCodec e a b
fixedField getter codec (FragileRecordCodec recordCodec) =
    let
        normalJsonDecoder =
            JD.map2
                (\f x ->
                    case ( f, x ) of
                        ( Ok fOk, Ok xOk ) ->
                            fOk xOk |> Ok

                        ( Err err, _ ) ->
                            Err err

                        ( _, Err err ) ->
                            Err err
                )
                recordCodec.jsonDecoder
                (JD.index recordCodec.fieldIndex (getJsonDecoder codec))
    in
    FragileRecordCodec
        { bytesEncoder = \v -> (getBytesEncoder codec <| getter v) :: recordCodec.bytesEncoder v
        , bytesDecoder =
            BD.map2
                (\f x ->
                    case ( f, x ) of
                        ( Ok fOk, Ok xOk ) ->
                            fOk xOk |> Ok

                        ( Err err, _ ) ->
                            Err err

                        ( _, Err err ) ->
                            Err err
                )
                recordCodec.bytesDecoder
                (getBytesDecoder codec)
        , jsonEncoder = \v -> (getJsonEncoder codec <| getter v) :: recordCodec.jsonEncoder v
        , jsonDecoder = normalJsonDecoder
        , fieldIndex = recordCodec.fieldIndex + 1
        }


{-| Finish creating a codec for an un-reorderable record.
-}
finishFragileRecord : FragileRecordCodec e a a -> Codec e a
finishFragileRecord (FragileRecordCodec codec) =
    Codec
        { bytesEncoder = codec.bytesEncoder >> List.reverse >> BE.sequence
        , bytesDecoder = codec.bytesDecoder
        , jsonEncoder = codec.jsonEncoder >> List.reverse >> JE.list identity
        , jsonDecoder = codec.jsonDecoder
        , nodeEncoder = Nothing
        , nodeDecoder = Nothing
        }



-- SMART RECORDS


type alias FieldIdentifier =
    ( FieldSlot, FieldName )


type alias FieldName =
    String


type alias FieldSlot =
    Int


type alias FieldValue =
    String


{-| A partially built Codec for a smart record.
-}
type PartialRecord errs full remaining
    = PartialRecord
        { bytesEncoder : full -> List BE.Encoder
        , bytesDecoder : BD.Decoder (Result (Error errs) remaining)
        , jsonEncoders : List (SmartJsonFieldEncoder full)
        , jsonArrayDecoder : JD.Decoder (Result (Error errs) remaining)
        , fieldIndex : Int
        , ronEncoders : List RegisterFieldEncoder
        , nodeDecoder : RegisterFieldDecoder errs remaining
        }


record : remaining -> PartialRecord errs full remaining
record remainingConstructor =
    PartialRecord
        { bytesEncoder = \_ -> []
        , bytesDecoder = BD.succeed (Ok remainingConstructor)
        , jsonEncoders = []
        , jsonArrayDecoder = JD.succeed (Ok remainingConstructor)
        , fieldIndex = 0
        , ronEncoders = []
        , nodeDecoder = \_ -> JD.succeed (Ok remainingConstructor)
        }


fieldRW : FieldIdentifier -> (full -> RW fieldType) -> Codec errs fieldType -> fieldType -> PartialRecord errs full (RW fieldType -> remaining) -> PartialRecord errs full remaining
fieldRW ( fieldSlot, fieldName ) fieldGetter fieldValueCodec fieldDefault (PartialRecord recordCodecSoFar) =
    let
        jsonObjectFieldKey =
            -- For now, just stick number and name together.
            String.fromInt fieldSlot ++ fieldName

        addToPartialBytesEncoderList existingRecord =
            -- Tack on the new encoder to the big list of all the encoders
            (getBytesEncoder fieldValueCodec <| .get (fieldGetter existingRecord)) :: recordCodecSoFar.bytesEncoder existingRecord

        addToPartialJsonEncoderList =
            -- Tack on the new encoder to the big list of all the encoders
            ( jsonObjectFieldKey, getJsonEncoder fieldValueCodec << (.get << fieldGetter) ) :: recordCodecSoFar.jsonEncoders

        nodeDecoder : RegisterFieldDecoderInputs -> JD.Decoder (Result (Error errs) (RW fieldType))
        nodeDecoder inputs =
            registerWritableFieldDecoder ( fieldSlot, fieldName ) fieldDefault fieldValueCodec inputs
    in
    PartialRecord
        { bytesEncoder = addToPartialBytesEncoderList
        , bytesDecoder = BD.fail
        , jsonEncoders = addToPartialJsonEncoderList
        , jsonArrayDecoder = JD.fail "Can't use RW wrapper with JSON decoding"
        , fieldIndex = recordCodecSoFar.fieldIndex + 1
        , ronEncoders = newRegisterFieldEncoderEntry ( fieldSlot, fieldName ) (Just fieldDefault) fieldValueCodec :: recordCodecSoFar.ronEncoders
        , nodeDecoder =
            nestableJDmap2
                combineIfBothSucceed
                -- the previous decoder layers, functions stacked on top of each other
                recordCodecSoFar.nodeDecoder
                -- and now we're wrapping it in yet another layer, this field's decoder
                nodeDecoder
        }


fieldR : FieldIdentifier -> (full -> fieldType) -> Codec errs fieldType -> fieldType -> PartialRecord errs full (fieldType -> remaining) -> PartialRecord errs full remaining
fieldR ( fieldSlot, fieldName ) fieldGetter fieldValueCodec fieldDefault (PartialRecord recordCodecSoFar) =
    let
        jsonObjectFieldKey =
            -- For now, just stick number and name together.
            -- TODO initial numbers  allowed in JSON field names?
            String.fromInt fieldSlot ++ fieldName

        addToPartialBytesEncoderList existingRecord =
            -- Tack on the new encoder to the big list of all the encoders
            (getBytesEncoder fieldValueCodec <| fieldGetter existingRecord) :: recordCodecSoFar.bytesEncoder existingRecord

        addToPartialJsonEncoderList =
            -- Tack on the new encoder to the big list of all the encoders
            ( jsonObjectFieldKey, getJsonEncoder fieldValueCodec << fieldGetter ) :: recordCodecSoFar.jsonEncoders

        nodeDecoder : RegisterFieldDecoderInputs -> JD.Decoder (Result (Error errs) fieldType)
        nodeDecoder inputs =
            registerReadOnlyFieldDecoder ( fieldSlot, fieldName ) (Just fieldDefault) fieldValueCodec inputs
    in
    PartialRecord
        { bytesEncoder = addToPartialBytesEncoderList
        , bytesDecoder =
            BD.map2
                combineIfBothSucceed
                recordCodecSoFar.bytesDecoder
                (getBytesDecoder fieldValueCodec)
        , jsonEncoders = addToPartialJsonEncoderList
        , jsonArrayDecoder =
            JD.map2
                combineIfBothSucceed
                -- the previous decoder layers, functions stacked on top of each other
                recordCodecSoFar.jsonArrayDecoder
                -- and now we're wrapping it in yet another layer, this field's decoder
                (JD.index recordCodecSoFar.fieldIndex (getJsonDecoder fieldValueCodec))
        , fieldIndex = recordCodecSoFar.fieldIndex + 1
        , ronEncoders = newRegisterFieldEncoderEntry ( fieldSlot, fieldName ) (Just fieldDefault) fieldValueCodec :: recordCodecSoFar.ronEncoders
        , nodeDecoder =
            nestableJDmap2
                combineIfBothSucceed
                -- the previous decoder layers, functions stacked on top of each other
                recordCodecSoFar.nodeDecoder
                -- and now we're wrapping it in yet another layer, this field's decoder
                nodeDecoder
        }


fieldN : FieldIdentifier -> (full -> fieldType) -> Codec errs fieldType -> PartialRecord errs full (fieldType -> remaining) -> PartialRecord errs full remaining
fieldN ( fieldSlot, fieldName ) fieldGetter fieldValueCodec (PartialRecord recordCodecSoFar) =
    let
        jsonObjectFieldKey =
            -- For now, just stick number and name together.
            String.fromInt fieldSlot ++ fieldName

        addToPartialBytesEncoderList existingRecord =
            -- Tack on the new encoder to the big list of all the encoders
            (getBytesEncoder fieldValueCodec <| fieldGetter existingRecord) :: recordCodecSoFar.bytesEncoder existingRecord

        addToPartialJsonEncoderList =
            -- Tack on the new encoder to the big list of all the encoders
            ( jsonObjectFieldKey, getJsonEncoder fieldValueCodec << fieldGetter ) :: recordCodecSoFar.jsonEncoders

        nodeDecoder : RegisterFieldDecoderInputs -> JD.Decoder (Result (Error errs) fieldType)
        nodeDecoder inputs =
            registerReadOnlyFieldDecoder ( fieldSlot, fieldName ) Nothing fieldValueCodec inputs
    in
    PartialRecord
        { bytesEncoder = addToPartialBytesEncoderList
        , bytesDecoder =
            BD.map2
                combineIfBothSucceed
                recordCodecSoFar.bytesDecoder
                (getBytesDecoder fieldValueCodec)
        , jsonEncoders = addToPartialJsonEncoderList
        , jsonArrayDecoder =
            JD.map2
                combineIfBothSucceed
                -- the previous decoder layers, functions stacked on top of each other
                recordCodecSoFar.jsonArrayDecoder
                -- and now we're wrapping it in yet another layer, this field's decoder
                (JD.index recordCodecSoFar.fieldIndex (getJsonDecoder fieldValueCodec))
        , fieldIndex = recordCodecSoFar.fieldIndex + 1
        , ronEncoders = newRegisterFieldEncoderEntry ( fieldSlot, fieldName ) Nothing fieldValueCodec :: recordCodecSoFar.ronEncoders
        , nodeDecoder =
            nestableJDmap2
                combineIfBothSucceed
                -- the previous decoder layers, functions stacked on top of each other
                recordCodecSoFar.nodeDecoder
                -- and now we're wrapping it in yet another layer, this field's decoder
                nodeDecoder
        }


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
nestableJDmap2 :
    (a -> b -> value)
    -> (RegisterFieldDecoderInputs -> JD.Decoder a)
    -> (RegisterFieldDecoderInputs -> JD.Decoder b)
    -> RegisterFieldDecoderInputs
    -> JD.Decoder value
nestableJDmap2 twoArgFunction nestableDecoderA nestableDecoderB inputs =
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


{-| RON what to do when decoding a (potentially nested!) object field.
-}
registerReadOnlyFieldDecoder : ( FieldSlot, FieldName ) -> Maybe fieldtype -> Codec e fieldtype -> RegisterFieldDecoderInputs -> JD.Decoder (Result (Error e) fieldtype)
registerReadOnlyFieldDecoder ( fieldSlot, fieldName ) defaultMaybe fieldValueCodec inputs =
    let
        fieldLatestValueMaybe =
            case inputs.parent of
                ExistingRegister registerObject ->
                    Register.getFieldLatestOnly registerObject ( fieldSlot, fieldName )

                _ ->
                    Nothing

        runFieldDecoder thingToDecode =
            JD.decodeValue
                (getNodeDecoder fieldValueCodec
                    { node = inputs.node, pendingCounter = inputs.pendingCounter, parentNotifier = updateMePostChildInit }
                )
                thingToDecode

        updateMePostChildInit changeToWrap =
            Change.Chunk
                { target =
                    case inputs.parent of
                        PendingRegister pendingID ->
                            PlaceholderPointer Register.reducerID pendingID inputs.parentNotifier

                        ExistingRegister reg ->
                            ExistingObjectPointer <| Register.getID reg
                , objectChanges =
                    [ Change.NewPayload (Register.encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) (changeToChangePayload changeToWrap)) ]
                }
    in
    case defaultMaybe of
        Just default ->
            case fieldLatestValueMaybe of
                Nothing ->
                    -- field was never set - fall back to default
                    JD.succeed (Ok default)

                Just foundField ->
                    -- field was set - decode value and use it
                    case runFieldDecoder (Op.payloadToJsonValue foundField) of
                        Ok something ->
                            JD.succeed something

                        Err problem ->
                            -- fall back to default if we failed to decode set value for some reason
                            -- TODO error instead?
                            -- JD.succeed <| Ok (default)
                            Debug.todo <| "decoder failure: " ++ JD.errorToString problem

        Nothing ->
            -- for nested objects ONLY (fieldN)
            let
                logMsg =
                    "++++ registerReadOnlyFieldDecoder (fieldN): in parent register found field '" ++ fieldName ++ "' with history "

                fieldUUIDHistoryList =
                    case inputs.parent of
                        ExistingRegister register ->
                            Register.getFieldHistoryValues register ( fieldSlot, fieldName )
                                |> List.concatMap Nonempty.toList

                        _ ->
                            -- decode an empty UUID list when there's no pre-existing objects
                            []

                allNestedObjects =
                    runFieldDecoder (JE.list Op.atomToJsonValue fieldUUIDHistoryList)
            in
            case allNestedObjects of
                Ok something ->
                    -- there was a set value AND it decoded successfully
                    JD.succeed something

                Err problem ->
                    -- there was no value set OR it failed to decode
                    Debug.todo ("failed to decode UUID list: " ++ JD.errorToString problem)


registerWritableFieldDecoder : ( FieldSlot, FieldName ) -> fieldtype -> Codec e fieldtype -> RegisterFieldDecoderInputs -> JD.Decoder (Result (Error e) (RW fieldtype))
registerWritableFieldDecoder ( fieldSlot, fieldName ) default fieldValueCodec inputs =
    let
        sameInputs =
            { node = inputs.node, pendingCounter = inputs.pendingCounter }

        wrapRW : Change.Pointer -> fieldtype -> RW fieldtype
        wrapRW targetObject head =
            Register.buildRW targetObject ( fieldSlot, fieldName ) fieldEncoder head

        fieldEncoder newValue =
            getNodeEncoder fieldValueCodec
                { node = inputs.node
                , mode = defaultEncodeMode
                , thingToEncode = EncodeThisFlat newValue
                , parentNotifier = updateMePostChildInit
                , pendingCounter = inputs.pendingCounter -- TODO increment?
                }

        updateMePostChildInit changeToWrap =
            Change.Chunk
                { target =
                    case inputs.parent of
                        PendingRegister pendingID ->
                            PlaceholderPointer Register.reducerID pendingID inputs.parentNotifier

                        ExistingRegister reg ->
                            ExistingObjectPointer <| Register.getID reg
                , objectChanges =
                    [ Change.NewPayload (Register.encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) (changeToChangePayload changeToWrap)) ]
                }
    in
    case inputs.parent of
        PendingRegister pendingID ->
            JD.succeed <| Ok <| wrapRW (PlaceholderPointer Register.reducerID pendingID updateMePostChildInit) default

        -- We are working with an Register
        ExistingRegister registerObject ->
            let
                desiredFieldEncodedMaybe =
                    Register.getFieldLatestOnly registerObject ( fieldSlot, fieldName )
                        |> Maybe.map Op.payloadToJsonValue

                desiredFieldDecodedMaybe =
                    Maybe.map runDecoderOnFoundField desiredFieldEncodedMaybe

                runDecoderOnFoundField : JE.Value -> Result JD.Error (Result (Error e) fieldtype)
                runDecoderOnFoundField foundValue =
                    JD.decodeValue (getNodeDecoder fieldValueCodec { node = inputs.node, pendingCounter = inputs.pendingCounter, parentNotifier = updateMePostChildInit }) foundValue

                -- TODO if nested codec is another register, decode with getFieldHistoryValues instead, using that as the list of objects
            in
            case desiredFieldDecodedMaybe of
                Nothing ->
                    JD.succeed <| Ok <| wrapRW (Change.ExistingObjectPointer (Register.getID registerObject)) default

                Just (Ok (Ok foundVal)) ->
                    JD.succeed <| Ok <| wrapRW (Change.ExistingObjectPointer (Register.getID registerObject)) foundVal

                Just (Ok (Err e)) ->
                    JD.succeed <| Err e

                Just (Err e) ->
                    -- better than failing silently? should be unreachable
                    --JD.succeed <| Err DataCorrupted
                    Log.crashInDev ("should be unreachable, decoder did not return Result-wrapped value! and ran into problem: " ++ JD.errorToString e)
                        (JD.succeed <| Err DataCorrupted)


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


{-| Finish creating a codec for a record.
-}
finishRecord : PartialRecord errs full full -> Codec errs full
finishRecord (PartialRecord allFieldsCodec) =
    let
        encodeAsJsonObject fullRecord =
            let
                passFullRecordToFieldEncoder ( fieldKey, fieldEncoder ) =
                    ( fieldKey, fieldEncoder fullRecord )
            in
            JE.object (List.map passFullRecordToFieldEncoder allFieldsCodec.jsonEncoders)

        encodeAsDictList fullRecord =
            JE.list (encodeEntryInDictList fullRecord) allFieldsCodec.jsonEncoders

        encodeEntryInDictList fullRecord ( fieldKey, entryValueEncoder ) =
            JE.list identity [ JE.string fieldKey, entryValueEncoder fullRecord ]

        nodeDecoder : NodeDecoder errs full
        nodeDecoder { node, pendingCounter, parentNotifier } =
            let
                registerDecoder : List ObjectID -> JD.Decoder (Result (Error errs) full)
                registerDecoder objectIDs =
                    let
                        pending =
                            Change.usePendingCounter 0 pendingCounter

                        register =
                            Maybe.map (Register.build node) (Node.getObjectIfExists node objectIDs)

                        parent =
                            case register of
                                Nothing ->
                                    PendingRegister pending.id

                                Just foundOne ->
                                    ExistingRegister foundOne
                    in
                    allFieldsCodec.nodeDecoder { node = node, pendingCounter = pending.passToChild, parent = parent, parentNotifier = parentNotifier }
            in
            JD.andThen registerDecoder concurrentObjectIDsDecoder

        nodeEncoder : NodeEncoder full
        nodeEncoder inputs =
            registerNodeEncoder allFieldsCodec.ronEncoders
                { thingToEncode = JustEncodeDefaultsIfNeeded
                , mode = inputs.mode
                , node = inputs.node
                , parentNotifier = inputs.parentNotifier
                , pendingCounter = inputs.pendingCounter
                }
    in
    Codec
        { bytesEncoder = allFieldsCodec.bytesEncoder >> List.reverse >> BE.sequence
        , bytesDecoder = allFieldsCodec.bytesDecoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = allFieldsCodec.jsonArrayDecoder
        , nodeEncoder = Just nodeEncoder
        , nodeDecoder = Just nodeDecoder
        }


{-| Encodes an register as a list of Ops.
-- The Op encoding the register comes last in the list, as the preceding Ops create registers that it depends on.
For each field:
-- if it's a normal value (no nodeEncoder) just encode it, return a FieldPreOp
-- if it's a nested register that does not yet exist in the tree, make an ID for it, then proceed with the following.
-- if it's a nested register that does exist, run its registerNodeEncoder and put its requisite ops above us.

Also returns the ObjectID so that parent registers can refer to it.

Why not create missing Objects in the encoder? Because if it already exists, we'd need to pass the existing ObjectID in anyway. Might as well pass in a guaranteed-existing Register (pre-created if needed)

JK: Updated thinking is this doesn't work anyway - a custom type could contain a register, that doesn't get initialized until set to a different variant. (e.g. `No | Yes a`.) So we have to be ready for on-demand initialization anyway.

-}
registerNodeEncoder : List RegisterFieldEncoder -> NodeEncoderInputs Register -> Change.PotentialPayload
registerNodeEncoder ronFieldEncoders ({ node, thingToEncode, mode, pendingCounter, parentNotifier } as details) =
    let
        existingRegisterMaybe : Maybe Register
        existingRegisterMaybe =
            case thingToEncode of
                EncodeThisFlat a ->
                    -- TODO not possible, right?
                    Nothing

                EncodeRegisterFieldLookupInstead register ->
                    Just register

                JustEncodeDefaultsIfNeeded ->
                    Nothing

        pending =
            Change.usePendingCounter 0 pendingCounter

        target =
            case existingRegisterMaybe of
                Nothing ->
                    PlaceholderPointer Register.reducerID pending.id parentNotifier

                Just foundRegister ->
                    ExistingObjectPointer <| Register.getID foundRegister

        updateMePostChildInit fieldChangedPayload =
            Change.Chunk
                { target = target
                , objectChanges = [ Change.NewPayload fieldChangedPayload ]
                }

        subChanges : List Change.ObjectChange
        subChanges =
            let
                runSubEncoder : Int -> (RegisterFieldEncoderInputs -> RegisterFieldEncoderOutput) -> Maybe Change.ObjectChange
                runSubEncoder index subEncoderFunction =
                    subEncoderFunction
                        { node = node
                        , registerMaybe = existingRegisterMaybe
                        , mode = mode
                        , pendingCounter = (Change.usePendingCounter index pending.passToChild).passToChild
                        , updateRegisterAfterChildInit = updateMePostChildInit
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
            ronFieldEncoders
                |> List.indexedMap runSubEncoder
                |> List.filterMap identity
    in
    List.singleton
        (Change.QuoteNestedObject
            (Chunk
                { target = target
                , objectChanges = subChanges
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


{-| Adds an item to the list of replica encoders, for encoding a single Register field into an Op, if applicable. This field may contain further nested fields which also are encoded, so the return result is a big list of Ops.

Updated to separate cases where the object needs to be created.

-}
newRegisterFieldEncoderEntry : FieldIdentifier -> Maybe fieldType -> Codec e fieldType -> (RegisterFieldEncoderInputs -> RegisterFieldEncoderOutput)
newRegisterFieldEncoderEntry ( fieldSlot, fieldName ) fieldDefaultIfApplies fieldValueCodec { mode, registerMaybe, node, updateRegisterAfterChildInit, pendingCounter } =
    let
        runFieldRonEncoder value =
            getNodeEncoder fieldValueCodec
                { mode = mode
                , node = node
                , thingToEncode = attemptRegisterOverride value
                , parentNotifier =
                    \changeToWrap ->
                        updateRegisterAfterChildInit
                            (Register.encodeFieldPayloadAsObjectPayload
                                ( fieldSlot, fieldName )
                                (changeToChangePayload changeToWrap)
                            )
                , pendingCounter = pendingCounter -- Already "used" by register encoder
                }

        wrapFieldEncoderOutput : fieldType -> Change.PotentialPayload
        wrapFieldEncoderOutput value =
            let
                wrapper =
                    Register.encodeFieldPayloadAsObjectPayload
                        ( fieldSlot, fieldName )
            in
            wrapper (runFieldRonEncoder value)

        attemptRegisterOverride : a -> ThingToEncode a
        attemptRegisterOverride fallbackValue =
            let
                hasNestedWritableObject =
                    -- check to see if there's a nested object, otherwise no point checking for register override
                    case fieldValueCodec of
                        Codec codecrecord ->
                            Maybe.Extra.isJust codecrecord.nodeEncoder

                encodedSubRegisterPotentially =
                    Maybe.andThen (\register -> Register.getFieldLatestOnly register ( fieldSlot, fieldName )) registerMaybe

                subRegisterObjectIDsMaybe : List ObjectID
                subRegisterObjectIDsMaybe =
                    Maybe.withDefault [] (Maybe.map Nonempty.toList encodedSubRegisterPotentially)
                        |> extractQuotedObjects
            in
            case ( hasNestedWritableObject, Maybe.map (Register.build node) (Node.getObjectIfExists node subRegisterObjectIDsMaybe) ) of
                ( True, Just subRegister ) ->
                    EncodeRegisterFieldLookupInstead subRegister

                _ ->
                    EncodeThisFlat fallbackValue

        getValue register =
            Register.getFieldLatestOnly register ( fieldSlot, fieldName )

        encodedDefault fieldDefault =
            runFieldRonEncoder fieldDefault

        explicitDefaultIfNeeded fieldDefault =
            case ( mode.setDefaultsExplicitly, wrapFieldEncoderOutput fieldDefault ) of
                ( True, changePayloadHead :: changePayloadTail ) ->
                    -- only if we got something back from the encoder
                    EncodeThisField <| Change.NewPayload (changePayloadHead :: changePayloadTail)

                _ ->
                    SkipThisField
    in
    case ( fieldDefaultIfApplies, registerMaybe ) of
        ( Just fieldDefault, Nothing ) ->
            explicitDefaultIfNeeded fieldDefault

        ( Just fieldDefault, Just containingRegister ) ->
            case getValue containingRegister of
                Nothing ->
                    explicitDefaultIfNeeded fieldDefault

                Just foundPreviousValue ->
                    -- since encoders return ChangeAtoms, we need to wrap the fetched existing value in a ChangeAtom to compare to the default output.
                    if Change.compareToRonPayload (encodedDefault fieldDefault) (Nonempty.toList foundPreviousValue) then
                        explicitDefaultIfNeeded fieldDefault

                    else
                        EncodeThisField <| Change.NewPayload <| Nonempty.toList <| Nonempty.map Change.RonAtom foundPreviousValue

        ( Nothing, Just containingRegister ) ->
            case getValue containingRegister of
                Nothing ->
                    SkipThisField

                Just foundPreviousValue ->
                    EncodeThisField <| Change.NewPayload <| Nonempty.toList <| Nonempty.map Change.RonAtom foundPreviousValue

        ( Nothing, Nothing ) ->
            SkipThisField


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
map : (a -> b) -> (b -> a) -> Codec e a -> Codec e b
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


mapHelper : (Result (Error e) a -> Result (Error e) b) -> (b -> a) -> Codec e a -> Codec e b
mapHelper fromBytes_ toBytes_ codec =
    let
        wrappedNodeDecoder : NodeDecoderInputs -> JD.Decoder (Result (Error e) b)
        wrappedNodeDecoder inputs =
            getNodeDecoder codec inputs |> JD.map fromBytes_

        mapNodeEncoderInputs : NodeEncoderInputs b -> NodeEncoderInputs a
        mapNodeEncoderInputs inputs =
            NodeEncoderInputs inputs.node inputs.mode (mapThingToEncode inputs.thingToEncode) inputs.pendingCounter inputs.parentNotifier

        mapThingToEncode : ThingToEncode b -> ThingToEncode a
        mapThingToEncode original =
            case original of
                EncodeThisFlat a ->
                    EncodeThisFlat (toBytes_ a)

                EncodeRegisterFieldLookupInstead reg ->
                    EncodeRegisterFieldLookupInstead reg

                JustEncodeDefaultsIfNeeded ->
                    JustEncodeDefaultsIfNeeded
    in
    buildNestableCodec
        (\v -> toBytes_ v |> getBytesEncoder codec)
        (getBytesDecoder codec |> BD.map fromBytes_)
        (\v -> toBytes_ v |> getJsonEncoder codec)
        (getJsonDecoder codec |> JD.map fromBytes_)
        (Just (\inputs -> mapNodeEncoderInputs inputs |> getNodeEncoder codec))
        (Just wrappedNodeDecoder)


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
mapValid : (a -> Result e b) -> (b -> a) -> Codec e a -> Codec e b
mapValid fromBytes_ toBytes_ codec =
    let
        wrappedNodeDecoder : NodeDecoderInputs -> JD.Decoder (Result (Error e) b)
        wrappedNodeDecoder inputs =
            getNodeDecoder codec inputs |> JD.map wrapCustomError

        mapNodeEncoderInputs : NodeEncoderInputs b -> NodeEncoderInputs a
        mapNodeEncoderInputs inputs =
            NodeEncoderInputs inputs.node inputs.mode (mapThingToEncode inputs.thingToEncode) inputs.pendingCounter inputs.parentNotifier

        mapThingToEncode : ThingToEncode b -> ThingToEncode a
        mapThingToEncode original =
            case original of
                EncodeThisFlat a ->
                    EncodeThisFlat (toBytes_ a)

                EncodeRegisterFieldLookupInstead reg ->
                    EncodeRegisterFieldLookupInstead reg

                JustEncodeDefaultsIfNeeded ->
                    JustEncodeDefaultsIfNeeded

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
        (Just (\inputs -> mapNodeEncoderInputs inputs |> getNodeEncoder codec))
        (Just wrappedNodeDecoder)


{-| Map errors generated by `mapValid`.
-}
mapError : (e1 -> e2) -> Codec e1 a -> Codec e2 a
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
        (Just (getNodeEncoder codec))
        (Just wrappedNodeDecoder)


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
        )



-- STACK UNSAFE


{-| Handle situations where you need to define a codec in terms of itself.

    import Serialize as S

    type Peano
        = Peano (Maybe Peano)

    {-| The compiler will complain that this function causes an infinite loop.
    -}
    badPeanoCodec : S.Codec e Peano
    badPeanoCodec =
        S.maybe badPeanoCodec |> S.map Peano (\(Peano a) -> a)

    {-| Now the compiler is happy!
    -}
    goodPeanoCodec : S.Codec e Peano
    goodPeanoCodec =
        S.maybe (S.lazy (\() -> goodPeanoCodec)) |> S.map Peano (\(Peano a) -> a)

**Warning:** This is not stack safe.

In general if you have a type that contains itself, like with our the Peano example, then you're at risk of a stack overflow while decoding.
Even if you're translating your nested data into a list before encoding, you're at risk, because the function translating back after decoding can cause a stack overflow if the original value was nested deeply enough.
Be careful here, and test your codecs using elm-test with larger inputs than you ever expect to see in real life.

-}
lazy : (() -> Codec e a) -> Codec e a
lazy f =
    buildUnnestableCodec
        (\value -> getBytesEncoder (f ()) value)
        (BD.succeed () |> BD.andThen (\() -> getBytesDecoder (f ())))
        (\value -> getJsonEncoder (f ()) value)
        (JD.succeed () |> JD.andThen (\() -> getJsonDecoder (f ())))


{-| A partially built codec for a custom type.
-}



-- CUSTOM


type alias VariantTag =
    ( Int, String )


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

    semaphoreCodec : S.Codec e Semaphore
    semaphoreCodec =
        S.customType
            (\redEncoder yellowEncoder greenEncoder value ->
                case value of
                    Red i s b ->
                        redEncoder i s b

                    Yellow f ->
                        yellowEncoder f

                    Green ->
                        greenEncoder
            )
            -- Note that removing a variantBuilder, inserting a variantBuilder before an existing one, or swapping two variants will prevent you from decoding any data you've previously encoded.
            |> S.variant3 Red S.int S.string S.bool
            |> S.variant1 Yellow S.float
            |> S.variant0 Green
            -- It's safe to add new variants here later though
            |> S.finishCustomType

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
        , node : NodeEncoderInputsNoVariable -> List Change.Atom
        }


{-| Normal Node encoders spit out NodeENcoderOutput, but since we need to iteratively build up a variant encoder from scratch, we modify encoders to just produce a list which can be empty. The "from scratch" actually starts with []
-}
type alias VariantNodeEncoder =
    NodeEncoderInputsNoVariable -> List Change.Atom


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
                , node = \_ -> []
                }

        wrapJE : List JE.Value -> VariantEncoder
        wrapJE variantPieces =
            VariantEncoder
                { bytes = BE.sequence []
                , json = JE.string (String.fromInt tagNum ++ "_" ++ tagName) :: variantPieces |> JE.list identity
                , node = \_ -> []
                }

        wrapNE : List VariantNodeEncoder -> VariantEncoder
        wrapNE variantEncoders =
            let
                piecesApplied inputs =
                    List.indexedMap (applyIndexedInputs inputs) variantEncoders
                        |> List.concat

                tag =
                    Change.RonAtom <| Op.NakedStringAtom <| tagName ++ "_" ++ String.fromInt tagNum

                applyIndexedInputs inputs index encoderFunction =
                    encoderFunction
                        { inputs | pendingCounter = (Change.usePendingCounter index inputs.pendingCounter).passToChild }
            in
            VariantEncoder
                { bytes = BE.sequence []
                , json = JE.null
                , node = \inputs -> List.singleton (Change.NestedAtoms (tag :: piecesApplied inputs))
                }

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
    { inputsND | pendingCounter = (Change.usePendingCounter pieceNum inputsND.pendingCounter).passToChild }


{-| Define a variantBuilder with 1 parameters for a custom type.
-}
variant1 :
    VariantTag
    -> (a -> v)
    -> Codec error a
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
    -> Codec error a
    -> Codec error b
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
    -> Codec error a
    -> Codec error b
    -> Codec error c
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
    -> Codec error a
    -> Codec error b
    -> Codec error c
    -> Codec error d
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
    -> Codec error a
    -> Codec error b
    -> Codec error c
    -> Codec error d
    -> Codec error e
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
    -> Codec error a
    -> Codec error b
    -> Codec error c
    -> Codec error d
    -> Codec error e
    -> Codec error f
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
    -> Codec error a
    -> Codec error b
    -> Codec error c
    -> Codec error d
    -> Codec error e
    -> Codec error f
    -> Codec error g
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
    -> Codec error a
    -> Codec error b
    -> Codec error c
    -> Codec error d
    -> Codec error e
    -> Codec error f
    -> Codec error g
    -> Codec error h
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
finishCustomType : CustomTypeCodec () e (a -> VariantEncoder) a -> Codec e a
finishCustomType (CustomTypeCodec priorVariants) =
    let
        nodeEncoder : NodeEncoder a
        nodeEncoder nodeEncoderInputs =
            let
                newInputs : NodeEncoderInputsNoVariable
                newInputs =
                    { node = nodeEncoderInputs.node
                    , mode = nodeEncoderInputs.mode
                    , pendingCounter = nodeEncoderInputs.pendingCounter
                    , parentNotifier = nodeEncoderInputs.parentNotifier
                    }

                nodeMatcher : VariantEncoder
                nodeMatcher =
                    case nodeEncoderInputs.thingToEncode of
                        EncodeThisFlat encodeThing ->
                            priorVariants.nodeMatcher encodeThing

                        _ ->
                            Debug.todo "there was nothing to encode, should never happen"

                getNodeVariantEncoder (VariantEncoder encoders) =
                    encoders.node newInputs
            in
            getNodeVariantEncoder nodeMatcher

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
        (Just nodeEncoder)
        (Just nodeDecoder)


{-| Specifically for variant encoders, we must
a) strip out the type variable from NodeEncoderInputs
b) return a normal list of change atoms so we can use normal list functions to build up the variant encoder's output.

Hence, inputs are modified to NodeEncoderInputsNoVariable and outputs are just List Change.Atom.
The input type variable is taken care of early on, and the output type is converted to NodeENcoderOutput in the last mile.

-}
getNodeEncoderModifiedForVariants : Codec e a -> a -> VariantNodeEncoder
getNodeEncoderModifiedForVariants codec thingToEncode =
    let
        finishInputs : NodeEncoderInputsNoVariable -> NodeEncoderInputs a
        finishInputs modifiedEncoder =
            { node = modifiedEncoder.node
            , mode = modifiedEncoder.mode
            , thingToEncode = EncodeThisFlat thingToEncode -- TODO would register instead be needed?
            , pendingCounter = modifiedEncoder.pendingCounter
            , parentNotifier = modifiedEncoder.parentNotifier
            }
    in
    \altInputs -> getNodeEncoder codec (finishInputs altInputs)
