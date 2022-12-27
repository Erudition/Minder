module Replicated.Node.NodeID exposing (..)

import SmartTime.Moment as Moment exposing (Moment)


type NodeID
    = -- never store "session" part - generate that on every run
      -- { primus : Int, peer : Int, client : Int, session : Int }
      NodeID String


generate : { primus : Int, peer : Int, client : Int, session : Int } -> NodeID
generate record =
    --TODO
    NodeID "here"


throwawayID =
    NodeID "temp"

bumpSessionID : NodeID -> NodeID
bumpSessionID (NodeID nodeIDString) =
    -- TODO { nodeID | session = nodeID.session + 1 }
    NodeID (nodeIDString ++ "2")


toString : NodeID -> String
toString (NodeID nodeIDString) =
    nodeIDString


fromString : String -> Maybe NodeID
fromString input =
    if String.length input > 0 then
        Just (NodeID input)
    else Nothing

