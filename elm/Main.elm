port module Main exposing (JsonAppDatabase, Model, Msg(..), Screen(..), ViewState, appDataFromJson, appDataToJson, buildModel, defaultView, emptyViewState, infoFooter, init, main, setStorage, subscriptions, testMsg, update, updateWithStorage, updateWithTime, view, viewUrl)

import AppData exposing (..)
import Browser
import Browser.Dom as Dom
import Browser.Events
import Browser.Navigation as Nav exposing (..)
import Environment exposing (..)
import External.Commands exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode
import Task as Job
import Task.Progress exposing (..)
import Task.TaskMoment exposing (..)
import TaskList
import Time
import TimeTracker exposing (..)
import Url
import Url.Parser as P exposing ((</>), Parser, int, map, oneOf, s, string)
import Url.Parser.Query as PQ


main : Program (Maybe JsonAppDatabase) Model Msg
main =
    Browser.application
        { init = initGraphical
        , view = view
        , update = updateWithTime
        , subscriptions = subscriptions
        , onUrlChange = NewUrl
        , onUrlRequest = Link
        }


subscriptions : Model -> Sub Msg
subscriptions ({ appData, environment } as model) =
    Sub.batch
        [ -- TODO unsubscribe when not visible
          -- TODO sync subscription with current activity
          Time.every (60 * 1000) (Tock NoOp)
        , Browser.Events.onVisibilityChange (\_ -> Tick NoOp)
        ]


port setStorage : JsonAppDatabase -> Cmd msg


{-| We want to `setStorage` on every update. This function adds the setStorage
command for every step of the update function.
-}
updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            update msg model
    in
    ( newModel
    , Cmd.batch [ setStorage (appDataToJson newModel.appData), cmds ]
    )


