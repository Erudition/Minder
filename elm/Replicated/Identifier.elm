module Replicated.Identifier exposing (..)

import Replicated.Serialize as RS
import SmartTime.Moment as Moment exposing (Moment)


type RonUUID
    = SpecialNamed NameVariety String -- "human-friendly string constants"
    | NumberOrHash NumberOrHashVariety String
    | Event EventStamp
    | DerivedEvent EventStamp


type NameVariety
    = Hardcoded
    | ISBN
    | EAN13
    | SIunits
    | PostalCode
    | IATAairport
    | TickerName
    | Currency
    | ShortDNS
    | PhoneNumber
    | CountryCode


type NumberOrHashVariety
    = DecimalIndex
    | SHA2
    | SHA3
    | SHA2Merkle
    | SHA3Merkle
    | RandomNumber
    | CryptoIDorFingerprint


type alias OpTimestamp =
    Moment


type alias OpOrigin =
    ReplicaID


type alias ReplicaID =
    -- never store "session" part - generate that on every run
    { primus : Int, peer : Int, client : Int, session : SessionID }


replicaIDCodec : RS.Codec e ReplicaID
replicaIDCodec =
    RS.record ReplicaID
        |> RS.field .primus RS.int
        |> RS.field .peer RS.int
        |> RS.field .client RS.int
        |> RS.field .session sessionIDCodec
        |> RS.finishRecord


type SessionID
    = SessionID Int


sessionIDCodec : RS.Codec e SessionID
sessionIDCodec =
    RS.int |> RS.map SessionID (\(SessionID id) -> id)


type alias Reducer =
    String
