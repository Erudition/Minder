module Replicated.ReplicaCodec exposing (..)

{-|


# Serialization

You have three options when encoding data. You can represent the data either as json, bytes, or a string.
Here's some advice when choosing:

  - If performance is important, use `encodeToJson` and `decodeFromJson`
  - If space efficiency is important, use `encodeToBytes` and `decodeFromBytes`\*
  - `encodeToString` and `decodeFromString` are good for URL safe strings but otherwise one of the other choices is probably better.

\*`encodeToJson` is more compact when encoding integers with 6 or fewer digits. You may want to try both `encodeToBytes` and `encodeToJson` and see which is better for your use case.

@docs encodeToJson, decodeFromJson, encodeToBytes, decodeFromBytes, encodeToString, decodeFromString


# Definition

@docs Codec, Error


# Primitives

@docs string, bool, float, int, unit, bytes, byte


# Data Structures

@docs maybe, list, array, dict, set, tuple, triple, result, enum


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
import Log
import Regex exposing (Regex)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Object as Object exposing (Object)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.OpID as OpID exposing (InCounter, OpID, OutCounter)
import Replicated.Reducer.Register as Register exposing (RW, Register(..), buildRW)
import Replicated.Reducer.RepSet as RepSet exposing (RepSet)
import Set exposing (Set)
import Toop exposing (T4(..), T5(..), T6(..), T7(..), T8(..))



-- CODEC DEFINITIONS


{-| Like a normal codec, but can have references instead of values, so must be passed the entire Replica so that some decoders may search elsewhere.
-}
type Codec e a
    = Codec
        { encoder : a -> BE.Encoder
        , decoder : BD.Decoder (Result (Error e) a)
        , jsonEncoder : a -> JE.Value
        , jsonDecoder : NestableJsonDecoder e a
        , ronEncoder : Maybe RonEncoder
        }



-- RON DEFINITIONS


type alias RonEncoderInputs =
    { node : Node
    , existingObjectIDMaybe : Maybe OpID.ObjectID
    , counter : InCounter
    , mode : ReplicaEncodeDepth
    }


type ReplicaEncodeDepth
    = MissingObjectsOnly
    | NonDefaultValues
    | IncludeDefaults


type alias ElsewhereData =
    Maybe ( Node, Maybe Register )


type alias NestableJsonDecoder e a =
    ElsewhereData -> JD.Decoder (Result (Error e) a)


type alias RonEncoder =
    RonEncoderInputs -> Op.Change


{-| The Ops formed by running nested ronEncoders. They always come first because the current encoder may rely on objects that have not been created yet.
RULE: If these Ops create something that needs to be referenced by its caller, the caller will assume the newly created object has the ID of the last Op in the list.
-}
type alias PrerequisiteOps =
    List Op


type alias RonFieldEncoder =
    RonFieldEncoderInputs -> RonFieldEncoderOutput


type alias RonFieldEncoderInputs =
    { node : Node
    , registerMaybe : Maybe Register -- no this MAY NOT exist yet, but it doesn't matter because
    , counter : InCounter
    , mode : ReplicaEncodeDepth
    }


type alias RonFieldEncoderOutput =
    { required : PrerequisiteOps
    , postPrereqCounter : OutCounter -- has only been used for prereqs & creation
    , opToWrite : Maybe UnfinishedOp -- no counters used at first
    }


{-| Since we must first publish each RonFieldEncoderEntry's prerequisite ops before assigning an OpIDs, we use a function that will later finish the Ops off with the next safe ID.

spits out OpID for next op to reference

-}
type alias UnfinishedOp =
    { counter : InCounter, opToReference : OpID, containingRegister : Register } -> ( Op, OutCounter, OpID )


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


version : Int
version =
    1



-- DECODE


{-| -}
decodeFromNode : Codec e a -> Node -> Result (Error e) a
decodeFromNode codec node =
    let
        oldDecoder =
            JD.index 0 JD.int
                |> JD.andThen
                    (\value ->
                        if value <= 0 then
                            Err DataCorrupted |> JD.succeed

                        else if value == version then
                            JD.index 1 (getJsonDecoder codec (Just ( node, Nothing )))

                        else
                            Err SerializerOutOfDate |> JD.succeed
                    )

        decoder =
            getJsonDecoder codec (Just ( node, Nothing ))
    in
    case node.root of
        Just rootID ->
            -- TODO we need to get rid of those quotes, but JD.string expects them for now
            case JD.decodeString decoder ("\"" ++ OpID.toString rootID ++ "\"") of
                Ok value ->
                    value

                Err something ->
                    Tuple.second ( Debug.log "problem decoding root" something, Err DataCorrupted )

        Nothing ->
            Debug.log "no root of node!" <| Err DataCorrupted


endian : Bytes.Endianness
endian =
    Bytes.BE


{-| Extracts the `Decoder` contained inside the `Codec`.
-}
getBytesDecoder : Codec e a -> BD.Decoder (Result (Error e) a)
getBytesDecoder (Codec m) =
    m.decoder


{-| Extracts the json `Decoder` contained inside the `Codec`.
-}
getJsonDecoder : Codec e a -> ElsewhereData -> JD.Decoder (Result (Error e) a)
getJsonDecoder (Codec m) elsewhereData =
    m.jsonDecoder elsewhereData


{-| Extracts the json `Decoder` contained inside the `Codec`.
-}
getNestableJsonDecoder : Codec e a -> NestableJsonDecoder e a
getNestableJsonDecoder (Codec m) =
    m.jsonDecoder


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
decodeFromString : Codec e a -> String -> Result (Error e) a
decodeFromString codec base64 =
    case decode base64 of
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
                            JD.index 1 (getJsonDecoder codec Nothing)

                        else
                            Err SerializerOutOfDate |> JD.succeed
                    )
    in
    case JD.decodeValue decoder json of
        Ok value ->
            value

        Err _ ->
            Err DataCorrupted


