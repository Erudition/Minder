module Replicated.Node.NodeID exposing (..)

import Replicated.Serialize as RS
import SmartTime.Moment as Moment exposing (Moment)


type alias NodeID =
    -- never store "session" part - generate that on every run
    { primus : Int, peer : Int, client : Int, session : Int }


nodeIDToString : NodeID -> String
nodeIDToString nodeID =
    String.fromInt nodeID.primus
        ++ "."
        ++ String.fromInt nodeID.peer
        ++ "."
        ++ String.fromInt nodeID.client
        ++ "."
        ++ String.fromInt nodeID.session


nodeIDFromString : String -> Maybe NodeID
nodeIDFromString input =
    case List.map String.toInt (String.split "." input) of
        [ Just first, Just second, Just third, Just fourth ] ->
            Just (NodeID first second third fourth)

        _ ->
            Nothing


nodeIDCodec : RS.Codec String NodeID
nodeIDCodec =
    RS.mapValid (Result.fromMaybe "" << nodeIDFromString) nodeIDToString RS.string
