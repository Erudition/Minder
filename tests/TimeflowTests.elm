module TimeflowTests exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import GraphicSVG exposing (GraphicSVG)
import List.Extra
import Main exposing (Screen(..))
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.OpID as OpID
import Replicated.Reducer.Register exposing (RW)
import Replicated.ReplicaCodec as RC exposing (Codec, decodeFromNode)
import SmartTime.Moment as Moment
import Test exposing (..)
import Timeflow


suite : Test
suite =
    describe "RON Encode-Decode"
        [ neighboringPoints
        , addPoints
        , roundedPolygon
        ]


neighboringPoints =
    test "[ 1, 2, 3 ] -> [ ( 1, 2, 3 ), ( 2, 3, 1 ), ( 3, 1, 2 ) ]" <|
        let
            list =
                [ 1, 2, 3 ]

            expected =
                [ ( 1, 2, 3 ), ( 2, 3, 1 ), ( 3, 1, 2 ) ]
        in
        \_ -> Expect.equal (Timeflow.neighboringLoop list) expected


addPoints =
    test "addPoints function" <|
        let
            points =
                [ ( 1, 2 ), ( 2, 3 ), ( 3, 1 ) ]

            la =
                points

            lb =
                List.drop 1 <| List.Extra.cycle (List.length points + 1) points

            -- a = [ ( ( 1, 2 ), ( 2, 3 ) ), ( ( 2, 3 ), ( 3, 1 ) ), ( ( 3, 1 ), ( 1, 2 ) ) ]
            neightboringPoints =
                List.Extra.zip la lb

            newPoints =
                List.map
                    (\( a, b ) ->
                        ( (Tuple.first b + Tuple.first a) / 2, (Tuple.second a + Tuple.second b) / 2 )
                    )
                    neightboringPoints

            allPoints =
                List.Extra.interweave points newPoints

            expected =
                [ ( 1, 2 ), ( 1.5, 2.5 ), ( 2, 3 ), ( 2.5, 2 ), ( 3, 1 ), ( 2, 1.5 ) ]
        in
        -- \_ -> Expect.equal allPoints expected
        \_ -> Expect.equal allPoints expected


roundedPolygon =
    test "aaaaaaaaaaaaaaaaaaaaa" <|
        let
            cornerList =
                [ ( 0, 0 )
                , ( 100, 0 )
                , ( 100, -30 )
                , ( 0, -30 )
                ]

            addedPoints =
                Timeflow.addPoints 10 cornerList

            pullers =
                addedPoints
                    |> List.Extra.cycle (List.length addedPoints + 2)
                    |> List.drop 1
                    |> List.Extra.groupsOf 2

            pullerList =
                -- Convert the list of list of points into a list of pullers.
                List.map
                    (\list ->
                        let
                            a =
                                Maybe.withDefault ( 0, 0 ) <| List.Extra.getAt 0 list

                            b =
                                Maybe.withDefault ( 0, 0 ) <| List.Extra.getAt 1 list
                        in
                        GraphicSVG.Pull a b
                    )
                    pullers

            expected =
                -- [ ( 1, 2 ), ( 1.5, 2.5 ), ( 2, 3 ), ( 2.5, 2 ), ( 3, 1 ), ( 2, 1.5 ) ] -- For testing
                -- [ [ ( 0.0, 0.0 ) ] ]
                -- [ GraphicSVG.Pull ( 0, 0 ) ( 100, 0 ) ]
                [ GraphicSVG.Pull ( 0, 0 ) ( 50, 0 )
                , GraphicSVG.Pull ( 100, 0 ) ( 100, -15 )
                , GraphicSVG.Pull ( 100, -30 ) ( 50, -30 )
                , GraphicSVG.Pull ( 0, -30 ) ( 0, -15 )
                , GraphicSVG.Pull ( 0, 0 ) ( 50, 0 )
                ]

            -- Should FAIL
        in
        \_ -> Expect.equal pullerList expected
