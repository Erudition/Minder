module Replicated.Codec.DataStructures.Immutable.SyncUnsafe exposing (array, dict, list, listEncodeHelper, listStepHelper, nonempty, set)

{-| "Immutable" Data Structures are the primitive/built-in collection types that don't support changes.
This module contains codecs for the "sync unsafe" data structures, meaning the user should consider using the mutable version instead.
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
import Replicated.Codec.Base as Base exposing (Codec(..), PrimitiveCodec, SelfSeededCodec, getBytesDecoder, getBytesEncoder, getJsonDecoder, getJsonEncoder, getNodeDecoder, getNodeEncoder)
import Replicated.Codec.Bytes.Decoder as BytesDecoder exposing (BytesDecoder)
import Replicated.Codec.Bytes.Encoder as BytesEncoder exposing (BytesEncoder)
import Replicated.Codec.DataStructures.Immutable.SyncSafe as SyncSafe exposing (pair)
import Replicated.Codec.Error as Error exposing (RepDecodeError(..))
import Replicated.Codec.Initializer as Initializer exposing (Initializer)
import Replicated.Codec.Json.Decoder as JsonDecoder exposing (JsonDecoder)
import Replicated.Codec.Json.Encoder exposing (JsonEncoder)
import Replicated.Codec.Node.Decoder as NodeDecoder exposing (Inputs, NodeDecoder)
import Replicated.Codec.Node.Encoder as NodeEncoder exposing (NodeEncoder)
import Replicated.Codec.RonPayloadDecoder as RonPayloadDecoder exposing (RonPayloadDecoder(..))
import Replicated.Node.Node as Node exposing (Node)
import Replicated.ObjectGroup as Object exposing (ObjectGroup)
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


list : Codec s o a -> Codec (List a) {} (List a)
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
            case NodeEncoder.getEncodedPrimitive inputs.thingToEncode of
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
                                , thingToEncode = NodeEncoder.EncodeThis item
                                , parent = inputs.parent -- not quite.
                                , position = Location.new "primitiveListItem" index
                                }
                                |> .complex
                    in
                    { complex = Nonempty.concat <| Nonempty.indexedMap memberNodeEncoded (Nonempty headItem moreItems) }

        nodeDecoder : Inputs (List a) -> JD.Decoder (Result RepDecodeError (List a))
        nodeDecoder _ =
            JD.oneOf
                [ JD.andThen
                    (\v ->
                        -- TODO what if someone encodes a list like ["[]"]
                        if v == "[]" then
                            JD.succeed (Ok [])

                        else
                            JD.fail "Not empty, moving on to normal list decoder below"
                    )
                    JD.string
                , normalJsonDecoder
                ]
    in
    Codec
        { bytesEncoder = listEncodeHelper (getBytesEncoder codec)
        , bytesDecoder =
            BD.unsignedInt32 BytesEncoder.endian
                |> BD.andThen
                    (\length -> BD.loop ( length, [] ) (listStepHelper (getBytesDecoder codec)))
        , jsonEncoder = JE.list (getJsonEncoder codec)
        , jsonDecoder = normalJsonDecoder
        , nodeEncoder = nodeEncoder
        , nodeDecoder = nodeDecoder
        , nodePlaceholder = \{ seed } -> seed
        }


listEncodeHelper : (a -> BE.Encoder) -> List a -> BE.Encoder
listEncodeHelper encoder_ list_ =
    list_
        |> List.map encoder_
        |> (::) (BE.unsignedInt32 BytesEncoder.endian (List.length list_))
        |> BE.sequence


listStepHelper : BytesDecoder a -> ( Int, List a ) -> BD.Decoder (BD.Step ( Int, List a ) (Result RepDecodeError (List a)))
listStepHelper decoder_ ( n, xs ) =
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


nonempty : SelfSeededCodec o userType -> SelfSeededCodec {} (Nonempty userType)
nonempty wrappedCodec =
    -- We can't use mapValid with built-in errors, since it will wrap it again with CustomError.
    -- So, we must implement mapValid from scratch, on top of the list codec.
    -- TODO is this still true after removing custom error type variable
    let
        nonemptyFromList : Result RepDecodeError (List userType) -> Result RepDecodeError (Nonempty userType)
        nonemptyFromList givenListResult =
            Result.andThen (\givenList -> Result.fromMaybe EmptyList <| Nonempty.fromList givenList) givenListResult

        listCodec =
            list wrappedCodec

        mapNodeEncoderInputs : NodeEncoder.Inputs (Nonempty a) -> NodeEncoder.Inputs (List a)
        mapNodeEncoderInputs inputs =
            NodeEncoder.Inputs inputs.node inputs.mode (mapThingToEncode inputs.thingToEncode) inputs.parent inputs.position

        mapThingToEncode : NodeEncoder.ThingToEncode (Nonempty a) -> NodeEncoder.ThingToEncode (List a)
        mapThingToEncode original =
            case original of
                NodeEncoder.EncodeThis a ->
                    NodeEncoder.EncodeThis (Nonempty.toList a)

                NodeEncoder.EncodeObjectOrThis objectIDs fieldVal ->
                    NodeEncoder.EncodeObjectOrThis objectIDs (Nonempty.toList fieldVal)
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
        , nodePlaceholder = Initializer.flatInit
        }


array : SelfSeededCodec o a -> SelfSeededCodec {} (Array a)
array codec =
    list codec |> Base.map Array.fromList Array.toList


dict : PrimitiveCodec comparable -> Codec s o a -> SelfSeededCodec {} (Dict comparable a)
dict keyCodec valueCodec =
    list (SyncSafe.pair keyCodec valueCodec)
        |> map Dict.fromList Dict.toList


set : PrimitiveCodec comparable -> SelfSeededCodec {} (Set comparable)
set codec =
    list codec |> map Set.fromList Set.toList
