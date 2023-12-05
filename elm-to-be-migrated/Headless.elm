port module Headless exposing (main)

import Json.Decode.Exploration exposing (..)
import Main exposing (..)
import OldShared.Model exposing (..)
import Platform exposing (worker)
import Profile exposing (..)
import Replicated.Change as Change exposing (ChangeSet, Frame)
import Url


main : Program ( String, Maybe StoredRON ) Shared Msg
main =
    worker
        (Debug.todo "framework for worker")



-- { init = initHeadless
-- , update = updateWithTime
-- , subscriptions = headlessSubscriptions
-- }


initHeadless : ( String, Profile ) -> ( List (Change.Frame String), MainModel, Cmd Msg )
initHeadless ( urlAsString, profile ) =
    let
        flags =
            { darkTheme = False }
    in
    init (urlOrElse urlAsString) Nothing flags profile


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


headlessSubscriptions : Shared -> Sub Msg
headlessSubscriptions _ =
    Sub.batch
        [ headlessMsg (\s -> NewUrl (urlOrElse s))

        -- headlessMsg (\s -> Main.testMsg)
        ]


port headlessMsg : (String -> msg) -> Sub msg
