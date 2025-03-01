module Replicated.Codec.RegisterField.Encoder exposing (Output, RegisterFieldEncoder)

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
import Replicated.Codec.Json.Decoder as JsonDecoder exposing (WrappedJsonDecoder)
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


type alias RegisterFieldEncoder full =
    Inputs full -> Output


{-| Inputs to a node Field encoder.

No "position" because it's already in the parent, and field index can be determined by record counter
No "parent", just pointer, because the parent is constructed in the individual field encoder.

-}
type alias Inputs field =
    { node : Node
    , mode : NodeEncoder.ChangesToGenerate
    , history : FieldHistoryDict
    , regPointer : Pointer
    , existingValMaybe : Maybe field
    }


{-| Whether we will be encoding this field, or skipping it. specific to registers. Used to do this for all encoder output, but it made everything harder.
-}
type Output
    = EncodeThisField Change.ObjectChange
    | SkipThisField
