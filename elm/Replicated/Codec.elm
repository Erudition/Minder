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
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Object as Object exposing (Object)
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
type Codec errType initData constraints a
    = Codec
        { bytesEncoder : a -> BE.Encoder
        , bytesDecoder : BD.Decoder (Result (Error errType) a)
        , jsonEncoder : a -> JE.Value
        , jsonDecoder : JD.Decoder (Result (Error errType) a)
        , nodeEncoder : NodeEncoder a constraints
        , nodeDecoder : NodeDecoder errType a
        , nodePlaceholder : PlaceholderGenerator initData a
        }


{-| For types that cannot be initialized from nothing, nor from a list of changes - you need the whole value upfront. We use the value itself as the "seed".
-}
type alias SelfSeededCodec e constraints thing =
    Codec e thing constraints thing


{-| A self-seeded codec with no special guarantees. Used as a building block for additional type constraints.
-}
type alias NullCodec e a =
    Codec e a {} a


{-| A self-seeded, primitive-only codec, like string or int.
-}
type alias PrimitiveCodec e a =
    Codec e a Primitive a


{-| Codec for unwrapped objects, like naked records.
-}
type alias SkelCodec e a =
    Codec e Skel SoloObject a


{-| Codec for wrapped objects, like replist or register, or unwrapped naked records.
-}
type alias WrappedOrSkelCodec e s a =
    Codec e (s -> List Change) SoloObject a


{-| Codec for wrapped objects, like replist or register, but not naked records.
-}
type alias WrappedCodec e a =
    Codec e (Changer a) SoloObject a


{-| Codec for wrapped objects that need an initial seed.
-}
type alias WrappedSeededCodec e seed a =
    Codec e ( seed, Changer a ) SoloObject a


{-| The type of function that produces a placeholder object. It may require a seed value.
-}
type alias PlaceholderGenerator seed a =
    PlaceholderInputs seed -> a


{-| The inputs to a placeholder generator function.
-}
type alias PlaceholderInputs seed =
    { parent : Change.Parent
    , position : Location
    , seed : seed
    }



-- NODE-BASED FEATURES ----------------------------------------


{-| All node encoders produce a complex payload.
-}
type alias EncoderOutput o =
    { o | complex : Change.ComplexPayload }


{-| Extra constraint for Primitive node encoders.
-}
type alias Primitive =
    { primitive : Change.PrimitivePayload }


{-| Primitive node encoders also produce a primitive payload.
-}
type alias PrimitiveEncoderOutput =
    EncoderOutput { primitive : Change.PrimitivePayload }


{-| Extra constraint for solo object encoders.
-}
type alias SoloObject =
    { nested : Change.SoloObjectEncoded }


{-| Nested object encoders also produce a solo object to reference.
-}
type alias SoloObjectEncoderOutput =
    EncoderOutput { nested : Change.SoloObjectEncoded }


type alias NodeEncoderInputs a =
    { node : Node
    , mode : ChangesToGenerate
    , thingToEncode : ThingToEncode a
    , parent : Parent
    , position : Location
    }


type ThingToEncode fieldType
    = EncodeThis fieldType
    | EncodeObjectOrThis (Nonempty ObjectID) fieldType -- so that naked registers have something to fall back on


type alias NodeEncoderInputsNoVariable =
    -- TODO make unnecessary, by currying NodeEncoderInputs
    { node : Node
    , mode : ChangesToGenerate
    , parent : Parent
    , position : Location
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


type alias NodeEncoder a o =
    NodeEncoderInputs a -> EncoderOutput o


type alias NodeDecoder e a =
    -- For now we just reuse Json Decoders
    NodeDecoderInputs -> JD.Decoder (Result (Error e) a)


type alias NodeDecoderInputs =
    { node : Node
    , parent : Parent
    , position : Location
    , cutoff : Maybe Moment
    }


type alias RegisterFieldEncoder full =
    RegisterFieldEncoderInputs full -> RegisterFieldEncoderOutput


{-| Inputs to a node Field encoder.

No "position" because it's already in the parent, and field index can be determined by record counter
No "parent", just pointer, because the parent is constructed in the individual field encoder.

-}
type alias RegisterFieldEncoderInputs field =
    { node : Node
    , mode : ChangesToGenerate
    , history : FieldHistoryDict
    , regPointer : Pointer
    , existingValMaybe : Maybe field
    }


type alias RegisterFieldDecoder e remaining =
    RegisterFieldDecoderInputs -> ( Maybe remaining, List (Error e) )


type alias RegisterFieldInitializer parentSeed remaining =
    parentSeed -> Change.Pointer -> remaining


type alias RegisterFieldDecoderInputs =
    { node : Node
    , regPointer : Pointer
    , history : FieldHistoryDict
    , cutoff : Maybe Moment
    }


type alias SmartJsonFieldEncoder full =
    ( String, full -> JE.Value )



-- NODE ENCODE OUTPUT HELPERS --------------------------------------


justInit : Pointer -> SoloObjectEncoderOutput
justInit placeholderPointer =
    let
        soloObject : Change.SoloObjectEncoded
        soloObject =
            { toReference = placeholderPointer
            , changeSet = Change.emptyChangeSet
            , skippable = True
            }
    in
    { nested = soloObject
    , complex = Change.complexFromSolo soloObject
    }


soloOut : Change.SoloObjectEncoded -> SoloObjectEncoderOutput
soloOut soloObject =
    { nested = soloObject
    , complex = Change.complexFromSolo soloObject
    }


singlePrimitiveOut : Change.PrimitiveAtom -> PrimitiveEncoderOutput
singlePrimitiveOut singlePrimitiveAtom =
    { primitive = Nonempty.singleton singlePrimitiveAtom
    , complex = Nonempty.singleton <| Change.FromPrimitiveAtom singlePrimitiveAtom
    }



-- ERROR HANDLING


{-| Possible errors that can occur when decoding.
-}
type Error e
    = CustomError e
    | BinaryDataCorrupted
    | BadVersionNumber Int
    | SerializerOutOfDate
    | ObjectNotFound OpID
    | JDError JD.Error
    | FailedToDecodeRegField FieldSlot FieldName String JD.Error
    | MissingRequiredField FieldSlot FieldName
    | NoMatchingVariant String
    | BadBoolean String
    | BadChar String
    | EmptyList
    | BadByteString String
    | BadIndex Int
    | WrongCutoff -- TODO what exactly goes wrong with wrong cutoff errors, may not be named correctly


errorToString : Error e -> String
errorToString codecError =
    case codecError of
        CustomError customErrorString ->
            "customErrorString NYI"

        BinaryDataCorrupted ->
            "Binary Data Corrupted"

        BadVersionNumber num ->
            "Bad Version Number: " ++ String.fromInt num

        SerializerOutOfDate ->
            "Serializer Out Of Date"

        ObjectNotFound opID ->
            "Object Not Found: " ++ OpID.toString opID

        JDError jdError ->
            JD.errorToString jdError

        FailedToDecodeRegField fieldSlot fieldName valueString jdError ->
            "Failed to decode reg field " ++ String.fromInt fieldSlot ++ "(" ++ fieldName ++ ") value: " ++ valueString ++ " because \n" ++ JD.errorToString jdError

        NoMatchingVariant tag ->
            "No Matching Variant found for tag " ++ tag

        MissingRequiredField fieldSlot fieldName ->
            "Could not find field " ++ String.fromInt fieldSlot ++ " " ++ fieldName ++ " but it is required"

        BadBoolean givenData ->
            "I was trying to parse a boolean but what I found was " ++ givenData

        BadChar givenData ->
            "I was trying to parse a char but what I found was " ++ givenData

        BadIndex givenData ->
            "I was trying to parse an index within bounds but what I found was " ++ String.fromInt givenData

        BadByteString givenData ->
            "I was trying to parse a string of bytes but what I found was " ++ givenData

        EmptyList ->
            "I was trying to parse a nonempty list, but the list I found was empty."

        WrongCutoff ->
            "Naked register cutoff function failed."


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
    case JD.decodeString (getNodeDecoder rootCodec { node = node, parent = Change.genesisParent "dFN", cutoff = Nothing, position = Location.none }) (prepDecoder rootEncoded) of
        Ok value ->
            Log.logMessageOnly "Decoding Node again." value

        Err jdError ->
            Err (JDError jdError)


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
            new rootCodec (Change.startContext "fDFN")
    in
    case JD.decodeString (getNodeDecoder rootCodec { node = node, parent = Change.genesisParent "fDFN", cutoff = Nothing, position = Location.none }) (prepDecoder rootEncoded) of
        Ok (Ok success) ->
            ( success, Nothing )

        Err jdError ->
            ( fromScratch, Just (JDError <| Debug.log "forceDecodeFromNode: forcing success, but there was an error... " <| jdError) )

        Ok (Err err) ->
            ( fromScratch, Debug.todo "nested error - come up with nicer presentation" )


{-| Create something new, from its Codec!
Be sure to pass in a `Context`, which you can get from its parent.
-}
new : Codec e (s -> List Change) o repType -> Context repType -> repType
new (Codec codecDetails) context =
    codecDetails.nodePlaceholder { parent = Change.getContextParent context, position = Location.nestSingle (Change.getContextLocation context) "new", seed = nonChanger }


{-| Create a new object from its Codec, given a unique integer to differentiate it from other times you use this function on the same Codec in the same context.
If the Codecs are different, you can just use new. If they aren't, using new multiple times will create references to a single object rather than multiple distinct objects. So be sure to use a different number for each usage of newN.
-}
newN : Int -> Codec e (s -> List Change) o repType -> Context repType -> repType
newN nth (Codec codecDetails) context =
    codecDetails.nodePlaceholder { parent = Change.getContextParent context, position = Location.nest (Change.getContextLocation context) "newN" nth, seed = nonChanger }


newWithChanges : WrappedCodec e repType -> Context repType -> Changer repType -> repType
newWithChanges (Codec codecDetails) context changer =
    -- TODO change argument order
    codecDetails.nodePlaceholder { parent = Change.getContextParent context, position = Location.nestSingle (Change.getContextLocation context) "newChanged", seed = changer }


seededNew : Codec e s o repType -> Context repType -> s -> repType
seededNew (Codec codecDetails) context seed =
    codecDetails.nodePlaceholder { parent = Change.getContextParent context, position = Location.nestSingle (Change.getContextLocation context) "sNew", seed = seed }


seededNewWithChanges : Codec e ( s, Changer repType ) o repType -> Context repType -> s -> Changer repType -> repType
seededNewWithChanges (Codec codecDetails) context seed changer =
    codecDetails.nodePlaceholder { parent = Change.getContextParent context, position = Location.nestSingle (Change.getContextLocation context) "sNewWC", seed = ( seed, changer ) }


nonChanger _ =
    []


getInitializer : Codec e i o repType -> PlaceholderGenerator i repType
getInitializer (Codec codecDetails) inputs =
    codecDetails.nodePlaceholder
        { parent = inputs.parent
        , position = inputs.position
        , seed = inputs.seed
        }


endian : Bytes.Endianness
endian =
    Bytes.BE


{-| Extracts the `Decoder` contained inside the `Codec`.
-}
getBytesDecoder : Codec e s o a -> BD.Decoder (Result (Error e) a)
getBytesDecoder (Codec m) =
    m.bytesDecoder


{-| Extracts the json `Decoder` contained inside the `Codec`.
-}
getJsonDecoder : Codec e s o a -> JD.Decoder (Result (Error e) a)
getJsonDecoder (Codec m) =
    m.jsonDecoder


{-| Extracts the ron decoder contained inside the `Codec`.
-}
getNodeDecoder : Codec e i o a -> NodeDecoder e a
getNodeDecoder (Codec m) =
    m.nodeDecoder


{-| Run a `Codec` to turn a sequence of bytes into an Elm value.
-}
decodeFromBytes : PrimitiveCodec e a -> Bytes.Bytes -> Result (Error e) a
decodeFromBytes codec bytes_ =
    let
        decoder =
            BD.unsignedInt8
                |> BD.andThen
                    (\value ->
                        if value <= 0 then
                            Err (BadVersionNumber value) |> BD.succeed

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
            Err BinaryDataCorrupted


{-| Run a `Codec` to turn a String encoded with `encodeToString` into an Elm value.
-}
decodeFromURLSafeByteString : PrimitiveCodec e a -> String -> Result (Error e) a
decodeFromURLSafeByteString codec base64 =
    case decodeStringToBytes base64 of
        Just bytes_ ->
            decodeFromBytes codec bytes_

        Nothing ->
            Err BinaryDataCorrupted


{-| Run a `Codec` to turn a json value encoded with `encodeToJson` into an Elm value.
-}
decodeFromJson : Codec e s o a -> JE.Value -> Result (Error e) a
decodeFromJson codec json =
    let
        decoder =
            JD.index 0 JD.int
                |> JD.andThen
                    (\value ->
                        if value <= 0 then
                            Err (BadVersionNumber value) |> JD.succeed

                        else if value == version then
                            JD.index 1 (getJsonDecoder codec)

                        else
                            Err SerializerOutOfDate |> JD.succeed
                    )
    in
    case JD.decodeValue decoder json of
        Ok value ->
            value

        Err jdError ->
            Err (JDError jdError)


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
getBytesEncoder : Codec e s o a -> a -> BE.Encoder
getBytesEncoder (Codec m) =
    m.bytesEncoder


{-| Extracts the replica encoding function contained inside the `Codec`.
-}
getNodeEncoder : Codec e s o a -> NodeEncoder a o
getNodeEncoder (Codec m) inputs =
    m.nodeEncoder inputs


{-| Get the node encoder for solo objects.
-}
getSoloNodeEncoder : Codec e s SoloObject a -> (NodeEncoderInputs a -> SoloObjectEncoderOutput)
getSoloNodeEncoder (Codec m) inputs =
    m.nodeEncoder inputs


{-| Extracts the replica encoding function contained inside the `Codec`.
-}
getPrimitiveNodeEncoder : Codec e s Primitive a -> (a -> PrimitiveEncoderOutput)
getPrimitiveNodeEncoder (Codec m) primitiveToEncode =
    let
        bogusInputs =
            NodeEncoderInputs Node.testNode defaultEncodeMode (EncodeThis primitiveToEncode) (Change.genesisParent "getPrimitiveNodeEncoder - never used") Location.none
    in
    m.nodeEncoder bogusInputs


{-| Extracts the json encoding function contained inside the `Codec`.
-}
getJsonEncoder : Codec e s o a -> a -> JE.Value
getJsonEncoder (Codec m) =
    m.jsonEncoder


{-| Convert an Elm value into a sequence of bytes.
-}
encodeToBytes : Codec e s o a -> a -> Bytes.Bytes
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
encodeToURLSafeByteString : Codec e s o a -> a -> String
encodeToURLSafeByteString codec =
    encodeToBytes codec >> replaceBase64Chars


{-| Gives you the raw string, for debugging
-}
encodeToJsonString : Codec e s o a -> a -> String
encodeToJsonString codec value =
    JE.encode 0 (getJsonEncoder codec value)


{-| Convert an Elm value into json data.
-}
encodeToJson : Codec e s o a -> a -> JE.Value
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
startNodeFromRoot : Maybe Moment -> WrappedOrSkelCodec e s a -> ( Node, List Op.ClosedChunk )
startNodeFromRoot maybeMoment rootCodec =
    let
        rootEncoderOutput =
            getSoloNodeEncoder rootCodec
                { node = Node.testNode
                , mode = { defaultEncodeMode | setDefaultsExplicitly = True }
                , thingToEncode = EncodeThis <| new rootCodec (Change.startContext "eD")
                , parent = Change.genesisParent "eD"
                , position = Location.none
                }

        rootPointer =
            rootEncoderOutput.nested.toReference

        startNode =
            (Node.startNewNode maybeMoment False []).newNode
    in
    if startNode.root == Nothing then
        case rootPointer of
            Change.ExistingObjectPointer existingID ->
                -- weird. why would it be existing already?
                ( { startNode | root = Just existingID.object }, [] )

            Change.PlaceholderPointer pendingID _ ->
                let
                    ( rootOpID, finalCounter ) =
                        OpID.generate (OpID.importCounter 0) startNode.identity False

                    rootInitOp =
                        Op.initObject pendingID.reducer rootOpID

                    nodeWithRoot =
                        Node.updateWithClosedOps startNode [ rootInitOp ]
                in
                ( { nodeWithRoot | root = Just rootOpID }, [ [ rootInitOp ] ] )

    else
        ( startNode, [] )


{-| Generates naked Changes from a Codec's default values. These are all the values that would normally be skipped, not encoded to Changes.
Useful for spitting out test data, and seeing the whole heirarchy of your types.
-}
encodeDefaults : Node -> WrappedOrSkelCodec e s a -> ChangeSet
encodeDefaults node rootCodec =
    let
        rootEncoderOutput =
            getSoloNodeEncoder rootCodec
                { node = node
                , mode = { defaultEncodeMode | setDefaultsExplicitly = True }
                , thingToEncode = EncodeThis <| new rootCodec (Change.startContext "eD")
                , parent = Change.genesisParent "eD"
                , position = Location.none
                }
    in
    rootEncoderOutput.nested.changeSet


{-| Generates naked Changes from a Codec's default values. Passes in a test node, not for production
-}
encodeDefaultsForTesting : WrappedOrSkelCodec e s a -> ChangeSet
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
    -> NodeEncoder a o
    -> NodeDecoder e a
    -> SelfSeededCodec e o a
buildNestableCodec encoder_ decoder_ jsonEncoder jsonDecoder ronEncoder ronDecoder =
    Codec
        { bytesEncoder = encoder_
        , bytesDecoder = decoder_
        , jsonEncoder = jsonEncoder
        , jsonDecoder = jsonDecoder
        , nodeEncoder = ronEncoder
        , nodeDecoder = ronDecoder
        , nodePlaceholder = flatInit
        }


flatInit : PlaceholderGenerator a a
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
string : PrimitiveCodec e String
string =
    let
        nodeEncoder : NodeEncoderInputs String -> PrimitiveEncoderOutput
        nodeEncoder inputs =
            singlePrimitiveOut <| Change.StringAtom <| getEncodedPrimitive inputs.thingToEncode
    in
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
        , nodeEncoder = nodeEncoder
        , nodeDecoder = \_ -> JD.string |> JD.map Ok
        , nodePlaceholder = flatInit
        }


{-| An ID is a Pointer that's meant to be more user-facing. It has a type variable so it can be used for constraining a wrapped reptype for type safety, unlike a Pointer. It also can only be gotten from already Saved Objects, or objects that are about to be saved in the same frame as the ID reference, so we can guarantee that the ID points to something that exists, anywhere it's used. Placeholder Pointers will always be resolved to real object IDs by the time of serialization, so it's serialized as simply an object ID.
-}
id : PrimitiveCodec e (ID userType)
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
                        Err _ ->
                            Log.crashInDev
                                ("Un-serializing an ID " ++ asString ++ " but I couldn't find the object referenced in the node!")
                                ID.fromPointer
                                (ExistingObjectPointer (Change.ExistingID "error" opID))

                        Ok ( reducerID, objectID ) ->
                            -- TODO should we use the OpID instead? For versioning?
                            -- Or is this better to switch to canonical ObjectIDs
                            ID.fromPointer (ExistingObjectPointer (Change.ExistingID reducerID objectID))

        nodeEncoder : NodeEncoderInputs (ID userType) -> PrimitiveEncoderOutput
        nodeEncoder inputs =
            { complex = Nonempty.singleton <| idToChangeAtom (getEncodedPrimitive inputs.thingToEncode)
            , primitive = Nonempty.singleton <| idToPrimitiveAtom (getEncodedPrimitive inputs.thingToEncode)
            }
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
                    (\charCount -> BD.string charCount |> BD.map (fromString Nothing >> Ok))
        , jsonEncoder = toString >> JE.string
        , jsonDecoder = JD.string |> JD.map (fromString Nothing >> Ok)
        , nodeEncoder = nodeEncoder
        , nodeDecoder = \inputs -> JD.string |> JD.map (fromString (Just inputs.node) >> Ok)
        , nodePlaceholder = flatInit
        }


