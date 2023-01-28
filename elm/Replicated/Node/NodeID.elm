module Replicated.Node.NodeID exposing (NodeID, bumpSessionID, fromString, generate, parser, toString)

import Parser.Advanced as Parser exposing ((|.), (|=), Parser, Token(..), int, spaces, succeed, symbol, token)
import SmartTime.Moment as Moment exposing (Moment)


type NodeID
    = NodeID NodeIDParts


{-| Not exposed - internal helper
-}
type alias NodeIDParts =
    { agent : Int, device : Int, client : Int, session : Int }


generate : { agent : Int, device : Int, client : Int, session : Int } -> NodeID
generate record =
    NodeID record


bumpSessionID : NodeID -> NodeID
bumpSessionID (NodeID oldNodeID) =
    NodeID { oldNodeID | session = oldNodeID.session + 1 }


toString : NodeID -> String
toString (NodeID nodeIDParts) =
    let
        sayPart prefix num =
            if num == 0 then
                ""

            else
                prefix ++ String.fromInt num
    in
    String.concat
        [ sayPart "a" nodeIDParts.agent
        , sayPart "d" nodeIDParts.device
        , sayPart "c" nodeIDParts.client
        , "s" ++ String.fromInt nodeIDParts.session
        ]


fromString : String -> Maybe NodeID
fromString input =
    Result.toMaybe (Parser.run parser input)


type alias NodeIDParser a =
    Parser Context ParseProblem a


type Context
    = Definition String
    | List
    | Record


type ParseProblem
    = BadCounter
    | BadNodeID
    | ExpectingCounter


parser : NodeIDParser NodeID
parser =
    Parser.map NodeID <|
        succeed NodeIDParts
            |= Parser.oneOf
                [ succeed identity
                    |. symbol (Token "a" BadNodeID)
                    |= int ExpectingCounter BadCounter
                , succeed 0
                ]
            |= Parser.oneOf
                [ succeed identity
                    |. symbol (Token "d" BadNodeID)
                    |= int ExpectingCounter BadCounter
                , succeed 0
                ]
            |= Parser.oneOf
                [ succeed identity
                    |. symbol (Token "c" BadNodeID)
                    |= int ExpectingCounter BadCounter
                , succeed 0
                ]
            |= Parser.oneOf
                [ succeed identity
                    |. symbol (Token "s" BadNodeID)
                    |= int ExpectingCounter BadCounter
                , succeed 0
                ]
