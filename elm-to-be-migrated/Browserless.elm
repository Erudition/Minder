port module Browserless exposing (..)

import Browser
import Html as PlainHtml
import Html.Styled exposing (node, toUnstyled)
import Main exposing (Msg, StoredRON)
import OldShared.Model exposing (..)
import Profile exposing (..)
import Replicated.Change as Change exposing (ChangeSet, Frame)
import Url
import VirtualDom


main : Program ( String, Maybe StoredRON ) Shared Msg
main =
    Browser.element
        (Debug.todo "framework for browser.element")



-- { init = initBrowserless
-- , view = \m -> PlainHtml.div [] (Main.view m).body
-- , update = Main.updateWithTime
-- , subscriptions = Main.subscriptions
-- }


initBrowserless : ( String, Profile ) -> ( List (Change.Frame String), Main.MainModel, Cmd Msg )
initBrowserless ( urlAsString, profile ) =
    let
        flags =
            { darkTheme = False }
    in
    Main.init (urlOrElse urlAsString) Nothing flags profile


browserlessView : Shared -> VirtualDom.Node Msg
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