{-| Codec for serializing a `Bool`
-}
bool : PrimitiveCodec e Bool
bool =
    let
        boolNodeEncoder : NodeEncoder Bool Primitive
        boolNodeEncoder { thingToEncode } =
            if getEncodedPrimitive thingToEncode then
                singlePrimitiveOut <| Change.NakedStringAtom "true"

            else
                singlePrimitiveOut <| Change.NakedStringAtom "false"

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

                other ->
                    JD.succeed (Err (BadBoolean other))
    in
    buildNestableCodec
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


{-| Codec for serializing an `Int`
-}
int : PrimitiveCodec e Int
int =
    buildNestableCodec
        (toFloat >> BE.float64 endian)
        (BD.float64 endian |> BD.map (round >> Ok))
        JE.int
        (JD.int |> JD.map Ok)
        (\{ thingToEncode } ->
            singlePrimitiveOut <| Change.IntegerAtom <| getEncodedPrimitive thingToEncode
        )
        (\_ -> JD.int |> JD.map Ok)


{-| Codec for serializing a `Float`
-}
float : PrimitiveCodec e Float
float =
    buildNestableCodec
        (BE.float64 endian)
        (BD.float64 endian |> BD.map Ok)
        JE.float
        (JD.float |> JD.map Ok)
        (\{ thingToEncode } ->
            singlePrimitiveOut <| Change.FloatAtom <| getEncodedPrimitive thingToEncode
        )
        (\_ -> JD.float |> JD.map Ok)


{-| Codec for serializing a `Char`
-}
char : PrimitiveCodec e Char
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
        (\{ thingToEncode } -> singlePrimitiveOut <| Change.StringAtom <| String.fromChar <| getEncodedPrimitive thingToEncode)
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



-- DATA STRUCTURES


{-| Codec for serializing a `Maybe`

import Serialize as S

maybeIntCodec : Codec e (Maybe Int)
maybeIntCodec =
S.maybe S.int

-}
maybe : Codec e s o a -> SelfSeededCodec e {} (Maybe a)
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
repList : Codec e memberSeed o memberType -> WrappedCodec e (RepList memberType)
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

        memberChanger : { node : Node, modeMaybe : Maybe ChangesToGenerate, parent : Change.Parent } -> Location -> memberType -> Maybe OpID -> Change.ObjectChange
        memberChanger { node, modeMaybe, parent } memberIndex newMemberValue newRefMaybe =
            let
                memberNodeEncoded : Change.ComplexPayload
                memberNodeEncoded =
                    getNodeEncoder memberCodec
                        { mode = Maybe.withDefault defaultEncodeMode modeMaybe
                        , node = node
                        , thingToEncode = EncodeThis newMemberValue
                        , parent = parent
                        , position = memberIndex
                        }
                        |> .complex
            in
            case newRefMaybe of
                Just givenRef ->
                    Change.NewPayloadWithRef { payload = memberNodeEncoded, ref = givenRef }

                Nothing ->
                    Change.NewPayload memberNodeEncoded

        memberRonDecoder : { node : Node, parent : Parent, cutoff : Maybe Moment } -> JE.Value -> Maybe memberType
        memberRonDecoder { node, parent, cutoff } encodedMember =
            case JD.decodeValue (getNodeDecoder memberCodec { node = node, parent = parent, position = Location.newSingle "repListContainer", cutoff = cutoff }) encodedMember of
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

                        repListAsParent =
                            Change.becomeInstantParent repListPointer

                        finalMemberChanger =
                            memberChanger { node = node, modeMaybe = Nothing, parent = repListAsParent }

                        finalPayloadToMember =
                            memberRonDecoder { node = node, parent = repListAsParent, cutoff = cutoff }
                    in
                    Ok <| RepList.buildFromReplicaDb object finalPayloadToMember finalMemberChanger nonChanger
            in
            JD.map repListBuilder concurrentObjectIDsDecoder

        repListRonEncoder : NodeEncoder (RepList memberType) SoloObject
        repListRonEncoder ({ node, thingToEncode, mode, parent, position } as details) =
            case thingToEncode of
                EncodeThis givenRepList ->
                    let
                        externalChanges =
                            RepList.getInit givenRepList
                    in
                    soloOut <|
                        Change.changeObjectWithExternal
                            { target = RepList.getPointer givenRepList
                            , objectChanges = []
                            , externalUpdates = externalChanges
                            }

                _ ->
                    let
                        repListPointer =
                            Change.newPointer { parent = parent, position = position, reducerID = RepList.reducerID }
                    in
                    justInit repListPointer

        initializer : PlaceholderGenerator (Changer (RepList memberType)) (RepList memberType)
        initializer { parent, position, seed } =
            let
                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], position = position, reducer = RepList.reducerID, parent = parent }

                repListAsParent =
                    Change.becomeInstantParent (Object.getPointer object)

                finalMemberChanger =
                    memberChanger { node = Node.testNode, modeMaybe = Nothing, parent = repListAsParent }

                finalPayloadToMember =
                    memberRonDecoder { node = Node.testNode, parent = repListAsParent, cutoff = Nothing }

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
        , nodePlaceholder = initializer
        }


