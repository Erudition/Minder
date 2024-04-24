module Pages.Undo exposing (Model, Msg, page)

import Components.Replicator as Replicator exposing (Replicator)
import Css exposing (..)
import Dict.Any as AnyDict exposing (AnyDict)
import Effect exposing (Effect)
import Html.Attributes as HA
import Html.Events as HE
import Html.Styled as SH exposing (..)
import Html.Styled.Attributes exposing (attribute, css)
import Html.Styled.Events as SHE
import Ion.Button
import Ion.Icon
import Layouts
import Page exposing (Page)
import Replicated.Change as Change
import Route exposing (Route)
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view shared
        }
        |> Page.withLayout toLayout


{-| Use the appframe layout on this page
-}
toLayout : Model -> Layouts.Layout Msg
toLayout model =
    Layouts.AppFrame
        {}



-- INIT


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init () =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = NoOp
    | Undo (Change.Frame String)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Effect.none
            )

        Undo frame ->
            ( model, Effect.saveFrame frame )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = "UI History (undo)"
    , body =
        [ node "ion-list" [] []
        ]
    }


viewHistoryFrame : { description : String, reverse : Change.Frame String, undone : Bool } -> Html Msg
viewHistoryFrame historyItem =
    let
        itemAttr =
            if historyItem.undone then
                [ css [ textDecoration lineThrough ] ]

            else
                []
    in
    node "ion-item"
        []
        [ span itemAttr [ text <| historyItem.description ]
        , SH.fromUnstyled <| Ion.Button.button [ HA.attribute "slot" "end", HE.onClick (Undo historyItem.reverse) ] [ Ion.Icon.basic "arrow-undo-circle-outline" ]
        ]
