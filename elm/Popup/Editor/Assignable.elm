module Popup.Editor.Assignable exposing (..)

import Effect exposing (Effect)
import Form exposing (Form)
import Form.Base.RangeField as RangeField
import Form.Base.TextField as TextField
import Form.Error
import Form.View
import Html as H exposing (Html, li, node, output, text)
import Html.Attributes as HA exposing (attribute, class, href, placeholder, property, type_)
import Html.Events as HE exposing (on, onClick)
import Json.Decode as JD
import Json.Encode as JE
import Popup.IonicForm
import Profile as Profile exposing (Profile)
import Replicated.Change as Change
import Replicated.Reducer.Register as Reg exposing (Reg)
import Replicated.Reducer.RepList as RepList
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import Task.Progress exposing (Portion)
import Task.Project exposing (..)
import Task.RelativeTiming as RelativeTiming exposing (RelativeTiming)


type alias Values =
    { title : String
    , importance : Maybe Float
    , defaultRelevanceStarts : List ( String, Int )
    , defaultRelevanceEnds : List ( String, Int )
    , defaultExternalDeadline : List ( String, Int )
    , minEffort : Maybe Float
    , estimatedEffort : Maybe Float
    , maxEffort : Maybe Float
    }


type alias Output =
    { title : String
    , importance : Maybe Float
    , defaultRelevanceStarts : List RelativeTiming
    , defaultRelevanceEnds : List RelativeTiming
    , defaultExternalDeadline : List RelativeTiming
    , minEffort : Duration
    , estimatedEffort : Duration
    , maxEffort : Duration
    }


initialModel : Profile -> Maybe Assignable -> Model
initialModel profile assignableMaybe =
    let
        initialRawValues : Assignable -> Values
        initialRawValues assignable =
            { title = assignableTitle assignable
            , importance = assignableImportance assignable |> Just
            , defaultRelevanceStarts = assignableDefaultRelevanceStarts assignable |> RepList.listValues |> List.map RelativeTiming.toRawPair
            , defaultRelevanceEnds = assignableDefaultRelevanceEnds assignable |> RepList.listValues |> List.map RelativeTiming.toRawPair
            , defaultExternalDeadline = assignableDefaultExternalDeadline assignable |> RepList.listValues |> List.map RelativeTiming.toRawPair
            , minEffort = assignableMinEffort assignable |> Duration.inMinutes |> Just
            , estimatedEffort = assignableEstimatedEffort assignable |> Duration.inMinutes |> Just
            , maxEffort = assignableMaxEffort assignable |> Duration.inMinutes |> Just
            }

        brandNew : Values
        brandNew =
            { title = ""
            , importance = Nothing
            , defaultRelevanceStarts = []
            , defaultRelevanceEnds = []
            , defaultExternalDeadline = []
            , minEffort = Just 2
            , estimatedEffort = Just 20
            , maxEffort = Just 120
            }

        initialFormModel =
            Form.View.idle <|
                Maybe.withDefault brandNew <|
                    Maybe.map initialRawValues assignableMaybe
    in
    { assignable = assignableMaybe, formModel = initialFormModel }


type alias FormModel =
    Form.View.Model Values


type alias Model =
    { formModel : FormModel
    , assignable : Maybe Assignable
    }


type Msg
    = FormChanged FormModel
    | Submit Output


isNonnegative : number -> Bool
isNonnegative n =
    n >= 0


