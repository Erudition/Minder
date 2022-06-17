module Replicated.Op.OpID exposing (EventStamp, InCounter, ObjectID, ObjectIDString, ObjectVersion, OpID, OpIDString, OutCounter, exportCounter, firstCounterOfFrame, fromString, fromStringForced, generate, highestCounter, importCounter, isIncremental, isReversion, jsonDecoder, latest, nextGenCounter, nextOpInChain, parser, toPointerString, toStamp, toString, unusedCounter)

import Json.Decode as JD
import Parser exposing ((|.), (|=), Parser, float, spaces, succeed, symbol)
import Replicated.Node.NodeID as NodeID exposing (NodeID)
import Replicated.Serialize as RS exposing (Codec)
import SmartTime.Moment as Moment exposing (Moment)


type OpID
    = OpID String


type alias ObjectID =
    OpID


type alias ObjectVersion =
    OpID


type alias ObjectIDString =
    String


type alias OpIDString =
    String


type alias OpClock =
    Int


type alias OpOrigin =
    NodeID


type alias EventStamp =
    { clock : OpClock
    , origin : NodeID
    , reversion : Bool
    }


isReversion : OpID -> Bool
isReversion input =
    (toStamp input).reversion


highestCounter : NewOpCounter -> NewOpCounter -> NewOpCounter
highestCounter (NewOpCounter c1) (NewOpCounter c2) =
    NewOpCounter (max c1 c2)


firstCounterOfFrame : Moment -> NewOpCounter
firstCounterOfFrame time =
    NewOpCounter (Moment.toSmartInt time)


unusedCounter : NewOpCounter
unusedCounter =
    NewOpCounter 0


generate : InCounter -> NodeID -> Bool -> ( OpID, OutCounter )
generate (NewOpCounter counter) origin reversion =
    ( fromStamp { clock = counter, origin = origin, reversion = reversion }, NewOpCounter (counter + 1) )


toString : OpID -> OpIDString
toString (OpID string) =
    string


toPointerString : OpID -> String
toPointerString (OpID string) =
    ">" ++ string


parser : Parser OpID
parser =
    Parser.map OpID <|
        Parser.getChompedString <|
            succeed ()
                -- |= Parser.chompWhile (\s -> s /= "+" && s /= "-")
                |. Parser.chompWhile (\char -> char /= ' ' && char /= '\t' && char /= '\u{000D}')


fromStamp : EventStamp -> OpID
fromStamp eventStamp =
    let
        nodeString =
            NodeID.toString <| eventStamp.origin

        clockString =
            String.fromInt eventStamp.clock

        separator =
            if eventStamp.reversion then
                "-"

            else
                "+"
    in
    OpID (clockString ++ separator ++ nodeString)


fromString : String -> Maybe OpID
fromString input =
    case ( String.split "+" input, String.split "-" input ) of
        ( [ clockString, nodeIDString ], _ ) ->
            case ( NodeID.fromString nodeIDString, String.toInt clockString ) of
                ( Just nodeID, Just clock ) ->
                    Just (OpID input)

                ( Just nodeID, Nothing ) ->
                    Debug.todo ("OpID from string failed to figure out a moment from input " ++ input)

                ( Nothing, _ ) ->
                    Debug.todo ("OpID from string failed to figure out a nodeID from input " ++ input)

        ( _, [ clockString, nodeIDString ] ) ->
            case ( NodeID.fromString nodeIDString, Maybe.map Moment.fromSmartInt (String.toInt clockString) ) of
                ( Just nodeID, Just clock ) ->
                    Just (OpID input)

                _ ->
                    Nothing

        _ ->
            Nothing


toStamp : OpID -> EventStamp
toStamp (OpID input) =
    case ( String.split "+" input, String.split "-" input ) of
        ( [ clockString, nodeIDString ], _ ) ->
            case ( NodeID.fromString nodeIDString, String.toInt clockString ) of
                ( Just nodeID, Just clock ) ->
                    EventStamp clock nodeID False

                _ ->
                    Debug.todo ("Something went wrong parsing OpID " ++ input ++ " into an event stamp! found clockString+nodeIDString format though")

        ( _, [ clockString, nodeIDString ] ) ->
            case ( NodeID.fromString nodeIDString, String.toInt clockString ) of
                ( Just nodeID, Just clock ) ->
                    EventStamp clock nodeID True

                _ ->
                    Debug.todo ("Something went wrong parsing OpID " ++ input ++ " into an event stamp! found clockString-nodeIDString format though")

        _ ->
            Debug.todo ("Something went wrong parsing OpID " ++ input ++ " into an event stamp! couldn't split based on plus or minus...")


fromStringForced : String -> OpID
fromStringForced string =
    OpID string


jsonDecoder : JD.Decoder OpID
jsonDecoder =
    let
        try string =
            case fromString string of
                Just opID ->
                    JD.succeed opID

                Nothing ->
                    JD.fail (string ++ " is not a valid OpID...")
    in
    JD.andThen try JD.string


momentCodec =
    RS.int |> RS.map Moment.fromSmartInt Moment.toSmartInt


nextOpInChain : OpID -> OpID
nextOpInChain input =
    let
        inputStamp =
            toStamp input

        outputStamp =
            { inputStamp | clock = inputStamp.clock + 1 }
    in
    fromStamp outputStamp


isIncremental : OpID -> OpID -> Bool
isIncremental id1 id2 =
    (toStamp id2).clock == ((toStamp id1).clock + 1)



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


nextGenCounter : InCounter -> InCounter
nextGenCounter (NewOpCounter int) =
    NewOpCounter (int + 100)


{-| Determine which OpID is newer and return the newest one.
-}
latest : OpID -> OpID -> OpID
latest firstID secondID =
    case compare (toStamp firstID).clock (toStamp secondID).clock of
        GT ->
            firstID

        _ ->
            secondID


importCounter : Int -> InCounter
importCounter int =
    NewOpCounter int


exportCounter : InCounter -> Int
exportCounter (NewOpCounter int) =
    int
