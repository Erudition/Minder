port module Browserless exposing (..)

import Browser
import Html.Styled exposing (Html, node, toUnstyled)
import Main exposing (JsonAppDatabase, Model, Msg)
import Platform exposing (worker)
import Url
import VirtualDom


main : Program ( String, Maybe JsonAppDatabase ) Model Msg
main =
    Browser.element
        { init = initBrowserless
        , view = browserlessView
        , update = Main.updateWithTime
        , subscriptions = Main.subscriptions
        }


initBrowserless : ( String, Maybe JsonAppDatabase ) -> ( Model, Cmd Msg )
initBrowserless ( urlAsString, maybeJson ) =
    Main.init maybeJson (urlOrElse urlAsString) Nothing


browserlessView : Model -> VirtualDom.Node Msg
browserlessView { viewState, profile, environment } =
    toUnstyled <|
        node "AbsoluteLayout" [] []


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


port browserlessMsg : (String -> msg) -> Sub msg
