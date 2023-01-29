port module Headless exposing (main)

import Json.Decode.Exploration exposing (..)
import Main exposing (..)
import Platform exposing (worker)
import Replicated.Change as Change exposing (ChangeSet, Frame)
import Profile exposing (..)

import Url


main : Program ( String, Maybe StoredRON ) Temp Msg
main =
    worker
        (Debug.todo "framework for worker")
        -- { init = initHeadless
        -- , update = updateWithTime
        -- , subscriptions = headlessSubscriptions
        -- }



initHeadless : ( String, Profile ) -> ( List Change.Frame, Temp, Cmd Msg )
initHeadless ( urlAsString, profile ) =
    init (urlOrElse urlAsString) Nothing profile


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


headlessSubscriptions : Temp -> Sub Msg
headlessSubscriptions (_) =
    Sub.batch
        [ headlessMsg (\s -> NewUrl (urlOrElse s))

        -- headlessMsg (\s -> Main.testMsg)
        ]


port headlessMsg : (String -> msg) -> Sub msg
