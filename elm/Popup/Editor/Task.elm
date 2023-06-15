module Popup.Editor.Task exposing (..)

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
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import Task.Assignment as Assignment exposing (..)
import Task.Progress exposing (Portion)


type alias Values =
    { classTitle : String
    , classImportance : Maybe Float
    , relevanceStarts : String
    , relevanceEnds : String
    , externalDeadline : String
    , minEffort : Maybe Float
    , estimatedEffort : Maybe Float
    , maxEffort : Maybe Float
    , progressMax : Maybe Int
    , completion : Maybe Int
    }


type alias Output =
    { classTitle : String
    , classImportance : Maybe Float
    , relevanceStarts : Maybe FuzzyMoment
    , relevanceEnds : Maybe FuzzyMoment
    , externalDeadline : Maybe FuzzyMoment
    , minEffort : Duration
    , estimatedEffort : Duration
    , maxEffort : Duration
    , progressMax : Maybe Portion
    , completion : Maybe Int
    }


initialModel : Profile -> Maybe Assignment -> Model
initialModel profile metaInstanceMaybe =
    let
        initialRawValues : Assignment -> Values
        initialRawValues meta =
            { classTitle = getTitle meta
            , classImportance = getImportance meta |> Just
            , relevanceStarts = getRelevanceStarts meta |> Maybe.map HumanMoment.fuzzyToString |> Maybe.withDefault ""
            , relevanceEnds = getRelevanceEnds meta |> Maybe.map HumanMoment.fuzzyToString |> Maybe.withDefault ""
            , externalDeadline = getExternalDeadline meta |> Maybe.map HumanMoment.fuzzyToString |> Maybe.withDefault ""
            , minEffort = getMinEffort meta |> Duration.inMinutes |> Just
            , estimatedEffort = getEstimatedEffort meta |> Duration.inMinutes |> Just
            , maxEffort = getMaxEffort meta |> Duration.inMinutes |> Just
            , progressMax = getProgressMaxInt meta |> Just
            , completion = getCompletionInt meta |> Just
            }

        brandNew : Values
        brandNew =
            { classTitle = ""
            , classImportance = Nothing
            , relevanceStarts = ""
            , relevanceEnds = ""
            , externalDeadline = ""
            , minEffort = Just 2
            , estimatedEffort = Just 20
            , maxEffort = Just 120
            , progressMax = Just 100
            , completion = Just 0
            }

        initialFormModel =
            Form.View.idle <|
                Maybe.withDefault brandNew <|
                    Maybe.map initialRawValues metaInstanceMaybe
    in
    { action = metaInstanceMaybe, formModel = initialFormModel }


type alias FormModel =
    Form.View.Model Values


type alias Model =
    { formModel : FormModel
    , action : Maybe Assignment
    }


type Msg
    = FormChanged FormModel
    | Submit Output


isNonnegative : number -> Bool
isNonnegative n =
    n >= 0


