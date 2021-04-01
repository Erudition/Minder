module Replicated.Replica exposing (..)

import Dict exposing (Dict)
import Replicated.Atom exposing (..)
import Replicated.Identifier as Identifier exposing (..)
import Replicated.Object exposing (Object)
import Replicated.Op exposing (Op)
import Replicated.Reducer.Record as RR exposing (Record)
import Replicated.Serialize as RS exposing (Codec)
import Replicated.Value exposing (Value)
import Set exposing (Set)
import SmartTime.Moment as Moment


type alias ReducerNameString =
    String


type alias ObjectID =
    String



-- REPLICA - Represents this one instance in the user's network of instances, with its own ID and log of ops.


applyOpToDb : ReplicaDb -> Op -> ReplicaDb
applyOpToDb previous newOp =
    let
        insertObjectByCreation oBCDict =
            Just <| Dict.update newOp.specifier.object.creation insertObjectEvent (Maybe.withDefault Dict.empty oBCDict)

        insertObjectEvent eventDict =
            Just <| Dict.insert eventString newOp.payload (Maybe.withDefault Dict.empty eventDict)
    in
    Dict.update newOp.specifier.object.reducer insertObjectByCreation previous


type alias ReplicaDb =
    Dict ReducerNameString ObjectsByCreationDb


type alias ObjectsByCreationDb =
    Dict ObjectID Object


objectsByCreationCodec : Codec e ObjectsByCreationDb
objectsByCreationCodec =
    RS.dict RS.string objectEventsCodec


type alias ObjectEvents =
    Dict EventString Payload


objectEventsCodec : Codec e ObjectEvents
objectEventsCodec =
    RS.dict RS.string RS.string


type alias EventString =
    String


type alias EventStrings =
    ( String, String, String )


type alias Replica =
    { identity : ReplicaID, peers : List Peer, db : ReplicaDb }


buildReplica : Value -> Result (RS.Error e) Replica
buildReplica inputDatabase =
    let
        lastSeenSessionID =
            -- TODO "filter ops by this client and determine highest session id"
            1

        newSessionID =
            SessionID (lastSeenSessionID + 1)
    in
    Replicated.Value.decode replicaCodec inputDatabase


replicaCodec : RS.Codec e Replica
replicaCodec =
    RS.record Replica
        |> RS.field .identity replicaIDCodec
        |> RS.field .peers (RS.list peerCodec)
        |> RS.field .db (RS.dict RS.string objectsByCreationCodec)
        |> RS.finishRecord



-- PEER


type alias Peer =
    { identity : ReplicaID }


peerCodec : Codec e Peer
peerCodec =
    RS.record Peer
        |> RS.field .identity replicaIDCodec
        |> RS.finishRecord
