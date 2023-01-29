port module Browserless exposing (..)

import Browser
import Html as PlainHtml
import Profile exposing (..)

import Replicated.Change as Change exposing (ChangeSet, Frame)
import Html.Styled exposing (node, toUnstyled)
import Main exposing (StoredRON, Temp, Msg)
import Url
import VirtualDom


main : Program ( String, Maybe StoredRON ) Temp Msg
main =
    Browser.element
        (Debug.todo "framework for browser.element")
        -- { init = initBrowserless
        -- , view = \m -> PlainHtml.div [] (Main.view m).body
        -- , update = Main.updateWithTime
        -- , subscriptions = Main.subscriptions
        -- }


initBrowserless : ( String, Profile ) -> ( List Change.Frame, Temp, Cmd Msg )
initBrowserless ( urlAsString, profile ) =
    Main.init (urlOrElse urlAsString) Nothing profile


browserlessView : Temp -> VirtualDom.Node Msg
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
