module HelperTests exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Helpers
import Test exposing (..)


suite : Test
suite =
    describe "Helper Tests"
        [ cycleGroupWithStep
        ]


cycleGroupWithStep =
    test "cycleGroupWithStep" <|
        let
            list =
                [ 1, 2, 3, 4 ]

            -- 3 1
            expected =
                [ [ 1, 2, 3 ], [ 2, 3, 4 ], [ 3, 4, 1 ], [ 4, 1, 2 ] ]

            -- 2 1
            -- expected = [ [ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 4, 1 ] ]
        in
        \_ -> Expect.equal (Helpers.cycleGroupWithStep 3 1 list) expected
