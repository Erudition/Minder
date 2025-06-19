module Replicated.Codec.Node.Decoder exposing (Inputs, NodeDecoder, NodeDecoderInputsNoVariable, Output, concurrentObjectIDsDecoder, lazy, map, mapTry, primitive, reuseOldIfUnchanged)

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
import Replicated.Codec.Error as Error exposing (RepDecodeError(..))
import Replicated.Codec.Json.Decoder as JsonDecoder exposing (JsonDecoder)
import Replicated.Codec.RonPayloadDecoder as RonPayloadDecoder exposing (RonPayloadDecoder)
import Replicated.Node.AncestorDb as AncestorDb exposing (AncestorDb)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.ObjectGroup as ObjectGroup exposing (ObjectGroup)
import Replicated.Op.ID as OpID exposing (InCounter, ObjectID, OpID, OpIDSortable, OutCounter)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Reducer.Register as Reg exposing (..)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict, RepDictEntry(..))
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Replicated.Reducer.RepStore as RepStore exposing (RepStore)
import Set exposing (Set)
import SmartTime.Moment as Moment exposing (Moment)
import Toop exposing (T4(..), T5(..), T6(..), T7(..), T8(..))


type alias NodeDecoder a =
    Inputs a -> Output a


type alias Inputs t =
    { node : Node
    , parent : Parent
    , position : Location
    , cutoff : Maybe Moment
    , oldMaybe : Maybe t
    , changedObjectIDs : List ObjectID
    }


type alias Output t =
    { decoder : RonPayloadDecoder t
    , ancestors : AncestorDb
    }


type alias NodeDecoderInputsNoVariable =
    { node : Node
    , parent : Parent
    , position : Location
    , cutoff : Maybe Moment
    }


primitive : RonPayloadDecoder a -> NodeDecoder a
primitive ronDecoder =
    \_ ->
        { decoder = ronDecoder
        , ancestors = AncestorDb.empty
        }



-- HELPERS


{-| Allows reptypes to lazily skip their decoders if their objectIDs were not listed as changed. Pass the Maybe reptype and the reptype's pointer getter.
-}
reuseOldIfUnchanged : Maybe a -> (a -> Pointer) -> List ObjectID -> JD.Decoder (Result RepDecodeError a) -> JD.Decoder (Result RepDecodeError a)
reuseOldIfUnchanged oldMaybe getPointer changedObjectIDList fallbackDecoder =
    case ( oldMaybe, changedObjectIDList ) of
        ( Just old, [ _ ] ) ->
            case getPointer old of
                ExistingObjectPointer { operationID } ->
                    -- an old copy of the reptype exists and we have its objectID, we can check if it's unchanged.
                    if List.member operationID changedObjectIDList then
                        JD.succeed (Ok old)

                    else
                        fallbackDecoder

                _ ->
                    fallbackDecoder

        _ ->
            fallbackDecoder


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


map : (a -> b) -> (b -> a) -> NodeDecoder a -> NodeDecoder b
map fromAtoB fromBtoA nodeDecoderA =
    let
        newDecoder : Inputs b -> Output b
        newDecoder inputsB =
            let
                runADecoderWithBInputs : Output a
                runADecoderWithBInputs =
                    nodeDecoderA
                        { node = inputsB.node
                        , parent = inputsB.parent
                        , position = inputsB.position
                        , cutoff = inputsB.cutoff
                        , oldMaybe = Maybe.map fromBtoA inputsB.oldMaybe
                        , changedObjectIDs = inputsB.changedObjectIDs
                        }
            in
            { decoder = RonPayloadDecoder.map fromAtoB runADecoderWithBInputs.decoder
            , ancestors = runADecoderWithBInputs.ancestors
            }
    in
    newDecoder


mapTry : (a -> Result Error.CustomError b) -> (b -> a) -> NodeDecoder a -> NodeDecoder b
mapTry fromAtoBResult fromBtoA nodeDecoderA =
    let
        newDecoder : Inputs b -> Output b
        newDecoder inputsB =
            let
                runADecoderWithBInputs : Output a
                runADecoderWithBInputs =
                    nodeDecoderA
                        { node = inputsB.node
                        , parent = inputsB.parent
                        , position = inputsB.position
                        , cutoff = inputsB.cutoff
                        , oldMaybe = Maybe.map fromBtoA inputsB.oldMaybe
                        , changedObjectIDs = inputsB.changedObjectIDs
                        }
            in
            { decoder = RonPayloadDecoder.mapTry fromAtoBResult runADecoderWithBInputs.decoder
            , ancestors = runADecoderWithBInputs.ancestors
            }
    in
    newDecoder


lazy : (() -> NodeDecoder a) -> NodeDecoder a
lazy unitToNodeDecoder =
    let
        runNow =
            unitToNodeDecoder ()
    in
    \input ->
        -- TODO is this lazy
        { decoder = RonPayloadDecoder.lazy (\() -> (runNow input).decoder)
        , ancestors = (runNow input).ancestors
        }
