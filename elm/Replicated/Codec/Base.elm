module Replicated.Codec.Base exposing (NullCodec, PrimitiveCodec, SelfSeededCodec, SkelCodec, WrappedCodec, WrappedOrSkelCodec, WrappedSeededCodec, buildCodec, getBytesDecoder, getBytesEncoder, getInitializer, getJsonDecoder, getJsonEncoder, getNodeDecoder, getNodeEncoder, getPrimitiveNodeEncoder, getSoloNodeEncoder, lazy, makeOpaque, map, mapError, mapValid, new, newUnique, newWithChanges, newWithSeed, newWithSeedAndChanges)

{-| Internal-only module defining the base of a Codec.
Only the aliases are exposed.
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
import Replicated.Codec.Bytes.Decoder as BytesDecoder exposing (BytesDecoder)
import Replicated.Codec.Bytes.Encoder as BytesEncoder exposing (BytesEncoder)
import Replicated.Codec.Error as Error exposing (RepDecodeError(..))
import Replicated.Codec.Initializer as Initializer exposing (Initializer)
import Replicated.Codec.Json.Decoder as JsonDecoder exposing (JsonDecoder)
import Replicated.Codec.Json.Encoder exposing (JsonEncoder)
import Replicated.Codec.Node.Decoder as NodeDecoder exposing (NodeDecoder, NodeDecoderInputs)
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



-- CODEC DEFINITIONS


{-| Internal base of all Codecs - not exposed

  - init: data needed for initialization, usually just the seed
  - constraints: record-based type for making sure codecs are used together correctly
  - thing: the type of the thing to ultimately be serialized

-}
type Codec init constraints thing
    = Codec
        { bytesEncoder : BytesEncoder thing
        , bytesDecoder : BytesDecoder thing
        , jsonEncoder : JsonEncoder thing
        , jsonDecoder : JsonDecoder thing
        , nodeEncoder : NodeEncoder thing constraints
        , nodeDecoder : NodeDecoder thing
        , nodePlaceholder : Initializer init thing
        }


{-| For types that cannot be initialized from nothing, nor from a list of changes - you need the whole value upfront. We use the value itself as the "seed".
-}
type alias SelfSeededCodec constraints thing =
    Codec thing constraints thing


{-| A self-seeded codec with no special guarantees. Used as a building block for additional type constraints.
-}
type alias NullCodec thing =
    Codec thing {} thing


{-| A self-seeded, primitive-only codec, like string or int.
-}
type alias PrimitiveCodec thing =
    Codec thing NodeEncoder.Primitive thing


{-| Codec for unwrapped objects, like naked records.
-}
type alias SkelCodec thing =
    Codec Initializer.Skel NodeEncoder.SoloObject thing


{-| Codec for wrapped objects, like replist or register, or unwrapped naked records.
-}
type alias WrappedOrSkelCodec s thing =
    Codec (s -> List Change) NodeEncoder.SoloObject thing


{-| Codec for wrapped objects, like replist or register, but not naked records.
-}
type alias WrappedCodec thing =
    Codec (Changer thing) NodeEncoder.SoloObject thing


{-| Codec for wrapped objects that need an initial seed.
-}
type alias WrappedSeededCodec seed thing =
    Codec ( seed, Changer thing ) NodeEncoder.SoloObject thing



-- GETTERS --------------------------------


{-| Extracts the encoding function contained inside the `Codec`.
-}
getBytesEncoder : Codec s o a -> BytesEncoder a
getBytesEncoder (Codec m) =
    m.bytesEncoder


{-| Extracts the replica encoding function contained inside the `Codec`.
-}
getNodeEncoder : Codec s o a -> NodeEncoder a o
getNodeEncoder (Codec m) inputs =
    m.nodeEncoder inputs


{-| Get the node encoder for solo objects.
-}
getSoloNodeEncoder : Codec s NodeEncoder.SoloObject a -> (NodeEncoder.Inputs a -> NodeEncoder.SoloObjectOutput)
getSoloNodeEncoder (Codec m) inputs =
    m.nodeEncoder inputs


{-| Extracts the replica encoding function contained inside the `Codec`.
-}
getPrimitiveNodeEncoder : Codec s NodeEncoder.Primitive a -> (a -> NodeEncoder.PrimitiveOutput)
getPrimitiveNodeEncoder (Codec m) primitiveToEncode =
    let
        bogusInputs =
            NodeEncoder.Inputs Node.testNode NodeEncoder.defaultMode (NodeEncoder.EncodeThis primitiveToEncode) (Change.genesisParent "getPrimitiveNodeEncoder - never used") Location.none
    in
    m.nodeEncoder bogusInputs


{-| Extracts the json encoding function contained inside the `Codec`.
-}
getJsonEncoder : Codec s o a -> a -> JE.Value
getJsonEncoder (Codec m) =
    m.jsonEncoder


{-| Extracts the Bytes `Decoder` contained inside the `Codec`.
-}
getBytesDecoder : Codec s o a -> BytesDecoder a
getBytesDecoder (Codec m) =
    m.bytesDecoder


{-| Extracts the JSON `Decoder` contained inside the `Codec`.
-}
getJsonDecoder : Codec s o a -> JsonDecoder a
getJsonDecoder (Codec m) =
    m.jsonDecoder


{-| Extracts the RON decoder contained inside the `Codec`.
-}
getNodeDecoder : Codec i o a -> NodeDecoder a
getNodeDecoder (Codec m) =
    m.nodeDecoder


getInitializer : Codec i o repType -> Initializer i repType
getInitializer (Codec codecDetails) inputs =
    codecDetails.nodePlaceholder
        { parent = inputs.parent
        , position = inputs.position
        , seed = inputs.seed
        }



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
map : (a -> b) -> (b -> a) -> Codec a o a -> Codec b o b
map fromAtoB fromBtoA codec =
    let
        fromResultData value =
            case value of
                Ok ok ->
                    fromAtoB ok |> Ok

                Err err ->
                    Err err

        wrappedNodeDecoder : NodeDecoderInputs b -> JD.Decoder (Result RepDecodeError b)
        wrappedNodeDecoder inputs =
            getNodeDecoder codec inputs |> JD.map fromResultData

        wrappedInitializer : InitializerInputs b -> b
        wrappedInitializer inputs =
            getInitializer codec (InitializerInputs inputs.parent inputs.position (fromBtoA inputs.seed))
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
makeOpaque : (a -> b) -> (b -> a) -> Codec i o a -> Codec i o b
makeOpaque fromAtoB fromBtoA codec =
    -- TODO reduce duplicate code
    let
        fromResultData value =
            case value of
                Ok ok ->
                    fromAtoB ok |> Ok

                Err err ->
                    Err err

        wrappedNodeDecoder : NodeDecoderInputs b -> JD.Decoder (Result RepDecodeError b)
        wrappedNodeDecoder inputs =
            getNodeDecoder codec inputs |> JD.map fromResultData

        wrappedInitializer : InitializerInputs i -> b
        wrappedInitializer inputs =
            getInitializer codec (InitializerInputs inputs.parent inputs.position inputs.seed)
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



-- mapHelper : (Result (RepDecodeError) a -> Result (RepDecodeError) b) -> (b -> a) -> Codec e a o a -> Codec e b o b
-- mapHelper fromResultAtoResultB fromBtoA codec =
--     let
--         wrappedNodeDecoder : NodeDecoderInputs -> JD.Decoder (Result (RepDecodeError) b)
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
mapValid : (a -> Result e b) -> (b -> a) -> SelfSeededCodec o a -> SelfSeededCodec o b
mapValid fromBytes_ toBytes_ codec =
    let
        wrappedNodeDecoder : NodeDecoderInputs b -> JD.Decoder (Result RepDecodeError b)
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
        , nodePlaceholder = Initializer.flatInit -- required, cant't have initializer returning an error
        }


