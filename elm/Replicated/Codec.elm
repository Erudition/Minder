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

@docs maybe, primitiveList, array, dict, set, tuple, triple, result, enum


# Records

@docs RecordCodec, record, fieldR, finishRecord


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
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Decode as JD
import Json.Encode as JE
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Maybe.Extra
import Regex exposing (Regex)
import Replicated.Change as Change exposing (Change(..), Pointer(..), changeToChangePayload)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Object as Object exposing (I, Object, Placeholder)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.OpID as OpID exposing (InCounter, ObjectID, OpID, OutCounter)
import Replicated.Reducer.Register as Register exposing (Register(..))
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict, RepDictEntry(..))
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Set exposing (Set)
import SmartTime.Moment as Moment exposing (Moment)
import Toop exposing (T4(..), T5(..), T6(..), T7(..), T8(..))



-- CODEC DEFINITIONS


{-| Like a normal codec, but can have references instead of values, so must be passed the entire Replica so that some decoders may search elsewhere.
-}
type RepCodec e i a
    = Codec
        { bytesEncoder : a -> BE.Encoder
        , bytesDecoder : BD.Decoder (Result (Error e) a)
        , jsonEncoder : a -> JE.Value
        , jsonDecoder : JD.Decoder (Result (Error e) a)
        , nodeEncoder : Maybe (NodeEncoder a)
        , nodeDecoder : Maybe (NodeDecoder e a)
        , init : Initializer i a
        }


type alias Codec e a =
    RepCodec e a a


type alias Initializer i a =
    Int -> i -> a



-- RON DEFINITIONS


type alias NodeEncoderInputs a =
    { node : Node
    , mode : ChangesToGenerate
    , thingToEncode : ThingToEncode a
    , pendingCounter : Change.PendingCounter
    , parentNotifier : Change -> Change
    }


type ThingToEncode fieldType
    = EncodeThis fieldType
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
    , cutoff : Maybe Moment
    }


type alias RegisterFieldEncoder r =
    RegisterFieldEncoderInputs r -> RegisterFieldEncoderOutput


{-| Inputs to a node Field decoder.
-}
type alias RegisterFieldEncoderInputs full =
    { node : Node
    , register : Register full
    , mode : ChangesToGenerate
    , updateRegisterAfterChildInit : Change.PotentialPayload -> Change
    , pendingCounter : Change.PendingCounter
    }


type alias RegisterFieldDecoder e full remaining =
    RegisterFieldDecoderInputs -> Register full -> ( Result (Error e) remaining, List (Error e) )


type alias RegisterFieldInitializer parentSeed full remaining =
    parentSeed -> Register full -> remaining


type alias RegisterFieldDecoderInputs =
    { node : Node
    , pendingCounter : Change.PendingCounter
    , parentNotifier : Change -> Change
    , cutoff : Maybe Moment
    }


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
    | JDError JD.Error


version : Int
version =
    1



-- DECODE


{-| Pass in the codec for the root object.
-}
decodeFromNode : Codec e profile -> Node -> Result (Error e) profile
decodeFromNode profileCodec node =
    let
        rootEncoded =
            node.root
                -- TODO we need to get rid of those quotes, but JD.string expects them for now
                |> Maybe.map (\i -> "[\"" ++ OpID.toString i ++ "\"]")
                |> Maybe.withDefault "\"[]\""
    in
    case getNodeDecoder profileCodec of
        nodeDecoder ->
            case JD.decodeString (nodeDecoder { node = node, pendingCounter = Change.firstPendingCounter, parentNotifier = identity, cutoff = Nothing }) (prepDecoder rootEncoded) of
                Ok value ->
                    value

                Err jdError ->
                    Err (FailedToDecodeRoot <| JD.errorToString jdError)


init : RepCodec e i repType -> Int -> i -> repType
init (Codec codecDetails) =
    codecDetails.init


endian : Bytes.Endianness
endian =
    Bytes.BE


{-| Extracts the `Decoder` contained inside the `Codec`.
-}
getBytesDecoder : RepCodec e s a -> BD.Decoder (Result (Error e) a)
getBytesDecoder (Codec m) =
    m.bytesDecoder


{-| Extracts the json `Decoder` contained inside the `Codec`.
-}
getJsonDecoder : RepCodec e s a -> JD.Decoder (Result (Error e) a)
getJsonDecoder (Codec m) =
    m.jsonDecoder


{-| Extracts the ron decoder contained inside the `Codec`.
-}
getNodeDecoder : RepCodec e i a -> NodeDecoder e a
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
getBytesEncoder : RepCodec e s a -> a -> BE.Encoder
getBytesEncoder (Codec m) =
    m.bytesEncoder


{-| Extracts the replica encoding function contained inside the `Codec`.
-}
getNodeEncoder : RepCodec e s a -> NodeEncoder a
getNodeEncoder (Codec m) inputs =
    case m.nodeEncoder of
        Just nativeRonEncoder ->
            nativeRonEncoder inputs

        Nothing ->
            case inputs.thingToEncode of
                EncodeThis thing ->
                    List.singleton <| Change.JsonValueAtom <| m.jsonEncoder thing

                JustEncodeDefaultsIfNeeded ->
                    -- no need to encode defaults for primitive encoders
                    []


{-| Extracts the json encoding function contained inside the `Codec`.
-}
getJsonEncoder : RepCodec e s a -> a -> JE.Value
getJsonEncoder (Codec m) =
    m.jsonEncoder


{-| Convert an Elm value into a sequence of bytes.
-}
encodeToBytes : RepCodec e s a -> a -> Bytes.Bytes
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



-- TODO is below needed?
-- {-| Get values from the Node into a Change.
-- Pass the codec of the root object.
-- -}
-- encodeNodeToChanges : Node -> Codec e profile -> Change.PotentialPayload
-- encodeNodeToChanges node profileCodec =
--     let
--         starterPendingID =
--             (Change.usePendingCounter 0 Change.firstPendingCounter).id
--
--         rootObject =
--             Node.getObject
--                 { node = node, cutoff = Nothing, foundIDs = List.filterMap identity [ node.root ], pendingID = starterPendingID, reducer = registerReducerID, parentNotifier = identity }
--
--         rootRegister =
--             Register.build rootObject regToRecord
--
--         thingToEncode =
--             EncodeThis rootRegister
--     in
--     getNodeEncoder profileCodec
--         { node = node
--         , mode = defaultEncodeMode
--         , thingToEncode = thingToEncode
--         , parentNotifier = identity
--         , pendingCounter = Change.firstPendingCounter
--         }


{-| Generates naked Changes from a Codec's default values. These are all the values that would normally be skipped, not encoded to Changes.
Useful for spitting out test data, and seeing the whole heirarchy of your types.
-}
encodeDefaults : Node -> Codec e a -> Change
encodeDefaults node rootCodec =
    let
        ronPayload =
            getNodeEncoder rootCodec
                { node = node
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


{-| Generates naked Changes from a Codec's default values. Passes in a test node, not for production
-}
encodeDefaultsForTesting : Codec e a -> Change
encodeDefaultsForTesting rootCodec =
    encodeDefaults Node.testNode rootCodec



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
        , init = \_ same -> same
        }


buildNestableCodec :
    (a -> BE.Encoder)
    -> BD.Decoder (Result (Error e) a)
    -> (a -> JE.Value)
    -> JD.Decoder (Result (Error e) a)
    -> Maybe (NodeEncoder a)
    -> Maybe (NodeDecoder e a)
    -> RepCodec e a a
