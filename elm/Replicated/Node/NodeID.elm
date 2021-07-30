module Replicated.Node.NodeID exposing (..)

import Replicated.Serialize as RS
import SmartTime.Moment as Moment exposing (Moment)


type alias NodeID =
    -- never store "session" part - generate that on every run
    { primus : Int, peer : Int, client : Int, session : Int }


toString : NodeID -> String
toString nodeID =
    String.fromInt nodeID.primus
        ++ "."
        ++ String.fromInt nodeID.peer
        ++ "."
        ++ String.fromInt nodeID.client
        ++ "."
        ++ String.fromInt nodeID.session


fromString : String -> Maybe NodeID
fromString input =
    case List.map String.toInt (String.split "." input) of
        [ Just first, Just second, Just third, Just fourth ] ->
            Just (NodeID first second third fourth)

        _ ->
            Nothing


codec : RS.Codec String NodeID
codec =
    RS.mapValid (Result.fromMaybe "" << fromString) toString RS.string
