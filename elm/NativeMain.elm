module NativeMain exposing (..)

import Browser
import Native exposing (Native)
import Native.Attributes as NA
import Native.Frame as Frame
import Native.Layout as Layout
import Native.Page as Page


type NavPage
    = HomePage


type alias Model =
    { rootFrame : Frame.Model NavPage
    }


init : ( Model, Cmd Msg )
init =
    ( { rootFrame = Frame.init HomePage }
    , Cmd.none
    )


type Msg
    = SyncFrame Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SyncFrame bool ->
            ( { model | rootFrame = Frame.handleBack bool model.rootFrame }, Cmd.none )


homePage : Model -> Native Msg
homePage _ =
    Page.pageWithActionBar SyncFrame
        []
        (Native.actionBar [ NA.title "Here we go!!!" ] [])
        (Layout.flexboxLayout
            [ NA.alignItems "center"
            , NA.justifyContent "center"
            , NA.height "100%"
            ]
            [ Native.label [ NA.class "main", NA.text "Elm is working." ] []
            ]
        )


getPage : Model -> NavPage -> Native Msg
getPage model page =
    case page of
        HomePage ->
            homePage model


view : Model -> Native Msg
view model =
    model.rootFrame
        |> Frame.view [] (getPage model)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = always init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