{-| Codec for an elm `List` primitive. Not sync-safe.
You will not be able to change the contents without replacing the entire list, and such changes will not merge nicely with concurrent changes, so consider using a `RepList` instead!
That said, useful for one-off lists, or Json serialization.
-}
list : Codec e s o a -> Codec e (List a) {} (List a)
list codec =
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

        nodeEncoder : NodeEncoder (List a) {}
        nodeEncoder inputs =
            case getEncodedPrimitive inputs.thingToEncode of
                [] ->
                    { complex = Nonempty.singleton <| Change.FromPrimitiveAtom <| Change.NakedStringAtom "[]"
                    }

                headItem :: moreItems ->
                    let
                        memberNodeEncoded : Int -> a -> Change.ComplexPayload
                        memberNodeEncoded index item =
                            getNodeEncoder codec
                                { mode = inputs.mode
                                , node = inputs.node
                                , thingToEncode = EncodeThis item
                                , parent = inputs.parent -- not quite.
                                , position = Location.new "primitiveListItem" index
                                }
                                |> .complex
                    in
                    { complex = Nonempty.concat <| Nonempty.indexedMap memberNodeEncoded (Nonempty headItem moreItems) }

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
        , nodePlaceholder = \{ seed } -> seed
        }


nonempty : SelfSeededCodec e o userType -> SelfSeededCodec e {} (Nonempty userType)
nonempty wrappedCodec =
    -- We can't use mapValid with built-in errors, since it will wrap it again with CustomError.
    -- So, we must implement mapValid from scratch, on top of the list codec.
    let
        nonemptyFromList : Result (Error e) (List userType) -> Result (Error e) (Nonempty userType)
        nonemptyFromList givenListResult =
            Result.andThen (\givenList -> Result.fromMaybe EmptyList <| Nonempty.fromList givenList) givenListResult

        listCodec =
            list wrappedCodec

        mapNodeEncoderInputs : NodeEncoderInputs (Nonempty a) -> NodeEncoderInputs (List a)
        mapNodeEncoderInputs inputs =
            NodeEncoderInputs inputs.node inputs.mode (mapThingToEncode inputs.thingToEncode) inputs.parent inputs.position

        mapThingToEncode : ThingToEncode (Nonempty a) -> ThingToEncode (List a)
        mapThingToEncode original =
            case original of
                EncodeThis a ->
                    EncodeThis (Nonempty.toList a)

                EncodeObjectOrThis objectIDs fieldVal ->
                    EncodeObjectOrThis objectIDs (Nonempty.toList fieldVal)
    in
    Codec
        { bytesEncoder = \v -> Nonempty.toList v |> getBytesEncoder listCodec
        , bytesDecoder =
            getBytesDecoder listCodec
                |> BD.map nonemptyFromList
        , jsonEncoder = \v -> Nonempty.toList v |> getJsonEncoder listCodec
        , jsonDecoder =
            getJsonDecoder listCodec
                |> JD.map nonemptyFromList
        , nodeEncoder = \inputs -> mapNodeEncoderInputs inputs |> getNodeEncoder listCodec
        , nodeDecoder = \inputs -> getNodeDecoder listCodec inputs |> JD.map nonemptyFromList
        , nodePlaceholder = flatInit
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
array : SelfSeededCodec e o a -> SelfSeededCodec e {} (Array a)
array codec =
    list codec |> map Array.fromList Array.toList


{-| A replicated set specifically for reptype members, with dictionary features such as getting a member by ID.
-}
repDb : Codec e s SoloObject memberType -> WrappedCodec e (RepDb memberType)
repDb memberCodec =
    let
        memberChanger : { node : Node, modeMaybe : Maybe ChangesToGenerate, asParent : Parent } -> memberType -> Change.ObjectChange
        memberChanger { node, modeMaybe, asParent } newValue =
            getNodeEncoder memberCodec
                { mode = Maybe.withDefault defaultEncodeMode modeMaybe
                , node = node
                , thingToEncode = EncodeThis newValue
                , parent = asParent
                , position = Location.newSingle "repDbContainer"
                }
                |> .complex
                |> Change.NewPayload

        memberRonDecoder : { node : Node, asParent : Parent, cutoff : Maybe Moment } -> JE.Value -> Maybe memberType
        memberRonDecoder { node, asParent, cutoff } encodedMember =
            case JD.decodeValue (getNodeDecoder memberCodec { node = node, parent = asParent, position = Location.newSingle "repDbMember", cutoff = cutoff }) encodedMember of
                Ok (Ok member) ->
                    Just member

                _ ->
                    Nothing

        childInstaller myPointer childPendingID =
            Change.delayedChangeObject myPointer
                (Change.NewPayload <| Nonempty.singleton (PendingObjectReferenceAtom childPendingID))

        repDbNodeDecoder : NodeDecoder e (RepDb memberType)
        repDbNodeDecoder { node, parent, position, cutoff } =
            let
                repDbBuilder foundObjectIDs =
                    let
                        object =
                            Node.getObject { node = node, cutoff = Nothing, foundIDs = foundObjectIDs, parent = parent, reducer = RepDb.reducerID, position = position }

                        repDbPointer =
                            Object.getPointer object

                        repDbAsParent =
                            Change.becomeDelayedParent repDbPointer (childInstaller repDbPointer)
                    in
                    Ok <| RepDb.buildFromReplicaDb object (memberRonDecoder { node = node, asParent = repDbAsParent, cutoff = cutoff }) (memberChanger { node = node, modeMaybe = Nothing, asParent = repDbAsParent }) nonChanger
            in
            JD.map repDbBuilder concurrentObjectIDsDecoder

        repDbNodeEncoder : NodeEncoder (RepDb memberType) SoloObject
        repDbNodeEncoder ({ node, thingToEncode, mode, parent, position } as details) =
            case thingToEncode of
                EncodeThis givenRepDb ->
                    let
                        externalChanges =
                            RepDb.getInit givenRepDb
                    in
                    soloOut <|
                        Change.changeObjectWithExternal
                            { target = RepDb.getPointer givenRepDb
                            , objectChanges = []
                            , externalUpdates = externalChanges
                            }

                _ ->
                    justInit (Change.newPointer { parent = parent, position = position, reducerID = RepDb.reducerID })

        initializer : PlaceholderInputs (Changer (RepDb memberType)) -> RepDb memberType
        initializer { parent, position, seed } =
            let
                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], position = position, reducer = RepDb.reducerID, parent = parent }

                repDbPointer =
                    Object.getPointer object

                repDbAsParent =
                    Change.becomeDelayedParent repDbPointer (childInstaller repDbPointer)

                finalMemberChanger =
                    memberChanger { node = Node.testNode, modeMaybe = Nothing, asParent = repDbAsParent }

                finalPayloadToMember =
                    memberRonDecoder { node = Node.testNode, asParent = repDbAsParent, cutoff = Nothing }
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
        , nodePlaceholder = initializer
        }


{-| A replicated dictionary.
-}
repDict : PrimitiveCodec e k -> Codec e vi o v -> WrappedCodec e (RepDict k v)
repDict keyCodec valueCodec =
    let
        -- We use the json-encoded form as the dict key, since it's always comparable!
        keyToString key =
            JE.encode 0 (getJsonEncoder keyCodec key)

        flatDictListCodec =
            list (pair keyCodec valueCodec)

        jsonEncoder : RepDict k v -> JE.Value
        jsonEncoder input =
            getJsonEncoder flatDictListCodec (RepDict.list input)

        bytesEncoder : RepDict k v -> BE.Encoder
        bytesEncoder input =
            getBytesEncoder flatDictListCodec (RepDict.list input)

        entryRonEncoder : Node -> Maybe ChangesToGenerate -> Pointer -> Location -> RepDict.RepDictEntry k v -> Change.ComplexPayload
        entryRonEncoder node encodeModeMaybe parent entryPosition newEntry =
            let
                keyEncoder givenKey =
                    getNodeEncoder keyCodec
                        { mode = Maybe.withDefault defaultEncodeMode encodeModeMaybe
                        , node = node
                        , thingToEncode = EncodeThis givenKey
                        , parent = Change.becomeInstantParent parent
                        , position = Location.nestSingle entryPosition ("repDictKey(" ++ keyToString givenKey ++ ")")
                        }

                valueEncoder givenValue =
                    getNodeEncoder valueCodec
                        { mode = Maybe.withDefault defaultEncodeMode encodeModeMaybe
                        , node = node
                        , thingToEncode = EncodeThis givenValue
                        , parent = Change.becomeInstantParent parent
                        , position = Location.nestSingle entryPosition "repDictVal"
                        }
            in
            case newEntry of
                RepDict.Cleared key ->
                    (keyEncoder key).complex

                RepDict.Present key value ->
                    Nonempty.append (keyEncoder key).complex (valueEncoder value).complex

        entryChanger node encodeModeMaybe parent entryPosition newEntry =
            Change.NewPayload (entryRonEncoder node encodeModeMaybe parent entryPosition newEntry)

        entryRonDecoder : Node -> Pointer -> Maybe Moment -> JE.Value -> Maybe (RepDictEntry k v)
        entryRonDecoder node parent cutoff encodedEntry =
            let
                decodeKey encodedKey =
                    JD.decodeValue (getNodeDecoder keyCodec { node = node, position = Location.newSingle "repDictKey", parent = Change.becomeInstantParent parent, cutoff = cutoff }) encodedKey

                decodeValue key encodedValue =
                    JD.decodeValue (getNodeDecoder valueCodec { node = node, position = Location.newSingle (keyToString key), parent = Change.becomeInstantParent parent, cutoff = cutoff }) encodedValue
            in
            case JD.decodeValue (JD.list JD.value) encodedEntry of
                Ok (keyEncoded :: [ valueEncoded ]) ->
                    case decodeKey keyEncoded of
                        Ok (Ok key) ->
                            case decodeValue key valueEncoded of
                                Ok (Ok value) ->
                                    Just (Present key value)

                                _ ->
                                    Log.crashInDev ("entryRonDecoder : found key " ++ keyToString key ++ " and decoded it, but not able to decode the value") Nothing

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

        repDictRonEncoder : NodeEncoder (RepDict k v) SoloObject
        repDictRonEncoder ({ node, thingToEncode, mode, parent, position } as details) =
            case thingToEncode of
                EncodeThis givenRepDict ->
                    let
                        externalChanges =
                            RepDict.getInit givenRepDict
                    in
                    soloOut <|
                        Change.changeObjectWithExternal
                            { target = RepDict.getPointer givenRepDict
                            , objectChanges = []
                            , externalUpdates = externalChanges
                            }

                _ ->
                    justInit (Change.newPointer { parent = parent, position = position, reducerID = RepDict.reducerID })

        initializer : PlaceholderInputs (Changer (RepDict k v)) -> RepDict k v
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
        , nodePlaceholder = initializer
        }