editorForm : Form Values Output
editorForm =
    let
        titleField : { parser : String -> Result String String, value : Values -> String, update : String -> Values -> Values, error : Values -> Maybe String, attributes : TextField.Attributes }
        titleField =
            { parser =
                \value ->
                    -- check if any other class names form the same slug
                    if String.length value > 2 then
                        Ok value

                    else
                        Err "Too short"
            , value = .title
            , update = \value values -> { values | title = value }
            , error = always Nothing
            , attributes =
                { label = "Assignable Title"
                , placeholder = "Mow the lawn"
                , htmlAttributes = [ ( "helper-text", "give it a unique name that includes any details you might forget." ) ]
                }
            }

        importanceField : { parser : Maybe Float -> Result String (Maybe Float), value : Values -> Maybe Float, update : Maybe Float -> Values -> Values, error : Values -> Maybe String, attributes : RangeField.Attributes Float }
        importanceField =
            { parser =
                \value ->
                    if Maybe.map isNonnegative value |> Maybe.withDefault True then
                        Ok value

                    else
                        Err "Can't be negative"
            , value = .importance
            , update = \value values -> { values | importance = value }
            , error = always Nothing
            , attributes =
                { label = "Importance"
                , max = Just 3
                , min = Just 0.0
                , step = 0.01
                , htmlAttributes = [ ( "helper-text", "1 to 3" ) ]
                }
            }

        defaultRelevanceStartsField : { parser : List ( String, Int ) -> List RelativeTiming, value : Values -> List ( String, Int ), update : List ( String, Int ) -> Values -> Values, error : Values -> Maybe String, attributes : TextField.Attributes }
        defaultRelevanceStartsField =
            { parser = \pairList -> List.filterMap RelativeTiming.fromRawPairMaybe pairList
            , value = .defaultRelevanceStarts
            , update = \value values -> { values | defaultRelevanceStarts = value }
            , error = always Nothing
            , attributes =
                { label = "Default Relevance Starts"
                , placeholder = "Immediately"
                , htmlAttributes = []
                }
            }

        defaultRelevanceEndsField : { parser : List ( String, Int ) -> List RelativeTiming, value : Values -> List ( String, Int ), update : List ( String, Int ) -> Values -> Values, error : Values -> Maybe String, attributes : TextField.Attributes }
        defaultRelevanceEndsField =
            { parser = \pairList -> List.filterMap RelativeTiming.fromRawPairMaybe pairList
            , value = .defaultRelevanceEnds
            , update = \value values -> { values | defaultRelevanceEnds = value }
            , error = always Nothing
            , attributes =
                { label = "Default Relevance Ends"
                , placeholder = "Never"
                , htmlAttributes = []
                }
            }

        defaultExternalDeadlineField : { parser : List ( String, Int ) -> List RelativeTiming, value : Values -> List ( String, Int ), update : List ( String, Int ) -> Values -> Values, error : Values -> Maybe String, attributes : TextField.Attributes }
        defaultExternalDeadlineField =
            { parser = \pairList -> List.filterMap RelativeTiming.fromRawPairMaybe pairList
            , value = .defaultExternalDeadline
            , update = \value values -> { values | defaultExternalDeadline = value }
            , error = always Nothing
            , attributes =
                { label = "Default External Deadline"
                , placeholder = "None"
                , htmlAttributes = []
                }
            }

        minEffortField : { parser : Maybe Float -> Result String Duration, value : Values -> Maybe Float, update : Maybe Float -> Values -> Values, error : Values -> Maybe String, attributes : RangeField.Attributes Float }
        minEffortField =
            { parser = maybeFloatMinutesToDurationResult
            , value = .minEffort
            , update = \value values -> { values | minEffort = value }
            , error = always Nothing
            , attributes =
                { label = "Minimum Time Required"
                , max = Nothing
                , min = Just 0.0
                , step = 1
                , htmlAttributes = []
                }
            }

        estimatedEffortField : { parser : Maybe Float -> Result String Duration, value : Values -> Maybe Float, update : Maybe Float -> Values -> Values, error : Values -> Maybe String, attributes : RangeField.Attributes Float }
        estimatedEffortField =
            { parser = maybeFloatMinutesToDurationResult
            , value = .estimatedEffort
            , update = \value values -> { values | estimatedEffort = value }
            , error = always Nothing
            , attributes =
                { label = "Estimated Time Required"
                , max = Nothing
                , min = Just 0.1
                , step = 1
                , htmlAttributes = []
                }
            }

        maxEffortField : { parser : Maybe Float -> Result String Duration, value : Values -> Maybe Float, update : Maybe Float -> Values -> Values, error : Values -> Maybe String, attributes : RangeField.Attributes Float }
        maxEffortField =
            { parser = maybeFloatMinutesToDurationResult
            , value = .maxEffort
            , update = \value values -> { values | maxEffort = value }
            , error = always Nothing
            , attributes =
                { label = "Maximum Time Required"
                , max = Nothing
                , min = Just 1
                , step = 1
                , htmlAttributes = []
                }
            }
    in
    Form.succeed Output
        |> Form.append (Form.textField titleField)
        |> Form.append (Form.rangeField importanceField)
        |> Form.append (Form.succeed [])
        -- (Form.optional (Form.textField defaultRelevanceStartsField))
        |> Form.append (Form.succeed [])
        --(Form.optional (Form.textField defaultRelevanceEndsField))
        |> Form.append (Form.succeed [])
        --(Form.optional (Form.textField defaultExternalDeadlineField))
        |> Form.append (Form.rangeField minEffortField)
        |> Form.append (Form.rangeField estimatedEffortField)
        |> Form.append (Form.rangeField maxEffortField)



