module Replicated.Op.OpID exposing (NewOpCounter, OpID)

import Replicated.Node.NodeID exposing (NodeID)
import SmartTime.Moment as Moment exposing (Moment)


type OpID
    = OpID EventStamp


type alias ObjectID =
    OpID


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


newOpID : NewOpCounter -> NodeID -> OpID
newOpID (NewOpCounter counter) origin =
    OpID { time = Moment.fromSmartInt counter, origin = origin }


eventStampToObjectID : EventStamp -> ObjectID
eventStampToObjectID stamp =
    String.fromInt (Moment.toSmartInt stamp.time) ++ "+" ++ nodeIDToString stamp.origin


objectIDFromCounter : NodeID -> NewOpCounter -> ObjectID
objectIDFromCounter nodeID counter =
    eventStampToObjectID (EventStamp (Moment.fromSmartInt (NewOpCounter.read counter)) nodeID)


objectIDtoEventStamp : ObjectID -> Maybe EventStamp
objectIDtoEventStamp objectID =
    case String.split "+" objectID of
        [ time, origin ] ->
            case ( Maybe.map Moment.fromSmartInt (String.toInt time), nodeIDFromString origin ) of
                ( Just moment, Just nodeID ) ->
                    Just (EventStamp moment nodeID)

                _ ->
                    Nothing

        _ ->
            Nothing


momentCodec =
    RS.int |> RS.map Moment.fromSmartInt Moment.toSmartInt



--- NEW OP GENERATION


{-| Each new Op in a frame gets a new consecutive ID from this counter.
Each frame starts with the counter set to the current Moment.
Every NEW Op generated consumes one ID and increments the counter.
Every pre-existing Op generated uses the pre-existing Op ID and does not increment the counter.
-}
type NewOpCounter
    = NewOpCounter Int


{-| After generating an OpID using a counter, generate the next one for later use.
-}
next : NewOpCounter -> NewOpCounter
next (NewOpCounter givenCounterInt) =
    NewOpCounter (givenCounterInt + 1)