{-| Map errors generated by `mapValid`.
-}
mapError : (e1 -> e2) -> PrimitiveCodec a -> PrimitiveCodec a
mapError mapFunc codec =
    let
        wrappedNodeDecoder : NodeDecoderInputs a -> JD.Decoder (Result RepDecodeError a)
        wrappedNodeDecoder inputs =
            getNodeDecoder codec inputs |> JD.map mapFunc
    in
    buildCodec
        (getBytesEncoder codec)
        (getBytesDecoder codec |> BD.map mapFunc)
        (getJsonEncoder codec)
        (getJsonDecoder codec |> JD.map mapFunc)
        (getNodeEncoder codec)
        wrappedNodeDecoder


lazy : (() -> Codec s o a) -> Codec s o a
lazy f =
    let
        lazyNodeDecoder : NodeDecoderInputs a -> JD.Decoder (Result RepDecodeError a)
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



-- INITIALIZERS - NEW* functions


new : Codec (s -> List Change) o repType -> Context repType -> repType
new (Codec codecDetails) context =
    codecDetails.nodePlaceholder { parent = Change.getContextParent context, position = Location.nestSingle (Change.getContextLocation context) "new", seed = \_ -> [] }


newUnique : Int -> Codec (s -> List Change) o repType -> Context repType -> repType
newUnique nth (Codec codecDetails) context =
    codecDetails.nodePlaceholder { parent = Change.getContextParent context, position = Location.nest (Change.getContextLocation context) "newN" nth, seed = \_ -> [] }


newWithChanges : WrappedCodec repType -> Context repType -> Changer repType -> repType
newWithChanges (Codec codecDetails) context changer =
    -- TODO change argument order
    codecDetails.nodePlaceholder { parent = Change.getContextParent context, position = Location.nestSingle (Change.getContextLocation context) "newChanged", seed = changer }


newWithSeed : Codec s o repType -> Context repType -> s -> repType
newWithSeed (Codec codecDetails) context seed =
    codecDetails.nodePlaceholder { parent = Change.getContextParent context, position = Location.nestSingle (Change.getContextLocation context) "sNew", seed = seed }


newWithSeedAndChanges : Codec ( s, Changer repType ) o repType -> Context repType -> s -> Changer repType -> repType
newWithSeedAndChanges (Codec codecDetails) context seed changer =
    codecDetails.nodePlaceholder { parent = Change.getContextParent context, position = Location.nestSingle (Change.getContextLocation context) "sNewWC", seed = ( seed, changer ) }