-- |> Form.append passwordField
-- |> Form.append rememberMeCheckbox


maybeFloatMinutesToDurationResult : Maybe Float -> Result String Duration
maybeFloatMinutesToDurationResult maybeFloat =
    case maybeFloat of
        Nothing ->
            Ok Duration.zero

        Just float ->
            if float >= 0 then
                Ok <| Duration.fromMinutes float

            else
                Err "Can't be negative"


view : Profile -> Model -> Html Msg
view profile model =
    Popup.IonicForm.htmlView
        { onChange = FormChanged
        , action = "Submit"
        , loading = "Submitting!"
        , validation = Form.View.ValidateOnSubmit
        }
        (Form.map Submit editorForm)
        model.formModel


update : Msg -> Model -> ( Model, List (Effect msg) )
update msg model =
    case msg of
        FormChanged formModel ->
            ( { model | formModel = formModel }, [] )

        Submit output ->
            let
                oldFormModel =
                    model.formModel

                newFormModel =
                    { oldFormModel | state = Form.View.Loading }
            in
            ( { model | formModel = newFormModel }
            , [ Effect.Save <| outputToChanges model.assignable output
              , Effect.ClosePopup
              ]
            )


outputToChanges : Maybe Assignable -> Output -> Change.Frame
outputToChanges assignableMaybe output =
    case assignableMaybe of
        Just assignable ->
            let
                updateTitle =
                    if output.title == assignableTitle assignable then
                        Nothing

                    else
                        Just (assignableSetTitle output.title assignable)

                updateImportance =
                    case output.importance of
                        Just newImportance ->
                            if newImportance == assignableImportance assignable then
                                Nothing

                            else
                                Just (assignableSetImportance newImportance assignable)

                        Nothing ->
                            Nothing

                updateEstimatedEffort =
                    if output.estimatedEffort == assignableEstimatedEffort assignable then
                        Nothing

                    else
                        Just (assignableSetEstimatedEffort output.estimatedEffort assignable)

                updateMinEffort =
                    if output.minEffort == assignableMinEffort assignable then
                        Nothing

                    else
                        Just (assignableSetMinEffort output.minEffort assignable)

                updateMaxEffort =
                    if output.maxEffort == assignableMaxEffort assignable then
                        Nothing

                    else
                        Just (assignableSetMaxEffort output.maxEffort assignable)
            in
            Change.saveChanges "Editing an assignable" <|
                List.filterMap identity
                    [ updateTitle
                    , updateImportance
                    , updateEstimatedEffort
                    , updateMinEffort
                    , updateMaxEffort
                    ]

        Nothing ->
            Change.none
