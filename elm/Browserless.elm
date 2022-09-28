port module Browserless exposing (..)

import Browser
import Html as PlainHtml
import Html.Styled exposing (node, toUnstyled)
import Main exposing (StoredRON, Model, Msg)
import Url
import VirtualDom


main : Program ( String, Maybe StoredRON ) Model Msg
main =
    Browser.element
        { init = initBrowserless
        , view = \m -> PlainHtml.div [] (Main.view m).body
        , update = Main.updateWithTime
        , subscriptions = Main.subscriptions
        }


initBrowserless : ( String, Maybe StoredRON ) -> ( Model, Cmd Msg )
initBrowserless ( urlAsString, maybeJson ) =
    Main.init maybeJson (urlOrElse urlAsString) Nothing


browserlessView : Model -> VirtualDom.Node Msg
browserlessView _ =
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
