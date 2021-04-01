module Replicated.Event exposing (..)

import Replicated.Identifier as Identifier
import Replicated.Serialize as RS exposing (Codec)
import SmartTime.Moment as Moment exposing (Moment)


{-| Unparsed information about an event within a known object.
-}
type alias ID =
    String


eventIDlj7 eventString =
    let
        momentCodec =
            RS.int |> RS.map Moment.fromSmartInt Moment.toSmartInt
    in
    RS.decodeFromString (RS.triple momentCodec Identifier.replicaIDCodec RS.string) eventString


type alias Payload =
    String


type alias Reference =
    ID


type Event
    = Event
        { time : Moment
        , origin : Identifier.ReplicaID
        , reference : Reference
        , payload : Payload
        }


build : ( Moment, Identifier.ReplicaID, Reference ) -> Payload -> Event
build ( time, place, reference ) payload =
    Event
        { time = time
        , origin = place
        , reference = reference
        , payload = payload
        }


generateEvent =
    Debug.todo "make an event from scratch"
