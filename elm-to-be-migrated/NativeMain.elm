module NativeMain exposing (..)

import Browser
import Html
import Main exposing (MainModel, Msg(..))
import Native exposing (Native)
import Native.Attributes as NA
import Native.Frame as Frame
import Native.Layout as Layout
import Native.Page as Page
import Profile exposing (Profile)
import Replicated.Framework as Framework
import OldShared.Model exposing (..)
import Url



-- update : Msg -> Model -> ( Model, Cmd Msg )
-- update msg model =
--     case msg of
--         SyncFrame bool ->
--             ( { model | rootFrame = Frame.handleBack bool model.rootFrame }, Cmd.none )


main : Framework.Program Flags Profile MainModel Main.Msg
main =
    let
        bogusTempUrl : Url.Url
        bogusTempUrl =
            { protocol = Url.Https
            , host = "minder.app"
            , port_ = Nothing
            , path = ""
            , query = Nothing
            , fragment = Nothing
            }
    in
    Framework.browserElement
        { init = \flags replica -> Main.init bogusTempUrl Nothing flags replica
        , view = Main.nativeView
        , update = Main.update
        , subscriptions = Main.subscriptions
        , replicaCodec = Profile.codec
        , portSetStorage = Main.setStorage
        , portIncomingChanges = Main.incomingFramesFromElsewhere
        }
