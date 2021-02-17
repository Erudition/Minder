module Replicated.Atom exposing (..)

import Set exposing (Set)


type RonUUID
    = SpecialNamed NameVariety String -- "human-friendly string constants"
    | NumberOrHash NumberOrHashVariety String
    | Event UUID
    | DerivedEvent UUID


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


type alias UUID =
    ( OpTimestamp, OpOrigin )


type alias OpTimeStamp =
    Moment


type alias OpOrigin =
    ReplicaID


type alias ReplicaID =
    { primus : Int, peer : Int, client : Int, session : Int }


type Atom
    = IDAtom RonUUID
    | IntAtom Int
    | FloatAtom Float
    | StringAtom String


type alias Tree =
    Set Op


type alias Patch =
    List Op


type alias Chunk =
    List Op


type alias Frame =
    List Patch


type alias OpLog =
    List Frame



-- To put in other files


type alias Op =
    { reducer : RonUUID -- omitted in short (closed) form, deduced via full database
    , object : RonUUID -- omitted in short (closed) form, deduced via full database
    , operationID : RonUUID
    , reference : RonUUID
    , payload : List Atom
    }


type OpPattern
    = NormalOp
    | DeletionOp
    | UnDeletionOp
    | CreationOp
    | Acknowledgement
    | Annotation
