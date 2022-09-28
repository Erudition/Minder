port module Headless exposing (main)

import Json.Decode.Exploration exposing (..)
import Main exposing (..)
import Platform exposing (worker)
import Url


main : Program ( String, Maybe StoredRON ) Model Msg
main =
    worker
        { init = initHeadless
        , update = updateWithTime
        , subscriptions = headlessSubscriptions
        }



initHeadless : ( String, Maybe StoredRON ) -> ( Model, Cmd Msg )
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
headlessSubscriptions (_ as _) =
    Sub.batch
        [ headlessMsg (\s -> NewUrl (urlOrElse s))

        -- headlessMsg (\s -> Main.testMsg)
        ]


port headlessMsg : (String -> msg) -> Sub msg
