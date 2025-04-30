module Replicated.Codec.Node.Encoder exposing (ChangesToGenerate, Inputs, InputsNoVariable, NodeEncoder, Output, Primitive, PrimitiveOutput, SoloObject, SoloObjectOutput, ThingToEncode(..), defaultMode, justInit, map, singlePrimitiveOut, soloOut)

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
import Replicated.Codec.Error as Error exposing (RepDecodeError(..))
import Replicated.Codec.Json.Decoder as JsonDecoder exposing (JsonDecoder)
import Replicated.Codec.Node.Decoder as NodeDecoder exposing (NodeDecoder, NodeDecoderInputs)
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


{-| All node encoders produce a complex payload.
-}
type alias Output o =
    { o | complex : Change.ComplexPayload }


{-| Extra constraint for Primitive node encoders.
-}
type alias Primitive =
    { primitive : Change.PrimitivePayload }


{-| Primitive node encoders also produce a primitive payload.
-}
type alias PrimitiveOutput =
    Output { primitive : Change.PrimitivePayload }


{-| Extra constraint for solo object encoders.
-}
type alias SoloObject =
    { nested : Change.SoloObjectEncoded }


{-| Nested object encoders also produce a solo object to reference.
-}
type alias SoloObjectOutput =
    Output { nested : Change.SoloObjectEncoded }


type alias Inputs a =
    { node : Node
    , mode : ChangesToGenerate
    , thingToEncode : ThingToEncode a
    , parent : Parent
    , position : Location
    }


type ThingToEncode fieldType
    = EncodeThis fieldType
    | EncodeObjectOrThis (Nonempty ObjectID) fieldType -- so that naked registers have something to fall back on


type alias InputsNoVariable =
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


defaultMode : ChangesToGenerate
defaultMode =
    { initializeUnusedObjects = False, setDefaultsExplicitly = False, generateSnapshot = False, cloneOldOps = False }


type alias NodeEncoder a o =
    Inputs a -> Output o



-- MAPPING ------------------------------


map : (b -> a) -> NodeEncoder a o -> NodeEncoder b o
map fromBtoA encoderA =
    let
        mapNodeEncoderInputs : Inputs b -> Inputs a
        mapNodeEncoderInputs inputs =
            Inputs inputs.node inputs.mode (mapThingToEncode inputs.thingToEncode) inputs.parent inputs.position

        mapThingToEncode : ThingToEncode b -> ThingToEncode a
        mapThingToEncode original =
            case original of
                EncodeThis a ->
                    EncodeThis (fromBtoA a)

                EncodeObjectOrThis objectIDs fieldVal ->
                    EncodeObjectOrThis objectIDs (fromBtoA fieldVal)
    in
    \inputs -> encoderA (mapNodeEncoderInputs inputs)



-- NODE ENCODE OUTPUT HELPERS --------------------------------------


justInit : Pointer -> SoloObjectOutput
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


soloOut : Change.SoloObjectEncoded -> SoloObjectOutput
soloOut soloObject =
    { nested = soloObject
    , complex = Change.complexFromSolo soloObject
    }


singlePrimitiveOut : Change.PrimitiveAtom -> PrimitiveOutput
singlePrimitiveOut singlePrimitiveAtom =
    { primitive = Nonempty.singleton singlePrimitiveAtom
    , complex = Nonempty.singleton <| Change.FromPrimitiveAtom singlePrimitiveAtom
    }