decode : String -> Maybe Bytes.Bytes
decode base64text =
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
getEncoder : Codec e a -> a -> BE.Encoder
getEncoder (Codec m) =
    m.encoder


{-| Extracts the replica encoding function contained inside the `Codec`.
-}
getRonEncoder : Codec e a -> Maybe RonEncoder
getRonEncoder (Codec m) =
    m.ronEncoder


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
        , value |> getEncoder codec
        ]
        |> BE.encode


{-| Convert an Elm value into a string. This string contains only url safe characters, so you can do the following:

    import Serlialize as S

    myUrl =
        "www.mywebsite.com/?data=" ++ S.encodeToString S.float 1234

and not risk generating an invalid url.

-}
encodeToURLString : Codec e a -> a -> String
encodeToURLString codec =
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


{-| Convert an Elm value into Ops.
-}
encodeToRon : Node -> InCounter -> Codec e a -> List Op
encodeToRon node counter codec =
    case getRonEncoder codec of
        Just ronEncoder ->
            .ops (ronEncoder { node = node, existingObjectIDMaybe = Nothing, counter = counter, mode = IncludeDefaults })

        Nothing ->
            []


{-| Convert an Elm value into Ops, capturing the root object's output ID.
-}
encodeToRonWithRootID : Node -> InCounter -> Codec e a -> ( List Op, Maybe OpID.ObjectID )
encodeToRonWithRootID node counter codec =
    case getRonEncoder codec of
        Just ronEncoder ->
            let
                encoded =
                    ronEncoder { node = node, existingObjectIDMaybe = Nothing, mode = IncludeDefaults }
            in
            ( .ops encoded, Just <| .objectID encoded )

        Nothing ->
            ( [], Nothing )



-- BASE


buildNoNest :
    (a -> BE.Encoder)
    -> BD.Decoder (Result (Error e) a)
    -> (a -> JE.Value)
    -> JD.Decoder (Result (Error e) a)
    -> Codec e a
buildNoNest encoder_ decoder_ jsonEncoder jsonDecoder =
    Codec
        { encoder = encoder_
        , decoder = decoder_
        , jsonEncoder = jsonEncoder
        , jsonDecoder = \_ -> jsonDecoder
        , ronEncoder = Nothing
        }


buildNestable :
    (a -> BE.Encoder)
    -> BD.Decoder (Result (Error e) a)
    -> (a -> JE.Value)
    -> NestableJsonDecoder e a
    -> Codec e a
buildNestable encoder_ decoder_ jsonEncoder jsonDecoder =
    Codec
        { encoder = encoder_
        , decoder = decoder_
        , jsonEncoder = jsonEncoder
        , jsonDecoder = jsonDecoder
        , ronEncoder = Nothing
        }


{-| Codec for serializing a `String`
-}
string : Codec e String
string =
    buildNoNest
        (\text ->
            BE.sequence
                [ BE.unsignedInt32 endian (BE.getStringWidth text)
                , BE.string text
                ]
        )
        (BD.unsignedInt32 endian
            |> BD.andThen
                (\charCount -> BD.string charCount |> BD.map Ok)
        )
        JE.string
        (JD.string |> JD.map Ok)


{-| Codec for serializing a `Bool`
-}
bool : Codec e Bool
bool =
    buildNoNest
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


{-| Codec for serializing an `Int`
-}
int : Codec e Int
int =
    buildNoNest
        (toFloat >> BE.float64 endian)
        (BD.float64 endian |> BD.map (round >> Ok))
        JE.int
        (JD.int |> JD.map Ok)


{-| Codec for serializing a `Float`
-}
float : Codec e Float
float =
    buildNoNest
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
    buildNoNest
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
--{-| Codec for serializing a `Maybe`
--
--    import Serialize as S
--
--    maybeIntCodec : S.Codec e (Maybe Int)
--    maybeIntCodec =
--        S.maybe S.int
--
---}
--maybe : NestableCodec e a -> NestableCodec e (Maybe a)
--maybe justCodec =
--    customType
--        (\nothingEncoder justEncoder value ->
--            case value of
--                Nothing ->
--                    nothingEncoder
--
--                Just value_ ->
--                    justEncoder value_
--        )
--        |> variant0 Nothing
--        |> variant1 Just justCodec
--        |> finishCustomType


