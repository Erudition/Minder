module Pages.NotFound_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html exposing (..)
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import Url exposing (Url)
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init route
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { route : Route () }


init : Route () -> () -> ( Model, Effect Msg )
init route () =
    ( { route = route }
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


view : Model -> View Msg
view model =
    View.fromString <| "Page not found: " ++ Maybe.withDefault "" model.route.url.fragment ++ " and the route was: " ++ Debug.toString model.route