{-| Codec for a replicated store. Accepts a key codec and a value codec.

  - The value type's codec can't have a creation changer, since there is no explicit creation in a store.
  - For the same reason, it can't have a seed.
    (Forcing the seed to be the key would work, but in practice that turns out not to be useful - you could customize the value's defaults based on the key, but you usually need outside information to do so, and this could be accomplished by wrapping `get` with your own accessor function that provides fallbacks for `Nothing` based on the key. It would also allow one to store the key in the value, which is a waste of resources.

-}
repStore : PrimitiveCodec e k -> Codec e (any -> List Change) o v -> WrappedCodec e (RepStore k v)
repStore keyCodec valueCodec =
    let
        keyToString : k -> String
        keyToString key =
            -- TODO parse same on decode
            String.join "_" <| Nonempty.toList <| Nonempty.map Change.primitiveAtomToString (getPrimitiveNodeEncoder keyCodec key).primitive

        flatDictListCodec =
            list (pair keyCodec valueCodec)

        jsonEncoder : RepStore k v -> JE.Value
        jsonEncoder input =
            getJsonEncoder flatDictListCodec (RepStore.listModified input)

        bytesEncoder : RepStore k v -> BE.Encoder
        bytesEncoder input =
            getBytesEncoder flatDictListCodec (RepStore.listModified input)

        entryNodeEncodeWrapper : Node -> Maybe ChangesToGenerate -> Parent -> Location -> k -> Change.PendingID -> Change.ComplexPayload
        entryNodeEncodeWrapper node encodeModeMaybe parent entryPosition keyToSet childPendingID =
            let
                keyEncoder givenKey =
                    getNodeEncoder keyCodec
                        { mode = Maybe.withDefault defaultEncodeMode encodeModeMaybe
                        , node = node
                        , thingToEncode = EncodeThis givenKey
                        , parent = parent
                        , position = Location.nestSingle entryPosition (keyToString keyToSet)
                        }
            in
            Nonempty.append (keyEncoder keyToSet).complex (Nonempty.singleton (Change.PendingObjectReferenceAtom childPendingID))

        entryNodeDecoder : Node -> Parent -> Maybe Moment -> JE.Value -> Maybe (RepStore.RepStoreEntry k v)
        entryNodeDecoder node parent cutoff encodedEntry =
            let
                decodeKey encodedKey =
                    JD.decodeValue (getNodeDecoder keyCodec { node = node, position = Location.newSingle "key", parent = parent, cutoff = cutoff }) encodedKey

                decodeValue key encodedValue =
                    JD.decodeValue
                        (getNodeDecoder valueCodec
                            { node = node
                            , position = Location.newSingle (keyToString key)
                            , parent = parent -- no need to wrap child changes as decoding entries means they already exist
                            , cutoff = cutoff
                            }
                        )
                        encodedValue
            in
            case JD.decodeValue (JD.list JD.value) encodedEntry of
                Ok (keyEncoded :: [ valueEncoded ]) ->
                    case decodeKey keyEncoded of
                        Ok (Ok key) ->
                            case decodeValue key valueEncoded of
                                Ok (Ok value) ->
                                    Just (RepStore.RepStoreEntry key value)

                                _ ->
                                    Log.crashInDev ("storeEntryNodeDecoder : found key " ++ keyToString key ++ " and value but not able to decode the value") Nothing

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

                repStoreAsParent =
                    Change.becomeInstantParent repStorePointer

                allEntries =
                    List.filterMap (\event -> entryNodeDecoder node repStoreAsParent Nothing (Object.eventPayloadAsJson event)) (AnyDict.values (Object.getEvents repStoreObject))

                entriesDict : AnyDict String k (List v)
                entriesDict =
                    let
                        addEntryToDict : RepStore.RepStoreEntry k v -> AnyDict String k (List v) -> AnyDict String k (List v)
                        addEntryToDict (RepStore.RepStoreEntry k v) dictSoFar =
                            AnyDict.update k (updateEntry v) dictSoFar
                    in
                    List.foldl addEntryToDict (AnyDict.empty keyToString) allEntries

                updateEntry newVal oldValMaybe =
                    case oldValMaybe of
                        Nothing ->
                            Just [ newVal ]

                        Just [] ->
                            Just [ newVal ]

                        Just prevEntries ->
                            Just (newVal :: prevEntries)

                fetcher : k -> v
                fetcher key =
                    AnyDict.get key entriesDict
                        |> Maybe.andThen List.head
                        |> Maybe.withDefault (createObjectAt key)

                createObjectAt key =
                    -- TODO FrameIndex needed?
                    new valueCodec (Change.Context (Location.newSingle "repStoreNew") (Change.becomeDelayedParent repStorePointer (wrapNewPendingChild key)))

                wrapNewPendingChild key pendingChild =
                    Change.delayedChangeObject repStorePointer
                        (Change.NewPayload (entryNodeEncodeWrapper node Nothing repStoreAsParent (Location.newSingle "repStoreVal") key pendingChild))
            in
            RepStore.buildFromReplicaDb { object = repStoreObject, fetcher = fetcher, start = changer }

        repStoreNodeEncoder : NodeEncoder (RepStore k v) SoloObject
        repStoreNodeEncoder { thingToEncode, parent, position } =
            case thingToEncode of
                EncodeThis givenRepStore ->
                    soloOut <|
                        Change.changeObjectWithExternal
                            { target = RepStore.getPointer givenRepStore
                            , objectChanges = []
                            , externalUpdates = RepStore.getInit givenRepStore
                            }

                _ ->
                    justInit (Change.newPointer { parent = parent, position = position, reducerID = RepStore.reducerID })

        initializer : PlaceholderInputs (Changer (RepStore k v)) -> RepStore k v
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
        , nodePlaceholder = initializer
        }


{-| Codec for serializing a `Dict`

    import Serialize as S

    type alias Name =
        String

    peoplesAgeCodec : S.Codec e (Dict Name Int)
    peoplesAgeCodec =
        S.dict S.string S.int

    Not sync-safe : use RepDict instead.

-}
dict : PrimitiveCodec e comparable -> Codec e s o a -> SelfSeededCodec e {} (Dict comparable a)
dict keyCodec valueCodec =
    list (pair keyCodec valueCodec)
        |> map Dict.fromList Dict.toList


{-| Codec for serializing a `Set`
-}
set : PrimitiveCodec e comparable -> SelfSeededCodec e {} (Set comparable)
set codec =
    list codec |> map Set.fromList Set.toList


{-| Codec for serializing `()` (aka `Unit`).
-}
unit : PrimitiveCodec e ()
unit =
    buildNestableCodec
        (always (BE.sequence []))
        (BD.succeed (Ok ()))
        (\_ -> JE.int 0)
        (JD.succeed (Ok ()))
        (\_ -> singlePrimitiveOut <| Change.IntegerAtom 0)
        (\_ -> JD.succeed (Ok ()))


