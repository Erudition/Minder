module Pages.Undo exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html.Attributes as HA
import Html.Styled as SH exposing (..)
import Html.Styled.Attributes exposing (attribute)
import Ion.Button
import Ion.Icon
import Layouts
import Page exposing (Page)
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


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    let
        viewChange profileChange =
            node "ion-item"
                []
                [ text (Shared.profileChangeToString profileChange)
                , SH.fromUnstyled <| Ion.Button.button [ HA.attribute "slot" "end" ] [ Ion.Icon.basic "arrow-undo-circle-outline" ]
                ]
    in
    { title = "UI History (undo)"
    , body =
        [ node "ion-list" [] (List.map viewChange shared.uiHistory)
        ]
    }
