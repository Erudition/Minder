port module Docket exposing (init, main, setStorage, subscriptions, updateWithStorage, updateWithTime)

-- core libraries
--community libraries
--import Time.DateTime as Moment exposing (DateTime, dateTime, year, month, day, hour, minute, second, millisecond)
--import Time.TimeZones as TimeZones
--import Time.ZonedDateTime as LocalMoment exposing (ZonedDateTime)
-- ours

import Html.Styled exposing (..)
import Model exposing (..)
import Task as Job
import Time
import Update exposing (..)
import View exposing (..)



{--IMPORT HANDLING
    Section where we massage imports to be the way we like
--}


main : Program (Maybe ModelAsJson) Model Msg
main =
    Html.Styled.programWithFlags
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every Time.minute MinutePassed


port setStorage : ModelAsJson -> Cmd msg


{-| We want to `setStorage` on every update. This function adds the setStorage
command for every step of the update function.
-}
updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            updateWithTime msg model
    in
    ( newModel
    , Cmd.batch [ setStorage (modelToJson newModel), cmds ]
    )


{-| Slips in before the real `update` function to pass in the current time.

For bookkeeping purposes, we want the current time for pretty much every update. This function intercepts the `update` process by first updating our model's `time` field before passing our Msg along to the real `update` function, which can then assume `model.time` is an up-to-date value.

(Since Elm is pure and Time is side-effect-y, there's no better way to do this.)
<https://stackoverflow.com/a/41025989/8645412>

-}
updateWithTime : Msg -> Model -> ( Model, Cmd Msg )
updateWithTime msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        Tick msg ->
            ( model
            , Job.perform (Tock msg) Time.now
            )

        Tock msg time ->
            update msg { model | updateTime = time }

        otherMsg ->
            updateWithTime (Tick msg) model



-- MODEL
-- The full application state of our todo app.
-- Entire program
-- initialize model


init : Maybe ModelAsJson -> ( Model, Cmd Msg )
init maybeModelAsJson =
    let
        startingModel =
            case maybeModelAsJson of
                Just modelAsJson ->
                    case modelFromJson modelAsJson of
                        Ok restoredModel ->
                            restoredModel

                        Err errormsg ->
                            { emptyModel | errors = [ Debug.log "Errors" errormsg ] }

                -- no json stored at all
                Nothing ->
                    emptyModel

        effects =
            [ Job.perform MinutePassed Time.now ]
    in
    ( startingModel
    , Cmd.batch effects
    )
