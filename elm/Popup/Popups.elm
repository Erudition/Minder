module Popup.Popups exposing (Model, Msg, getCorrectModel, init, initEmpty, popupWrapper, update)

import Effect exposing (Effect)
import Form
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD
import Json.Encode as JE
import Popup.Editor.Task as TaskEditor
import Profile as Profile exposing (Profile)
import Replicated.Change as Change
import Shared.Model exposing (Shared)
import Shared.PopupType as PopupType exposing (PopupType)


type Model
    = ProjectEditor TaskEditor.Model
    | JustText (Html ())


type Msg
    = ProjectEditorMsg TaskEditor.Msg
    | JustTextMsg
    | RunEffects (List (Effect Msg))


init : Profile -> PopupType -> Model
init profile popupType =
    case popupType of
        PopupType.ProjectEditor maybeAction ->
            ProjectEditor <| TaskEditor.initialModel profile maybeAction

        PopupType.JustText _ ->
            JustText (H.div [] [ H.text "Just text" ])


initEmpty : Model
initEmpty =
    JustText (H.div [] [ H.text "Just text" ])


update : Msg -> Model -> Profile -> Shared -> ( Model, List (Effect Msg) )
update msg model profile shared =
    let
        correctModel =
            getCorrectModel profile shared model
    in
    case ( correctModel, msg ) of
        ( ProjectEditor projectEditorModel, ProjectEditorMsg projectEditorMsg ) ->
            let
                ( outModel, outEffects ) =
                    TaskEditor.update projectEditorMsg projectEditorModel
            in
            ( ProjectEditor outModel, outEffects )

        ( JustText _, JustTextMsg ) ->
            ( correctModel, [] )

        ( _, RunEffects effects ) ->
            ( correctModel, effects )

        _ ->
            ( correctModel, [] )


viewPopup : Model -> Profile -> Shared -> Html Msg
viewPopup model profile shared =
    case getCorrectModel profile shared model of
        ProjectEditor formModel ->
            TaskEditor.view profile formModel
                |> H.map ProjectEditorMsg

        JustText htmlWithoutMsg ->
            htmlWithoutMsg
                |> H.map (\_ -> JustTextMsg)


popupWrapper : Model -> Profile -> Shared -> H.Html Msg
popupWrapper popupModel profile shared =
    -- It's important that this be unstyled Html for now, since adding style elements throws off the elm-ionic interaction
    let
        outerShell innerStuff =
            [ H.node "ion-header"
                [ HA.id "ion-modal-header" ]
                [ H.node "ion-toolbar"
                    []
                    [ H.node "ion-buttons"
                        [ HA.attribute "slot" "end" ]
                        [ H.node "ion-button"
                            [ HA.attribute "color" "medium"
                            , HE.onClick (RunEffects [ Effect.ClosePopup ])
                            ]
                            [ H.text "Cancel" ]
                        ]
                    , H.node "ion-title" [] [ H.text "Project Editor" ]

                    -- , H.node "ion-buttons"
                    --     [ HA.attribute "slot" "end" ]
                    --     [ H.node "ion-button" [ HA.attribute "strong" "true", HE.onClick (RunEffects [ Effect.ClosePopup, Effect.Toast "Pretended to Save Changes!" ]) ] [ H.text "Confirm" ]
                    --     ]
                    ]
                ]
            , H.node "ion-content"
                [ HA.class "ion-padding" ]
                innerStuff
            ]

        isOpen =
            case shared.modal of
                Just popup ->
                    True

                Nothing ->
                    False

        contents =
            outerShell
                [ viewPopup popupModel profile shared
                ]
    in
    H.node "ion-modal"
        [ HA.property "isOpen" (JE.bool isOpen)
        , HE.on "didDismiss" <| JD.succeed (RunEffects [ Effect.ClosePopup ])
        ]
        [ H.div [ HA.class "ion-delegate-host", HA.class "ion-page" ] contents ]


getCorrectModel : Profile -> Shared -> Model -> Model
getCorrectModel profile shared model =
    case ( shared.modal, model ) of
        -- model is correct match
        ( Just (PopupType.ProjectEditor newAction), ProjectEditor { action } ) ->
            if newAction == action then
                model

            else
                init profile (PopupType.ProjectEditor newAction)

        ( Just (PopupType.JustText _), JustText _ ) ->
            model

        ( Nothing, _ ) ->
            --popup is closed, leave old model in place
            JustText (H.div [] [ H.text "Just text" ])

        ( Just popupType, _ ) ->
            -- model doesn't match, substitute blank
            init profile popupType