{-| Codec for serializing a tuple with 2 elements

    import Codec exposing (Codec)

    pointCodec : Codec e ( Float, Float ) ( Float, Float )
    pointCodec =
        Codec.tuple Codec.float Codec.float

-}
pair : Codec e ia oa a -> Codec e ib ob b -> NullCodec e ( a, b )
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
triple : Codec e ia oa a -> Codec e ib ob b -> Codec e ic oc c -> SelfSeededCodec e {} ( a, b, c )
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
result : Codec e sa oa error -> Codec e sb ob value -> SelfSeededCodec e {} (Result error value)
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
bytes : PrimitiveCodec e Bytes.Bytes
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
                            Err (BadByteString text)
                )
        )
        (\inputs -> singlePrimitiveOut <| Change.StringAtom <| replaceBase64Chars <| getEncodedPrimitive inputs.thingToEncode)
        (\_ ->
            JD.string
                |> JD.map
                    (\text ->
                        case decodeStringToBytes text of
                            Just bytes_ ->
                                Ok bytes_

                            Nothing ->
                                Err (BadByteString text)
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
byte : PrimitiveCodec e Int
byte =
    buildNestableCodec
        BE.unsignedInt8
        (BD.unsignedInt8 |> BD.map Ok)
        (modBy 256 >> JE.int)
        (JD.int |> JD.map Ok)
        (\{ thingToEncode } -> singlePrimitiveOut <| Change.IntegerAtom <| modBy 256 <| getEncodedPrimitive thingToEncode)
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
quickEnum : a -> List a -> PrimitiveCodec e a
quickEnum defaultItem items =
    let
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

        intNodeEncoder : NodeEncoder a Primitive
        intNodeEncoder { thingToEncode } =
            singlePrimitiveOut <| Change.IntegerAtom <| getIndex <| getEncodedPrimitive <| thingToEncode
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
    | PlaceholderDefault fieldSeed
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

        PlaceholderDefault seed ->
            Nothing

        DefaultFromParentSeed _ ->
            Nothing


fieldLocationLabel : String -> Int -> String
fieldLocationLabel fieldName fieldSlot =
    "." ++ fieldName ++ String.fromInt fieldSlot


{-| Not exposed - for all `readable` functions
-}
readableHelper : FieldIdentifier -> (full -> fieldType) -> Codec errs fieldSeed o fieldType -> FieldFallback parentSeed fieldSeed fieldType -> PartialRegister errs parentSeed full (fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
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
                            Log.crashInDev ("Codec.readableHelper.nodeDecoder: '" ++ fieldName ++ "' field decoded to nothing.. error was " ++ (String.join " ... and also ..." <| List.map errorToString thisFieldErrors) ++ " for the object at " ++ Debug.toString inputs.regPointer) Nothing

                        ( _, Nothing ) ->
                            Log.crashInDev ("Codec.readableHelper.nodeDecoder: " ++ fieldName ++ " field was missing prior constructor, error was " ++ Debug.toString thisFieldErrors) Nothing
            in
            ( updatedConstructorMaybe, soFarErrors ++ thisFieldErrors )

        nodeInitializer : RegisterFieldInitializer parentSeed remaining
        nodeInitializer parentSeed regPointer =
            let
                applyToRemaining =
                    recordCodecSoFar.nodeInitializer parentSeed regPointer

                fieldInit : fieldSeed -> fieldType
                fieldInit fieldSeed =
                    getInitializer fieldCodec
                        { parent = Change.becomeDelayedParent regPointer (updateRegisterPostChildInit regPointer ( fieldSlot, fieldName ))
                        , position = Location.new (fieldLocationLabel fieldName fieldSlot) newFieldIndex
                        , seed = fieldSeed
                        }

                fieldValue : fieldType
                fieldValue =
                    case fallback of
                        HardcodedDefault fieldType ->
                            fieldType

                        PlaceholderDefault fieldSeed ->
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
                    , regPointer = inputs.regPointer
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
writableHelper : FieldIdentifier -> (full -> RW fieldType) -> Codec errs fieldSeed o fieldType -> FieldFallback parentSeed fieldSeed fieldType -> Bool -> PartialRegister errs parentSeed full (RW fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
writableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec fallback isDelayable (PartialRegister recordCodecSoFar) =
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

        asParent regPointer =
            -- make instant? this is for using .set on RWs, which should never need to init their parents.
            -- there may be a wrapper between the object and the parent (such as Just) which would be missing from the delayed init change anyway, causing errors.
            if isDelayable then
                Change.becomeDelayedParent regPointer (updateRegisterPostChildInit regPointer ( fieldSlot, fieldName ))

            else
                Change.becomeInstantParent regPointer

        nodeDecoder : RegisterFieldDecoder errs remaining
        nodeDecoder inputs =
            let
                ( thisFieldValueMaybe, thisFieldErrors ) =
                    registerWritableFieldDecoder newFieldIndex ( fieldSlot, fieldName ) fallback isDelayable fieldCodec inputs

                ( remainingRecordConstructorMaybe, soFarErrors ) =
                    recordCodecSoFar.nodeDecoder inputs

                updatedConstructorMaybe =
                    case ( thisFieldValueMaybe, remainingRecordConstructorMaybe ) of
                        ( Just thisFieldValue, Just remainingRecordConstructor ) ->
                            Just <| remainingRecordConstructor thisFieldValue

                        ( Nothing, _ ) ->
                            Log.crashInDev ("Codec.writableHelper.nodeDecoder: '" ++ fieldName ++ "' field decoded to nothing.. error was " ++ Debug.toString thisFieldErrors ++ " for the object at " ++ Debug.toString inputs.regPointer ++ " with history " ++ Debug.toString (Dict.get fieldSlot inputs.history)) Nothing

                        ( _, Nothing ) ->
                            Log.crashInDev ("Codec.writableHelper.nodeDecoder:" ++ fieldName ++ " field was missing prior constructor..") Nothing
            in
            ( updatedConstructorMaybe, soFarErrors ++ thisFieldErrors )

        nodeInitializer : RegisterFieldInitializer parentSeed remaining
        nodeInitializer parentSeed regPointer =
            let
                applyToRemaining =
                    recordCodecSoFar.nodeInitializer parentSeed regPointer

                fieldInit : fieldSeed -> fieldType
                fieldInit seed =
                    getInitializer fieldCodec
                        { parent = asParent regPointer
                        , position = Location.new (fieldLocationLabel fieldName fieldSlot) newFieldIndex
                        , seed = seed
                        }

                fieldValue : fieldType
                fieldValue =
                    case fallback of
                        HardcodedDefault fieldType ->
                            fieldType

                        PlaceholderDefault fieldSeed ->
                            fieldInit fieldSeed

                        InitWithParentSeed parentSeedToFieldSeed ->
                            fieldInit (parentSeedToFieldSeed parentSeed)

                        DefaultFromParentSeed parentSeedToFieldDefault ->
                            parentSeedToFieldDefault parentSeed

                        DefaultAndInitWithParentSeed default parentSeedToFieldSeed ->
                            fieldInit (parentSeedToFieldSeed parentSeed)

                wrapRW : fieldType -> RW fieldType
                wrapRW head =
                    buildRW regPointer ( fieldSlot, fieldName ) fieldEncoder head

                fieldEncoder newValue =
                    getNodeEncoder fieldCodec
                        { node = Node.testNode
                        , mode = defaultEncodeMode
                        , thingToEncode = EncodeThis newValue
                        , parent = asParent regPointer
                        , position = Location.new (fieldLocationLabel fieldName fieldSlot) newFieldIndex
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
                    , regPointer = inputs.regPointer
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
field : FieldIdentifier -> (full -> fieldType) -> Codec errs fieldType o fieldType -> fieldType -> PartialRegister errs i full (fieldType -> remaining) -> PartialRegister errs i full remaining
field ( fieldSlot, fieldName ) fieldGetter fieldCodec fieldDefault soFar =
    readableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec (HardcodedDefault fieldDefault) soFar


{-| Read a field containing a nested register, using an auto-generated default.

  - This field is read-only, which is good because you can use the nested register's native way of writing changes. For example, a nested record can have `RW` fields, you can `Change` it that way.
  - Auto-generating a default only works for seedless codecs - make sure your codec is of type `SkelCodec e MyType`, aka the seed is `()`. If you have a seeded object to put here, see `seededR` instead.

-}
fieldReg : FieldIdentifier -> (full -> fieldType) -> WrappedOrSkelCodec errs s fieldType -> PartialRegister errs i full (fieldType -> remaining) -> PartialRegister errs i full remaining
fieldReg ( fieldSlot, fieldName ) fieldGetter fieldCodec soFar =
    readableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec (PlaceholderDefault nonChanger) soFar


{-| Read a field containing a nested record, using an auto-generated default.

  - This field is read-only, which is good because you can use the nested register's native way of writing changes. For example, a nested record can have `RW` fields, you can `Change` it that way.
  - Naked records "skeletons" can only be initialized this way, or using full record literal syntax.

-}
fieldRec : FieldIdentifier -> (full -> fieldType) -> SkelCodec errs fieldType -> PartialRegister errs i full (fieldType -> remaining) -> PartialRegister errs i full remaining
fieldRec ( fieldSlot, fieldName ) fieldGetter fieldCodec soFar =
    readableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec (PlaceholderDefault nonChanger) soFar


{-| Read a `Maybe something` field without adding the `maybe` codec. Default is Nothing.

  - If your field will more often be set to something else (e.g. `Just 0`), consider using `readable` with your `maybe`-wrapped codec instead and using the common value as the default. This will save space and bandwidth.

-}
maybeR : FieldIdentifier -> (full -> Maybe justFieldType) -> Codec errs o fieldSeed justFieldType -> PartialRegister errs i full (Maybe justFieldType -> remaining) -> PartialRegister errs i full remaining
maybeR fieldID fieldGetter fieldCodec recordBuilt =
    readableHelper fieldID fieldGetter (maybe fieldCodec) (HardcodedDefault Nothing) recordBuilt


{-| Read a `RepList` field without adding the `repList` codec. Default is an empty `RepList`.

  - Will not work with primitive `List` fields. For that, use the `immutableList` codec with `field`.
  - Default is an empty RepList. Want a different default? Use `field` with the `repList` codec.
  - If any items in the RepList are corrupted, they will be silently excluded.
  - If your field is not a `RepList` but a type that wraps one (or more), you will need to use `field` or `fieldRW` with the `repList` codec instead.

-}
fieldList : FieldIdentifier -> (full -> RepList memberType) -> Codec errs o memberSeed memberType -> PartialRegister errs i full (RepList memberType -> remaining) -> PartialRegister errs i full remaining
fieldList fieldID fieldGetter fieldCodec recordBuilt =
    readableHelper fieldID fieldGetter (repList fieldCodec) (PlaceholderDefault nonChanger) recordBuilt


{-| Read a `RepDict` field without adding the `repDict` codec. Default is an empty `RepDict`. Instead of supplying a single codec for members, you provide a pair of codec in a tuple, e.g. `(string, bool)`.

  - Will not yet work with primitive `Dict` fields. For that, use the `immutableList` codec with `field`.
  - Default is an empty RepDict. Want a different default? Use `field` with the `repDict` codec.
  - If any items in the RepDict are corrupted, they will be silently excluded.
  - If your field is not a `RepDict` but a type that wraps one (or more), you will need to use `field` or `fieldRW` with the `repDict` codec instead.

-}
fieldDict : FieldIdentifier -> (full -> RepDict keyType valueType) -> ( PrimitiveCodec errs keyType, Codec errs valInit o valueType ) -> PartialRegister errs i full (RepDict keyType valueType -> remaining) -> PartialRegister errs i full remaining
fieldDict fieldID fieldGetter ( keyCodec, valueCodec ) recordBuilt =
    readableHelper fieldID fieldGetter (repDict keyCodec valueCodec) (PlaceholderDefault nonChanger) recordBuilt


{-| Read a `RepStore` field without adding the `repStore` codec. Default is an empty `RepStore`. Instead of supplying a single codec for members, you provide a pair of codec in a tuple, e.g. `(string, bool)`.

  - Default is an empty RepStore. Want a different default? Use `field` with the `repStore` codec.
  - If any items in the RepStore are corrupted, they will be silently excluded.
  - If your field is not a `RepStore` but a type that wraps one (or more), you will need to use `field` or `fieldRW` with the `repStore` codec instead.

-}
fieldStore : FieldIdentifier -> (full -> RepStore keyType valueType) -> ( PrimitiveCodec errs keyType, Codec errs (any -> List Change) o valueType ) -> PartialRegister errs i full (RepStore keyType valueType -> remaining) -> PartialRegister errs i full remaining
fieldStore fieldID fieldGetter ( keyCodec, valueCodec ) recordBuilt =
    readableHelper fieldID fieldGetter (repStore keyCodec valueCodec) (PlaceholderDefault nonChanger) recordBuilt


{-| Read a `RepDb` field without adding the `repDb` codec. Default is an empty `RepDb`.

  - If any items in the RepDb are corrupted, they will be silently excluded.
  - If your field is not a `RepDb` but a type that wraps one (or more), you will need to use `field` or `fieldRW` with the `repDb` codec instead.

-}
fieldDb : FieldIdentifier -> (full -> RepDb memberType) -> Codec errs memberSeed SoloObject memberType -> PartialRegister errs i full (RepDb memberType -> remaining) -> PartialRegister errs i full remaining
fieldDb fieldID fieldGetter fieldCodec recordBuilt =
    readableHelper fieldID fieldGetter (repDb fieldCodec) (PlaceholderDefault nonChanger) recordBuilt


{-| Read a record field wrapped with `RW` and `Maybe`. This makes the field writable and optional.
Equivalent to using `fieldRW` with the `maybe` codec wrapper and a `Nothing` default value.

  - Due to the RW wrapper, you will need to add `.get` to the output whenever you want to access the field's latest value as usual. Read-only fields do not require this.
  - Thanks to the RW wrapper, you can add `.set` to the output anywhere in your program to produce a `Change`. These changes can then be saved, updating the stored value.

-}
fieldRWM : FieldIdentifier -> (full -> RWMaybe fieldType) -> Codec errs fieldSeed o fieldType -> PartialRegister errs i full (RWMaybe fieldType -> remaining) -> PartialRegister errs i full remaining
fieldRWM fieldIdentifier fieldGetter fieldCodec soFar =
    writableHelper fieldIdentifier fieldGetter (maybe fieldCodec) (HardcodedDefault Nothing) False soFar


{-| Read a record field wrapped with `RW`. This makes the field writable.
The last argument specifies a default value, which is used when initializing the record for the first time.

  - Due to the RW wrapper, you will need to add `.get` to the output whenever you want to access the field's latest value as usual. Read-only fields do not require this.
  - Thanks to the RW wrapper, you can add `.set` to the output anywhere in your program to produce a `Change`. These changes can then be saved, updating the stored value.
  - Consider setting the default to the "most popular" value (e.g. "scaling factor" set to 1.0), as it will be omitted from the serialized data, saving space and bandwidth.
  - Consider setting the default to the "safest" value, as missing fields will be parsed as the default.
  - If you can't come up with a sensible default value (e.g. date of birth), consider wrapping the field in `Maybe` or `Result`, with e.g. `Nothing` or `Err Unset` as the default.
  - If there's no sensible default and this record is not useful with missing data unless you add another validation step ("Parse, Don't Validate"!), consider `readableRequired` as a last resort.

-}
fieldRW : FieldIdentifier -> (full -> RW fieldType) -> Codec errs fieldType o fieldType -> fieldType -> PartialRegister errs i full (RW fieldType -> remaining) -> PartialRegister errs i full remaining
fieldRW fieldIdentifier fieldGetter fieldCodec fieldDefault soFar =
    writableHelper fieldIdentifier fieldGetter fieldCodec (HardcodedDefault fieldDefault) False soFar


{-| Read a field that is required, yet has no sensible default. Use sparingly.

  - Only add required fields BEFORE using in production for the first time.
  - NEVER add required fields after that, or old data may be seen as corrupt.
  - Useful for "Parse, Don't Validate" as you can use this to avoid extra validation later, e.g. `Maybe` wrappers on fields that should never be missing.
  - Will it be essential forever? Once you require a field, you can't make it optional later - omitted values from new clients will be seen as corrupt by old ones!
  - Consider if this field being set upfront is essential to this record. For graceful degradation, records missing essential fields will be omitted from any containing collections. If the field is in your root object, it may fail to parse entirely. (And that's exactly what you would want, if this field were truly essential.)

-}
coreR : FieldIdentifier -> (full -> fieldType) -> Codec errs fieldSeed o fieldType -> (parentSeed -> fieldSeed) -> PartialRegister errs parentSeed full (fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
coreR fieldID fieldGetter fieldCodec seeder recordBuilt =
    readableHelper fieldID fieldGetter fieldCodec (InitWithParentSeed seeder) recordBuilt


{-| Read and Write a core field. A core field is both required, AND has no sensible default. Prefer non-core fields when possible.

Including any core fields in your register will force you to pass in a "seed" any time you initialize it. The seed value contains whatever you need to initialize all the core fields. Registers that do not need seeds are more robust to serialization!

  - If this field is truly unique to the register upon initialization, does it really need to be writable? Consider using `coreR` instead, so your code can initialize the field with a seed but not accidentally modify it later.

-}
coreRW : FieldIdentifier -> (full -> RW fieldType) -> Codec errs fieldSeed o fieldType -> (parentSeed -> fieldSeed) -> PartialRegister errs parentSeed full (RW fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
coreRW fieldID fieldGetter fieldCodec seeder recordBuilt =
    writableHelper fieldID fieldGetter fieldCodec (InitWithParentSeed seeder) False recordBuilt


{-| Read a field that needs a seed.
Pass in a `(\parentSeed -> fieldSeed)` function, which gives you access to the parent's seed, if it has one. Otherwise, that's just `()` The return value will be used to seed the field.

  - Does your field actually need to be available as soon as the parent exists? If not, consider wrapping it in something like `Maybe` so you can give a it a default of `Nothing` and seed it when you actually need it. Then you don't need a seed from the parent.
  - You can use this to seed the field with a constant, ignoring the parent seed like `(\_ -> [1,2,3])` if you need that for some reason. But if a constant works, your field's type can probably be made seedless anyway. You can also just use a field default, rather than seeding, so your parent register can be seedless.

-}
seededR : FieldIdentifier -> (full -> fieldType) -> Codec errs fieldSeed o fieldType -> fieldType -> (parentSeed -> fieldSeed) -> PartialRegister errs parentSeed full (fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
seededR fieldID fieldGetter fieldCodec default seeder recordBuilt =
    readableHelper fieldID fieldGetter fieldCodec (DefaultAndInitWithParentSeed default seeder) recordBuilt


{-| Read/Write a field that needs a seed.
Pass in a `(\parentSeed -> fieldSeed)` function, which gives you access to the parent's seed, if it has one. Otherwise, that's just `()` The return value will be used to seed the field.

  - Does your field actually need to be available as soon as the parent exists? If not, consider wrapping it in something like `Maybe` so you can give a it a default of `Nothing` and seed it when you actually need it. Then you don't need a seed from the parent.
  - You can use this to seed the field with a constant, ignoring the parent seed like `(\_ -> [1,2,3])` if you need that for some reason. But if a constant works, your field's type can probably be made seedless anyway. You can also just use a field default, rather than seeding, so your parent register can be seedless.

-}
seededRW : FieldIdentifier -> (full -> RW fieldType) -> Codec errs fieldSeed o fieldType -> fieldType -> (parentSeed -> fieldSeed) -> PartialRegister errs parentSeed full (RW fieldType -> remaining) -> PartialRegister errs parentSeed full remaining
seededRW fieldID fieldGetter fieldCodec default seeder recordBuilt =
    writableHelper fieldID fieldGetter fieldCodec (DefaultAndInitWithParentSeed default seeder) False recordBuilt


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
updateRegisterPostChildInit : Pointer -> FieldIdentifier -> Change.PendingID -> Change.DelayedChange
updateRegisterPostChildInit parentPointer fieldIdentifier pendingChildToWrap =
    Change.delayedChangeObject parentPointer
        (Change.NewPayload (encodeFieldPayloadAsObjectPayload fieldIdentifier (Nonempty.singleton <| PendingObjectReferenceAtom pendingChildToWrap)))


{-| RON what to do when decoding a (potentially nested!) object field.
-}
registerReadOnlyFieldDecoder : Int -> ( FieldSlot, FieldName ) -> FieldFallback parentSeed fieldSeed fieldType -> Codec e fieldSeed o fieldType -> RegisterFieldDecoderInputs -> ( Maybe fieldType, List (Error e) )
registerReadOnlyFieldDecoder index (( fieldSlot, fieldName ) as fieldIdentifier) fallback fieldCodec inputs =
    let
        regAsParent =
            Change.becomeDelayedParent inputs.regPointer (updateRegisterPostChildInit inputs.regPointer fieldIdentifier)

        position =
            Location.new (fieldLocationLabel fieldName fieldSlot) index

        runFieldDecoder thingToDecode =
            JD.decodeValue
                (getNodeDecoder fieldCodec
                    { node = inputs.node, position = position, parent = regAsParent, cutoff = inputs.cutoff }
                )
                thingToDecode

        generatedDefaultMaybe =
            case fallback of
                PlaceholderDefault fieldSeed ->
                    Just <| getInitializer fieldCodec { parent = regAsParent, seed = fieldSeed, position = position }

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
                        -- TODO custom error type for missing field
                        ( default, [ MissingRequiredField fieldSlot fieldName ] )

        Just foundField ->
            -- field was set before
            case runFieldDecoder (Op.payloadToJsonValue foundField) of
                Ok (Ok goodValue) ->
                    ( Just goodValue, [] )

                Ok (Err problem) ->
                    ( default, [ problem ] )

                Err jsonDecodeError ->
                    ( default, [ FailedToDecodeRegField fieldSlot fieldName (Op.payloadToJsonValue foundField |> JE.encode 0) jsonDecodeError ] )


registerWritableFieldDecoder : Int -> ( FieldSlot, FieldName ) -> FieldFallback parentSeed fieldSeed fieldType -> Bool -> Codec e fieldSeed o fieldType -> RegisterFieldDecoderInputs -> ( Maybe (RW fieldType), List (Error e) )
registerWritableFieldDecoder index (( fieldSlot, fieldName ) as fieldIdentifier) fallback isDelayable fieldCodec inputs =
    let
        regAsParent =
            if isDelayable then
                Change.becomeDelayedParent inputs.regPointer (updateRegisterPostChildInit inputs.regPointer ( fieldSlot, fieldName ))

            else
                Change.becomeInstantParent inputs.regPointer

        fieldEncoder newValue =
            getNodeEncoder fieldCodec
                { node = inputs.node
                , mode = defaultEncodeMode
                , thingToEncode = EncodeThis newValue
                , parent = regAsParent
                , position = Location.new (fieldLocationLabel fieldName fieldSlot) index
                }

        wrapRW : Change.Pointer -> fieldType -> RW fieldType
        wrapRW targetObject head =
            buildRW targetObject fieldIdentifier fieldEncoder head
    in
    case registerReadOnlyFieldDecoder index fieldIdentifier fallback fieldCodec inputs of
        ( Just thingToWrap, errorsSoFar ) ->
            ( Just (wrapRW inputs.regPointer thingToWrap), errorsSoFar )

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
finishRecord : PartialRegister errs () full full -> SkelCodec errs full
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

                        regPointer =
                            Object.getPointer object

                        history =
                            buildRegisterFieldDictionary object

                        regToRecordByDecodingMaybe =
                            case
                                allFieldsCodec.nodeDecoder { node = node, regPointer = regPointer, cutoff = cutoff, history = history }
                            of
                                ( success, [] ) ->
                                    success

                                ( recovered, errors ) ->
                                    Log.log ("regToRecordByDecoding returned errors! " ++ Log.dump errors ++ " while decoding record at " ++ Location.toString position) recovered

                        regToRecordByInit =
                            allFieldsCodec.nodeInitializer

                        finalRecord =
                            case regToRecordByDecodingMaybe of
                                Just recordDecoded ->
                                    recordDecoded

                                Nothing ->
                                    Log.crashInDev "nakedRegisterDecoder decoded nothing!" <|
                                        regToRecordByInit () regPointer
                    in
                    JD.succeed <| Ok <| finalRecord
            in
            JD.andThen nakedRegisterDecoder concurrentObjectIDsDecoder

        nodeEncoder : NodeEncoder full SoloObject
        nodeEncoder inputs =
            recordNodeEncoder partial inputs

        emptyRegister : PlaceholderGenerator Skel full
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
        { nodeEncoder = nodeEncoder
        , nodeDecoder = nodeDecoder
        , bytesEncoder = allFieldsCodec.bytesEncoder >> List.reverse >> BE.sequence
        , bytesDecoder = bytesDecoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = jsonDecoder
        , nodePlaceholder = emptyRegister
        }


{-| Finish creating a codec for a naked Register.
This is a Register, stripped of its wrapper.
-}
finishSeededRecord : PartialRegister errs s full full -> Codec errs s SoloObject full
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

                        regPointer =
                            Object.getPointer object

                        history =
                            buildRegisterFieldDictionary object

                        regToRecordByDecoding givenCutoff =
                            case
                                allFieldsCodec.nodeDecoder { node = node, regPointer = regPointer, cutoff = givenCutoff, history = history }
                            of
                                ( success, [] ) ->
                                    success

                                ( recovered, errors ) ->
                                    Log.crashInDev ("regToRecordByDecoding returned errors!" ++ Log.dump errors) recovered

                        wrongCutoffRegToRecordByDecoding =
                            case
                                allFieldsCodec.nodeDecoder { node = node, regPointer = regPointer, cutoff = Nothing, history = history }
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
                            JD.succeed <| Err WrongCutoff
            in
            JD.andThen nakedRegisterDecoder concurrentObjectIDsDecoder

        nodeEncoder : NodeEncoder full SoloObject
        nodeEncoder inputs =
            recordNodeEncoder partial inputs

        emptyRegister : PlaceholderGenerator s full
        emptyRegister { parent, position, seed } =
            let
                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], parent = parent, reducer = registerReducerID, position = position }
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
        { nodeEncoder = nodeEncoder
        , nodeDecoder = nodeDecoder
        , bytesEncoder = allFieldsCodec.bytesEncoder >> List.reverse >> BE.sequence
        , bytesDecoder = bytesDecoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = jsonDecoder
        , nodePlaceholder = emptyRegister
        }


{-| Finish creating a codec for a register.
-}
finishRegister : PartialRegister errs () full full -> WrappedCodec errs (Reg full)
finishRegister ((PartialRegister allFieldsCodec) as partialRegister) =
    let
        encodeAsJsonObject (Register regDetails) =
            let
                fullRecord =
                    regDetails.latest

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

                        regPointer =
                            Object.getPointer object

                        regToRecordByDecoding givenCutoff =
                            case
                                allFieldsCodec.nodeDecoder { node = node, regPointer = regPointer, cutoff = givenCutoff, history = history }
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
                                    regToRecordByInit () regPointer
                    in
                    JD.succeed <| Ok <| Register { pointer = regPointer, included = Object.All, latest = regToRecord Nothing, older = Just >> regToRecord, history = history, init = nonChanger }
            in
            JD.andThen registerDecoder concurrentObjectIDsDecoder

        nodeEncoder : NodeEncoder (Reg full) SoloObject
        nodeEncoder inputs =
            registerNodeEncoder partialRegister inputs

        emptyRegister : PlaceholderGenerator (Changer (Reg full)) (Reg full)
        emptyRegister { parent, position, seed } =
            let
                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], parent = parent, reducer = registerReducerID, position = position }

                history =
                    buildRegisterFieldDictionary object

                regToRecord =
                    allFieldsCodec.nodeInitializer () (Object.getPointer object)
            in
            Register { pointer = Object.getPointer object, included = Object.All, latest = regToRecord, older = \_ -> regToRecord, history = history, init = seed }

        tempEmpty =
            emptyRegister { parent = Change.genesisParent "flatTodo", seed = nonChanger, position = Location.none }

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
        { nodeEncoder = nodeEncoder
        , nodeDecoder = nodeDecoder
        , bytesEncoder = \(Register regDetails) -> (allFieldsCodec.bytesEncoder >> List.reverse >> BE.sequence) regDetails.latest
        , bytesDecoder = bytesDecoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = jsonDecoder
        , nodePlaceholder = emptyRegister
        }


{-| Finish creating a codec for a register that needs a seed.
-}
finishSeededRegister : PartialRegister errs s full full -> WrappedSeededCodec errs s (Reg full)
finishSeededRegister ((PartialRegister allFieldsCodec) as partialRegister) =
    let
        encodeAsJsonObject (Register regDetails) =
            let
                fullRecord =
                    regDetails.latest

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

                        regPointer =
                            Object.getPointer object

                        history =
                            buildRegisterFieldDictionary object

                        regToRecordByDecoding givenCutoff =
                            allFieldsCodec.nodeDecoder { node = node, regPointer = regPointer, cutoff = givenCutoff, history = history }
                                -- TODO currently ignoring errors
                                |> Tuple.first

                        wrongCutoffRegToRecordByDecoding =
                            allFieldsCodec.nodeDecoder { node = node, regPointer = regPointer, cutoff = Nothing, history = history }
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
                            JD.succeed <| Ok <| Register { pointer = regPointer, included = Object.All, latest = regToRecord regCanBeBuilt Nothing, older = Just >> regToRecord regCanBeBuilt, history = history, init = nonChanger }

                        Nothing ->
                            JD.succeed <| Err WrongCutoff
            in
            JD.andThen registerDecoder concurrentObjectIDsDecoder

        nodeEncoder : NodeEncoder (Reg full) SoloObject
        nodeEncoder inputs =
            registerNodeEncoder partialRegister inputs

        emptyRegister { parent, position, seed } =
            let
                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], parent = parent, reducer = registerReducerID, position = position }

                regPointer =
                    Object.getPointer object

                history =
                    buildRegisterFieldDictionary object

                regToRecord =
                    allFieldsCodec.nodeInitializer (Tuple.first seed) regPointer
            in
            Register { pointer = regPointer, included = Object.All, latest = regToRecord, older = \_ -> regToRecord, history = history, init = Tuple.second seed }

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
        { nodeEncoder = nodeEncoder
        , nodeDecoder = nodeDecoder
        , bytesEncoder = \(Register regDetails) -> (allFieldsCodec.bytesEncoder >> List.reverse >> BE.sequence) regDetails.latest
        , bytesDecoder = bytesDecoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = jsonDecoder
        , nodePlaceholder = emptyRegister
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
                    Log.logSeparate ("WARNING addFieldEntry on op " ++ OpID.toString eventID ++ ": " ++ problem) (Object.eventPayload event) buildingDict

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


encodeFieldPayloadAsObjectPayload : FieldIdentifier -> Change.ComplexPayload -> Change.ComplexPayload
encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) fieldPayload =
    Nonempty.append
        (Nonempty (Change.FromPrimitiveAtom (Change.IntegerAtom fieldSlot)) [ Change.FromPrimitiveAtom (Change.NakedStringAtom fieldName) ])
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


buildRW : Change.Pointer -> FieldIdentifier -> (fieldVal -> EncoderOutput o) -> fieldVal -> RW fieldVal
buildRW targetObject ( fieldSlot, fieldName ) nestedRonEncoder latestValue =
    let
        nestedChange newValue =
            encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName )
                (nestedRonEncoder newValue).complex

        setter setValue =
            Change.changeObject
                { target = targetObject
                , objectChanges = [ Change.NewPayload (nestedChange setValue) ]
                }
                |> .changeSet
    in
    { get = latestValue
    , set = \setValue -> Change.WithFrameIndex (\_ -> setter setValue)
    }


buildRWH : Change.Pointer -> FieldIdentifier -> (fieldVal -> EncoderOutput o) -> fieldVal -> List ( OpID, fieldVal ) -> RWH fieldVal
buildRWH targetObject ( fieldSlot, fieldName ) nestedRonEncoder latestValue rest =
    let
        nestedChange newValue =
            encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName )
                (nestedRonEncoder newValue).complex

        setter setValue =
            Change.changeObject
                { target = targetObject
                , objectChanges = [ Change.NewPayload (nestedChange setValue) ]
                }
                |> .changeSet
    in
    { get = latestValue
    , set = \setValue -> Change.WithFrameIndex (\_ -> setter setValue)
    , history = rest
    }


interceptPlaceholderLocation : Pointer -> Pointer -> Pointer
interceptPlaceholderLocation givenObjectPointer freshPointerFromEncoder =
    case ( givenObjectPointer, freshPointerFromEncoder ) of
        ( Change.PlaceholderPointer oldPendingID _, Change.PlaceholderPointer freshPendingID _ ) ->
            if oldPendingID == freshPendingID then
                -- no difference, leave it alone
                givenObjectPointer

            else
                Debug.log ("old pointer was " ++ Change.pendingIDToString oldPendingID ++ " and new pointer is " ++ Change.pendingIDToString freshPendingID) freshPointerFromEncoder

        ( _, _ ) ->
            -- existing objects don't need to be intercepted,
            -- and the fresh pointer given should always be a placeholder
            givenObjectPointer


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
registerNodeEncoder : PartialRegister errs i full full -> NodeEncoderInputs (Reg full) -> EncoderOutput SoloObject
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

        subChanges : List Change.ObjectChange
        subChanges =
            let
                runSubEncoder : (RegisterFieldEncoderInputs full -> RegisterFieldEncoderOutput) -> Maybe Change.ObjectChange
                runSubEncoder subEncoderFunction =
                    subEncoderFunction
                        { node = node
                        , history = history
                        , mode = mode
                        , regPointer = registerPointer
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
                -- TODO so we set them in slot-increasing order.
                |> List.reverse

        -- { earlier, mine, later } =
        --     -- TODO optimizes op order, but should be unnecessary.
        --     -- mine currently broken as it leaves a pending ref
        --     Change.extractOwnSubChanges registerPointer initChanges
        allObjectChanges =
            subChanges

        -- outputWithoutEarlyChanges =
        --     Change.changeObjectWithExternal
        --         { target = registerPointer
        --         , objectChanges = allObjectChanges
        --         , externalUpdates = later
        --         }
        -- outputWithEarlyChanges =
        --     { outputWithoutEarlyChanges | changeSet = Change.mergeChanges outputWithoutEarlyChanges.changeSet (Log.logMessageOnly (Change.changeSetDebug 0 earlier) earlier) }
    in
    soloOut <|
        Change.changeObjectWithExternal
            { target = registerPointer
            , objectChanges = allObjectChanges
            , externalUpdates = Change.collapseChangesToChangeSet "registerInit" initChanges
            }


{-| Encodes a naked record
-}
recordNodeEncoder : PartialRegister errs i full full -> NodeEncoderInputs full -> EncoderOutput SoloObject
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

        registerPointer =
            Object.getPointer object

        subChanges : List Change.ObjectChange
        subChanges =
            let
                runSubEncoder : (RegisterFieldEncoderInputs full -> RegisterFieldEncoderOutput) -> Maybe Change.ObjectChange
                runSubEncoder subEncoderFunction =
                    subEncoderFunction
                        { node = node
                        , history = buildRegisterFieldDictionary object
                        , mode = mode
                        , regPointer = registerPointer
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
                |> List.reverse

        -- TODO so we set them in slot-increasing order.
    in
    soloOut
        (Change.changeObject
            { target = registerPointer
            , objectChanges = subChanges
            }
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
newRegisterFieldEncoderEntry : Int -> FieldIdentifier -> FieldFallback parentSeed fieldSeed fieldType -> Codec e fieldSeed o fieldType -> (RegisterFieldEncoderInputs fieldType -> RegisterFieldEncoderOutput)
newRegisterFieldEncoderEntry index ( fieldSlot, fieldName ) fieldFallback fieldCodec { mode, node, regPointer, history, existingValMaybe } =
    let
        regAsParent =
            Change.becomeDelayedParent regPointer (updateRegisterPostChildInit regPointer ( fieldSlot, fieldName ))

        runFieldNodeEncoder valueToEncode =
            getNodeEncoder fieldCodec
                { mode = mode
                , node = node
                , thingToEncode = valueToEncode
                , parent = regAsParent
                , position = Location.new (fieldLocationLabel fieldName fieldSlot) index
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
                            , position = Location.new (fieldLocationLabel fieldName fieldSlot) index
                            , parent = regAsParent
                            , cutoff = Nothing
                            }
                        )
                        (Op.payloadToJsonValue payload)
            in
            case run of
                Ok (Ok fieldValue) ->
                    Just fieldValue

                problem ->
                    Log.crashInDev ("fieldDecodedMaybe: Failed to decode from register memory, got " ++ Log.dump problem) Nothing

        explicitDefaultIfNeeded val =
            if mode.setDefaultsExplicitly then
                -- we were asked to encode all defaults
                EncodeThisField <| Change.NewPayload <| encodedDefaultAsPayload val

            else
                case encodeDefaultVal val of
                    (Nonempty (Change.QuoteNestedObject { skippable }) []) as encodedVal ->
                        -- payload must be a single nested object with no other atoms
                        if skippable then
                            -- field encoder said we can skip this one
                            -- EncodeThisField <|
                            --     Change.NewPayload <|
                            --         wrappedOutput val
                            SkipThisField

                        else
                            EncodeThisField <|
                                Change.NewPayload <|
                                    encodedDefaultAsPayload val

                    _ ->
                        if isExistingSameAsDefault then
                            -- it's equivalent to default
                            SkipThisField

                        else
                            -- Nested objects are never equal to default, respect their necessity
                            EncodeThisField <| Change.NewPayload <| encodedDefaultAsPayload val

        isExistingSameAsDefault =
            case ( fieldDefaultMaybe fieldFallback, Maybe.andThen fieldDecodedMaybe getPayloadIfSet ) of
                ( Just fieldDefault, Just existingValue ) ->
                    -- is the calculated default the same as the existing/placeholder value?
                    fieldDefault == existingValue

                ( Just _, Nothing ) ->
                    -- no existing val in memory, so equal to default unless it's seeded
                    True

                ( Nothing, Nothing ) ->
                    case fieldFallback of
                        PlaceholderDefault _ ->
                            -- we can figure out how to init this
                            True

                        _ ->
                            -- guess it must require a seed
                            False

                _ ->
                    -- if there's no default, and not placeholder, it can't be equal. (seeded)
                    False

        encodeDefaultVal : fieldType -> Change.ComplexPayload
        encodeDefaultVal defaultVal =
            -- EncodeThis because this only gets used on default value
            (runFieldNodeEncoder (EncodeThis defaultVal)).complex

        encodedDefaultAsPayload : fieldType -> Change.ComplexPayload
        encodedDefaultAsPayload val =
            encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) (encodeDefaultVal val)
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
                    -- EncodeThisField <| Change.NewPayload <| encodeVal foundPreviousValue
                    Debug.todo "what to do here?"

        Nothing ->
            -- we have no default to fall back to, this is for SEEDED nested objects only
            case getPayloadIfSet of
                Nothing ->
                    -- no default, no seed, no pre-existing object.. can't encode defaults even if we wanted to. Should only occur with seeded naked records
                    SkipThisField

                Just latestPayload ->
                    -- it was set before, can we decode it?
                    case fieldDecodedMaybe latestPayload of
                        Nothing ->
                            -- -- give up! spit back out what we already had in the register.
                            -- EncodeThisField <| Change.NewPayload <| Nonempty.map Change.FromPrimitiveAtom latestPayload
                            Log.logSeparate "WARNING newRegisterFieldEncoderEntry: failed to decode latest payload from reg, can't encode it." latestPayload SkipThisField

                        Just fieldValue ->
                            -- object acquired! make sure we don't miss the opportunity to pass objectID info to naked subcodecs
                            case extractQuotedObjects (Nonempty.toList latestPayload) of
                                [] ->
                                    -- -- give up! spit back out what we already had in the register.
                                    -- EncodeThisField <| Change.NewPayload <| Nonempty.map Change.FromPrimitiveAtom latestPayload
                                    Log.logSeparate "WARNING newRegisterFieldEncoderEntry: failed to extract ObjectIDs from latest payload from reg, can't encode it." latestPayload SkipThisField

                                firstFoundObjectID :: moreFoundObjectIDs ->
                                    let
                                        runNestedEncoder =
                                            EncodeObjectOrThis (Nonempty firstFoundObjectID moreFoundObjectIDs) fieldValue
                                                |> runFieldNodeEncoder
                                    in
                                    -- encode not only this field (set to this object), but also grab any encoder output from that object
                                    EncodeThisField <| Change.NewPayload runNestedEncoder.complex


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
map : (a -> b) -> (b -> a) -> Codec e a o a -> Codec e b o b
map fromAtoB fromBtoA codec =
    let
        fromResultData value =
            case value of
                Ok ok ->
                    fromAtoB ok |> Ok

                Err err ->
                    Err err

        wrappedNodeDecoder : NodeDecoderInputs -> JD.Decoder (Result (Error e) b)
        wrappedNodeDecoder inputs =
            getNodeDecoder codec inputs |> JD.map fromResultData

        wrappedInitializer : PlaceholderInputs b -> b
        wrappedInitializer inputs =
            getInitializer codec (PlaceholderInputs inputs.parent inputs.position (fromBtoA inputs.seed))
                |> fromAtoB

        mapNodeEncoderInputs : NodeEncoderInputs b -> NodeEncoderInputs a
        mapNodeEncoderInputs inputs =
            NodeEncoderInputs inputs.node inputs.mode (mapThingToEncode inputs.thingToEncode) inputs.parent inputs.position

        mapThingToEncode : ThingToEncode b -> ThingToEncode a
        mapThingToEncode original =
            case original of
                EncodeThis a ->
                    EncodeThis (fromBtoA a)

                EncodeObjectOrThis objectIDs fieldVal ->
                    EncodeObjectOrThis objectIDs (fromBtoA fieldVal)
    in
    Codec
        { bytesEncoder = \v -> fromBtoA v |> getBytesEncoder codec
        , bytesDecoder = getBytesDecoder codec |> BD.map fromResultData
        , jsonEncoder = \v -> fromBtoA v |> getJsonEncoder codec
        , jsonDecoder = getJsonDecoder codec |> JD.map fromResultData
        , nodeEncoder = \inputs -> mapNodeEncoderInputs inputs |> getNodeEncoder codec
        , nodeDecoder = wrappedNodeDecoder
        , nodePlaceholder = wrappedInitializer
        }


{-| Make a record Codec an opaque type by wrapping it with an opaque type constructor. Seed does not change type.
-}
makeOpaque : (a -> b) -> (b -> a) -> Codec e i o a -> Codec e i o b
makeOpaque fromAtoB fromBtoA codec =
    -- TODO reduce duplicate code
    let
        fromResultData value =
            case value of
                Ok ok ->
                    fromAtoB ok |> Ok

                Err err ->
                    Err err

        wrappedNodeDecoder : NodeDecoderInputs -> JD.Decoder (Result (Error e) b)
        wrappedNodeDecoder inputs =
            getNodeDecoder codec inputs |> JD.map fromResultData

        wrappedInitializer : PlaceholderInputs i -> b
        wrappedInitializer inputs =
            getInitializer codec (PlaceholderInputs inputs.parent inputs.position inputs.seed)
                |> fromAtoB

        mapNodeEncoderInputs : NodeEncoderInputs b -> NodeEncoderInputs a
        mapNodeEncoderInputs inputs =
            NodeEncoderInputs inputs.node inputs.mode (mapThingToEncode inputs.thingToEncode) inputs.parent inputs.position

        mapThingToEncode : ThingToEncode b -> ThingToEncode a
        mapThingToEncode original =
            case original of
                EncodeThis a ->
                    EncodeThis (fromBtoA a)

                EncodeObjectOrThis objectIDs fieldVal ->
                    EncodeObjectOrThis objectIDs (fromBtoA fieldVal)
    in
    Codec
        { bytesEncoder = \v -> fromBtoA v |> getBytesEncoder codec
        , bytesDecoder = getBytesDecoder codec |> BD.map fromResultData
        , jsonEncoder = \v -> fromBtoA v |> getJsonEncoder codec
        , jsonDecoder = getJsonDecoder codec |> JD.map fromResultData
        , nodeEncoder = \inputs -> mapNodeEncoderInputs inputs |> getNodeEncoder codec
        , nodeDecoder = wrappedNodeDecoder
        , nodePlaceholder = wrappedInitializer
        }



-- mapHelper : (Result (Error e) a -> Result (Error e) b) -> (b -> a) -> Codec e a o a -> Codec e b o b
-- mapHelper fromResultAtoResultB fromBtoA codec =
--     let
--         wrappedNodeDecoder : NodeDecoderInputs -> JD.Decoder (Result (Error e) b)
--         wrappedNodeDecoder inputs =
--             getNodeDecoder codec inputs |> JD.map fromResultAtoResultB
--         wrappedInitializer : InitializerInputs b -> b
--         wrappedInitializer inputs =
--             getInitializer codec (InitializerInputs inputs.parent inputs.position (fromBtoA inputs.seed))
--             |> fromAtoB
--         mapNodeEncoderInputs : NodeEncoderInputs b -> NodeEncoderInputs a
--         mapNodeEncoderInputs inputs =
--             NodeEncoderInputs inputs.node inputs.mode (mapThingToEncode inputs.thingToEncode) inputs.parent inputs.position
--         mapThingToEncode : ThingToEncode b -> ThingToEncode a
--         mapThingToEncode original =
--             case original of
--                 EncodeThis a ->
--                     EncodeThis (fromBtoA a)
--                 EncodeObjectOrThis objectIDs fieldVal ->
--                     EncodeObjectOrThis objectIDs (fromBtoA fieldVal)
--     in
--     Codec
--     { bytesEncoder = \v -> fromBtoA v |> getBytesEncoder codec
--     , bytesDecoder = getBytesDecoder codec |> BD.map fromResultAtoResultB
--     , jsonEncoder = \v -> fromBtoA v |> getJsonEncoder codec
--     , jsonDecoder = getJsonDecoder codec |> JD.map fromResultAtoResultB
--     , nodeEncoder = \inputs -> mapNodeEncoderInputs inputs |> getNodeEncoder codec
--     , nodeDecoder = wrappedNodeDecoder
--     , init = wrappedInitializer
--     }


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
mapValid : (a -> Result e b) -> (b -> a) -> SelfSeededCodec e o a -> SelfSeededCodec e o b
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
    Codec
        { bytesEncoder = \v -> toBytes_ v |> getBytesEncoder codec
        , bytesDecoder =
            getBytesDecoder codec
                |> BD.map wrapCustomError
        , jsonEncoder = \v -> toBytes_ v |> getJsonEncoder codec
        , jsonDecoder =
            getJsonDecoder codec
                |> JD.map wrapCustomError
        , nodeEncoder = \inputs -> mapNodeEncoderInputs inputs |> getNodeEncoder codec
        , nodeDecoder = wrappedNodeDecoder
        , nodePlaceholder = flatInit -- required, cant't have initializer returning an error
        }


{-| Map errors generated by `mapValid`.
-}
mapError : (e1 -> e2) -> PrimitiveCodec e1 a -> PrimitiveCodec e2 a
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
        (getNodeEncoder codec)
        wrappedNodeDecoder


mapErrorHelper : (e -> a) -> Result (Error e) b -> Result (Error a) b
mapErrorHelper mapFunc =
    Result.mapError
        (\error ->
            case error of
                CustomError custom ->
                    mapFunc custom |> CustomError

                SerializerOutOfDate ->
                    SerializerOutOfDate

                ObjectNotFound opID ->
                    ObjectNotFound opID

                JDError jsonDecodeError ->
                    JDError jsonDecodeError

                FailedToDecodeRegField fieldSlot fieldName value jdError ->
                    FailedToDecodeRegField fieldSlot fieldName value jdError

                NoMatchingVariant tag ->
                    NoMatchingVariant tag

                BinaryDataCorrupted ->
                    BinaryDataCorrupted

                BadVersionNumber num ->
                    BadVersionNumber num

                MissingRequiredField fieldSlot fieldName ->
                    MissingRequiredField fieldSlot fieldName

                BadBoolean givenData ->
                    BadBoolean givenData

                BadChar givenData ->
                    BadChar givenData

                EmptyList ->
                    EmptyList

                BadByteString badData ->
                    BadByteString badData

                BadIndex badData ->
                    BadIndex badData

                WrongCutoff ->
                    WrongCutoff
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
lazy : (() -> Codec e s o a) -> Codec e s o a
lazy f =
    let
        lazyNodeDecoder : NodeDecoderInputs -> JD.Decoder (Result (Error e) a)
        lazyNodeDecoder inputs =
            JD.succeed () |> JD.andThen (\() -> getNodeDecoder (f ()) inputs)

        lazyNodeEncoder : NodeEncoder a o
        lazyNodeEncoder inputs =
            getNodeEncoder (f ()) inputs
    in
    Codec
        { bytesEncoder = \value -> getBytesEncoder (f ()) value
        , bytesDecoder = BD.succeed () |> BD.andThen (\() -> getBytesDecoder (f ()))
        , jsonEncoder = \value -> getJsonEncoder (f ()) value
        , jsonDecoder = JD.succeed () |> JD.andThen (\() -> getJsonDecoder (f ()))
        , nodeEncoder = lazyNodeEncoder
        , nodeDecoder = lazyNodeDecoder
        , nodePlaceholder = \inputs -> getInitializer (f ()) inputs
        }


{-| When you haven't gotten to writing a Codec for this yet.
-}
todo : a -> PrimitiveCodec e a
todo bogusValue =
    Codec
        { bytesEncoder = \_ -> BE.unsignedInt8 9
        , bytesDecoder = BD.fail
        , jsonEncoder = \_ -> JE.null
        , jsonDecoder = JD.fail "TODO"
        , nodeEncoder = \_ -> singlePrimitiveOut <| Change.StringAtom "TODO"
        , nodeDecoder = \_ -> JD.fail "TODO"
        , nodePlaceholder = \_ -> bogusValue
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
    NodeEncoderInputsNoVariable -> Change.ComplexPayload


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
                        { inputs
                          -- | parent =
                          --     Change.becomeInstantParent <|
                          --         Change.newPointer
                          --             { parent = inputs.parent, position = Location.nest inputs.position (tagName ++ "(" ++ String.fromInt tagNum ++ ")") index, reducerID = "variant" }
                            | position =
                                Location.nest inputs.position (tagName ++ "(" ++ String.fromInt tagNum ++ ")") index
                        }
            in
            VariantEncoder
                { bytes = BE.sequence []
                , json = JE.null
                , node = \inputs -> Nonempty.singleton (Change.NestedAtoms (Nonempty nodeTag (piecesApplied inputs)))
                }

        nodeTag =
            Change.FromPrimitiveAtom <| Change.NakedStringAtom <| tagName ++ "_" ++ String.fromInt tagNum

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
    { inputsND
        | parent = Change.becomeInstantParent <| Change.newPointer { parent = inputsND.parent, position = Location.nest inputsND.position "piece" pieceNum, reducerID = "variant" }
        , position = Location.nest inputsND.position "piece" pieceNum
    }


{-| Define a variantBuilder with 1 parameters for a custom type.
-}
variant1 :
    VariantTag
    -> (a -> v)
    -> Codec error ia oa a
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
                [ getNodeEncoderModifiedForVariants 1 codec1 v
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
    -> Codec error ia oa a
    -> Codec error ib ob b
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
                [ getNodeEncoderModifiedForVariants 1 codec1 v1
                , getNodeEncoderModifiedForVariants 2 codec2 v2
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
    -> Codec error ia oa a
    -> Codec error ib ob b
    -> Codec error ic oc c
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
                [ getNodeEncoderModifiedForVariants 1 codec1 v1
                , getNodeEncoderModifiedForVariants 2 codec2 v2
                , getNodeEncoderModifiedForVariants 3 codec3 v3
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
    -> Codec error ia oa a
    -> Codec error ib ob b
    -> Codec error ic oc c
    -> Codec error id od d
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
                [ getNodeEncoderModifiedForVariants 1 codec1 v1
                , getNodeEncoderModifiedForVariants 2 codec2 v2
                , getNodeEncoderModifiedForVariants 3 codec3 v3
                , getNodeEncoderModifiedForVariants 4 codec4 v4
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
    -> Codec error ia oa a
    -> Codec error ib ob b
    -> Codec error ic oc c
    -> Codec error id od d
    -> Codec error ie oe e
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
                [ getNodeEncoderModifiedForVariants 1 codec1 v1
                , getNodeEncoderModifiedForVariants 2 codec2 v2
                , getNodeEncoderModifiedForVariants 3 codec3 v3
                , getNodeEncoderModifiedForVariants 4 codec4 v4
                , getNodeEncoderModifiedForVariants 5 codec5 v5
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
    -> Codec error ia oa a
    -> Codec error ib ob b
    -> Codec error ic oc c
    -> Codec error id od d
    -> Codec error ie oe e
    -> Codec error if_ of_ f
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
                [ getNodeEncoderModifiedForVariants 1 codec1 v1
                , getNodeEncoderModifiedForVariants 2 codec2 v2
                , getNodeEncoderModifiedForVariants 3 codec3 v3
                , getNodeEncoderModifiedForVariants 4 codec4 v4
                , getNodeEncoderModifiedForVariants 5 codec5 v5
                , getNodeEncoderModifiedForVariants 6 codec6 v6
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
    -> Codec error ia oa a
    -> Codec error ib ob b
    -> Codec error ic oc c
    -> Codec error id od d
    -> Codec error ie oe e
    -> Codec error if_ of_ f
    -> Codec error ig og g
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
                [ getNodeEncoderModifiedForVariants 1 codec1 v1
                , getNodeEncoderModifiedForVariants 2 codec2 v2
                , getNodeEncoderModifiedForVariants 3 codec3 v3
                , getNodeEncoderModifiedForVariants 4 codec4 v4
                , getNodeEncoderModifiedForVariants 5 codec5 v5
                , getNodeEncoderModifiedForVariants 6 codec6 v6
                , getNodeEncoderModifiedForVariants 7 codec7 v7
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
    -> Codec error ia oa a
    -> Codec error ib ob b
    -> Codec error ic oc c
    -> Codec error id od d
    -> Codec error ie oe e
    -> Codec error if_ of_ f
    -> Codec error ig og g
    -> Codec error ih o h
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
                [ getNodeEncoderModifiedForVariants 1 codec1 v1
                , getNodeEncoderModifiedForVariants 2 codec2 v2
                , getNodeEncoderModifiedForVariants 3 codec3 v3
                , getNodeEncoderModifiedForVariants 4 codec4 v4
                , getNodeEncoderModifiedForVariants 5 codec5 v5
                , getNodeEncoderModifiedForVariants 6 codec6 v6
                , getNodeEncoderModifiedForVariants 7 codec7 v7
                , getNodeEncoderModifiedForVariants 8 codec8 v8
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
finishCustomType : CustomTypeCodec () e (a -> VariantEncoder) a -> NullCodec e a
finishCustomType (CustomTypeCodec priorVariants) =
    let
        nodeEncoder : NodeEncoder a {}
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
            { complex = getNodeVariantEncoder nodeMatcher }

        nodeDecoder : NodeDecoder e a
        nodeDecoder inputs =
            let
                getTagNum tag =
                    String.split "_" tag
                        |> List.Extra.last
                        |> Maybe.andThen String.toInt
                        |> Maybe.Extra.withDefaultLazy failedToGetTagNum

                failedToGetTagNum _ =
                    Log.crashInDev "could not find tag num! defaulting to -1" -1

                checkTag tag =
                    priorVariants.nodeDecoder (getTagNum tag) (\_ -> JD.succeed (Err (NoMatchingVariant tag))) inputs
            in
            JD.oneOf
                [ JD.index 0 JD.string |> JD.andThen checkTag

                -- allow non-array input for variant0s:
                -- , JD.string |> JD.andThen checkTag
                ]
    in
    Codec
        { bytesEncoder = priorVariants.bytesMatcher >> (\(VariantEncoder encoders) -> encoders.bytes)
        , bytesDecoder =
            BD.unsignedInt16 endian
                |> BD.andThen
                    (\tag ->
                        priorVariants.bytesDecoder tag (BD.succeed (Err (NoMatchingVariant (String.fromInt tag))))
                    )
        , jsonEncoder = priorVariants.jsonMatcher >> (\(VariantEncoder encoders) -> encoders.json)
        , jsonDecoder =
            JD.index 0 JD.int
                |> JD.andThen
                    (\tag ->
                        priorVariants.jsonDecoder tag (JD.succeed (Err (NoMatchingVariant (String.fromInt tag))))
                    )
        , nodeEncoder = nodeEncoder
        , nodeDecoder = nodeDecoder
        , nodePlaceholder = \inputs -> inputs.seed -- hmm, we could process the init as well, giving proper locations to the Codec.new instances... would that matter?
        }


{-| Specifically for variant encoders, we must
a) strip out the type variable from NodeEncoderInputs
b) return a normal list of change atoms so we can use normal list functions to build up the variant encoder's output.

Hence, inputs are modified to NodeEncoderInputsNoVariable and outputs are just List Change.Atom.
The input type variable is taken care of early on, and the output type is converted to NodeENcoderOutput in the last mile.

-}
getNodeEncoderModifiedForVariants : Int -> Codec e ia o a -> a -> VariantNodeEncoder
getNodeEncoderModifiedForVariants index codec thingToEncode =
    let
        finishInputs : NodeEncoderInputsNoVariable -> NodeEncoderInputs a
        finishInputs modifiedEncoder =
            { node = modifiedEncoder.node
            , mode = modifiedEncoder.mode
            , thingToEncode = EncodeThis thingToEncode
            , position = Location.nest modifiedEncoder.position "piece" index
            , parent = modifiedEncoder.parent
            }
    in
    \altInputs -> (getNodeEncoder codec (finishInputs altInputs)).complex
