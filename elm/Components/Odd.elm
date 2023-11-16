module Components.Odd exposing (..)

import Html exposing (th)
import Task
import Webnative exposing (Foundation)
import Webnative.AppInfo
import Webnative.Auth
import Webnative.CID
import Webnative.Configuration
import Webnative.Error exposing (Error(..))
import Webnative.FileSystem exposing (Base(..), FileSystem, exists)
import Webnative.Namespace
import Webnative.Path as Path
import Webnative.Program exposing (Program)
import Webnative.Session exposing (Session)



-- INIT


appInfo : Webnative.AppInfo.AppInfo
appInfo =
    { creator = "Minder", name = "Minder" }


config : Webnative.Configuration.Configuration
config =
    appInfo
        |> Webnative.Namespace.fromAppInfo
        |> Webnative.Configuration.fromNamespace


type Model
    = Unprepared
    | NotAuthenticated Program
    | Authenticated Program Session FileSystem


init : ( Model, Cmd Msg )
init =
    ( Unprepared
    , -- 🚀
      config
        |> Webnative.program
        |> Webnative.attemptTask
            { ok = Liftoff
            , error = HandleWebnativeError
            }
      --   Cmd.none
      -- temporarily disabled while the package is broken
    )


path =
    Path.file [ "RON", "profile.ron" ]



-- UPDATE


type Msg
    = HandleWebnativeError Error
    | GotFileContents String
    | GotSessionAndFileSystem (Maybe { session : Session, fileSystem : FileSystem })
    | ReadFileContents
    | WriteFileContents String
    | Published Webnative.CID.CID
    | Liftoff Foundation
    | RegisterUser Program { success : Bool }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -----------------------------------------
        -- 🚀
        -----------------------------------------
        Liftoff foundation ->
            let
                newModel =
                    -- Previous authenticated session?
                    -- Presence of a FileSystem depends on your configuration.
                    case ( foundation.fileSystem, foundation.session ) of
                        ( Just fs, Just session ) ->
                            Authenticated foundation.program session fs

                        _ ->
                            NotAuthenticated foundation.program
            in
            ( newModel
              -- Next action
              --------------
            , case newModel of
                NotAuthenticated program ->
                    -- Option (A), register a new account.
                    -- We're skipping the username validation and
                    -- username availability checking here to keep it short.
                    { email = Nothing
                    , username = "test-user-1"
                    }
                        |> Webnative.Auth.register program
                        |> Webnative.attemptTask
                            { ok = RegisterUser program
                            , error = HandleWebnativeError
                            }

                -- Option (B), link an existing account.
                -- See 'Linking' section below.
                Authenticated program session fileSystem ->
                    let
                        createIfExists exists =
                            if exists then
                                ReadFileContents

                            else
                                WriteFileContents "first"
                    in
                    Webnative.FileSystem.exists fileSystem (AppData appInfo) path
                        |> Webnative.attemptTask
                            { ok = createIfExists
                            , error = HandleWebnativeError
                            }

                Unprepared ->
                    Cmd.none
            )

        -----------------------------------------
        -- 🙋
        -----------------------------------------
        RegisterUser program { success } ->
            if success then
                ( model
                , program
                    |> Webnative.Auth.sessionWithFileSystem
                    |> Webnative.attemptTask
                        { ok = GotSessionAndFileSystem
                        , error = HandleWebnativeError
                        }
                )

            else
                -- Could show message in create-account form.
                ( model, Cmd.none )

        GotSessionAndFileSystem (Just { fileSystem, session }) ->
            ( -- Authenticated
              case model of
                NotAuthenticated program ->
                    Authenticated program session fileSystem
                        |> Debug.log "Authenticated successfully in Odd.elm"

                _ ->
                    model
              -- Next action
              --------------
            , Task.perform (\_ -> ReadFileContents) (Task.succeed ())
            )

        ReadFileContents ->
            case model of
                Authenticated program session fileSystem ->
                    ( model
                    , Webnative.FileSystem.readUtf8 fileSystem (AppData appInfo) path
                        |> Webnative.attemptTask
                            { ok = GotFileContents
                            , error = HandleWebnativeError
                            }
                    )

                _ ->
                    ( model, Cmd.none )

        WriteFileContents newContents ->
            case model of
                Authenticated program session fileSystem ->
                    ( model
                    , Webnative.FileSystem.writeUtf8 fileSystem (AppData appInfo) path newContents
                        |> Task.andThen (\_ -> Webnative.FileSystem.publish fileSystem)
                        |> Webnative.attemptTask
                            { ok = Published
                            , error = HandleWebnativeError
                            }
                    )

                _ ->
                    ( model, Cmd.none )

        Published newCID ->
            ( Debug.log "Published successfully!" model, Cmd.none )

        -----------------------------------------
        -- 💾
        -----------------------------------------
        GotFileContents string ->
            Debug.log ("Odd.elm got file contents!" ++ string) ( model, Cmd.none )

        -----------------------------------------
        -- 🥵
        -----------------------------------------
        HandleWebnativeError UnsupportedBrowser ->
            -- No indexedDB? Depends on how Webnative is configured.
            Debug.todo "Unsupported"

        HandleWebnativeError InsecureContext ->
            -- Webnative requires a secure context
            Debug.todo "no https"

        HandleWebnativeError (JavascriptError string) ->
            -- Notification.push ("Got JS error: " ++ string)
            Debug.todo string

        GotSessionAndFileSystem Nothing ->
            -- Notification.push ("Got JS error: " ++ string)
            Debug.todo "Got nothing when I expected a filesystem and session."