{-| A repset
-}
repSet : Codec e a -> Codec e (RepSet a)
repSet memberCodec =
    let
        nestableJsonDecoder : ElsewhereData -> JD.Decoder (Result (Error e) (RepSet a))
        nestableJsonDecoder outer =
            case outer of
                Nothing ->
                    normalJsonDecoder

                Just ( node, locationMaybe ) ->
                    -- we're working with a replica! Try to decode a UUID instead.
                    -- then, if we find a RepSet by that UUID, run the big decoder on that instead!
                    let
                        unstringifier memberAsString =
                            case JD.decodeString (getJsonDecoder memberCodec outer) memberAsString of
                                Ok (Ok member) ->
                                    Just member

                                other ->
                                    Log.logSeparate "did not parse list member" other Nothing

                        stringifier member =
                            JE.encode 0 (getJsonEncoder memberCodec member)

                        objectFinder : OpID.ObjectID -> Result (Error errs) (RepSet a)
                        objectFinder foundID =
                            case RepSet.buildFromReplicaDb node foundID unstringifier stringifier of
                                Nothing ->
                                    Err <| Debug.todo "repset not found"

                                Just repset ->
                                    Ok repset

                        finalDecoder =
                            -- take our found ObjectID and convert it to a Register decoder
                            JD.map objectFinder objectIDDecoder
                    in
                    finalDecoder

        normalJsonDecoder =
            JD.fail "no repset"

        jsonEncoder : RepSet a -> JE.Value
        jsonEncoder input =
            JE.list (getJsonEncoder memberCodec) (RepSet.list input)

        bytesEncoder : RepSet a -> BE.Encoder
        bytesEncoder input =
            listEncode (getEncoder memberCodec) (RepSet.list input)

        ronEncoder : RonEncoder
        ronEncoder { node, existingMaybe, mode } =
            case RepSet.buildFromReplicaDb node existingMaybe unstringifier stringifier of
                Nothing ->
                    Op.Chunk { object = Op.NewObject RepSet.reducerID, objectChanges = [] }

                Just foundRepSetObjectID ->
                    Op.Chunk
                        { object = Op.ExistingObject foundRepSetObjectID
                        , objectChanges = []
                        }
    in
    Codec
        { encoder = bytesEncoder
        , decoder =
            BD.fail
        , jsonEncoder = jsonEncoder
        , jsonDecoder = nestableJsonDecoder
        , ronEncoder = ronEncoder
        }


{-| Encodes a RON object as a list of Ops.
-- The Op initializing the object comes last in the output list, as the preceding Ops create objects that it depends on. That way we never reference an Op we haven't seen before.
For nested values:
-- if it's a normal value (no ronEncoder) just encode it, return a FieldPreOp
-- if it's a nested object that does not yet exist in the tree, make an ID for it, then proceed with the following.
-- if it's a nested object that does exist, run its ronEncoder and put its requisite ops above us.

Also returns the ObjectID so that parent repSets can refer to it.

-}
repSetRonEncoder : Codec e nestedType -> RonEncoderInputs -> RonEncoderOutput
repSetRonEncoder nestedCodec ({ node, existingObjectIDMaybe, counter, mode } as details) =
    case ( Node.getObjectIfExists node existingObjectIDMaybe, RepSet.buildFromReplicaDb node existingObjectIDMaybe addMember ) of
        ( Just foundObject, Just foundRepSet ) ->
            let
                -- run each nested encoder to build up our prerequisites
                runRonEncoderOnNestedItems : ( Dict RepSet.MemberID memberType, RonEncoderOutput )
                runRonEncoderOnNestedItems =
                    let
                        passDetailsToNestedEncoder : InCounter -> ( OutCounter, ( Dict RepSet.MemberID memberType, RonEncoderOutput ) )
                        passDetailsToNestedEncoder thisMemberCounter =
                            let
                                toMember oldKey event dictSoFar =
                                    case unstringifier (Object.eventPayload event) of
                                        Just decodedPayload ->
                                            Dict.insert ( OpID.toString (Object.eventReference event), OpID.toString (Object.eventID event) ) decodedPayload dictSoFar

                                        Nothing ->
                                            dictSoFar

                                run =
                                    getRonEncoder nestedCodec { node = node, repSetMaybe = oldRepSetMaybe, counter = thisMemberCounter, mode = mode }
                            in
                            ( run.postPrereqCounter, ( members, run ) )
                    in
                    -- keep track of how many new op IDs have already been used and pass it into the next
                    List.Extra.mapAccuml passDetailsToNestedEncoder counter foundObject.events

                -- this object's counter is the next one after all the nested encoders have been run
                objectInitCounter : InCounter
                objectInitCounter =
                    runNestedRonEncoder.outCounter

                -- how to create a new object if we can't find an existing one
                ( newObject, newObjectCreationOp, counterAfterInitialization ) =
                    let
                        ( newObjectID, newOutCounter ) =
                            OpID.generate objectInitCounter node.identity False

                        newObjectCreationOp =
                            Object.create RepSet.reducerID newObjectID
                    in
                    ( RepSet.buildFromReplicaDb node newObjectID unstringifier stringifier, newObjectCreationOp, newOutCounter )

                newObjectCreationOpAsSingletonIfNeeded =
                    case oldObjectMaybe of
                        Just _ ->
                            []

                        Nothing ->
                            [ newObjectCreationOp ]

                counterToStartPrereqs : InCounter
                counterToStartPrereqs =
                    case oldRepSetMaybe of
                        Just _ ->
                            repSetReadyCounter

                        Nothing ->
                            counterAfterInitialization

                prerequisiteOps : List Op
                prerequisiteOps =
                    List.concat (List.map .required (Tuple.second runFieldEncodersFirstPass))

                finalRepSet =
                    Maybe.withDefault newRepSet oldRepSetMaybe

                latestReference =
                    -- TODO if prewritten Ops for this Object exist, use the latest OpID, otherwise the creation OpID
                    -- RepSet.getLatestReference finalRepSet
                    RepSet.getID finalRepSet

                -- finally, the actual Ops that set each field
                finishFieldOps : ( ( OutCounter, OpID.OpID ), List Op )
                finishFieldOps =
                    let
                        accumulator : ( OutCounter, OpID.OpID )
                        accumulator =
                            ( counterToStartPrereqs, latestReference )

                        unstampedOpList =
                            List.filterMap .opToWrite (Tuple.second runFieldEncodersFirstPass)

                        finishOps : ( InCounter, OpID.OpID ) -> UnfinishedOp -> ( ( OutCounter, OpID.OpID ), Op )
                        finishOps ( givenOpCounter, priorOpID ) opFinisher =
                            let
                                ( finishedOp, counterToPassAlong, backReference ) =
                                    opFinisher { counter = givenOpCounter, opToReference = priorOpID, containingRepSet = finalRepSet }
                            in
                            ( ( counterToPassAlong, backReference ), finishedOp )
                    in
                    List.Extra.mapAccuml finishOps accumulator unstampedOpList

                exitCounter =
                    Tuple.first (Tuple.first finishFieldOps)

                fieldSettingOps =
                    Tuple.second finishFieldOps
            in
            -- spit out Ops in dependency order
            { ops = prerequisiteOps ++ newRepSetCreationOpAsSingletonIfNeeded ++ fieldSettingOps
            , objectID = RepSet.getID finalRepSet
            , nextCounter = exitCounter
            }

        _ ->
            Debug.todo "not found"


