port module Docket exposing (..)

-- core libraries
--community libraries
--import Time.DateTime as Moment exposing (DateTime, dateTime, year, month, day, hour, minute, second, millisecond)
--import Time.TimeZones as TimeZones
--import Time.ZonedDateTime as LocalMoment exposing (ZonedDateTime)
-- ours

import Html.Styled exposing (..)
import Model exposing (..)
import Porting exposing (..)
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
        , subscriptions = \_ -> Sub.none
        }



-- main : Program Model Msg
-- main =
--     Html.program
--         { init = init
--         , view = view
--         , update = update
--         , subscriptions = \_ -> Sub.none
--         }


port setStorage : ModelAsJson -> Cmd msg


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
    , Cmd.batch [ setStorage (modelToJson newModel), cmds ]
    )



-- MODEL
-- The full application state of our todo app.
-- Entire program
-- initialize model


init : Maybe ModelAsJson -> ( Model, Cmd Msg )
init maybeModelAsJson =
    let
        finalModel =
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
    in
    finalModel ! []
