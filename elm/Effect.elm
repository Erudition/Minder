module Effect exposing (Effect(..), map, none, perform)

import External.Commands
import Http
import Json.Decode as JD
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as JE exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import ML.OnlineChat
import Process
import Profile exposing (Profile)
import Replicated.Change as Change
import Replicated.Framework
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Shared.Model exposing (..)
import Shared.PopupType as PopupType exposing (PopupType)
import Task as ElmTask
import TaskPort


type Effect msg
    = NoOp
    | Toast String
    | DialogPrompt (Result TaskPort.Error String -> msg) PromptOptions
    | OpenPopup PopupType
    | ClosePopup
    | FocusIonInput String
    | Save Change.Frame
    | Predict (Result String ML.OnlineChat.Prediction -> msg) ML.OnlineChat.Prediction
    | LogError String


perform : (String -> msg) -> Shared -> Profile -> List (Effect msg) -> ( List Change.Frame, Shared, Cmd msg )
perform noOp sharedIn profile effects =
    let
        runEffect : Shared -> Effect msg -> ( List Change.Frame, Shared, List (Cmd msg) )
        runEffect shared effect =
            case effect of
                NoOp ->
                    ( [], shared, [] )

                OpenPopup popupType ->
                    ( [], { shared | modal = Just popupType }, [] )

                ClosePopup ->
                    ( [], { shared | modal = Nothing }, [] )

                Toast toastMessage ->
                    ( [], shared, [ External.Commands.toast toastMessage ] )

                DialogPrompt toMsg options ->
                    ( []
                    , shared
                    , [ ElmTask.attempt toMsg (dialogPrompt options) ]
                    )

                FocusIonInput inputToFocus ->
                    ( []
                    , shared
                    , [ Process.sleep 100
                            |> ElmTask.andThen (\_ -> ionInputSetFocus inputToFocus)
                            |> ElmTask.attempt (\_ -> noOp <| "set focus to" ++ inputToFocus)
                      ]
                    )

                Save frame ->
                    ( [ frame ], shared, [] )

                Predict toMsg prompt ->
                    ( []
                    , shared
                    , [ ML.OnlineChat.predict toMsg prompt ]
                    )

                LogError error ->
                    ( [ Change.saveChanges "logging" [ RepList.insert RepList.Last error profile.errors ] ], shared, [] )

        addEffect : Effect msg -> ( List Change.Frame, Shared, List (Cmd msg) ) -> ( List Change.Frame, Shared, List (Cmd msg) )
        addEffect effect ( framesSoFar, sharedSoFar, cmdsSoFar ) =
            let
                ( framesAfterEffect, sharedAfterEffect, cmdsAfterEffect ) =
                    runEffect sharedSoFar effect
            in
            ( framesSoFar ++ framesAfterEffect, sharedAfterEffect, cmdsSoFar ++ cmdsAfterEffect )

        ( allFrames, finalShared, allCmds ) =
            List.foldl addEffect ( [], sharedIn, [] ) effects
    in
    ( allFrames, finalShared, Cmd.batch allCmds )



-- {-| Should this go in a Shared/ module?
-- -}
-- update : Shared -> Profile -> Msg -> ( List Change.Frame, Shared, Cmd Msg )
-- update shared replica msg =
--     case msg of
--         Shared.Msg.NoOp ->
--             ( [], shared, Cmd.none )


{-| Transform the messages produced by an effect.
-}
map : (a -> msg) -> Effect a -> Effect msg
map changeMsg effect =
    case effect of
        NoOp ->
            NoOp

        OpenPopup popup ->
            OpenPopup popup

        ClosePopup ->
            ClosePopup

        Toast toastMessage ->
            Toast toastMessage

        FocusIonInput inputToFocus ->
            FocusIonInput inputToFocus

        Save frame ->
            Save frame

        Predict toMsg prompt ->
            Predict (toMsg >> changeMsg) prompt

        DialogPrompt toMsg prompt ->
            DialogPrompt (toMsg >> changeMsg) prompt

        LogError error ->
            LogError error


{-| No effect.
-}
none : Effect msg
none =
    NoOp


ionInputSetFocus : String -> TaskPort.Task ()
ionInputSetFocus ionInputIDToFocus =
    TaskPort.call
        { function = "ionInputSetFocus"
        , valueDecoder = TaskPort.ignoreValue
        , argsEncoder = JE.string
        }
        ionInputIDToFocus


type alias PromptOptions =
    { title : Maybe String
    , message : String
    , okButtonTitle : Maybe String
    , cancelButtonTitle : Maybe String
    , inputPlaceholder : Maybe String
    , inputText : Maybe String
    }


dialogPrompt : PromptOptions -> TaskPort.Task String
dialogPrompt inOptions =
    let
        optionsEncoder : PromptOptions -> JE.Value
        optionsEncoder options =
            JE.object
                [ ( "title"
                  , case options.title of
                        Just title ->
                            JE.string title

                        Nothing ->
                            JE.null
                  )
                , ( "message"
                  , JE.string options.message
                  )
                , ( "okButtonTitle"
                  , case options.okButtonTitle of
                        Just okButtonTitle ->
                            JE.string okButtonTitle

                        Nothing ->
                            JE.null
                  )
                , ( "cancelButtonTitle"
                  , case options.cancelButtonTitle of
                        Just cancelButtonTitle ->
                            JE.string cancelButtonTitle

                        Nothing ->
                            JE.null
                  )
                , ( "inputPlaceholder"
                  , case options.inputPlaceholder of
                        Just inputPlaceholder ->
                            JE.string inputPlaceholder

                        Nothing ->
                            JE.null
                  )
                , ( "inputText"
                  , case options.inputText of
                        Just inputText ->
                            JE.string inputText

                        Nothing ->
                            JE.null
                  )
                ]
    in
    TaskPort.call
        { function = "dialogPrompt"
        , valueDecoder = JD.at [ "value" ] JD.string
        , argsEncoder = optionsEncoder
        }
        inOptions
