port module Headless exposing (main)

import AppData exposing (AppData)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode
import Main exposing (..)
import Platform exposing (worker)
import Task as Job
import Time
import Url


main : Program ( String, Maybe JsonAppDatabase ) Model Msg
main =
    worker
        { init = initHeadless
        , update = updateWithTime
        , subscriptions = headlessSubscriptions
        }


initHeadless : ( String, Maybe JsonAppDatabase ) -> ( Model, Cmd Msg )
initHeadless ( urlAsString, maybeJson ) =
    init maybeJson (urlOrElse urlAsString) Nothing


urlOrElse : String -> Url.Url
urlOrElse urlAsString =
    -- since we can't pull URLs from JS
    let
        fallbackUrl =
            { protocol = Url.Http, host = "docket.app", port_ = Nothing, path = "", query = Nothing, fragment = Nothing }
    in
    Maybe.withDefault fallbackUrl (Url.fromString urlAsString)


headlessSubscriptions : Model -> Sub Msg
headlessSubscriptions ({ appData, environment } as model) =
    Sub.batch
        [ headlessMsg (\s -> Debug.log s NoOp)
        ]


port headlessMsg : (String -> msg) -> Sub msg
