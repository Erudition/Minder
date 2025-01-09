module Replicated.Codec.NodeDecoder exposing (NodeDecoder, NodeDecoderInputs, NodeDecoderInputsNoVariable, primitive)

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
import Replicated.Codec.Error exposing (RepDecodeError(..))
import Replicated.Codec.JsonDecoder as JsonDecoder exposing (JsonDecoder)
import Replicated.Codec.RonPayloadDecoder as RonPayloadDecoder exposing (RonPayloadDecoder)
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


type NodeDecoder a
    = NodeDecoder (NodeDecoderInputs a -> RonPayloadDecoder a)


type alias NodeDecoderInputs t =
    { node : Node
    , parent : Parent
    , position : Location
    , cutoff : Maybe Moment
    , oldMaybe : Maybe t
    }


type alias NodeDecoderInputsNoVariable =
    { node : Node
    , parent : Parent
    , position : Location
    , cutoff : Maybe Moment
    }


primitive : RonPayloadDecoder a -> NodeDecoder a
primitive ronDecoder =
    NodeDecoder (\_ -> ronDecoder)
