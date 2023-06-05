module Effect exposing (Effect(..), map, none, perform)

import External.Commands
import Json.Decode as JD
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as JE exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Process
import Profile exposing (Profile)
import Replicated.Change as Change
import Replicated.Framework
import Shared.Model exposing (..)
import Shared.PopupType as PopupType exposing (PopupType)
import Task as ElmTask
import TaskPort


type Effect msg
    = NoOp
    | Toast String
    | OpenPopup PopupType
    | ClosePopup
    | FocusIonInput String
    | Save Change.Frame


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
