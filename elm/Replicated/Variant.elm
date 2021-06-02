module Replicated.Variant exposing (..)

{-| A partially built codec for a custom type.
-}

-- CUSTOM


type CustomTypeCodec a e match v
    = CustomTypeCodec
        { match : match
        , jsonMatch : match
        , decoder : Int -> BD.Decoder (Result (Error e) v) -> BD.Decoder (Result (Error e) v)
        , jsonDecoder : Int -> JD.Decoder (Result (Error e) v) -> JD.Decoder (Result (Error e) v)
        , idCounter : Int
        }


{-| Starts building a `Codec` for a custom type.
You need to pass a pattern matching function, see the FAQ for details.

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
            -- Note that removing a variant, inserting a variant before an existing one, or swapping two variants will prevent you from decoding any data you've previously encoded.
            |> S.variant3 Red S.int S.string S.bool
            |> S.variant1 Yellow S.float
            |> S.variant0 Green
            -- It's safe to add new variants here later though
            |> S.finishCustomType

-}
customType : match -> CustomTypeCodec { youNeedAtLeastOneVariant : () } e match value
customType match =
    CustomTypeCodec
        { match = match
        , jsonMatch = match
        , decoder = \_ -> identity
        , jsonDecoder = \_ -> identity
        , idCounter = 0
        }


{-| -}
type VariantEncoder
    = VariantEncoder ( BE.Encoder, JE.Value )


variant :
    ((List BE.Encoder -> VariantEncoder) -> a)
    -> ((List JE.Value -> VariantEncoder) -> a)
    -> BD.Decoder (Result (Error error) v)
    -> JD.Decoder (Result (Error error) v)
    -> CustomTypeCodec z error (a -> b) v
    -> CustomTypeCodec () error b v
variant matchPiece matchJsonPiece decoderPiece jsonDecoderPiece (CustomTypeCodec am) =
    let
        enc : List BE.Encoder -> VariantEncoder
        enc v =
            ( BE.unsignedInt16 endian am.idCounter :: v |> BE.sequence
            , JE.null
            )
                |> VariantEncoder

        jsonEnc : List JE.Value -> VariantEncoder
        jsonEnc v =
            ( BE.sequence []
            , JE.int am.idCounter :: v |> JE.list identity
            )
                |> VariantEncoder

        decoder_ : Int -> BD.Decoder (Result (Error error) v) -> BD.Decoder (Result (Error error) v)
        decoder_ tag orElse =
            if tag == am.idCounter then
                decoderPiece

            else
                am.decoder tag orElse

        jsonDecoder_ : Int -> JD.Decoder (Result (Error error) v) -> JD.Decoder (Result (Error error) v)
        jsonDecoder_ tag orElse =
            if tag == am.idCounter then
                jsonDecoderPiece

            else
                am.jsonDecoder tag orElse
    in
    CustomTypeCodec
        { match = am.match <| matchPiece enc
        , jsonMatch = am.jsonMatch <| matchJsonPiece jsonEnc
        , decoder = decoder_
        , jsonDecoder = jsonDecoder_
        , idCounter = am.idCounter + 1
        }


{-| Define a variant with 0 parameters for a custom type.
-}
variant0 : v -> CustomTypeCodec z e (VariantEncoder -> a) v -> CustomTypeCodec () e a v
variant0 ctor =
    variant
        (\c -> c [])
        (\c -> c [])
        (BD.succeed (Ok ctor))
        (JD.succeed (Ok ctor))


{-| Define a variant with 1 parameters for a custom type.
-}
variant1 :
    (a -> v)
    -> NestableCodec error a
    -> CustomTypeCodec z error ((a -> VariantEncoder) -> b) v
    -> CustomTypeCodec () error b v
variant1 ctor m1 =
    variant
        (\c v ->
            c
                [ getEncoder m1 v
                ]
        )
        (\c v ->
            c
                [ getJsonEncoder m1 v
                ]
        )
        (BD.map (result1 ctor) (getBytesDecoder m1))
        (JD.map (result1 ctor) (JD.index 1 (getJsonDecoder m1)))


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