buildNestableCodec encoder_ decoder_ jsonEncoder jsonDecoder ronEncoderMaybe ronDecoderMaybe =
    Codec
        { bytesEncoder = encoder_
        , bytesDecoder = decoder_
        , jsonEncoder = jsonEncoder
        , jsonDecoder = jsonDecoder
        , nodeEncoder = ronEncoderMaybe
        , nodeDecoder = ronDecoderMaybe
        , init = \_ same -> same
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
                        EncodeThis stringToEncode ->
                            -- TODO eliminate quotes and decode without them
                            List.singleton <| Change.RonAtom <| Op.StringAtom stringToEncode

                        _ ->
                            Log.crashInDev "tried to node-encode with string encoder but not passed a flat string value" []
        , nodeDecoder = Nothing
        , init = \_ same -> same
        }


{-| Codec for serializing a `Bool`
-}
bool : Codec e Bool
bool =
    let
        boolNodeEncoder : NodeEncoder Bool
        boolNodeEncoder { thingToEncode } =
            case thingToEncode of
                EncodeThis True ->
                    [ Change.RonAtom <| Op.NakedStringAtom "true" ]

                EncodeThis False ->
                    [ Change.RonAtom <| Op.NakedStringAtom "false" ]

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
                EncodeThis givenInt ->
                    [ Change.RonAtom <| Op.IntegerAtom givenInt ]

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
repList : RepCodec e memberSeed memberType -> RepCodec e (List memberType) (RepList memberType)
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

        memberRonEncoder : Node -> Maybe ChangesToGenerate -> Change.ParentNotifier -> memberType -> Change.PotentialPayload
        memberRonEncoder node encodeModeMaybe parentNotifier newValue =
            getNodeEncoder memberCodec
                { mode = Maybe.withDefault defaultEncodeMode encodeModeMaybe
                , node = node
                , thingToEncode = EncodeThis newValue
                , parentNotifier = parentNotifier
                , pendingCounter = Change.unmatchableCounter
                }

        memberChanger node encodeModeMaybe parentNotifier newMemberValue newRefMaybe =
            case newRefMaybe of
                Just givenRef ->
                    Change.NewPayloadWithRef { payload = memberRonEncoder node encodeModeMaybe parentNotifier newMemberValue, ref = givenRef }

                Nothing ->
                    Change.NewPayload (memberRonEncoder node encodeModeMaybe parentNotifier newMemberValue)

        memberRonDecoder : Node -> Change.PendingCounter -> Maybe Moment -> JE.Value -> Maybe memberType
        memberRonDecoder node childPendingCounter cutoff encodedMember =
            case JD.decodeValue (getNodeDecoder memberCodec { node = node, pendingCounter = childPendingCounter, parentNotifier = identity, cutoff = cutoff }) encodedMember of
                Ok (Ok member) ->
                    Just member

                _ ->
                    Nothing

        repListRonDecoder : NodeDecoder e (RepList memberType)
        repListRonDecoder ({ node, pendingCounter, parentNotifier, cutoff } as details) =
            let
                pending =
                    Change.usePendingCounter 0 pendingCounter

                object foundObjectIDs =
                    Node.getObject { node = node, cutoff = cutoff, foundIDs = foundObjectIDs, pendingID = pending.id, reducer = RepList.reducerID, parentNotifier = parentNotifier }

                repListBuilder foundObjects =
                    Ok <| RepList.buildFromReplicaDb (object foundObjects) (memberRonDecoder node pending.passToChild cutoff) (memberChanger node Nothing parentNotifier) []
            in
            JD.map repListBuilder concurrentObjectIDsDecoder

        repListRonEncoder : NodeEncoder (RepList memberType)
        repListRonEncoder ({ node, thingToEncode, mode, parentNotifier, pendingCounter } as details) =
            case thingToEncode of
                EncodeThis existingRepList ->
                    changeToChangePayload <|
                        Chunk
                            { target = RepList.getID existingRepList
                            , objectChanges = List.map (\v -> memberChanger node (Just mode) parentNotifier v Nothing) (RepList.getInit existingRepList)
                            }

                _ ->
                    changeToChangePayload <|
                        Chunk
                            { target = Change.PlaceholderPointer RepList.reducerID (Change.usePendingCounter 0 pendingCounter).id identity
                            , objectChanges = []
                            }

        initializer : Initializer (List memberType) (RepList memberType)
        initializer key initMembers =
            let
                pending =
                    -- TODO use another number to differentiate e.g. replist init 0 from register init 0, since their children would both have pending id 0.0...
                    Change.usePendingCounter key Change.firstPendingCounter

                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], pendingID = pending.id, reducer = RepList.reducerID, parentNotifier = identity }

                repListBuilder =
                    RepList.buildFromReplicaDb object (memberRonDecoder Node.testNode pending.passToChild Nothing) (memberChanger Node.testNode Nothing identity) initMembers
            in
            repListBuilder
    in
    Codec
        { bytesEncoder = bytesEncoder
        , bytesDecoder =
            BD.fail
        , jsonEncoder = jsonEncoder
        , jsonDecoder = normalJsonDecoder
        , nodeEncoder = Just repListRonEncoder
        , nodeDecoder = Just repListRonDecoder
        , init = initializer
        }


{-| Codec for an elm `List` primitive.
You will not be able to change the contents without replacing the entire list, and such changes will not merge nicely with concurrent changes, so consider using a `RepList` instead!
That said, useful for one-off lists, or Json serialization.
-}
primitiveList : Codec e a -> Codec e (List a)
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
        , init = \_ same -> same
        }


primitiveNonempty : Codec String userType -> Codec String (Nonempty userType)
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
array : Codec e a -> Codec e (Array a)
array codec =
    primitiveList codec |> mapHelper (Result.map Array.fromList) Array.toList