{-| Find an object in the replica object database.
-}
preExistingObjectMaybe : Node -> ObjectID -> Maybe Object
preExistingObjectMaybe node givenID =
    case existingObjectIDMaybe of
        Just givenID ->
            case Node.getObjectIfExists node givenID of
                Just existingObject ->
                    Ok existingObject

                Nothing ->
                    Nothing

        Nothing ->
            Nothing


{-| A list
-}
list : Codec e a -> Codec e (List a)
list codec =
    let
        nestableJsonDecoder : ElsewhereData -> JD.Decoder (Result (Error e) (List a))
        nestableJsonDecoder outer =
            case outer of
                Nothing ->
                    normalJsonDecoder

                Just ( node, locationMaybe ) ->
                    -- we're working with a replica! Try to decode a UUID instead.
                    -- then, if we find a RepSet by that UUID, run the big decoder on that instead!
                    let
                        unstringifier memberAsString =
                            case JD.decodeString (getJsonDecoder codec outer) memberAsString of
                                Ok (Ok member) ->
                                    Just member

                                other ->
                                    Log.logSeparate "did not parse list member" other Nothing

                        stringifier member =
                            JE.encode 0 (getJsonEncoder codec member)

                        objectFinder : OpID.ObjectID -> Result (Error errs) (List a)
                        objectFinder foundID =
                            case RepSet.buildFromReplicaDb node foundID unstringifier stringifier of
                                Nothing ->
                                    Err <| Debug.todo "repset not found"

                                Just repset ->
                                    Ok (RepSet.list repset)

                        finalDecoder =
                            -- take our found ObjectID and convert it to a Register decoder
                            JD.map objectFinder objectIDDecoder
                    in
                    finalDecoder

        normalJsonDecoder =
            JD.list (getJsonDecoder codec Nothing)
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
        { encoder = listEncode (getEncoder codec)
        , decoder =
            BD.unsignedInt32 endian
                |> BD.andThen
                    (\length -> BD.loop ( length, [] ) (listStep (getBytesDecoder codec)))
        , jsonEncoder = JE.list (getJsonEncoder codec)
        , jsonDecoder = nestableJsonDecoder
        , ronEncoder = Nothing
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
    list codec |> mapHelper (Result.map Array.fromList) Array.toList


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
    list (tuple keyCodec valueCodec)
        |> mapHelper (Result.map Dict.fromList) Dict.toList


{-| Codec for serializing a `Set`
-}
set : Codec e comparable -> Codec e (Set comparable)
set codec =
    list codec |> mapHelper (Result.map Set.fromList) Set.toList


{-| Codec for serializing `()` (aka `Unit`).
-}
unit : Codec e ()
unit =
    buildNoNest
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



--{-| Codec for serializing a `Result`
---}
--result : NestableCodec e error -> NestableCodec e value -> NestableCodec e (Result error value)
--result errorCodec valueCodec =
--    customType
--        (\errEncoder okEncoder value ->
--            case value of
--                Err err ->
--                    errEncoder err
--
--                Ok ok ->
--                    okEncoder ok
--        )
--        |> variant1 Err errorCodec
--        |> variant1 Ok valueCodec
--        |> finishCustomType


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
    buildNoNest
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
                    case decode text of
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
    buildNoNest
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
enum : a -> List a -> Codec e a
enum defaultItem items =
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
    in
    buildNoNest
        (getIndex >> BE.unsignedInt32 endian)
        (BD.unsignedInt32 endian |> BD.map getItem)
        (getIndex >> JE.int)
        (JD.int |> JD.map getItem)


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
        { encoder : a -> List BE.Encoder
        , decoder : BD.Decoder (Result (Error e) b)
        , jsonEncoder : a -> List JE.Value
        , jsonDecoder : NestableJsonDecoder e b
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
        { encoder = \_ -> []
        , decoder = BD.succeed (Ok ctor)
        , jsonEncoder = \_ -> []
        , jsonDecoder = \_ -> JD.succeed (Ok ctor)
        , fieldIndex = 0
        }


{-| Add an un-reorderable field to the record we are creating a codec for.
-}
fixedField : (a -> f) -> Codec e f -> FragileRecordCodec e a (f -> b) -> FragileRecordCodec e a b
fixedField getter codec (FragileRecordCodec recordCodec) =
    let
        normalJsonDecoder elsewhereData =
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
                -- TODO proper to use both elsewhereData here?
                (recordCodec.jsonDecoder elsewhereData)
                (JD.index recordCodec.fieldIndex (getJsonDecoder codec elsewhereData))
    in
    FragileRecordCodec
        { encoder = \v -> (getEncoder codec <| getter v) :: recordCodec.encoder v
        , decoder =
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
                recordCodec.decoder
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
        { encoder = codec.encoder >> List.reverse >> BE.sequence
        , decoder = codec.decoder
        , jsonEncoder = codec.jsonEncoder >> List.reverse >> JE.list identity
        , jsonDecoder = codec.jsonDecoder
        , ronEncoder = Nothing
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
        { encoder : full -> List BE.Encoder
        , decoder : BD.Decoder (Result (Error errs) remaining)
        , jsonEncoders : List (SmartJsonFieldEncoder full)
        , jsonArrayDecoder : NestableJsonDecoder errs remaining
        , fieldIndex : Int
        , ronEncoders : List RonFieldEncoder
        }


record : remaining -> PartialRecord errs full remaining
record remainingConstructor =
    PartialRecord
        { encoder = \_ -> []
        , decoder = BD.succeed (Ok remainingConstructor)
        , jsonEncoders = []
        , jsonArrayDecoder = \elsewhereData -> JD.succeed (Ok remainingConstructor)
        , fieldIndex = 0
        , ronEncoders = []
        }


fieldRW : FieldIdentifier -> (full -> RW fieldType) -> Codec errs fieldType -> fieldType -> PartialRecord errs full (RW fieldType -> remaining) -> PartialRecord errs full remaining
fieldRW ( fieldSlot, fieldName ) fieldGetter fieldValueCodec fieldDefault (PartialRecord recordCodecSoFar) =
    let
        wrappedFieldValueCodec objectID =
            map (rwWrapper objectID) .get fieldValueCodec

        jsonObjectFieldKey =
            -- For now, just stick number and name together.
            String.fromInt fieldSlot ++ fieldName

        addToPartialBytesEncoderList existingRecord =
            -- Tack on the new encoder to the big list of all the encoders
            (getEncoder fieldValueCodec <| .get (fieldGetter existingRecord)) :: recordCodecSoFar.encoder existingRecord

        addToPartialJsonEncoderList =
            -- Tack on the new encoder to the big list of all the encoders
            ( jsonObjectFieldKey, getJsonEncoder fieldValueCodec << (.get << fieldGetter) ) :: recordCodecSoFar.jsonEncoders

        rwWrapper objectID =
            buildRW objectID ( fieldSlot, fieldName ) (encodeToJsonString fieldValueCodec)

        wrappedNestableJsonFieldDecoder : ElsewhereData -> JD.Decoder (Result (Error errs) (RW fieldType))
        wrappedNestableJsonFieldDecoder elsewheredata =
            let
                registerObjectMaybe =
                    Maybe.andThen Tuple.second elsewheredata
            in
            case registerObjectMaybe of
                Nothing ->
                    -- TODO should still work as readable for JSON encoding
                    JD.fail "No ObjectID to give to RW writer"

                Just registerObject ->
                    nestableJsonFieldDecoder ( fieldSlot, fieldName ) (rwWrapper (Register.getID registerObject) fieldDefault) (wrappedFieldValueCodec (Register.getID registerObject)) elsewheredata
    in
    PartialRecord
        { encoder = addToPartialBytesEncoderList
        , decoder =
            BD.map2
                combineIfBothSucceed
                recordCodecSoFar.decoder
                -- (getBytesDecoder wrappedFieldValueCodec)
                BD.fail
        , jsonEncoders = addToPartialJsonEncoderList
        , jsonArrayDecoder =
            nestableJDmap2
                combineIfBothSucceed
                -- the previous decoder layers, functions stacked on top of each other
                recordCodecSoFar.jsonArrayDecoder
                -- and now we're wrapping it in yet another layer, this field's decoder
                wrappedNestableJsonFieldDecoder
        , fieldIndex = recordCodecSoFar.fieldIndex + 1
        , ronEncoders = newRonFieldEncoderEntry ( fieldSlot, fieldName ) fieldDefault fieldValueCodec :: recordCodecSoFar.ronEncoders
        }


fieldR : FieldIdentifier -> (full -> fieldType) -> Codec errs fieldType -> fieldType -> PartialRecord errs full (fieldType -> remaining) -> PartialRecord errs full remaining
fieldR ( fieldSlot, fieldName ) fieldGetter fieldValueCodec fieldDefault (PartialRecord recordCodecSoFar) =
    let
        jsonObjectFieldKey =
            -- For now, just stick number and name together.
            String.fromInt fieldSlot ++ fieldName

        addToPartialBytesEncoderList existingRecord =
            -- Tack on the new encoder to the big list of all the encoders
            (getEncoder fieldValueCodec <| fieldGetter existingRecord) :: recordCodecSoFar.encoder existingRecord

        addToPartialJsonEncoderList =
            -- Tack on the new encoder to the big list of all the encoders
            ( jsonObjectFieldKey, getJsonEncoder fieldValueCodec << fieldGetter ) :: recordCodecSoFar.jsonEncoders
    in
    PartialRecord
        { encoder = addToPartialBytesEncoderList
        , decoder =
            BD.map2
                combineIfBothSucceed
                recordCodecSoFar.decoder
                (getBytesDecoder fieldValueCodec)
        , jsonEncoders = addToPartialJsonEncoderList
        , jsonArrayDecoder =
            nestableJDmap2
                combineIfBothSucceed
                -- the previous decoder layers, functions stacked on top of each other
                recordCodecSoFar.jsonArrayDecoder
                -- and now we're wrapping it in yet another layer, this field's decoder
                (nestableJsonFieldDecoder ( fieldSlot, fieldName ) fieldDefault fieldValueCodec)
        , fieldIndex = recordCodecSoFar.fieldIndex + 1
        , ronEncoders = newRonFieldEncoderEntry ( fieldSlot, fieldName ) fieldDefault fieldValueCodec :: recordCodecSoFar.ronEncoders
        }


combineIfBothSucceed : Result (Error e) (fieldType -> remaining) -> Result (Error e) fieldType -> Result (Error e) remaining
combineIfBothSucceed decoderA decoderB =
    case ( decoderA, decoderB ) of
        ( Ok aDecodedValue, Ok bDecodedValue ) ->
            -- is A being applied to B?
            Ok (aDecodedValue bDecodedValue)

        ( Err a_error, _ ) ->
            Err a_error

        ( _, Err b_error ) ->
            Err b_error


{-| Same as JD.map2, but with the elsewheredata argument built in
-}
nestableJDmap2 :
    (a -> b -> value)
    -> (ElsewhereData -> JD.Decoder a)
    -> (ElsewhereData -> JD.Decoder b)
    -> ElsewhereData
    -> JD.Decoder value
nestableJDmap2 twoArgFunction nestableDecoderA nestableDecoderB elsewhereData =
    let
        -- typevars a and b contain the Result blob
        decoderA : JD.Decoder a
        decoderA =
            nestableDecoderA elsewhereData

        decoderB : JD.Decoder b
        decoderB =
            nestableDecoderB elsewhereData
    in
    JD.map2 twoArgFunction decoderA decoderB


{-| JSON version: what to do when decoding a (potentially nested!) object field.
-}
nestableJsonFieldDecoder : ( FieldSlot, FieldName ) -> fieldtype -> Codec e fieldtype -> ElsewhereData -> JD.Decoder (Result (Error e) fieldtype)
nestableJsonFieldDecoder ( fieldSlot, fieldName ) default fieldValueCodec outer =
    case outer of
        -- There is no known replica. This is normal decoding.
        Nothing ->
            -- Getting JSON Object field seems more efficient than finding our field in an array because the elm kernel uses JS direct access, object["fieldname"], under the hood. That's better than `index` because Elm won't let us use Strings for that or even numbers out of order. Plus it's more human-readable JSON!
            JD.field (String.fromInt fieldSlot ++ "_" ++ fieldName) (getJsonDecoder fieldValueCodec Nothing)

        Just ( replica, Nothing ) ->
            Debug.todo "a replica exists but we seem to be working with normal flat decoding. Why was a replica passed in then?"

        -- We are working with an Register
        Just ( replica, Just registerObject ) ->
            let
                desiredField =
                    Register.getFieldLatest registerObject ( fieldSlot, fieldName )
            in
            case desiredField of
                Nothing ->
                    JD.succeed (Ok default)

                Just foundField ->
                    let
                        runDecoderOnFoundField : Result JD.Error (Result (Error e) fieldtype)
                        runDecoderOnFoundField =
                            JD.decodeString (getJsonDecoder fieldValueCodec outer) (prepDecoder foundField)

                        convertResult : Result (Error e) fieldtype
                        convertResult =
                            case runDecoderOnFoundField of
                                Ok something ->
                                    something

                                Err problem ->
                                    -- TODO FIXME
                                    Err DataCorrupted
                    in
                    JD.succeed convertResult


prepDecoder : String -> String
prepDecoder inputString =
    case String.startsWith "{" inputString of
        True ->
            "\"" ++ String.dropLeft 1 (String.dropRight 1 inputString) ++ "\""

        False ->
            inputString


objectIDDecoder : JD.Decoder OpID.ObjectID
objectIDDecoder =
    OpID.jsonDecoder


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

        -- Are we running on a Json object or a replica object?
        runJsonDecoderOnCorrectObject : Maybe ( Node, Maybe Register ) -> JD.Decoder (Result (Error errs) full)
        runJsonDecoderOnCorrectObject elsewhereData =
            case elsewhereData of
                Nothing ->
                    -- we're not working with a replica, fall back to normal behavior
                    allFieldsCodec.jsonArrayDecoder elsewhereData

                Just ( node, _ ) ->
                    -- we're working with a replica! Try to decode a UUID instead.
                    -- then, if we find a Register by that UUID, run the big decoder on that instead!
                    let
                        objectFinder : OpID.ObjectID -> Result (Error errs) full
                        objectFinder foundID =
                            case Register.build node foundID of
                                Nothing ->
                                    Debug.todo "register not found"

                                Just register ->
                                    case JD.decodeString (decodeWhatWeFound register) "{}" of
                                        Ok nestedResult ->
                                            -- could be Ok (Ok something) or Ok (Err something)
                                            nestedResult

                                        Err someerror ->
                                            -- TODO FIXME
                                            Tuple.second ( Debug.log "found register but error decoding it" someerror, Err DataCorrupted )

                        decodeWhatWeFound : Register -> JD.Decoder (Result (Error errs) full)
                        decodeWhatWeFound register =
                            allFieldsCodec.jsonArrayDecoder (Just ( node, Just register ))

                        finalDecoder =
                            -- take our found ObjectID and convert it to a Register decoder
                            JD.map objectFinder objectIDDecoder
                    in
                    finalDecoder
    in
    Codec
        { encoder = allFieldsCodec.encoder >> List.reverse >> BE.sequence
        , decoder = allFieldsCodec.decoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = runJsonDecoderOnCorrectObject
        , ronEncoder = Just (registerRonEncoder allFieldsCodec.ronEncoders) -- replace with Nothing for forced-immutable fields
        }


{-| Encodes an register as a list of Ops.
-- The Op encoding the register comes last in the list, as the preceding Ops create registers that it depends on.
For each field:
-- if it's a normal value (no ronEncoder) just encode it, return a FieldPreOp
-- if it's a nested register that does not yet exist in the tree, make an ID for it, then proceed with the following.
-- if it's a nested register that does exist, run its registerRonEncoder and put its requisite ops above us.

Also returns the ObjectID so that parent registers can refer to it.

Why not create missing Objects in the encoder? Because if it already exists, we'd need to pass the existing ObjectID in anyway. Might as well pass in a guaranteed-existing Register (pre-created if needed)

-}
registerRonEncoder : List RonFieldEncoder -> RonEncoderInputs -> RonEncoderOutput
registerRonEncoder ronFieldEncoders ({ node, existingObjectIDMaybe, counter, mode } as details) =
    let
        oldRegisterMaybe =
            case existingObjectIDMaybe of
                Just givenID ->
                    case Register.build node givenID of
                        Just oldRegister ->
                            Just oldRegister

                        Nothing ->
                            Nothing

                Nothing ->
                    Nothing

        -- run each field encoder to build up our register
        runFieldEncodersFirstPass : ( OutCounter, List RonFieldEncoderOutput )
        runFieldEncodersFirstPass =
            let
                passDetailsToField : InCounter -> RonFieldEncoder -> ( OutCounter, RonFieldEncoderOutput )
                passDetailsToField thisFieldCounter fieldFunction =
                    let
                        run =
                            fieldFunction { node = node, registerMaybe = oldRegisterMaybe, counter = thisFieldCounter, mode = mode }
                    in
                    ( run.postPrereqCounter, run )
            in
            -- keep track of how many new op IDs have already been used and pass it into the next
            List.Extra.mapAccuml passDetailsToField counter ronFieldEncoders

        -- this register's counter is the next one after all the field encoders have been run
        registerReadyCounter : InCounter
        registerReadyCounter =
            Tuple.first runFieldEncodersFirstPass

        -- how to create a new Register object if we can't find an existing one
        ( newRegister, newRegisterCreationOp, counterAfterInitialization ) =
            let
                ( newObjectID, newOutCounter ) =
                    OpID.generate registerReadyCounter node.identity False

                newObjectCreationOp =
                    Register.creation node newObjectID
            in
            ( Register.empty newObjectID, newObjectCreationOp, newOutCounter )

        newRegisterCreationOpAsSingletonIfNeeded =
            case oldRegisterMaybe of
                Just _ ->
                    []

                Nothing ->
                    [ newRegisterCreationOp ]

        counterToStartPrereqs : InCounter
        counterToStartPrereqs =
            case oldRegisterMaybe of
                Just _ ->
                    registerReadyCounter

                Nothing ->
                    counterAfterInitialization

        prerequisiteOps : List Op
        prerequisiteOps =
            List.concat (List.map .required (Tuple.second runFieldEncodersFirstPass))

        finalRegister =
            Maybe.withDefault newRegister oldRegisterMaybe

        latestReference =
            -- if prewritten Ops for this Object exist, use the latest OpID, otherwise the creation OpID
            Maybe.withDefault (Register.getID finalRegister) (Maybe.map .lastSeen oldRegisterMaybe)

        -- finally, the actual Ops that set each field
        finishFieldOps : ( ( OutCounter, OpID.OpID ), List Op )
        finishFieldOps =
            let
                accumulator : ( OutCounter, OpID.OpID )
                accumulator =
                    ( counterToStartPrereqs, latestReference )

                unstampedOpList =
                    List.filterMap .opToWrite (Tuple.second runFieldEncodersFirstPass)

                finishOps : ( InCounter, OpID.OpID ) -> UnfinishedOp -> ( ( OutCounter, OpID.OpID ), Op )
                finishOps ( givenOpCounter, priorOpID ) opFinisher =
                    let
                        ( finishedOp, counterToPassAlong, backReference ) =
                            opFinisher { counter = givenOpCounter, opToReference = priorOpID, containingRegister = finalRegister }
                    in
                    ( ( counterToPassAlong, backReference ), finishedOp )
            in
            List.Extra.mapAccuml finishOps accumulator unstampedOpList

        exitCounter =
            Tuple.first (Tuple.first finishFieldOps)

        fieldSettingOps =
            Tuple.second finishFieldOps
    in
    -- spit out Ops in dependency order
    { ops = prerequisiteOps ++ newRegisterCreationOpAsSingletonIfNeeded ++ fieldSettingOps
    , objectID = Register.getID finalRegister
    , nextCounter = exitCounter
    }


{-| Does nothing but remind you not to reuse historical slots
-}
obsolete : List FieldIdentifier -> anything -> anything
obsolete reservedList input =
    input


{-| Adds an item to the list of replica encoders, for encoding a single Register field into an Op, if applicable. This field may contain further nested fields which also are encoded, so the return result is a big list of Ops.

Updated to separate cases where the object needs to be created.

-}
newRonFieldEncoderEntry : FieldIdentifier -> fieldType -> Codec e fieldType -> (RonFieldEncoderInputs -> RonFieldEncoderOutput)
newRonFieldEncoderEntry ( fieldSlot, fieldName ) fieldDefault fieldValueCodec details =
    case getRonEncoder fieldValueCodec of
        -- leaf node : nothing nested further, just a flat value
        Nothing ->
            ronEncoderForNoNestFields ( fieldSlot, fieldName ) fieldDefault fieldValueCodec details

        Just fieldRonEncoder ->
            ronEncoderForNestedFields ( fieldSlot, fieldName ) fieldDefault fieldValueCodec fieldRonEncoder details


ronEncoderForNoNestFields : FieldIdentifier -> fieldType -> Codec e fieldType -> (RonFieldEncoderInputs -> RonFieldEncoderOutput)
ronEncoderForNoNestFields fieldIdentifier fieldDefault fieldValueCodec ({ node, registerMaybe, counter, mode } as details) =
    let
        -- attempt to find this field set in memory already
        registerField =
            case registerMaybe of
                Just existingRegister ->
                    Register.getFieldLatest existingRegister fieldIdentifier

                Nothing ->
                    Nothing

        interpretFieldValue encodedValue =
            Result.toMaybe (decodeFromString fieldValueCodec encodedValue)

        defaultJsonEncoded =
            encodeToJsonString fieldValueCodec fieldDefault

        isAlreadyDefault =
            -- missing values count as default
            Maybe.withDefault True (Maybe.map ((==) defaultJsonEncoded) registerField)

        valueToWrite =
            Maybe.withDefault defaultJsonEncoded registerField

        opToWriteField : UnfinishedOp
        opToWriteField lazyInput =
            let
                ( op, outCounter ) =
                    Register.fieldToOp
                        lazyInput.counter
                        node.identity
                        lazyInput.containingRegister
                        lazyInput.opToReference
                        fieldIdentifier
                        valueToWrite
            in
            ( op, outCounter, Op.id op )

        finalOpFilteredByRequest =
            case mode of
                MissingObjectsOnly ->
                    Nothing

                NonDefaultValues ->
                    if isAlreadyDefault then
                        Nothing

                    else
                        Just opToWriteField

                IncludeDefaults ->
                    Just opToWriteField
    in
    { required = []
    , postPrereqCounter = counter -- never used because no prereqs
    , opToWrite = finalOpFilteredByRequest
    }


ronEncoderForNestedFields : FieldIdentifier -> fieldType -> Codec e fieldType -> RonEncoder -> (RonFieldEncoderInputs -> RonFieldEncoderOutput)
ronEncoderForNestedFields ( fieldSlot, fieldName ) fieldDefault fieldValueCodec ronEncoder ({ node, registerMaybe, counter, mode } as details) =
    let
        -- attempt to find this field set in memory already
        registerField =
            case registerMaybe of
                Just registerFound ->
                    -- still returns a maybe
                    Register.getFieldLatest registerFound ( fieldSlot, fieldName )

                Nothing ->
                    Nothing

        fieldValueToObjectID : FieldValue -> Maybe OpID.ObjectID
        fieldValueToObjectID fieldValue =
            OpID.fromString fieldValue

        finalObjectMaybe =
            Maybe.andThen fieldValueToObjectID registerField

        defaultJsonEncoded =
            encodeToJsonString fieldValueCodec fieldDefault

        isAlreadyDefault =
            -- TODO: True if stored value is same as default
            False

        -- is there a nested Register? If so, dig in
        findNestedRegister : Maybe Register
        findNestedRegister =
            Maybe.andThen (Register.build node) finalObjectMaybe

        -- if we found a nested Register,
        runNestedRonEncoder : RonEncoderOutput
        runNestedRonEncoder =
            ronEncoder
                { node = node
                , existingObjectIDMaybe = Maybe.map Register.getID findNestedRegister
                , counter = counter -- right?
                , mode = mode
                }

        finalCounter =
            runNestedRonEncoder.nextCounter

        childID : OpID.ObjectID
        childID =
            runNestedRonEncoder.objectID

        opToWriteField : UnfinishedOp
        opToWriteField lazyInputs =
            let
                ( op, outCounter ) =
                    Register.fieldToOp
                        lazyInputs.counter
                        node.identity
                        lazyInputs.containingRegister
                        lazyInputs.opToReference
                        ( fieldSlot, fieldName )
                        ("{" ++ OpID.toString childID ++ "}")
            in
            ( op, outCounter, Op.id op )

        decideToEncodeOpBasedOnMode : Maybe UnfinishedOp
        decideToEncodeOpBasedOnMode =
            case mode of
                MissingObjectsOnly ->
                    Nothing

                -- TODO how do we know it's not missing
                NonDefaultValues ->
                    -- field set so probably non-default! check to be sure
                    if isAlreadyDefault then
                        Nothing

                    else
                        Just opToWriteField

                IncludeDefaults ->
                    Just opToWriteField
    in
    { opToWrite = decideToEncodeOpBasedOnMode
    , required = runNestedRonEncoder.ops
    , postPrereqCounter = finalCounter
    }



-- create op using default
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
    buildNestable
        (\v -> toBytes_ v |> getEncoder codec)
        (getBytesDecoder codec |> BD.map fromBytes_)
        (\v -> toBytes_ v |> getJsonEncoder codec)
        (\elsewheredata -> getJsonDecoder codec elsewheredata |> JD.map fromBytes_)


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
    buildNestable
        (\v -> toBytes_ v |> getEncoder codec)
        (getBytesDecoder codec
            |> BD.map
                (\value ->
                    case value of
                        Ok ok ->
                            fromBytes_ ok |> Result.mapError CustomError

                        Err err ->
                            Err err
                )
        )
        (\v -> toBytes_ v |> getJsonEncoder codec)
        (\elsewhereData ->
            getJsonDecoder codec elsewhereData
                |> JD.map
                    (\value ->
                        case value of
                            Ok ok ->
                                fromBytes_ ok |> Result.mapError CustomError

                            Err err ->
                                Err err
                    )
        )


{-| Map errors generated by `mapValid`.
-}
mapError : (e1 -> e2) -> Codec e1 a -> Codec e2 a
mapError mapFunc codec =
    buildNestable
        (getEncoder codec)
        (getBytesDecoder codec |> BD.map (mapErrorHelper mapFunc))
        (getJsonEncoder codec)
        (\elsewhereData -> getJsonDecoder codec elsewhereData |> JD.map (mapErrorHelper mapFunc))


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
    buildNestable
        (\value -> getEncoder (f ()) value)
        (BD.succeed () |> BD.andThen (\() -> getBytesDecoder (f ())))
        (\value -> getJsonEncoder (f ()) value)
        (\elsewhereData -> JD.succeed () |> JD.andThen (\() -> getJsonDecoder (f ()) elsewhereData))
