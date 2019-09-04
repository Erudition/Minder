port module Headless exposing (main)

import AppData exposing (AppData)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode
import Main exposing (..)
import Platform exposing (worker)
import Task as Job
import Time
import TimeTracker
import Url


main : Program ( String, Maybe JsonAppDatabase ) Model Msg
main =
    worker
        { init = initHeadless
        , update = updateWithTime
        , subscriptions = headlessSubscriptions
        }


updateWithVMupdate : Msg -> Model -> ( Model, Cmd Msg )
updateWithVMupdate msg model =
    let
        ( newModel, cmds ) =
            updateWithTime msg model

        ( _, exportCmds ) =
            updateWithTime (TimeTrackerMsg TimeTracker.ExportVM) model
    in
    ( newModel
    , Cmd.batch [ cmds ]
    )


initHeadless : ( String, Maybe JsonAppDatabase ) -> ( Model, Cmd Msg )
initHeadless ( urlAsString, maybeJson ) =
    init maybeJson (urlOrElse urlAsString) Nothing


urlOrElse : String -> Url.Url
urlOrElse urlAsString =
    let
        finalUrlAsString =
            String.replace "minder://" "https://internalURI.minder.app/" urlAsString
    in
    -- since we can't pull URLs from JS
    Maybe.withDefault fallbackUrl (Url.fromString (Debug.log "url in elm:" finalUrlAsString))


fallbackUrl : Url.Url
fallbackUrl =
    { protocol = Url.Http, host = "headless.docket.com", port_ = Nothing, path = "", query = Nothing, fragment = Nothing }


headlessSubscriptions : Model -> Sub Msg
headlessSubscriptions ({ appData, environment } as model) =
    Sub.batch
        [ headlessMsg (\s -> NewUrl (urlOrElse s))

        -- headlessMsg (\s -> Main.testMsg)
        ]


port headlessMsg : (String -> msg) -> Sub msg
