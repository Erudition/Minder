module Replicated.Op.OpID exposing (EventStamp, InCounter, ObjectID, ObjectIDString, OpID, OpIDString, OutCounter, codec, fromString, generate, getEventStamp, jsonDecoder, toString)

import Json.Decode as JD
import Replicated.Node.NodeID as NodeID exposing (NodeID)
import Replicated.Serialize as RS exposing (Codec)
import SmartTime.Moment as Moment exposing (Moment)


type OpID
    = OpID EventStamp


type alias ObjectID =
    OpID


type alias ObjectIDString =
    String


type alias OpIDString =
    String


type alias OpTimestamp =
    Moment


type alias OpOrigin =
    NodeID


type alias EventStamp =
    { time : Moment
    , origin : NodeID
    }


generate : InCounter -> NodeID -> ( OpID, OutCounter )
generate (NewOpCounter counter) origin =
    ( OpID { time = Moment.fromSmartInt counter, origin = origin }, NewOpCounter (counter + 1) )


toString : OpID -> OpIDString
toString (OpID eventStamp) =
    let
        nodeString =
            NodeID.toString <| eventStamp.origin

        timeString =
            String.fromInt (Moment.toSmartInt eventStamp.time)
    in
    nodeString ++ "+" ++ timeString


fromString : String -> Maybe OpID
fromString input =
    case String.split "+" input of
        [ node, time ] ->
            Debug.todo "get opID out of string"

        _ ->
            Nothing


codec : Codec (RS.Error e) OpID
codec =
    let
        to =
            toString

        from inputString =
            Result.fromMaybe RS.DataCorrupted (fromString inputString)
    in
    RS.mapValid from to RS.string


jsonDecoder : JD.Decoder OpID
jsonDecoder =
    let
        try string =
            case fromString string of
                Just opID ->
                    JD.succeed opID

                Nothing ->
                    JD.fail "Not a valid OpID..."
    in
    JD.andThen try JD.string


momentCodec =
    RS.int |> RS.map Moment.fromSmartInt Moment.toSmartInt


getEventStamp (OpID stamp) =
    stamp



--- NEW OP GENERATION


{-| Each new Op in a frame gets a new consecutive ID from this counter.
Each frame starts with the counter set to the current Moment.
Every NEW Op generated consumes one ID and increments the counter.
Every pre-existing Op generated uses the pre-existing Op ID and does not increment the counter.
-}
type NewOpCounter
    = NewOpCounter Int


{-| Reserved for passing into a function that will use a fresh counter that it has been given
-}
type alias InCounter =
    NewOpCounter


{-| Reserved for a counter that should not be used here but passed out to the next function
-}
type alias OutCounter =
    NewOpCounter