{-| Define a variant with 2 parameters for a custom type.
-}
variant2 :
    (a -> b -> v)
    -> NestableCodec error a
    -> NestableCodec error b
    -> CustomTypeCodec z error ((a -> b -> VariantEncoder) -> c) v
    -> CustomTypeCodec () error c v
variant2 ctor m1 m2 =
    variant
        (\c v1 v2 ->
            [ getEncoder m1 v1
            , getEncoder m2 v2
            ]
                |> c
        )
        (\c v1 v2 ->
            [ getJsonEncoder m1 v1
            , getJsonEncoder m2 v2
            ]
                |> c
        )
        (BD.map2
            (result2 ctor)
            (getBytesDecoder m1)
            (getBytesDecoder m2)
        )
        (JD.map2
            (result2 ctor)
            (JD.index 1 (getJsonDecoder m1))
            (JD.index 2 (getJsonDecoder m2))
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


{-| Define a variant with 3 parameters for a custom type.
-}
variant3 :
    (a -> b -> c -> v)
    -> NestableCodec error a
    -> NestableCodec error b
    -> NestableCodec error c
    -> CustomTypeCodec z error ((a -> b -> c -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () error partial v
variant3 ctor m1 m2 m3 =
    variant
        (\c v1 v2 v3 ->
            [ getEncoder m1 v1
            , getEncoder m2 v2
            , getEncoder m3 v3
            ]
                |> c
        )
        (\c v1 v2 v3 ->
            [ getJsonEncoder m1 v1
            , getJsonEncoder m2 v2
            , getJsonEncoder m3 v3
            ]
                |> c
        )
        (BD.map3
            (result3 ctor)
            (getBytesDecoder m1)
            (getBytesDecoder m2)
            (getBytesDecoder m3)
        )
        (JD.map3
            (result3 ctor)
            (JD.index 1 (getJsonDecoder m1))
            (JD.index 2 (getJsonDecoder m2))
            (JD.index 3 (getJsonDecoder m3))
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


{-| Define a variant with 4 parameters for a custom type.
-}
variant4 :
    (a -> b -> c -> d -> v)
    -> NestableCodec error a
    -> NestableCodec error b
    -> NestableCodec error c
    -> NestableCodec error d
    -> CustomTypeCodec z error ((a -> b -> c -> d -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () error partial v
variant4 ctor m1 m2 m3 m4 =
    variant
        (\c v1 v2 v3 v4 ->
            [ getEncoder m1 v1
            , getEncoder m2 v2
            , getEncoder m3 v3
            , getEncoder m4 v4
            ]
                |> c
        )
        (\c v1 v2 v3 v4 ->
            [ getJsonEncoder m1 v1
            , getJsonEncoder m2 v2
            , getJsonEncoder m3 v3
            , getJsonEncoder m4 v4
            ]
                |> c
        )
        (BD.map4
            (result4 ctor)
            (getBytesDecoder m1)
            (getBytesDecoder m2)
            (getBytesDecoder m3)
            (getBytesDecoder m4)
        )
        (JD.map4
            (result4 ctor)
            (JD.index 1 (getJsonDecoder m1))
            (JD.index 2 (getJsonDecoder m2))
            (JD.index 3 (getJsonDecoder m3))
            (JD.index 4 (getJsonDecoder m4))
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


{-| Define a variant with 5 parameters for a custom type.
-}
variant5 :
    (a -> b -> c -> d -> e -> v)
    -> NestableCodec error a
    -> NestableCodec error b
    -> NestableCodec error c
    -> NestableCodec error d
    -> NestableCodec error e
    -> CustomTypeCodec z error ((a -> b -> c -> d -> e -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () error partial v
variant5 ctor m1 m2 m3 m4 m5 =
    variant
        (\c v1 v2 v3 v4 v5 ->
            [ getEncoder m1 v1
            , getEncoder m2 v2
            , getEncoder m3 v3
            , getEncoder m4 v4
            , getEncoder m5 v5
            ]
                |> c
        )
        (\c v1 v2 v3 v4 v5 ->
            [ getJsonEncoder m1 v1
            , getJsonEncoder m2 v2
            , getJsonEncoder m3 v3
            , getJsonEncoder m4 v4
            , getJsonEncoder m5 v5
            ]
                |> c
        )
        (BD.map5
            (result5 ctor)
            (getBytesDecoder m1)
            (getBytesDecoder m2)
            (getBytesDecoder m3)
            (getBytesDecoder m4)
            (getBytesDecoder m5)
        )
        (JD.map5
            (result5 ctor)
            (JD.index 1 (getJsonDecoder m1))
            (JD.index 2 (getJsonDecoder m2))
            (JD.index 3 (getJsonDecoder m3))
            (JD.index 4 (getJsonDecoder m4))
            (JD.index 5 (getJsonDecoder m5))
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


{-| Define a variant with 6 parameters for a custom type.
-}
variant6 :
    (a -> b -> c -> d -> e -> f -> v)
    -> NestableCodec error a
    -> NestableCodec error b
    -> NestableCodec error c
    -> NestableCodec error d
    -> NestableCodec error e
    -> NestableCodec error f
    -> CustomTypeCodec z error ((a -> b -> c -> d -> e -> f -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () error partial v
variant6 ctor m1 m2 m3 m4 m5 m6 =
    variant
        (\c v1 v2 v3 v4 v5 v6 ->
            [ getEncoder m1 v1
            , getEncoder m2 v2
            , getEncoder m3 v3
            , getEncoder m4 v4
            , getEncoder m5 v5
            , getEncoder m6 v6
            ]
                |> c
        )
        (\c v1 v2 v3 v4 v5 v6 ->
            [ getJsonEncoder m1 v1
            , getJsonEncoder m2 v2
            , getJsonEncoder m3 v3
            , getJsonEncoder m4 v4
            , getJsonEncoder m5 v5
            , getJsonEncoder m6 v6
            ]
                |> c
        )
        (BD.map5
            (result6 ctor)
            (getBytesDecoder m1)
            (getBytesDecoder m2)
            (getBytesDecoder m3)
            (getBytesDecoder m4)
            (BD.map2 Tuple.pair
                (getBytesDecoder m5)
                (getBytesDecoder m6)
            )
        )
        (JD.map5
            (result6 ctor)
            (JD.index 1 (getJsonDecoder m1))
            (JD.index 2 (getJsonDecoder m2))
            (JD.index 3 (getJsonDecoder m3))
            (JD.index 4 (getJsonDecoder m4))
            (JD.map2 Tuple.pair
                (JD.index 5 (getJsonDecoder m5))
                (JD.index 6 (getJsonDecoder m6))
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


{-| Define a variant with 7 parameters for a custom type.
-}
variant7 :
    (a -> b -> c -> d -> e -> f -> g -> v)
    -> NestableCodec error a
    -> NestableCodec error b
    -> NestableCodec error c
    -> NestableCodec error d
    -> NestableCodec error e
    -> NestableCodec error f
    -> NestableCodec error g
    -> CustomTypeCodec z error ((a -> b -> c -> d -> e -> f -> g -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () error partial v
variant7 ctor m1 m2 m3 m4 m5 m6 m7 =
    variant
        (\c v1 v2 v3 v4 v5 v6 v7 ->
            [ getEncoder m1 v1
            , getEncoder m2 v2
            , getEncoder m3 v3
            , getEncoder m4 v4
            , getEncoder m5 v5
            , getEncoder m6 v6
            , getEncoder m7 v7
            ]
                |> c
        )
        (\c v1 v2 v3 v4 v5 v6 v7 ->
            [ getJsonEncoder m1 v1
            , getJsonEncoder m2 v2
            , getJsonEncoder m3 v3
            , getJsonEncoder m4 v4
            , getJsonEncoder m5 v5
            , getJsonEncoder m6 v6
            , getJsonEncoder m7 v7
            ]
                |> c
        )
        (BD.map5
            (result7 ctor)
            (getBytesDecoder m1)
            (getBytesDecoder m2)
            (getBytesDecoder m3)
            (BD.map2 Tuple.pair
                (getBytesDecoder m4)
                (getBytesDecoder m5)
            )
            (BD.map2 Tuple.pair
                (getBytesDecoder m6)
                (getBytesDecoder m7)
            )
        )
        (JD.map5
            (result7 ctor)
            (JD.index 1 (getJsonDecoder m1))
            (JD.index 2 (getJsonDecoder m2))
            (JD.index 3 (getJsonDecoder m3))
            (JD.map2 Tuple.pair
                (JD.index 4 (getJsonDecoder m4))
                (JD.index 5 (getJsonDecoder m5))
            )
            (JD.map2 Tuple.pair
                (JD.index 6 (getJsonDecoder m6))
                (JD.index 7 (getJsonDecoder m7))
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


{-| Define a variant with 8 parameters for a custom type.
-}
variant8 :
    (a -> b -> c -> d -> e -> f -> g -> h -> v)
    -> NestableCodec error a
    -> NestableCodec error b
    -> NestableCodec error c
    -> NestableCodec error d
    -> NestableCodec error e
    -> NestableCodec error f
    -> NestableCodec error g
    -> NestableCodec error h
    -> CustomTypeCodec z error ((a -> b -> c -> d -> e -> f -> g -> h -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () error partial v
variant8 ctor m1 m2 m3 m4 m5 m6 m7 m8 =
    variant
        (\c v1 v2 v3 v4 v5 v6 v7 v8 ->
            [ getEncoder m1 v1
            , getEncoder m2 v2
            , getEncoder m3 v3
            , getEncoder m4 v4
            , getEncoder m5 v5
            , getEncoder m6 v6
            , getEncoder m7 v7
            , getEncoder m8 v8
            ]
                |> c
        )
        (\c v1 v2 v3 v4 v5 v6 v7 v8 ->
            [ getJsonEncoder m1 v1
            , getJsonEncoder m2 v2
            , getJsonEncoder m3 v3
            , getJsonEncoder m4 v4
            , getJsonEncoder m5 v5
            , getJsonEncoder m6 v6
            , getJsonEncoder m7 v7
            , getJsonEncoder m8 v8
            ]
                |> c
        )
        (BD.map5
            (result8 ctor)
            (getBytesDecoder m1)
            (getBytesDecoder m2)
            (BD.map2 Tuple.pair
                (getBytesDecoder m3)
                (getBytesDecoder m4)
            )
            (BD.map2 Tuple.pair
                (getBytesDecoder m5)
                (getBytesDecoder m6)
            )
            (BD.map2 Tuple.pair
                (getBytesDecoder m7)
                (getBytesDecoder m8)
            )
        )
        (JD.map5
            (result8 ctor)
            (JD.index 1 (getJsonDecoder m1))
            (JD.index 2 (getJsonDecoder m2))
            (JD.map2 Tuple.pair
                (JD.index 3 (getJsonDecoder m3))
                (JD.index 4 (getJsonDecoder m4))
            )
            (JD.map2 Tuple.pair
                (JD.index 5 (getJsonDecoder m5))
                (JD.index 6 (getJsonDecoder m6))
            )
            (JD.map2 Tuple.pair
                (JD.index 7 (getJsonDecoder m7))
                (JD.index 8 (getJsonDecoder m8))
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
finishCustomType : CustomTypeCodec () e (a -> VariantEncoder) a -> NestableCodec e a
finishCustomType (CustomTypeCodec am) =
    buildNoNest
        (am.match >> (\(VariantEncoder ( a, _ )) -> a))
        (BD.unsignedInt16 endian
            |> BD.andThen
                (\tag ->
                    am.decoder tag (BD.succeed (Err DataCorrupted))
                )
        )
        (am.jsonMatch >> (\(VariantEncoder ( _, a )) -> a))
        (JD.index 0 JD.int
            |> JD.andThen
                (\tag ->
                    am.jsonDecoder tag (JD.succeed (Err DataCorrupted))
                )
        )
