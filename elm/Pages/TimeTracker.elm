module Pages.TimeTracker exposing (Model, Msg, page)

import Activity.Activity as Activity exposing (..)
import Activity.HistorySession as Timeline exposing (HistorySession, Timeline)
import Activity.Template
import Browser
import Browser.Dom
import Css exposing (..)
import Date
import Dict
import Effect exposing (Effect)
import Helpers exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Html.Styled.Keyed as Keyed
import Html.Styled.Lazy exposing (..)
import ID
import Incubator.IntDict.Extra as IntDict
import IntDict
import Json.Decode as OldDecode
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Page exposing (Page)
import Profile exposing (..)
import Refocus
import Replicated.Change as Change exposing (ChangeSet)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Route exposing (Route)
import Shared
import Shared.Model
import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Clock as Clock exposing (TimeOfDay)
import SmartTime.Human.Duration as HumanDuration exposing (..)
import SmartTime.Human.Moment as HumanMoment
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period exposing (Period)
import Task as Job
import Task.Layers
import Time
import TimeTrackable exposing (TimeTrackable)
import Url.Parser as P exposing ((</>), (<?>), Parser, fragment, int, map, oneOf, s, string)
import Url.Parser.Query as PQ
import View exposing (View)
import VirtualDom
import VitePluginHelper


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update shared
        , subscriptions = subscriptions
        , view = view shared route
        }



-- INIT


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init () =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = NoOp
    | StartTracking ActivityID
    | ExportVM


update : Shared.Model.Model -> Msg -> Model -> ( Model, Effect Msg )
update shared msg model =
    case msg of
        NoOp ->
            ( model
            , Effect.none
            )

        StartTracking activityId ->
            let
                projectLayers =
                    Task.Layers.buildLayerDatabase shared.replica.projects

                newTrackable =
                    TimeTrackable.TrackedActivityID activityId

                switchEffects =
                    Refocus.switchActivity newTrackable shared.replica projectLayers ( shared.time, shared.timeZone )
            in
            ( model
            , switchEffects
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Shared.Model.Model -> Route () -> Model -> View Msg
view shared route model =
    { title = "Time Tracker"
    , body =
        [ section
            [ class "activity-screen" ]
            [ lazy2 viewActivities ( shared.time, shared.timeZone ) shared.replica
            ]
        , section [ css [ opacity (num 0.1) ] ]
            [ text "Quite Ambitious."
            ]
        ]
    }


viewActivities : ( Moment, HumanMoment.Zone ) -> Profile -> Html Msg
viewActivities ( time, timeZone ) app =
    section
        [ class "main" ]
        [ ul [ class "activity-list" ] <|
            List.map (viewActivity app ( time, timeZone )) (Activity.allUnhidden app.activities)
        ]


viewActivity : Profile -> ( Moment, HumanMoment.Zone ) -> Activity -> Html Msg
viewActivity app ( time, timeZone ) activity =
    let
        describePeriod sesh =
            Timeline.inHoursMinutes (Period.length sesh) ++ "\n"

        filterPeriod =
            Period.between Moment.zero time

        trackingFlipID =
            if Profile.currentActivityID app == Activity.getID activity then
                attribute "data-flip-key" "current"

            else
                class "not-current"
    in
    li
        [ class "activity" ]
        [ button
            [ class "activity-button"
            , classList [ ( "current", Profile.currentActivityID app == Activity.getID activity ) ]
            , onClick (StartTracking (Activity.getID activity))
            , trackingFlipID
            , title <| List.foldl (++) "" (List.map describePeriod (Timeline.periodsOfActivity filterPeriod (RepList.listValues app.timeline) (Activity.getID activity)))
            ]
            [ viewIcon (Activity.getIcon activity)
            , div []
                [ text (writeActivityUsage app ( time, timeZone ) activity)
                ]
            , div []
                [ text (writeActivityToday app ( time, timeZone ) activity)
                ]
            , label
                []
                [ text (Activity.getName activity)
                ]
            ]
        ]


writeTime : Shared.Model.Model -> String
writeTime env =
    let
        nowClock =
            HumanMoment.extractTime env.timeZone env.time
    in
    String.fromInt (Clock.hour nowClock) ++ ":" ++ String.fromInt (Clock.minute nowClock)


viewIcon : Activity.Icon -> Html Msg
viewIcon getIcon =
    case getIcon of
        File svgPath ->
            img
                [ class "activity-icon"
                , src ("/media/icons/" ++ svgPath)
                , css [ Css.float left ]
                ]
                []

        Ion ->
            text ""

        Other ->
            text ""

        Emoji singleEmoji ->
            text singleEmoji


writeActivityUsage : Profile -> ( Moment, HumanMoment.Zone ) -> Activity -> String
writeActivityUsage app ( time, timeZone ) activity =
    let
        maxTimeDenominator =
            Tuple.second (Activity.getMaxTimePortion activity)

        lastPeriod =
            Period.fromEnd time maxTimeDenominator

        total =
            Timeline.activityTotalDuration lastPeriod (RepList.listValues app.timeline) (Activity.getID activity)

        totalMinutes =
            Duration.inMinutesRounded total
    in
    if inMs total > 0 then
        String.fromInt totalMinutes ++ "/" ++ String.fromInt (inMinutesRounded maxTimeDenominator) ++ "m"

    else
        ""


writeActivityToday : Profile -> ( Moment, HumanMoment.Zone ) -> Activity -> String
writeActivityToday app ( time, timeZone ) activity =
    Timeline.inHoursMinutes (Timeline.justTodayTotal (RepList.listValues app.timeline) ( time, timeZone ) (Activity.getID activity))