{-| A replicated set specifically for reptype members, with dictionary features such as getting a member by ID.
-}
repDb : Codec e memberType -> RepCodec e (List memberType) (RepDb memberType)
repDb memberCodec =
    let
        memberRonEncoder : Node -> Maybe ChangesToGenerate -> Change.ParentNotifier -> memberType -> Change.PotentialPayload
        memberRonEncoder node encodeModeMaybe parentNotifier newValue =
            getNodeEncoder memberCodec
                { mode = Maybe.withDefault defaultEncodeMode encodeModeMaybe
                , node = node
                , thingToEncode = EncodeThis newValue
                , parentNotifier = parentNotifier
                , pendingCounter = Change.unmatchableCounter
                }

        memberChanger node encodeModeMaybe parentNotifier newMemberValue =
            Change.NewPayload (memberRonEncoder node encodeModeMaybe parentNotifier newMemberValue)

        memberRonDecoder : Node -> Change.PendingCounter -> Maybe Moment -> JE.Value -> Maybe memberType
        memberRonDecoder node childPendingCounter cutoff encodedMember =
            case JD.decodeValue (getNodeDecoder memberCodec { node = node, pendingCounter = childPendingCounter, parentNotifier = identity, cutoff = cutoff }) encodedMember of
                Ok (Ok member) ->
                    Just member

                _ ->
                    Nothing

        repDbNodeDecoder : NodeDecoder e (RepDb memberType)
        repDbNodeDecoder ({ node, pendingCounter, parentNotifier, cutoff } as details) =
            let
                pending =
                    Change.usePendingCounter 0 pendingCounter

                object foundObjectIDs =
                    Node.getObject { node = node, cutoff = Nothing, foundIDs = foundObjectIDs, pendingID = pending.id, reducer = RepDb.reducerID, parentNotifier = parentNotifier }

                repDbBuilder foundObjects =
                    Ok <| RepDb.buildFromReplicaDb (object foundObjects) (memberRonDecoder node pending.passToChild cutoff) (memberChanger node Nothing parentNotifier) []
            in
            JD.map repDbBuilder concurrentObjectIDsDecoder

        repDbNodeEncoder : NodeEncoder (RepDb memberType)
        repDbNodeEncoder ({ node, thingToEncode, mode, parentNotifier, pendingCounter } as details) =
            case thingToEncode of
                EncodeThis existingRepDb ->
                    changeToChangePayload <|
                        Chunk
                            { target = RepDb.getPointer existingRepDb
                            , objectChanges = List.map (memberChanger node (Just mode) parentNotifier) (RepDb.getInit existingRepDb)
                            }

                _ ->
                    changeToChangePayload <|
                        Chunk
                            { target = Change.PlaceholderPointer RepDb.reducerID (Change.usePendingCounter 0 pendingCounter).id identity
                            , objectChanges = []
                            }

        initializer : Int -> List memberType -> RepDb memberType
        initializer key initMembers =
            let
                pending =
                    Change.usePendingCounter key Change.firstPendingCounter

                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], pendingID = pending.id, reducer = RepDb.reducerID, parentNotifier = identity }
            in
            RepDb.buildFromReplicaDb object (memberRonDecoder Node.testNode pending.passToChild Nothing) (memberChanger Node.testNode Nothing identity) initMembers
    in
    Codec
        { bytesEncoder = \input -> listEncode (getBytesEncoder memberCodec) (RepDb.listValues input)
        , bytesDecoder = BD.fail
        , jsonEncoder = \input -> JE.list (getJsonEncoder memberCodec) (RepDb.listValues input)
        , jsonDecoder = JD.fail "no repdb"
        , nodeEncoder = Just repDbNodeEncoder
        , nodeDecoder = Just repDbNodeDecoder
        , init = initializer
        }


