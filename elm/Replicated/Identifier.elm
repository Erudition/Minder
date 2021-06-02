module Replicated.Identifier exposing (..)

import Replicated.Serialize as RS
import SmartTime.Moment as Moment exposing (Moment)


type alias ObjectID =
    String


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
    NodeID


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


type alias ReducerID =
    String


type alias EventStamp =
    { time : Moment
    , origin : NodeID
    }


eventStampToObjectID : EventStamp -> ObjectID
eventStampToObjectID stamp =
    String.fromInt (Moment.toSmartInt stamp.time) ++ "+" ++ nodeIDToString stamp.origin


objectIDFromCounter : NodeID -> Int -> ObjectID
objectIDFromCounter nodeID counter =
    eventStampToObjectID (EventStamp (Moment.fromSmartInt counter) nodeID)


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