{-| Slips in before the real `update` function to pass in the current time.

For bookkeeping purposes, we want the current time for pretty much every update. This function intercepts the `update` process by first updating our model's `time` field before passing our Msg along to the real `update` function, which can then assume `model.time` is an up-to-date value.

(Since Elm is pure and Time is side-effect-y, there's no better way to do this.)
<https://stackoverflow.com/a/41025989/8645412>

-}
updateWithTime : Msg -> Model -> ( Model, Cmd Msg )
updateWithTime msg ({ environment } as model) =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        -- first get the current time
        Tick submsg ->
            ( model
            , Job.perform (Tock submsg) Time.now
            )

        -- actually do the update
        Tock submsg time ->
            let
                newEnv =
                    { environment | time = time }
            in
            updateWithStorage submsg { model | environment = newEnv }

        SetZoneAndTime zone time ->
            -- The only time we ever need to fetch the zone is at the start, and that's also when we need the time, so we combine them to reduce initial updates - this saves us one
            let
                newEnv =
                    { environment | time = time, timeZone = zone }
            in
            -- no need to run updateWithStorage yet - on first run we do the first update anyway, with the passed in Msg, so skipping it here saves us another update with a storage write
            ( { model | environment = newEnv }, Cmd.none )

        -- intercept normal update
        otherMsg ->
            updateWithTime (Tick msg) model


initGraphical : Maybe JsonAppDatabase -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
initGraphical maybeJson url key =
    init maybeJson url (Just key)


init : Maybe JsonAppDatabase -> Url.Url -> Maybe Nav.Key -> ( Model, Cmd Msg )
init maybeJson url maybeKey =
    let
        startingModel =
            case maybeJson of
                Just jsonAppDatabase ->
                    case appDataFromJson jsonAppDatabase of
                        Success savedAppData ->
                            buildModel savedAppData url maybeKey

                        WithWarnings warnings savedAppData ->
                            buildModel (AppData.saveWarnings savedAppData warnings) url maybeKey

                        Errors errors ->
                            buildModel (AppData.saveErrors AppData.fromScratch errors) url maybeKey

                        BadJson ->
                            buildModel AppData.fromScratch url maybeKey

                -- no json stored at all
                Nothing ->
                    buildModel AppData.fromScratch url maybeKey

        ( modelWithFirstUpdate, firstEffects ) =
            updateWithTime (NewUrl url) startingModel

        effects =
            [ Job.perform identity (Job.map2 SetZoneAndTime Time.here Time.now) -- reduces initial calls to update
            , firstEffects
            ]
    in
    ( modelWithFirstUpdate
    , Cmd.batch effects
    )



--            MM    MM  OOOOO  DDDDD   EEEEEEE LL
--            MMM  MMM OO   OO DD  DD  EE      LL
--            MM MM MM OO   OO DD   DD EEEEE   LL
--            MM    MM OO   OO DD   DD EE      LL
--            MM    MM  OOOO0  DDDDDD  EEEEEEE LLLLLLL


{-| Our whole app's Model.
Intentionally minimal - we originally went with the common elm habit of stuffing any and all kinds of 'state' into the model, but we find it cleaner to separate the _"real" state_ (transient stuff, e.g. "dialog box is open", all stored in the page's URL (`viewState`)) from _"application data"_ (e.g. "task is due thursday", all stored in App "Database").
-}
type alias Model =
    { viewState : ViewState
    , appData : AppData
    , environment : Environment
    }


buildModel : AppData -> Url.Url -> Maybe Nav.Key -> Model
buildModel appData url maybeKey =
    { viewState = viewUrl url
    , appData = appData
    , environment = Environment.preInit maybeKey
    }


type alias JsonAppDatabase =
    String


appDataFromJson : JsonAppDatabase -> DecodeResult AppData
appDataFromJson incomingJson =
    Decode.decodeString decodeAppData incomingJson


appDataToJson : AppData -> JsonAppDatabase
appDataToJson appData =
    Encode.encode 0 (encodeAppData appData)


type alias ViewState =
    { primaryView : Screen
    , uid : Int
    }


emptyViewState : ViewState
emptyViewState =
    { primaryView = TimeTracker TimeTracker.defaultView
    , uid = 0
    }


type Screen
    = TaskList TaskList.ViewState
    | TimeTracker TimeTracker.ViewState
    | Calendar
    | Features
    | Preferences


screenToViewState : Screen -> ViewState
screenToViewState screen =
    { primaryView = screen, uid = 0 }



--            :::     ::: ::::::::::: :::::::::: :::       :::
--            :+:     :+:     :+:     :+:        :+:       :+:
--            +:+     +:+     +:+     +:+        +:+       +:+
--            +#+     +:+     +#+     +#++:++#   +#+  +:+  +#+
--             +#+   +#+      +#+     +#+        +#+ +#+#+ +#+
--              #+#+#+#       #+#     #+#         #+#+# #+#+#
--                ###     ########### ##########   ###   ###


defaultView : ViewState
defaultView =
    ViewState (TimeTracker TimeTracker.defaultView) 0


view : Model -> Browser.Document Msg
view { viewState, appData, environment } =
    if environment.time == Time.millisToPosix 0 then
        { title = "Loading..."
        , body = [ toUnstyled (H.map (\_ -> NoOp) (text "Loading")) ]
        }

    else
        case viewState.primaryView of
            TaskList subState ->
                { title = "Docket - Task List"
                , body =
                    List.map toUnstyled
                        [ H.map TaskListMsg (TaskList.view subState appData environment)
                        , infoFooter
                        , errorList appData.errors
                        ]
                }

            TimeTracker subState ->
                { title = "Docket Time Tracker"
                , body =
                    List.map toUnstyled
                        [ H.map TimeTrackerMsg (TimeTracker.view subState appData environment)
                        , infoFooter
                        , errorList appData.errors
                        ]
                }

            _ ->
                { title = "TODO Some other page"
                , body = List.map toUnstyled [ infoFooter ]
                }



-- myStyle = (style, "color:red")
--
-- div [(att1, "hi"), (att2, "yo"), (myStyle completion)] [nodes]
--
-- <div att1="hi" att2="yo">nodes</div>


infoFooter : Html Msg
infoFooter =
    footer [ class "info" ]
        [ p [] [ text "Here we go! Deployment is instant now!" ]
        , p []
            [ text "Written by "
            , a [ href "https://github.com/Erudition" ] [ text "Erudition" ]
            ]
        , p []
            [ text "(Increasingly more distant) fork of Evan's elm "
            , a [ href "http://todomvc.com" ] [ text "TodoMVC" ]
            ]
        ]


errorList : List String -> Html Msg
errorList stringList =
    let
        asLi desc =
            li [ onClick ClearErrors ] [ text desc ]
    in
    ol [] (List.map asLi stringList)



-- type Phrase = Written_by
--             | Double_click_to_edit_a_task
-- say : Phrase -> Language -> String
-- say phrase language =
--     ""
--             _   _ ______ ______   ___   _____  _____
--            | | | || ___ \|  _  \ / _ \ |_   _||  ___|
--            | | | || |_/ /| | | |/ /_\ \  | |  | |__
--            | | | ||  __/ | | | ||  _  |  | |  |  __|
--            | |_| || |    | |/ / | | | |  | |  | |___
--             \___/ \_|    |___/  \_| |_/  \_/  \____/


{-| Users of our app can trigger messages by clicking and typing. These
messages are fed into the `update` function as they occur, letting us react
to them.
-}
type Msg
    = NoOp
    | Tick Msg
    | Tock Msg Time.Posix
    | SetZoneAndTime Time.Zone Time.Posix
    | ClearErrors
    | Link Browser.UrlRequest
    | NewUrl Url.Url
    | TaskListMsg TaskList.Msg
    | TimeTrackerMsg TimeTracker.Msg



-- How we update our Model on a given Msg?


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ viewState, appData, environment } as model) =
    let
        justRunCommand command =
            ( model, command )

        justSetEnv newEnv =
            ( Model viewState appData newEnv, Cmd.none )
    in
    case ( msg, viewState.primaryView ) of
        ( ClearErrors, _ ) ->
            ( Model viewState { appData | errors = [] } environment, Cmd.none )

        ( Link urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    case environment.navkey of
                        Just navkey ->
                            -- in browser
                            justRunCommand <| Nav.pushUrl navkey (Url.toString url)

                        Nothing ->
                            -- running headless
                            ( model, Cmd.none )

                Browser.External href ->
                    justRunCommand <| Nav.load href

        -- TODO done!
        ( NewUrl url, _ ) ->
            let
                ( modelAfter, effectsAfter ) =
                    handleUrlTriggers url model

                -- effectsAfterDebug =External.Commands.toast ("got NewUrl: " ++ Url.toString url)
            in
            ( { modelAfter | viewState = viewUrl url }, effectsAfter )

        ( TaskListMsg subMsg, TaskList subViewState ) ->
            let
                ( newState, newApp, newCommand ) =
                    TaskList.update subMsg subViewState appData environment
            in
            ( Model (ViewState (TaskList newState) 0) newApp environment, Cmd.map TaskListMsg newCommand )

        ( TimeTrackerMsg subMsg, TimeTracker subViewState ) ->
            let
                ( newState, newApp, newCommand ) =
                    TimeTracker.update subMsg subViewState appData environment
            in
            ( Model (ViewState (TimeTracker newState) 0) newApp environment, Cmd.map TimeTrackerMsg newCommand )

        ( _, _ ) ->
            ( model, Cmd.none )



-- PARSER


{-| This dense function lets us pretend we have a server redirecting sub-urls (like app/task/57) to our app, even when we don't (like when running as a simple local file). Simply insert a "#" in the address bar, right before the path that gets passed into our app (inc. query&fragment) and this function will make it disappear before our app parses its url.

Example: `http://localhost:8000/www/index.html#/sub/path?hey=there#yo`

is normally parsed as
`url: { fragment = Just "/sub/path?hey=there#yo", host = "localhost", path = "/www/index.html", port_ = Just 8000, protocol = Http, query = Nothing }`

but with this function we can pretend it was:
`url: { fragment = Just "yo", host = "localhost", path = "/www/index.html/sub/path", port_ = Just 8000, protocol = Http, query = Just "hey=there" }`

even though that path may have resulted in a 404 on any host without fancy redirection set up (such as the development environment). Sweet!

-}
bypassFakeFragment : Url.Url -> Url.Url
bypassFakeFragment url =
    case Maybe.map String.uncons url.fragment of
        -- only if "#" is immediately followed by a "/" (path)
        Just (Just ( '/', fakeFragment )) ->
            -- take the url and drop the first "#", then re-parse it
            case String.split "#" (Url.toString url) of
                front :: _ ->
                    -- Url.fromString can fail, but it shouldn't here
                    Maybe.withDefault url <|
                        -- include all the rest (even later "#"s)
                        Url.fromString (front ++ "/" ++ fakeFragment)

                _ ->
                    url

        _ ->
            url


viewUrl : Url.Url -> ViewState
viewUrl url =
    let
        finalUrl =
            bypassFakeFragment url
    in
    Maybe.withDefault defaultView (P.parse routeParser finalUrl)


routeParser : Parser (ViewState -> a) a
routeParser =
    let
        wrapScreen parser =
            P.map screenToViewState parser
    in
    P.oneOf
        [ wrapScreen (P.map TaskList TaskList.routeView)
        , wrapScreen (P.map TimeTracker TimeTracker.routeView)
        ]


{-| Like an `update` function, but instead of accepting `Msg`s it works on the URL query -- to allow us to send `Msg`s from the address bar! (to the real update function). Thus our web app should be completely scriptable.
-}
handleUrlTriggers : Url.Url -> Model -> ( Model, Cmd Msg )
handleUrlTriggers rawUrl ({ appData, environment } as model) =
    -- let
    --     url =
    --         bypassFakeFragment rawUrl
    --
    --     -- so that parsers run regardless of path:
    --     normalizedUrl =
    --         { url | path = "" }
    --
    --     parsed =
    --         P.parse (P.oneOf parseList) (Debug.log "url" <| normalizedUrl)
    --
    --     parseList =
    --         List.map P.query (timeTrackerTriggers ++ taskTriggers)
    --
    --     timeTrackerTriggers =
    --         List.map (PQ.map (Maybe.map TimeTrackerMsg)) (TimeTracker.urlTriggers appData)
    --
    --     taskTriggers =
    --         []
    --
    --     --TODO only remove handled triggers
    --     removeTriggersFromUrl =
    --         case environment.navkey of
    --             Just navkey ->
    --                 -- TODO maintain Fake Fragment. currently destroys it
    --                 Nav.replaceUrl navkey (Url.toString { url | query = Nothing })
    --
    --             Nothing ->
    --                 Cmd.none
    -- in
    -- case parsed of
    --     Just (Just triggerMsg) ->
    --         -- let
    --         --     ( newModel, newCmd ) =
    --         --         update triggerMsg model
    --         --
    --         --     newCmdWithUrlCleaner =
    --         --         Cmd.batch [ newCmd, removeTriggersFromUrl ]
    --         -- in
    ( model
      -- newModel
    , External.Commands.toast "I'm inside handleUrlTriggers!"
      -- newCmdWithUrlCleaner
    )



--
-- _ ->
--     ( model, Cmd.none )


nerfUrl : Url.Url -> Url.Url
nerfUrl original =
    { original | path = "" }


testMsg : Msg
testMsg =
    TimeTrackerMsg TimeTracker.testMsg