{-| A replicated dictionary.
-}
repDict : Codec e k -> Codec e v -> RepCodec e (List ( k, v )) (RepDict k v)
repDict keyCodec valueCodec =
    let
        -- We use the json-encoded form as the dict key, since it's always comparable!
        keyToString key =
            JE.encode 0 (getJsonEncoder keyCodec key)

        flatDictListCodec =
            primitiveList (tuple keyCodec valueCodec)

        jsonEncoder : RepDict k v -> JE.Value
        jsonEncoder input =
            getJsonEncoder flatDictListCodec (RepDict.list input)

        bytesEncoder : RepDict k v -> BE.Encoder
        bytesEncoder input =
            getBytesEncoder flatDictListCodec (RepDict.list input)

        entryRonEncoder : Node -> Maybe ChangesToGenerate -> Change.ParentNotifier -> RepDict.RepDictEntry k v -> Change.PotentialPayload
        entryRonEncoder node encodeModeMaybe parentNotifier newEntry =
            let
                keyEncoder givenKey =
                    getNodeEncoder keyCodec
                        { mode = Maybe.withDefault defaultEncodeMode encodeModeMaybe
                        , node = node
                        , thingToEncode = EncodeThis givenKey
                        , parentNotifier = parentNotifier
                        , pendingCounter = Change.unmatchableCounter
                        }

                valueEncoder givenValue =
                    getNodeEncoder valueCodec
                        { mode = Maybe.withDefault defaultEncodeMode encodeModeMaybe
                        , node = node
                        , thingToEncode = EncodeThis givenValue
                        , parentNotifier = parentNotifier
                        , pendingCounter = Change.unmatchableCounter
                        }
            in
            case newEntry of
                RepDict.Cleared key ->
                    keyEncoder key

                RepDict.Present key value ->
                    keyEncoder key ++ valueEncoder value

        entryChanger node encodeModeMaybe parentNotifier newEntry =
            Change.NewPayload (entryRonEncoder node encodeModeMaybe parentNotifier newEntry)

        entryRonDecoder : Node -> Change.PendingCounter -> Maybe Moment -> JE.Value -> Maybe (RepDictEntry k v)
        entryRonDecoder node childPendingCounter cutoff encodedEntry =
            let
                decodeKey encodedKey =
                    JD.decodeValue (getNodeDecoder keyCodec { node = node, pendingCounter = childPendingCounter, parentNotifier = identity, cutoff = cutoff }) encodedKey

                decodeValue encodedValue =
                    JD.decodeValue (getNodeDecoder valueCodec { node = node, pendingCounter = childPendingCounter, parentNotifier = identity, cutoff = cutoff }) encodedValue
            in
            case JD.decodeValue (JD.list JD.value) encodedEntry of
                Ok (keyEncoded :: [ valueEncoded ]) ->
                    case ( decodeKey keyEncoded, decodeValue valueEncoded ) of
                        ( Ok (Ok key), Ok (Ok value) ) ->
                            Just (Present key value)

                        _ ->
                            Debug.todo "found key and value but not able to decode them"

                Ok [ keyEncoded ] ->
                    case decodeKey keyEncoded of
                        Ok (Ok key) ->
                            Just (Cleared key)

                        _ ->
                            Debug.todo "found just key alone but not able to decode it"

                other ->
                    Debug.todo "the dict entry wasn't in the expected shape"

        repDictRonDecoder : NodeDecoder e (RepDict k v)
        repDictRonDecoder ({ node, pendingCounter, parentNotifier, cutoff } as details) =
            let
                pending =
                    Change.usePendingCounter 0 pendingCounter

                object foundObjectIDs =
                    Node.getObject { node = node, cutoff = cutoff, foundIDs = foundObjectIDs, pendingID = pending.id, reducer = RepDict.reducerID, parentNotifier = parentNotifier }

                repDictBuilder foundObjects =
                    Ok <| RepDict.buildFromReplicaDb (object foundObjects) (entryRonDecoder node pending.passToChild cutoff) (entryChanger node Nothing parentNotifier) keyToString []
            in
            JD.map repDictBuilder concurrentObjectIDsDecoder

        repDictRonEncoder : NodeEncoder (RepDict k v)
        repDictRonEncoder ({ node, thingToEncode, mode, parentNotifier, pendingCounter } as details) =
            case thingToEncode of
                EncodeThis existingRepDict ->
                    changeToChangePayload <|
                        Chunk
                            { target = RepDict.getPointer existingRepDict
                            , objectChanges = List.map (\( k, v ) -> entryChanger node (Just mode) parentNotifier (Present k v)) (RepDict.getInit existingRepDict)
                            }

                _ ->
                    changeToChangePayload <|
                        Chunk
                            { target = Change.PlaceholderPointer RepList.reducerID (Change.usePendingCounter 0 pendingCounter).id identity
                            , objectChanges = []
                            }

        initializer : Int -> List ( k, v ) -> RepDict k v
        initializer key initMembers =
            let
                pending =
                    Change.usePendingCounter key Change.firstPendingCounter

                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], pendingID = pending.id, reducer = RepDb.reducerID, parentNotifier = identity }
            in
            RepDict.buildFromReplicaDb object (entryRonDecoder Node.testNode pending.passToChild Nothing) (entryChanger Node.testNode Nothing identity) keyToString initMembers
    in
    Codec
        { bytesEncoder = bytesEncoder
        , bytesDecoder = BD.fail
        , jsonEncoder = jsonEncoder
        , jsonDecoder = JD.fail "no repdict"
        , nodeEncoder = Just repDictRonEncoder
        , nodeDecoder = Just repDictRonDecoder
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
primitiveDict : Codec e comparable -> Codec e a -> Codec e (Dict comparable a)
primitiveDict keyCodec valueCodec =
    primitiveList (tuple keyCodec valueCodec)
        |> mapHelper (Result.map Dict.fromList) Dict.toList


{-| Codec for serializing a `Set`
-}
primitiveSet : Codec e comparable -> Codec e (Set comparable)
primitiveSet codec =
    primitiveList codec |> mapHelper (Result.map Set.fromList) Set.toList


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
quickEnum : a -> List a -> Codec e a
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
            case thingToEncode of
                EncodeThis givenInt ->
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


{-| Add an un-reorderable fieldR to the record we are creating a codec for.
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
        , init = \_ same -> same
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


type FieldFallback parentSeed fieldSeed fieldType
    = Default fieldType
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
        , nodeDecoder : RegisterFieldDecoder errs full remaining
        , nodeInitializer : RegisterFieldInitializer s full remaining
        }


record : remaining -> PartialRegister errs i full remaining
record remainingConstructor =
    PartialRegister
        { bytesEncoder = \_ -> []
        , bytesDecoder = BD.succeed (Ok remainingConstructor)
        , jsonEncoders = []
        , jsonArrayDecoder = JD.succeed (Ok remainingConstructor)
        , fieldIndex = 0
        , nodeEncoders = []
        , nodeDecoder = \_ _ -> ( remainingConstructor, [] )
        }


fieldDefaultMaybe fallback =
    case fallback of
        Default default ->
            Just default

        InitWithParentSeed _ ->
            Nothing


{-| Not exposed - for all `readable` functions
-}
readableHelper : FieldIdentifier -> (full -> fieldType) -> RepCodec errs fieldSeed fieldType -> FieldFallback parentSeed fieldSeed fieldType -> PartialRegister errs parentSeed full (fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
readableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec fallback (PartialRegister recordCodecSoFar) =
    let
        jsonObjectFieldKey =
            -- For now, just stick number and name together.
            fieldName ++ String.fromInt fieldSlot

        addToPartialBytesEncoderList existingRecord =
            -- Tack on the new encoder to the big list of all the encoders
            (getBytesEncoder fieldCodec <| fieldGetter existingRecord) :: recordCodecSoFar.bytesEncoder existingRecord

        addToPartialJsonEncoderList =
            -- Tack on the new encoder to the big list of all the encoders
            ( jsonObjectFieldKey, getJsonEncoder fieldCodec << fieldGetter ) :: recordCodecSoFar.jsonEncoders

        nodeDecoder : RegisterFieldDecoder errs full remaining
        nodeDecoder inputs inputRegister =
            let
                ( thisFieldValue, thisFieldErrors ) =
                    registerReadOnlyFieldDecoder ( fieldSlot, fieldName ) fallback fieldCodec inputs inputRegister

                ( remainingRecordConstructor, soFarErrors ) =
                    recordCodecSoFar.nodeDecoder inputs inputRegister
            in
            ( remainingRecordConstructor thisFieldValue, soFarErrors ++ thisFieldErrors )
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
        , fieldIndex = recordCodecSoFar.fieldIndex + 1
        , nodeEncoders = newRegisterFieldEncoderEntry ( fieldSlot, fieldName ) (fieldDefaultMaybe fallback) fieldCodec :: recordCodecSoFar.nodeEncoders
        , nodeDecoder = nodeDecoder
        }


{-| Not exposed - for all `writable` functions
-}
writableHelper : FieldIdentifier -> (full -> RW fieldType) -> RepCodec errs fieldSeed fieldType -> FieldFallback parentSeed fieldSeed fieldType -> PartialRegister errs parentSeed full (RW fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
writableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec fallback (PartialRegister recordCodecSoFar) =
    let
        jsonObjectFieldKey =
            -- For now, just stick number and name together.
            fieldName ++ String.fromInt fieldSlot

        addToPartialBytesEncoderList existingRecord =
            -- Tack on the new encoder to the big list of all the encoders
            (getBytesEncoder fieldCodec <| .get (fieldGetter existingRecord)) :: recordCodecSoFar.bytesEncoder existingRecord

        addToPartialJsonEncoderList =
            -- Tack on the new encoder to the big list of all the encoders
            ( jsonObjectFieldKey, getJsonEncoder fieldCodec << (.get << fieldGetter) ) :: recordCodecSoFar.jsonEncoders

        nodeDecoder : RegisterFieldDecoder errs full remaining
        nodeDecoder inputs inputRegister =
            let
                ( thisFieldValue, thisFieldErrors ) =
                    registerWritableFieldDecoder ( fieldSlot, fieldName ) fallback fieldCodec inputs inputRegister

                ( remainingRecordConstructor, soFarErrors ) =
                    recordCodecSoFar.nodeDecoder inputs inputRegister
            in
            ( remainingRecordConstructor thisFieldValue, soFarErrors ++ thisFieldErrors )
    in
    PartialRegister
        { bytesEncoder = addToPartialBytesEncoderList
        , bytesDecoder = BD.fail
        , jsonEncoders = addToPartialJsonEncoderList
        , jsonArrayDecoder = JD.fail "Can't use RW wrapper with JSON decoding"
        , fieldIndex = recordCodecSoFar.fieldIndex + 1
        , nodeEncoders = newRegisterFieldEncoderEntry ( fieldSlot, fieldName ) (fieldDefaultMaybe fallback) fieldCodec :: recordCodecSoFar.nodeEncoders
        , nodeDecoder = nodeDecoder
        }


{-| Read a record field.
The last argument specifies a default value, which is used when initializing the record for the first time.

  - Your code will not be able to make changes to this fieldR, only read the value set by other sources. Consider "writable" if you want a read+write field. You will need to prefix your field's type with `RW`.
  - Consider setting the default to the "most popular" value (e.g. "scaling factor" set to 1.0), as it will be omitted from the serialized data, saving space and bandwidth.
  - Consider setting the default to the "safest" value, as missing fields will be parsed as the default.
  - If you can't come up with a sensible default value (e.g. date of birth), consider wrapping the fieldR in `Maybe` or `Result`, with e.g. `Nothing` or `Err Unset` as the default.
  - If there's no sensible default and this record is not useful with missing data unless you add another validation step ("Parse, Don't Validate"!), consider `readableRequired` as a last resort.

-}
fieldR : FieldIdentifier -> (full -> fieldType) -> Codec errs fieldType -> fieldType -> PartialRegister errs i full (fieldType -> remaining) -> PartialRegister errs i full remaining
fieldR ( fieldSlot, fieldName ) fieldGetter fieldCodec fieldDefault soFar =
    readableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec (Default fieldDefault) soFar


{-| Read a `Maybe something` field without adding the `maybe` codec. Default is Nothing.

  - If your fieldR will more often be set to something else (e.g. `Just 0`), consider using `readable` with your `maybe`-wrapped codec instead and using the common value as the default. This will save space and bandwidth.

-}
maybeR : FieldIdentifier -> (full -> Maybe justFieldType) -> Codec errs justFieldType -> PartialRegister errs i full (Maybe justFieldType -> remaining) -> PartialRegister errs i full remaining
maybeR fieldID fieldGetter fieldCodec recordBuilt =
    readableHelper fieldID fieldGetter (maybe fieldCodec) (Default Nothing) recordBuilt


{-| Read a `RepList` field without adding the `repList` codec. Default is an empty `RepList`.

  - Will not work with primitive `List` fields. For that, use the `immutableList` codec with `field`.
  - Default is an empty RepList. Want a different default? Use `field` with the `repList` codec.
  - If any items in the RepList are corrupted, they will be silently excluded.
  - If your fieldR is not a `RepList` but a type that wraps one (or more), you will need to use `field` or `fieldRW` with the `repList` codec instead.

-}
fieldList : FieldIdentifier -> (full -> RepList memberType) -> RepCodec errs memberSeed memberType -> PartialRegister errs i full (RepList memberType -> remaining) -> PartialRegister errs i full remaining
fieldList fieldID fieldGetter fieldCodec recordBuilt =
    readableHelper fieldID fieldGetter (repList fieldCodec) (InitWithParentSeed (\parentSeed -> [])) recordBuilt


{-| Read a `RepDict` field without adding the `repDict` codec. Default is an empty `RepDict`. Instead of supplying a single codec for members, you provide a pair of codec in a tuple, e.g. `(string, bool)`.

  - Will not yet work with primitive `Dict` fields. For that, use the `immutableList` codec with `field`.
  - Default is an empty RepDict. Want a different default? Use `field` with the `repDict` codec.
  - If any items in the RepDict are corrupted, they will be silently excluded.
  - If your fieldR is not a `RepDict` but a type that wraps one (or more), you will need to use `field` or `fieldRW` with the `repDict` codec instead.

-}
fieldDict : FieldIdentifier -> (full -> RepDict keyType valueType) -> ( Codec errs keyType, Codec errs valueType ) -> PartialRegister errs i full (RepDict keyType valueType -> remaining) -> PartialRegister errs i full remaining
fieldDict fieldID fieldGetter ( keyCodec, valueCodec ) recordBuilt =
    readableHelper fieldID fieldGetter (repDict keyCodec valueCodec) (InitWithParentSeed (\parentSeed -> [])) recordBuilt


{-| Read a `RepDb` field without adding the `repDb` codec. Default is an empty `RepDb`.

  - If any items in the RepDb are corrupted, they will be silently excluded.
  - If your field is not a `RepDb` but a type that wraps one (or more), you will need to use `field` or `fieldRW` with the `repDb` codec instead.

-}
fieldDb : FieldIdentifier -> (full -> RepDb memberType) -> Codec errs memberType -> PartialRegister errs i full (RepDb memberType -> remaining) -> PartialRegister errs i full remaining
fieldDb fieldID fieldGetter fieldCodec recordBuilt =
    readableHelper fieldID fieldGetter (repDb fieldCodec) (InitWithParentSeed (\parentSeed -> [])) recordBuilt


{-| Read a record field wrapped with `RW`. This makes the fieldR writable.
The last argument specifies a default value, which is used when initializing the record for the first time.

  - Due to the RW wrapper, you will need to add `.get` to the output whenever you want to access the field's latest value as usual. Read-only fields do not require this.
  - Thanks to the RW wrapper, you can add `.set` to the output anywhere in your program to produce a `Change`. These changes can then be saved, updating the stored value.
  - Consider setting the default to the "most popular" value (e.g. "scaling factor" set to 1.0), as it will be omitted from the serialized data, saving space and bandwidth.
  - Consider setting the default to the "safest" value, as missing fields will be parsed as the default.
  - If you can't come up with a sensible default value (e.g. date of birth), consider wrapping the fieldR in `Maybe` or `Result`, with e.g. `Nothing` or `Err Unset` as the default.
  - If there's no sensible default and this record is not useful with missing data unless you add another validation step ("Parse, Don't Validate"!), consider `readableRequired` as a last resort.

-}
maybeRW : FieldIdentifier -> (full -> RW (Maybe fieldType)) -> Codec errs fieldType -> PartialRegister errs i full (RW (Maybe fieldType) -> remaining) -> PartialRegister errs i full remaining
maybeRW fieldIdentifier fieldGetter fieldCodec soFar =
    writableHelper fieldIdentifier fieldGetter (maybe fieldCodec) (Default Nothing) soFar


{-| Read a `Maybe` record field wrapped with `RW`. This makes the fieldR writable.
The last argument specifies a default value, which is used when initializing the record for the first time.

  - Due to the RW wrapper, you will need to add `.get` to the output whenever you want to access the field's latest value as usual. Read-only fields do not require this.
  - Thanks to the RW wrapper, you can add `.set` to the output anywhere in your program to produce a `Change`. These changes can then be saved, updating the stored value.
  - Consider setting the default to the "most popular" value (e.g. "scaling factor" set to 1.0), as it will be omitted from the serialized data, saving space and bandwidth.
  - Consider setting the default to the "safest" value, as missing fields will be parsed as the default.
  - If you can't come up with a sensible default value (e.g. date of birth), consider wrapping the fieldR in `Maybe` or `Result`, with e.g. `Nothing` or `Err Unset` as the default.
  - If there's no sensible default and this record is not useful with missing data unless you add another validation step ("Parse, Don't Validate"!), consider `readableRequired` as a last resort.

-}
fieldRW : FieldIdentifier -> (full -> RW fieldType) -> Codec errs fieldType -> fieldType -> PartialRegister errs i full (RW fieldType -> remaining) -> PartialRegister errs i full remaining
fieldRW fieldIdentifier fieldGetter fieldCodec fieldDefault soFar =
    writableHelper fieldIdentifier fieldGetter fieldCodec (Default fieldDefault) soFar


{-| Read a field that is required, yet has no sensible default. Use sparingly.

  - Only add required fields BEFORE using in production for the first time.
  - NEVER add required fields after that, or old data may be seen as corrupt.
  - Useful for "Parse, Don't Validate" as you can use this to avoid extra validation later, e.g. `Maybe` wrappers on fields that should never be missing.
  - Will it be essential forever? Once you require a field, you can't make it optional later - omitted values from new clients will be seen as corrupt by old ones!
  - Consider if this field being set upfront is essential to this record. For graceful degradation, records missing essential fields will be omitted from any containing collections. If the field is in your root object, it may fail to parse entirely. (And that's exactly what you would want, if this field were truly essential.)

-}
coreR : FieldIdentifier -> (full -> fieldType) -> RepCodec errs fieldSeed fieldType -> (parentSeed -> fieldSeed) -> PartialRegister errs parentSeed full (fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
coreR fieldID fieldGetter fieldCodec seeder recordBuilt =
    readableHelper fieldID fieldGetter fieldCodec (InitWithParentSeed seeder) recordBuilt


{-| Read and Write a core field. A core field is both required, AND has no sensible default. Prefer non-core fields when possible.

Including any core fields in your register will force you to pass in a "seed" any time you initialize it. The seed value contains whatever you need to initialize all the core fields. Registers that do not need seeds are more robust to serialization!

  - If this field is truly unique to the register upon initialization, does it really need to be writable? Consider using `coreR` instead, so your code can initialize the field with a seed but not accidentally modify it later.

-}
coreRW : FieldIdentifier -> (full -> RW fieldType) -> RepCodec errs fieldSeed fieldType -> (parentSeed -> fieldSeed) -> PartialRegister errs parentSeed full (RW fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
coreRW fieldID fieldGetter fieldCodec seeder recordBuilt =
    writableHelper fieldID fieldGetter fieldCodec (InitWithParentSeed seeder) recordBuilt


{-| Read a field that is not needs a seed.
Pass in a `(\parentSeed -> fieldSeed)` function, which gives you access to the parent's seed, if it has one. Otherwise, that's just `()` The return value will be used to seed the field.

  - Does your field actually need to be available as soon as the parent exists? If not, consider wrapping it in something like `Maybe` so you can give a it a default of `Nothing` and seed it when you actually need it. Then you don't need a seed from the parent.
  - You can use this to seed the field with a constant, ignoring the parent seed like `(\_ -> [1,2,3])` if you need that for some reason. But if a constant works, your field's type can probably be made seedless anyway. You can also just use a field default, rather than seeding, so your parent register can be seedless.

-}
seededR : FieldIdentifier -> (full -> fieldType) -> RepCodec errs fieldSeed fieldType -> fieldType -> (parentSeed -> fieldSeed) -> PartialRegister errs parentSeed full (fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
seededR fieldID fieldGetter fieldCodec default seeder recordBuilt =
    readableHelper fieldID fieldGetter fieldCodec (DefaultAndInitWithParentSeed default seeder) recordBuilt


{-| Read/Write a field that needs a seed.
Pass in a `(\parentSeed -> fieldSeed)` function, which gives you access to the parent's seed, if it has one. Otherwise, that's just `()` The return value will be used to seed the field.

  - Does your field actually need to be available as soon as the parent exists? If not, consider wrapping it in something like `Maybe` so you can give a it a default of `Nothing` and seed it when you actually need it. Then you don't need a seed from the parent.
  - You can use this to seed the field with a constant, ignoring the parent seed like `(\_ -> [1,2,3])` if you need that for some reason. But if a constant works, your field's type can probably be made seedless anyway. You can also just use a field default, rather than seeding, so your parent register can be seedless.

-}
seededRW : FieldIdentifier -> (full -> RW fieldType) -> RepCodec errs fieldSeed fieldType -> fieldType -> (parentSeed -> fieldSeed) -> PartialRegister errs parentSeed full (RW fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
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
updateRegisterPostChildInit : Register a -> FieldIdentifier -> Change -> Change
updateRegisterPostChildInit parentRegister fieldIdentifier changeToWrap =
    Change.Chunk
        { target =
            Register.getPointer parentRegister
        , objectChanges =
            [ Change.NewPayload (encodeFieldPayloadAsObjectPayload fieldIdentifier (changeToChangePayload changeToWrap)) ]
        }


{-| RON what to do when decoding a (potentially nested!) object field.
-}
registerReadOnlyFieldDecoder : ( FieldSlot, FieldName ) -> FieldFallback parentSeed fieldSeed fieldType -> RepCodec e fieldSeed fieldType -> RegisterFieldDecoderInputs -> Register record -> ( fieldType, List (Error e) )
registerReadOnlyFieldDecoder (( fieldSlot, fieldName ) as fieldIdentifier) fallback fieldCodec inputs parent =
    let
        runFieldDecoder thingToDecode =
            JD.decodeValue
                (getNodeDecoder fieldCodec
                    { node = inputs.node, pendingCounter = inputs.pendingCounter, parentNotifier = updateRegisterPostChildInit parent fieldIdentifier, cutoff = inputs.cutoff }
                )
                thingToDecode

        default =
            case fallback of
                Default defaultGiven ->
                    defaultGiven

                InitWithParentSeed seedToFieldType ->
                    -- TODO zero is probably not a good choice
                    init fieldCodec 0 (seedToFieldType inputs.parentSeed)

        nestedCodecIsObject =
            False
    in
    case nestedCodecIsObject of
        False ->
            case getFieldLatestOnly parent fieldIdentifier of
                Nothing ->
                    -- field was never set - fall back to default
                    ( default, [] )

                Just foundField ->
                    -- fieldR was set - decode value and use it
                    case runFieldDecoder (Op.payloadToJsonValue foundField) of
                        Ok (Ok goodValue) ->
                            ( goodValue, [] )

                        Ok (Err problem) ->
                            ( default, [ problem ] )

                        Err jsonDecodeError ->
                            ( default, [ JDError jsonDecodeError ] )

        True ->
            -- let
            --     fieldUUIDHistoryList =
            --         getFieldHistoryValues parent ( fieldSlot, fieldName )
            --             |> List.concatMap Nonempty.toList
            --
            --     allNestedObjects =
            --         runFieldDecoder (JE.list Op.atomToJsonValue fieldUUIDHistoryList)
            -- in
            -- case allNestedObjects of
            --     Ok something ->
            --         -- there was a set value AND it decoded successfully
            --         JD.succeed something
            --
            --     Err problem ->
            --         -- there was no value set OR it failed to decode
            --         Debug.todo ("failed to decode UUID list: " ++ JD.errorToString problem)
            Debug.todo "we need to handle multiple concurrent object IDs"


registerWritableFieldDecoder : ( FieldSlot, FieldName ) -> FieldFallback parentSeed fieldSeed fieldType -> RepCodec e fieldSeed fieldType -> RegisterFieldDecoderInputs -> Register record -> ( RW fieldType, List (Error e) )
registerWritableFieldDecoder fieldIdentifier fallback fieldCodec inputs parent =
    let
        fieldEncoder newValue =
            getNodeEncoder fieldCodec
                { node = inputs.node
                , mode = defaultEncodeMode
                , thingToEncode = EncodeThis newValue
                , parentNotifier = updateRegisterPostChildInit parent fieldIdentifier
                , pendingCounter = inputs.pendingCounter -- TODO increment?
                }

        wrapRW : Change.Pointer -> fieldType -> RW fieldType
        wrapRW targetObject head =
            buildRW targetObject fieldIdentifier fieldEncoder head

        ( readHelpOutputFieldType, readHelpOutputErrors ) =
            registerReadOnlyFieldDecoder fieldIdentifier fallback fieldCodec inputs parent
    in
    ( wrapRW (Register.getPointer parent) readHelpOutputFieldType, readHelpOutputErrors )


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
This is a Register, stripped of its wrapper.
-}
finishRecord : PartialRegister errs () full full -> RepCodec errs () full
finishRecord partial =
    let
        finishedRegister : RepCodec errs () (Register full)
        finishedRegister =
            finishRegister partial

        unwrapRecord =
            Debug.todo "override individual"
    in
    unwrapRecord


{-| Finish creating a codec for a register.
-}
finishRegister : PartialRegister errs () full full -> RepCodec errs () (Register full)
finishRegister ((PartialRegister allFieldsCodec) as partialRegister) =
    let
        encodeAsJsonObject reg =
            let
                fullRecord =
                    Register.latest reg

                passFullRecordToFieldEncoder ( fieldKey, fieldEncoder ) =
                    ( fieldKey, fieldEncoder fullRecord )
            in
            JE.object (List.map passFullRecordToFieldEncoder allFieldsCodec.jsonEncoders)

        encodeAsDictList fullRecord =
            JE.list (encodeEntryInDictList fullRecord) allFieldsCodec.jsonEncoders

        encodeEntryInDictList fullRecord ( fieldKey, entryValueEncoder ) =
            JE.list identity [ JE.string fieldKey, entryValueEncoder fullRecord ]

        nodeDecoder : NodeDecoder errs (Register full)
        nodeDecoder { node, pendingCounter, parentNotifier, cutoff } =
            let
                registerDecoder : List ObjectID -> JD.Decoder (Result (Error errs) (Register full))
                registerDecoder objectIDs =
                    let
                        pending =
                            Change.usePendingCounter 0 pendingCounter

                        object =
                            Node.getObject { node = node, cutoff = cutoff, foundIDs = objectIDs, pendingID = pending.id, reducer = registerReducerID, parentNotifier = parentNotifier }

                        regToRecord givenCutoff reg =
                            allFieldsCodec.nodeDecoder { node = node, pendingCounter = pending.passToChild, parentNotifier = parentNotifier, cutoff = givenCutoff } reg
                                -- TODO currently ignoring errors
                                |> Tuple.first
                    in
                    JD.succeed <| Ok <| Register.build object regToRecord
            in
            JD.andThen registerDecoder concurrentObjectIDsDecoder

        nodeEncoder : NodeEncoder (Register full)
        nodeEncoder inputs =
            registerNodeEncoder partialRegister
                Nothing
                { thingToEncode = inputs.thingToEncode
                , mode = inputs.mode
                , node = inputs.node
                , parentNotifier = inputs.parentNotifier
                , pendingCounter = inputs.pendingCounter
                }

        emptyRegister key seed =
            let
                pending =
                    Change.usePendingCounter key Change.unmatchableCounter

                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], pendingID = pending.id, reducer = registerReducerID, parentNotifier = identity }

                regToRecord cutoff =
                    allFieldsCodec.nodeInitializer
            in
            Register.build object regToRecord

        bytesDecoder : BD.Decoder (Result (Error errs) (Register full))
        bytesDecoder =
            -- TODO use allFieldsCodec.bytesDecoder
            BD.succeed <| Ok <| emptyRegister Nothing

        jsonDecoder : JD.Decoder (Result (Error errs) (Register full))
        jsonDecoder =
            -- TODO use allFieldsCodec.jsonArrayDecoder
            JD.succeed <| Ok <| emptyRegister Nothing
    in
    Codec
        { nodeEncoder = Just nodeEncoder
        , nodeDecoder = Just nodeDecoder
        , bytesEncoder = \reg -> (allFieldsCodec.bytesEncoder >> List.reverse >> BE.sequence) (Register.latest reg)
        , bytesDecoder = bytesDecoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = jsonDecoder
        , init = \key initialInputs -> emptyRegister key initialInputs
        }


{-| Finish creating a codec for a register that needs a seed.
-}
finishSeededRegister : PartialRegister errs s full full -> RepCodec errs s (Register full)
finishSeededRegister ((PartialRegister allFieldsCodec) as partialRegister) =
    let
        encodeAsJsonObject reg =
            let
                fullRecord =
                    Register.latest reg

                passFullRecordToFieldEncoder ( fieldKey, fieldEncoder ) =
                    ( fieldKey, fieldEncoder fullRecord )
            in
            JE.object (List.map passFullRecordToFieldEncoder allFieldsCodec.jsonEncoders)

        encodeAsDictList fullRecord =
            JE.list (encodeEntryInDictList fullRecord) allFieldsCodec.jsonEncoders

        encodeEntryInDictList fullRecord ( fieldKey, entryValueEncoder ) =
            JE.list identity [ JE.string fieldKey, entryValueEncoder fullRecord ]

        nodeDecoder : NodeDecoder errs (Register full)
        nodeDecoder { node, pendingCounter, parentNotifier, cutoff } =
            let
                registerDecoder : List ObjectID -> JD.Decoder (Result (Error errs) (Register full))
                registerDecoder objectIDs =
                    let
                        pending =
                            Change.usePendingCounter 0 pendingCounter

                        object =
                            Node.getObject { node = node, cutoff = cutoff, foundIDs = objectIDs, pendingID = pending.id, reducer = registerReducerID, parentNotifier = parentNotifier }

                        regToRecord givenCutoff reg =
                            allFieldsCodec.nodeDecoder { node = node, pendingCounter = pending.passToChild, parentNotifier = parentNotifier, cutoff = givenCutoff } reg
                                -- TODO currently ignoring errors
                                |> Tuple.first
                    in
                    JD.succeed <| Ok <| Register.build object regToRecord
            in
            JD.andThen registerDecoder concurrentObjectIDsDecoder

        nodeEncoder : NodeEncoder (Register full)
        nodeEncoder inputs =
            registerNodeEncoder partialRegister
                Nothing
                { thingToEncode = inputs.thingToEncode
                , mode = inputs.mode
                , node = inputs.node
                , parentNotifier = inputs.parentNotifier
                , pendingCounter = inputs.pendingCounter
                }

        emptyRegister key seed =
            let
                pending =
                    Change.usePendingCounter key Change.unmatchableCounter

                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], pendingID = pending.id, reducer = registerReducerID, parentNotifier = identity }

                regToRecord cutoff reg =
                    allFieldsCodec.nodeInitializer seed reg
            in
            Register.build object regToRecord

        bytesDecoder : BD.Decoder (Result (Error errs) (Register full))
        bytesDecoder =
            -- TODO use allFieldsCodec.bytesDecoder
            BD.fail

        jsonDecoder : JD.Decoder (Result (Error errs) (Register full))
        jsonDecoder =
            -- TODO use allFieldsCodec.jsonArrayDecoder
            JD.fail "Need to add decoder to reptype"
    in
    Codec
        { nodeEncoder = Just nodeEncoder
        , nodeDecoder = Just nodeDecoder
        , bytesEncoder = \reg -> (allFieldsCodec.bytesEncoder >> List.reverse >> BE.sequence) (Register.latest reg)
        , bytesDecoder = bytesDecoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = jsonDecoder
        , init = \key initialInputs -> emptyRegister key initialInputs
        }


type alias FieldPayload =
    Nonempty Op.OpPayloadAtom


type alias FieldHistoryBackwards =
    Nonempty ( OpID, FieldPayload )


type alias FieldHistoryDict =
    Dict FieldSlot FieldHistoryBackwards


registerReducerID : Op.ReducerID
registerReducerID =
    "lww"


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


encodeFieldPayloadAsObjectPayload : FieldIdentifier -> List Change.Atom -> List Change.Atom
encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) fieldPayload =
    [ Change.RonAtom (Op.IntegerAtom fieldSlot)
    , Change.RonAtom (Op.NakedStringAtom fieldName)
    ]
        ++ fieldPayload


getFieldLatestOnly : FieldHistoryDict -> FieldIdentifier -> Maybe FieldPayload
getFieldLatestOnly fields ( fieldSlot, _ ) =
    Dict.get fieldSlot fields
        |> Maybe.map Nonempty.head
        |> Maybe.map Tuple.second


getFieldHistory : FieldHistoryDict -> FieldIdentifier -> List ( OpID, FieldPayload )
getFieldHistory fields ( desiredFieldSlot, name ) =
    Dict.get desiredFieldSlot fields
        |> Maybe.map Nonempty.toList
        |> Maybe.withDefault []


getFieldHistoryValues : FieldHistoryDict -> FieldIdentifier -> List FieldPayload
getFieldHistoryValues fields field =
    List.map Tuple.second (getFieldHistory fields field)


type alias RW fieldVal =
    { get : fieldVal
    , set : fieldVal -> Change
    }


buildRW : Change.Pointer -> FieldIdentifier -> (fieldVal -> List Change.Atom) -> fieldVal -> RW fieldVal
buildRW targetObject ( fieldSlot, fieldName ) nestedRonEncoder latestValue =
    let
        nestedChange newValue =
            encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) (nestedRonEncoder newValue)
    in
    { get = latestValue
    , set = \new -> Change.Chunk { target = targetObject, objectChanges = [ Change.NewPayload (nestedChange new) ] }
    }