taskEditorForm : Form Values Output
taskEditorForm =
    let
        classTitleField : { parser : String -> Result String String, value : Values -> String, update : String -> Values -> Values, error : Values -> Maybe String, attributes : TextField.Attributes }
        classTitleField =
            { parser =
                \value ->
                    -- check if any other class names form the same slug
                    if String.length value > 2 then
                        Ok value

                    else
                        Err "Too short"
            , value = .classTitle
            , update = \value values -> { values | classTitle = value }
            , error = always Nothing
            , attributes =
                { label = "Project Title"
                , placeholder = "Mow the lawn"
                , htmlAttributes = [ ( "helper-text", "give it a unique name that includes any details you might forget." ) ]
                }
            }

        classImportanceField : { parser : Maybe Float -> Result String (Maybe Float), value : Values -> Maybe Float, update : Maybe Float -> Values -> Values, error : Values -> Maybe String, attributes : RangeField.Attributes Float }
        classImportanceField =
            { parser =
                \value ->
                    if Maybe.map isNonnegative value |> Maybe.withDefault True then
                        Ok value

                    else
                        Err "Can't be negative"
            , value = .classImportance
            , update = \value values -> { values | classImportance = value }
            , error = always Nothing
            , attributes =
                { label = "Importance"
                , max = Just 3
                , min = Just 0.0
                , step = 0.01
                , htmlAttributes = [ ( "helper-text", "1 to 3" ) ]
                }
            }

        relevanceStartsField : { parser : String -> Result String FuzzyMoment, value : Values -> String, update : String -> Values -> Values, error : Values -> Maybe String, attributes : TextField.Attributes }
        relevanceStartsField =
            { parser = HumanMoment.fuzzyFromString
            , value = .relevanceStarts
            , update = \value values -> { values | relevanceStarts = value }
            , error = always Nothing
            , attributes =
                { label = "Relevance Starts"
                , placeholder = "Immediately"
                , htmlAttributes = []
                }
            }

        relevanceEndsField : { parser : String -> Result String FuzzyMoment, value : Values -> String, update : String -> Values -> Values, error : Values -> Maybe String, attributes : TextField.Attributes }
        relevanceEndsField =
            { parser = HumanMoment.fuzzyFromString
            , value = .relevanceEnds
            , update = \value values -> { values | relevanceEnds = value }
            , error = always Nothing
            , attributes =
                { label = "Relevance Ends"
                , placeholder = "Never"
                , htmlAttributes = []
                }
            }

        externalDeadlineField : { parser : String -> Result String FuzzyMoment, value : Values -> String, update : String -> Values -> Values, error : Values -> Maybe String, attributes : TextField.Attributes }
        externalDeadlineField =
            { parser = HumanMoment.fuzzyFromString
            , value = .externalDeadline
            , update = \value values -> { values | externalDeadline = String.filter (\c -> Char.isDigit c || c == '-' || c == '/') value }
            , error = always Nothing
            , attributes =
                { label = "External Deadline"
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
                { label = "Reasonably Minimum Time Required"
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
                { label = "Reasonably Maximum Time Required"
                , max = Nothing
                , min = Just 1
                , step = 1
                , htmlAttributes = []
                }
            }

        progressMaxField : { parser : Maybe Float -> Result String (Maybe Int), value : Values -> Maybe Float, update : Maybe Float -> Values -> Values, error : Values -> Maybe String, attributes : RangeField.Attributes Float }
        progressMaxField =
            { parser = Ok << Maybe.map round
            , value = .progressMax >> Maybe.map toFloat
            , update = \value values -> { values | progressMax = Maybe.map round value }
            , error = always Nothing
            , attributes =
                { label = "Out Of:"
                , max = Just 100
                , min = Just 0
                , step = 1
                , htmlAttributes = []
                }
            }

        completionField : { parser : Maybe Float -> Result String (Maybe Int), value : Values -> Maybe Float, update : Maybe Float -> Values -> Values, error : Values -> Maybe String, attributes : RangeField.Attributes Float }
        completionField =
            { parser = Ok << Maybe.map round
            , value = .completion >> Maybe.map toFloat
            , update = \value values -> { values | completion = Maybe.map round value }
            , error = always Nothing
            , attributes =
                { label = "Completion:"
                , max = Just 100 -- TODO use progressMax
                , min = Just 0
                , step = 1
                , htmlAttributes = []
                }
            }

        rememberMeCheckbox =
            Form.checkboxField
                { parser = Ok
                , value = .rememberMe
                , update = \value values -> { values | rememberMe = value }
                , error = always Nothing
                , attributes =
                    { label = "Remember me"
                    , htmlAttributes = []
                    }
                }
    in
    Form.succeed Output
        |> Form.append (Form.textField classTitleField)
        |> Form.append (Form.rangeField classImportanceField)
        |> Form.append (Form.optional (Form.textField relevanceStartsField))
        |> Form.append (Form.optional (Form.textField relevanceEndsField))
        |> Form.append (Form.optional (Form.textField externalDeadlineField))
        |> Form.append (Form.rangeField minEffortField)
        |> Form.append (Form.rangeField estimatedEffortField)
        |> Form.append (Form.rangeField maxEffortField)
        |> Form.append (Form.rangeField progressMaxField)
        |> Form.append (Form.rangeField completionField)



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
        (Form.map Submit taskEditorForm)
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
            , [ Effect.Save <| outputToChanges model.action output
              , Effect.ClosePopup
              ]
            )


outputToChanges : Maybe Assignment -> Output -> Change.Frame
outputToChanges actionMaybe output =
    case actionMaybe of
        Just action ->
            let
                updateTitle =
                    if output.classTitle == Assignment.getTitle action then
                        Nothing

                    else
                        Just (Assignment.setProjectTitle output.classTitle action)

                updateImportance =
                    case output.classImportance of
                        Just newImportance ->
                            if newImportance == Assignment.getImportance action then
                                Nothing

                            else
                                Just (Assignment.setImportance action newImportance)

                        Nothing ->
                            Nothing

                updateEstimatedEffort =
                    if output.estimatedEffort == Assignment.getEstimatedEffort action then
                        Nothing

                    else
                        Just (Assignment.setEstimatedEffort action output.estimatedEffort)
            in
            Change.saveChanges "Editing a task" <|
                List.filterMap identity
                    [ updateTitle
                    , updateImportance
                    , updateEstimatedEffort
                    ]

        Nothing ->
            Change.none
