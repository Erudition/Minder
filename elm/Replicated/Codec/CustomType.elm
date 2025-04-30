module Replicated.Codec.CustomType exposing (CustomTypeCodec, VariantTag, customType, finishCustomType, variant0, variant1, variant2, variant3, variant4, variant5, variant6, variant7, variant8)

{-| Codecs for Custom Types.
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
import Replicated.Codec.Base as Base exposing (Codec(..), NullCodec, getBytesDecoder, getBytesEncoder, getJsonDecoder, getJsonEncoder, getNodeDecoder, getNodeEncoder)
import Replicated.Codec.Bytes.Decoder as BytesDecoder exposing (BytesDecoder)
import Replicated.Codec.Bytes.Encoder as BytesEncoder exposing (BytesEncoder)
import Replicated.Codec.Error as Error exposing (RepDecodeError(..))
import Replicated.Codec.Initializer as Initializer exposing (Initializer)
import Replicated.Codec.Json.Decoder as JsonDecoder exposing (JsonDecoder)
import Replicated.Codec.Json.Encoder exposing (JsonEncoder)
import Replicated.Codec.Node.Decoder as NodeDecoder exposing (NodeDecoder)
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


type alias VariantTag =
    ( Int, String )


{-| A partially built codec for a custom type.
-}
type CustomTypeCodec a matcher v
    = CustomTypeCodec
        { bytesMatcher : matcher
        , jsonMatcher : matcher
        , nodeMatcher : matcher
        , bytesDecoder : Int -> BytesDecoder v -> BytesDecoder v
        , jsonDecoder : Int -> JD.Decoder (Result RepDecodeError v) -> JD.Decoder (Result RepDecodeError v)
        , nodeDecoder : Int -> NodeDecoder v -> NodeDecoder v
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
customType : matcher -> CustomTypeCodec { youNeedAtLeastOneVariant : () } matcher value
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
    NodeEncoder.InputsNoVariable -> Change.ComplexPayload


variantBuilder :
    VariantTag
    -> ((List BE.Encoder -> VariantEncoder) -> finalWrappedValue)
    -> ((List JE.Value -> VariantEncoder) -> finalWrappedValue)
    -> ((List VariantNodeEncoder -> VariantEncoder) -> finalWrappedValue)
    -> BD.Decoder (Result RepDecodeError v)
    -> JD.Decoder (Result RepDecodeError v)
    -> NodeDecoder v
    -> CustomTypeCodec z (finalWrappedValue -> b) v
    -> CustomTypeCodec () b v
variantBuilder ( tagNum, tagName ) piecesBytesEncoder piecesJsonEncoder piecesNodeEncoder piecesBytesDecoder piecesJsonDecoder piecesNodeDecoder (CustomTypeCodec priorVariants) =
    let
        -- for the input encoder functions: they're expecting to be handed one of the wrappers below, but otherwise they're just the piecewise encoders of all the variant's pieces (in one big final encoder) needing only to be wrapped (e.g. add the `Just`).
        -- for these wrapper functions: input list is individual encoders of the variant's sub-pieces. The variant's tag is prepended and the output is effectively an encoder of the entire variantBuilder at once. It then gets combined below with the other variantBuilder encoders to form the encoder of the whole custom type.
        wrapBE : List BE.Encoder -> VariantEncoder
        wrapBE variantPieces =
            VariantEncoder
                { bytes = BE.unsignedInt16 BytesEncoder.endian tagNum :: variantPieces |> BE.sequence
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

        unwrapBD : Int -> BD.Decoder (Result RepDecodeError v) -> BD.Decoder (Result RepDecodeError v)
        unwrapBD tagNumToDecode orElse =
            if tagNumToDecode == tagNum then
                -- variantBuilder match! now decode the pieces
                piecesBytesDecoder

            else
                -- not this variantBuilder, pass along to other variantBuilder decoders
                priorVariants.bytesDecoder tagNumToDecode orElse

        unwrapJD : Int -> JD.Decoder (Result RepDecodeError v) -> JD.Decoder (Result RepDecodeError v)
        unwrapJD tagNumToDecode orElse =
            if tagNumToDecode == tagNum then
                -- variantBuilder match! now decode the pieces
                piecesJsonDecoder

            else
                -- not this variantBuilder, pass along to other variantBuilder decoders
                priorVariants.jsonDecoder tagNumToDecode orElse

        unwrapND : Int -> NodeDecoder v -> NodeDecoder v
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


variant0 : VariantTag -> v -> CustomTypeCodec z (VariantEncoder -> a) v -> CustomTypeCodec () a v
variant0 tag ctor =
    variantBuilder tag
        (\wrapper -> wrapper [])
        (\wrapper -> wrapper [])
        (\wrapper -> wrapper [])
        (BD.succeed (Ok ctor))
        (JD.succeed (Ok ctor))
        (\_ -> JD.succeed (Ok ctor))


passNDInputs : Int -> NodeDecoder.Inputs a -> NodeDecoder.Inputs a
passNDInputs pieceNum inputsND =
    { inputsND
        | parent = Change.becomeInstantParent <| Change.newPointer { parent = inputsND.parent, position = Location.nest inputsND.position "piece" pieceNum, reducerID = "variant" }
        , position = Location.nest inputsND.position "piece" pieceNum
    }


variant1 :
    VariantTag
    -> (a -> v)
    -> Codec ia oa a
    -> CustomTypeCodec z ((a -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
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


variant2 :
    VariantTag
    -> (a -> b -> v)
    -> Codec ia oa a
    -> Codec ib ob b
    -> CustomTypeCodec z ((a -> b -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
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


variant3 :
    VariantTag
    -> (a -> b -> c -> v)
    -> Codec ia oa a
    -> Codec ib ob b
    -> Codec ic oc c
    -> CustomTypeCodec z ((a -> b -> c -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
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


variant4 :
    VariantTag
    -> (a -> b -> c -> d -> v)
    -> Codec ia oa a
    -> Codec ib ob b
    -> Codec ic oc c
    -> Codec id od d
    -> CustomTypeCodec z ((a -> b -> c -> d -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
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


variant5 :
    VariantTag
    -> (a -> b -> c -> d -> e -> v)
    -> Codec ia oa a
    -> Codec ib ob b
    -> Codec ic oc c
    -> Codec id od d
    -> Codec ie oe e
    -> CustomTypeCodec z ((a -> b -> c -> d -> e -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
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


variant6 :
    VariantTag
    -> (a -> b -> c -> d -> e -> f -> v)
    -> Codec ia oa a
    -> Codec ib ob b
    -> Codec ic oc c
    -> Codec id od d
    -> Codec ie oe e
    -> Codec if_ of_ f
    -> CustomTypeCodec z ((a -> b -> c -> d -> e -> f -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
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


variant7 :
    VariantTag
    -> (a -> b -> c -> d -> e -> f -> g -> v)
    -> Codec ia oa a
    -> Codec ib ob b
    -> Codec ic oc c
    -> Codec id od d
    -> Codec ie oe e
    -> Codec if_ of_ f
    -> Codec ig og g
    -> CustomTypeCodec z ((a -> b -> c -> d -> e -> f -> g -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
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


variant8 :
    VariantTag
    -> (a -> b -> c -> d -> e -> f -> g -> h -> v)
    -> Codec ia oa a
    -> Codec ib ob b
    -> Codec ic oc c
    -> Codec id od d
    -> Codec ie oe e
    -> Codec if_ of_ f
    -> Codec ig og g
    -> Codec ih o h
    -> CustomTypeCodec z ((a -> b -> c -> d -> e -> f -> g -> h -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
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


finishCustomType : CustomTypeCodec () (a -> VariantEncoder) a -> NullCodec a
finishCustomType (CustomTypeCodec priorVariants) =
    let
        nodeEncoder : NodeEncoder a {}
        nodeEncoder nodeEncoderInputs =
            let
                newInputs : NodeEncoder.InputsNoVariable
                newInputs =
                    { node = nodeEncoderInputs.node
                    , mode = nodeEncoderInputs.mode
                    , position = nodeEncoderInputs.position
                    , parent = nodeEncoderInputs.parent
                    }

                nodeMatcher : VariantEncoder
                nodeMatcher =
                    priorVariants.nodeMatcher (NodeEncoder.getEncodedPrimitive nodeEncoderInputs.thingToEncode)

                getNodeVariantEncoder (VariantEncoder encoders) =
                    encoders.node newInputs
            in
            { complex = getNodeVariantEncoder nodeMatcher }

        nodeDecoder : NodeDecoder a
        nodeDecoder inputs =
            let
                getTagNum tag =
                    String.split "_" tag
                        |> List.Extra.last
                        |> Maybe.andThen String.toInt
                        |> Maybe.Extra.withDefaultLazy (\_ -> -1)

                findDecoderMatchingTag : JD.Decoder (Result RepDecodeError a)
                findDecoderMatchingTag =
                    let
                        nestedDecoderFromTag tag =
                            priorVariants.nodeDecoder (getTagNum tag) (fallback tag) inputs
                    in
                    JD.index 0 JD.string
                        |> JD.andThen nestedDecoderFromTag

                fallback tag =
                    \_ -> JD.succeed (Err (NoMatchingVariant tag))

                captureSubGroups : List JE.Value -> List JE.Value
                captureSubGroups inputList =
                    -- This is needed because we may have custom types nested within custom types with different numbers of parameters, but there is no easy way for a nested decoder to report back the number of atoms it consumes. This is a known amount normally, so it would be good to switch to that method at some point for more compact code and less atoms (though potentially worse readability). For now we wrap nested atoms with parens.
                    let
                        inputListWithoutParens =
                            -- strip parens if we were given a parenthesized list
                            if Maybe.map isNotOpeningParen (List.head inputList) == Just False then
                                List.drop 1 inputList |> List.Extra.init |> Maybe.withDefault []

                            else
                                inputList

                        isNotOpeningParen val =
                            JE.encode 0 val /= "\"(\""
                    in
                    case List.Extra.span isNotOpeningParen inputListWithoutParens of
                        ( [], [] ) ->
                            []

                        ( outsideList, [] ) ->
                            outsideList

                        --outsideList
                        ( outsideList, [ justParen ] ) ->
                            Log.crashInDev ("found opening paren but nothing after it: " ++ String.join "," (List.map (JE.encode 0) outsideList)) outsideList

                        ( outsideBeforeFirstGroup, openingParen :: afterParen ) ->
                            let
                                foundClosingParen val =
                                    JE.encode 0 val /= "\")\""
                            in
                            -- found subgroup. Drop the opening paren, then take until the closing one.
                            case ( List.Extra.dropWhileRight foundClosingParen afterParen |> List.Extra.init, List.Extra.takeWhileRight foundClosingParen afterParen ) of
                                ( Nothing, afterGroup ) ->
                                    Log.crashInDev ("found opening paren but nothing after it: " ++ String.join "," (List.map (JE.encode 0) afterParen)) outsideBeforeFirstGroup

                                ( Just insideGroup, afterGroup ) ->
                                    -- encode the inner group into a sublist Json Value. Recurse on remainder, but not on inner group as this function will be run again in the nested decoder.
                                    outsideBeforeFirstGroup
                                        ++ [ JE.list identity insideGroup ]
                                        ++ captureSubGroups afterGroup

                reDecodeGroupedList groupedList =
                    -- hack. how can we transform input to a decoder rather than output?
                    -- for now we have to use JD.andThen to get the decoded value, then re-encode it and run further decoder on that value.
                    let
                        reEncoded =
                            JE.list identity groupedList
                    in
                    case JD.decodeValue findDecoderMatchingTag reEncoded of
                        Ok successValue ->
                            JD.succeed successValue

                        Err errorMessage ->
                            JD.fail (JD.errorToString errorMessage)
            in
            JD.oneOf
                [ JD.list JD.value |> JD.map captureSubGroups |> JD.andThen reDecodeGroupedList

                -- allow non-array input for variant0s:
                , findDecoderMatchingTag
                ]
    in
    Codec
        { bytesEncoder = priorVariants.bytesMatcher >> (\(VariantEncoder encoders) -> encoders.bytes)
        , bytesDecoder =
            BD.unsignedInt16 BytesEncoder.endian
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
getNodeEncoderModifiedForVariants : Int -> Codec ia o a -> a -> VariantNodeEncoder
getNodeEncoderModifiedForVariants index codec thingToEncode =
    let
        finishInputs : NodeEncoder.InputsNoVariable -> NodeEncoder.Inputs a
        finishInputs modifiedEncoder =
            { node = modifiedEncoder.node
            , mode = modifiedEncoder.mode
            , thingToEncode = NodeEncoder.EncodeThis thingToEncode
            , position = Location.nest modifiedEncoder.position "piece" index
            , parent = modifiedEncoder.parent
            }
    in
    \altInputs -> (getNodeEncoder codec (finishInputs altInputs)).complex