type alias RWH fieldVal =
    { get : fieldVal
    , set : fieldVal -> Change
    , history : List ( OpID, fieldVal )
    }


buildRWH : Change.Pointer -> FieldIdentifier -> (fieldVal -> List Change.Atom) -> fieldVal -> List ( OpID, fieldVal ) -> RWH fieldVal
buildRWH targetObject ( fieldSlot, fieldName ) nestedRonEncoder latestValue rest =
    let
        nestedChange newValue =
            encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) (nestedRonEncoder newValue)
    in
    { get = latestValue
    , set = \new -> Change.Chunk { target = targetObject, objectChanges = [ Change.NewPayload (nestedChange new) ] }
    , history = rest
    }


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
registerNodeEncoder : PartialRegister errs i full full -> Maybe i -> NodeEncoderInputs (Register full) -> Change.PotentialPayload
registerNodeEncoder (PartialRegister allFieldsCodec) seedMaybe ({ node, thingToEncode, mode, pendingCounter, parentNotifier } as details) =
    let
        registerMaybe =
            case thingToEncode of
                EncodeThis reg ->
                    Just reg

                JustEncodeDefaultsIfNeeded ->
                    Maybe.map fallbackRegister seedMaybe

        fallbackObject =
            Node.getObject { node = node, cutoff = Nothing, foundIDs = [], pendingID = pending.id, reducer = registerReducerID, parentNotifier = parentNotifier }

        fallbackRegister seed =
            Register.build fallbackObject regToRecord

        regToRecord cutoff reg =
            -- this would never get used, right? just to make the build function happy, but we're only encoding defaults here, of a placeholder object
            allFieldsCodec.nodeDecoder { node = node, pendingCounter = pendingCounter, parentNotifier = parentNotifier, cutoff = cutoff } reg
                |> Tuple.first

        pending =
            Change.usePendingCounter 0 pendingCounter
    in
    case registerMaybe of
        Just register ->
            let
                target =
                    Register.getPointer register

                updateMePostChildInit fieldChangedPayload =
                    Change.Chunk
                        { target = target
                        , objectChanges = [ Change.NewPayload fieldChangedPayload ]
                        }

                subChanges : List Change.ObjectChange
                subChanges =
                    let
                        runSubEncoder : Int -> (RegisterFieldEncoderInputs full -> RegisterFieldEncoderOutput) -> Maybe Change.ObjectChange
                        runSubEncoder index subEncoderFunction =
                            subEncoderFunction
                                { node = node
                                , register = register
                                , mode = mode
                                , pendingCounter = (Change.usePendingCounter index pending.passToChild).passToChild
                                , updateRegisterAfterChildInit = updateMePostChildInit -- wraps overall object change, but field encoders wrap specific field payload subchanges
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

        Nothing ->
            []


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
newRegisterFieldEncoderEntry : FieldIdentifier -> Maybe fieldType -> RepCodec e fieldSeed fieldType -> (RegisterFieldEncoderInputs full -> RegisterFieldEncoderOutput)
newRegisterFieldEncoderEntry ( fieldSlot, fieldName ) fieldDefaultIfApplies fieldCodec { mode, register, node, updateRegisterAfterChildInit, pendingCounter } =
    let
        runFieldRonEncoder value =
            getNodeEncoder fieldCodec
                { mode = mode
                , node = node
                , thingToEncode = value
                , parentNotifier =
                    \changeToWrap ->
                        updateRegisterAfterChildInit
                            (encodeFieldPayloadAsObjectPayload
                                ( fieldSlot, fieldName )
                                (changeToChangePayload changeToWrap)
                            )
                , pendingCounter = pendingCounter -- Already "used" by register encoder
                }

        wrapFieldEncoderOutput : fieldType -> Change.PotentialPayload
        wrapFieldEncoderOutput value =
            let
                wrapper =
                    encodeFieldPayloadAsObjectPayload
                        ( fieldSlot, fieldName )
            in
            wrapper (runFieldRonEncoder (EncodeThis value))

        -- attemptRegisterOverride : a -> ThingToEncode a
        -- attemptRegisterOverride fallbackValue =
        --     -- TODO instead of this, check nested encoder's output for a single QuoteNestedObject atom that indicates output from a Register encoder.
        --     let
        --         hasNestedWritableObject =
        --             -- check to see if there's a nested object, otherwise no point checking for register override
        --             case fieldCodec of
        --                 Codec codecrecord ->
        --                     Maybe.Extra.isJust codecrecord.nodeEncoder
        --
        --         encodedSubRegisterPotentially =
        --             getFieldLatestOnly register ( fieldSlot, fieldName )
        --
        --         subRegisterObjectIDsMaybe : List ObjectID
        --         subRegisterObjectIDsMaybe =
        --             Maybe.withDefault [] (Maybe.map Nonempty.toList encodedSubRegisterPotentially)
        --                 |> extractQuotedObjects
        --
        --         subRegister =
        --             Register.build node (Change.usePendingCounter 0 pendingCounter).id (Node.getObject node subRegisterObjectIDsMaybe)
        --     in
        --     case hasNestedWritableObject of
        --         True ->
        --             EncodeRegisterFieldLookupInstead subRegister
        --
        --         False ->
        --             EncodeThis fallbackValue
        getValue =
            getFieldLatestOnly register ( fieldSlot, fieldName )

        encodedDefault fieldDefault =
            runFieldRonEncoder (EncodeThis fieldDefault)

        explicitDefaultIfNeeded fieldDefault =
            case ( mode.setDefaultsExplicitly, wrapFieldEncoderOutput fieldDefault ) of
                ( True, changePayloadHead :: changePayloadTail ) ->
                    -- only if we got something back from the encoder
                    EncodeThisField <| Change.NewPayload (changePayloadHead :: changePayloadTail)

                _ ->
                    SkipThisField
    in
    case fieldDefaultIfApplies of
        Just fieldDefault ->
            case getValue of
                Nothing ->
                    explicitDefaultIfNeeded fieldDefault

                Just foundPreviousValue ->
                    -- since encoders return ChangeAtoms, we need to wrap the fetched existing value in a ChangeAtom to compare to the default output.
                    if Change.compareToRonPayload (encodedDefault fieldDefault) (Nonempty.toList foundPreviousValue) then
                        explicitDefaultIfNeeded fieldDefault

                    else
                        EncodeThisField <| Change.NewPayload <| Nonempty.toList <| Nonempty.map Change.RonAtom foundPreviousValue

        Nothing ->
            case getValue of
                Nothing ->
                    SkipThisField

                Just foundPreviousValue ->
                    EncodeThisField <| Change.NewPayload <| Nonempty.toList <| Nonempty.map Change.RonAtom foundPreviousValue


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
                EncodeThis a ->
                    EncodeThis (toBytes_ a)

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
                EncodeThis a ->
                    EncodeThis (toBytes_ a)

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
                        EncodeThis encodeThing ->
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
            , thingToEncode = EncodeThis thingToEncode -- TODO would register instead be needed?
            , pendingCounter = modifiedEncoder.pendingCounter
            , parentNotifier = modifiedEncoder.parentNotifier
            }
    in
    \altInputs -> getNodeEncoder codec (finishInputs altInputs)
