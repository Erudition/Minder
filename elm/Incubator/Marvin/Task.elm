module Incubator.Todoist.Item exposing (..)

import Json.Decode.Exploration exposing (..)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Encode as Encode
import Json.Encode.Extra as Encode exposing (..)
import Porting exposing (..)
import SmartTime.Duration exposing (Duration(..))
import SmartTime.Human.Calendar exposing (CalendarDate(..))
import SmartTime.Human.Calendar.Month exposing (Month(..))
import SmartTime.Human.Calendar.Year exposing (Year(..))
import SmartTime.Human.Clock exposing (TimeOfDay)
import SmartTime.Moment exposing (Moment(..))


type alias ItemID =
    Int


type alias UserID =
    Int


type alias CategoryOrProjectID =
    String


type alias LabelID =
    String


type alias CustomSectionID =
    String


type alias TimeBlockID =
    String


type alias RewardID =
    String


{-| Tasks - simplified API

// Time offset in minutes
//
// Added to time to fix time zone issues. So if the user is in Pacific time,
// this would be -8\*60. If the user added a task with +today at 22:00 local
// time 2019-12-05, then we want to create the task on 2019-12-05 and not
// 2019-12-06 (which is the server date).

-}
type alias Task =
    { done : Bool
    , day : Maybe CalendarDate
    , title : String
    , parentId : CategoryOrProjectID
    , labelIds : List LabelID
    , firstScheduled : CalendarDate
    , rank : Int
    , dailySection : String
    , bonusSection : EssentialOrBonus
    , customSection : CustomSectionID
    , timeBlockSection : TimeBlockID
    , note : String
    , dueDate : CalendarDate
    , timeEstimate : Duration
    , isReward : Bool
    , isStarred : Int
    , isFrogged : Int
    , plannedWeek : Maybe CalendarDate
    , plannedMonth : Maybe ( Year, Month )
    , rewardPoints : Float
    , rewardId : RewardID
    , backburner : Bool
    , reviewDate : CalendarDate
    , timeEstimate : Duration
    , itemSnoozeTime : Maybe Moment
    , permaSnoozeTime : Maybe TimeOfDay
    , timeZoneOffset : Int
    }


encodeTask : Task -> Encode.Value
encodeTask task =
    Encode.object <|
        [ ( "done", Encode.bool task.done )
        , ( "day", Encode.maybe encodeCalendarDate task.day )
        , ( "title", Encode.string task.title )
        , ( "parentId", Encode.string task.parentId )
        , ( "labelIds", Encode.list Encode.string task.labelIds )
        , ( "firstScheduled", encodeCalendarDate task.firstScheduled )
        , ( "rank", Encode.int task.rank )
        , ( "dailySection", Encode.string task.dailySection )
        , ( "bonusSection", encodeEssentialOrBonus task.bonusSection )
        , ( "customSection", Encode.string task.customSection )
        , ( "timeBlockSection", Encode.string task.timeBlockSection )
        , ( "note", Encode.string task.note )
        , ( "dueDate", encodeCalendarDate task.dueDate )
        , ( "timeEstimate", encodeDuration task.timeEstimate )
        , ( "isReward", Encode.bool task.isReward )
        , ( "isStarred", Encode.int task.isStarred )
        , ( "isFrogged", Encode.int task.isFrogged )
        , ( "plannedWeek", Encode.maybe encodeCalendarDate task.plannedWeek )
        , ( "plannedMonth", encodeMonth task.plannedMonth )
        , ( "rewardPoints", Encode.float task.rewardPoints )
        , ( "rewardId", Encode.string task.rewardId )
        , ( "backburner", Encode.bool task.backburner )
        , ( "reviewDate", encodeCalendarDate task.reviewDate )
        , ( "itemSnoozeTime", Encode.maybe encodeMoment task.itemSnoozeTime )
        , ( "permaSnoozeTime", Encode.maybe encodeTimeOfDay task.permaSnoozeTime )
        , ( "timeZoneOffset", Encode.int task.timeZoneOffset )
        ]


decodeTask : Decoder Task
decodeTask =
    succeed Task
        |> required "done" bool
        |> required "day" (nullable calendarDateDecoder)
        |> required "title" string
        |> required "parentId" string
        |> required "labelIds" (list string)
        |> required "firstScheduled" calendarDateDecoder
        |> required "rank" int
        |> required "dailySection" string
        |> required "bonusSection" essentialOrBonusDecoder
        |> required "customSection" string
        |> required "timeBlockSection" string
        |> required "note" string
        |> required "dueDate" calendarDateDecoder
        |> required "timeEstimate" decodeDuration
        |> required "isReward" bool
        |> required "isStarred" int
        |> required "isFrogged" int
        |> required "plannedWeek" (nullable calendarDateDecoder)
        |> required "plannedMonth" (nullable monthDecoder)
        |> required "rewardPoints" float
        |> required "rewardId" string
        |> required "backburner" bool
        |> required "reviewDate" calendarDateDecoder
        |> required "itemSnoozeTime" (nullable decodeMoment)
        |> required "permaSnoozeTime" (nullable timeOfDayDecoder)
        |> required "timeZoneOffset" int


encodeCalendarDate : CalendarDate -> Encode.Value
encodeCalendarDate date =
    Encode.string <| SmartTime.Human.Calendar.toStandardString date


calendarDateDecoder : Decoder CalendarDate
calendarDateDecoder =
    customDecoder string SmartTime.Human.Calendar.fromNumberString


type EssentialOrBonus
    = Essential
    | Bonus


encodeEssentialOrBonus : EssentialOrBonus -> Encode.Value
encodeEssentialOrBonus essentialOrBonus =
    case essentialOrBonus of
        Essential ->
            Encode.string "Essential"

        Bonus ->
            Encode.string "Bonus"


essentialOrBonusDecoder : Decoder EssentialOrBonus
essentialOrBonusDecoder =
    let
        get id =
            case id of
                "Essential" ->
                    succeed Essential

                "Bonus" ->
                    succeed Bonus

                _ ->
                    fail ("unknown value for EssentialOrBonus: " ++ id)
    in
    string |> andThen get


encodeMonth : Maybe ( Year, Month ) -> Encode.Value
encodeMonth maybeMonth =
    case maybeMonth of
        Just ( year, month ) ->
            Encode.string (SmartTime.Human.Calendar.Year.toString year ++ (String.fromInt <| SmartTime.Human.Calendar.Month.toInt month))

        Nothing ->
            Encode.null


monthDecoder : Decoder ( Year, Month )
monthDecoder =
    let
        fakeDate twoPartString =
            SmartTime.Human.Calendar.fromNumberString (twoPartString ++ "-01")

        toYearAndMonth date =
            ( SmartTime.Human.Calendar.year date, SmartTime.Human.Calendar.month date )

        output input =
            Result.map toYearAndMonth (fakeDate input)
    in
    customDecoder string output


encodeTimeOfDay : TimeOfDay -> Encode.Value
encodeTimeOfDay clock =
    Encode.string <| SmartTime.Human.Clock.toStandardString clock


timeOfDayDecoder : Decoder TimeOfDay
timeOfDayDecoder =
    customDecoder string SmartTime.Human.Clock.fromStandardString
