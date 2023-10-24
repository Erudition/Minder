module Popup.Editor.Assignment exposing (..)

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
import Profile exposing (Profile)
import Replicated.Change as Change
import Replicated.Reducer.Register as Reg exposing (Reg)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import Task.Assignment as Assignment exposing (Assignment)
import Task.Progress exposing (Portion)


type alias Values =
    { relevanceStarts : String
    , relevanceEnds : String
    , externalDeadline : String
    , completion : Maybe Int
    }


type alias Output =
    { relevanceStarts : Maybe FuzzyMoment
    , relevanceEnds : Maybe FuzzyMoment
    , externalDeadline : Maybe FuzzyMoment
    , completion : Int
    }


initialModel : Profile -> Maybe Assignment -> Model
initialModel profile assignmentMaybe =
    let
        initialRawValues : Assignment -> Values
        initialRawValues assignment =
            { relevanceStarts = Assignment.relevanceStarts assignment |> Maybe.map HumanMoment.fuzzyToString |> Maybe.withDefault ""
            , relevanceEnds = Assignment.relevanceEnds assignment |> Maybe.map HumanMoment.fuzzyToString |> Maybe.withDefault ""
            , externalDeadline = Assignment.externalDeadline assignment |> Maybe.map HumanMoment.fuzzyToString |> Maybe.withDefault ""
            , completion = Assignment.completion assignment |> Just
            }

        brandNew : Values
        brandNew =
            { relevanceStarts = ""
            , relevanceEnds = ""
            , externalDeadline = ""
            , completion = Just 0
            }

        initialFormModel =
            Form.View.idle <|
                Maybe.withDefault brandNew <|
                    Maybe.map initialRawValues assignmentMaybe
    in
    { assignment = assignmentMaybe, formModel = initialFormModel }


type alias FormModel =
    Form.View.Model Values


type alias Model =
    { formModel : FormModel
    , assignment : Maybe Assignment
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

        completionField : { parser : Maybe Float -> Result String Int, value : Values -> Maybe Float, update : Maybe Float -> Values -> Values, error : Values -> Maybe String, attributes : RangeField.Attributes Float }
        completionField =
            { parser = \input -> Result.fromMaybe "bad completion field input" (Maybe.map round input)
            , value = .completion >> Maybe.map toFloat
            , update = \value values -> { values | completion = Maybe.map round value }
            , error = always Nothing
            , attributes =
                { label = "Completion:"
                , max = Just 100.0 -- TODO use progressMax
                , min = Just 0.0
                , step = 1
                , htmlAttributes = []
                }
            }
    in
    Form.succeed Output
        |> Form.append (Form.optional (Form.textField relevanceStartsField))
        |> Form.append (Form.optional (Form.textField relevanceEndsField))
        |> Form.append (Form.optional (Form.textField externalDeadlineField))
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
            , [ Effect.saveFrame <| outputToChanges model.assignment output

              --, Effect.ClosePopup
              ]
            )


outputToChanges : Maybe Assignment -> Output -> Change.Frame
outputToChanges existingAssignmentMaybe output =
    case existingAssignmentMaybe of
        Just existingAssignment ->
            let
                updateRelevanceStarts =
                    if output.relevanceStarts == Assignment.relevanceStarts existingAssignment then
                        Nothing

                    else
                        Just (Assignment.setRelevanceStarts output.relevanceStarts existingAssignment)

                updateRelevanceEnds =
                    if output.relevanceEnds == Assignment.relevanceEnds existingAssignment then
                        Nothing

                    else
                        Just (Assignment.setRelevanceEnds output.relevanceEnds existingAssignment)

                updateExternalDeadline =
                    if output.externalDeadline == Assignment.externalDeadline existingAssignment then
                        Nothing

                    else
                        Just (Assignment.setExternalDeadline output.externalDeadline existingAssignment)

                updateCompletion =
                    if output.completion == Assignment.completion existingAssignment then
                        Nothing

                    else
                        Just (Assignment.setCompletion output.completion existingAssignment)
            in
            Change.saveChanges "Editing an assignment" <|
                List.filterMap identity
                    [ updateRelevanceStarts
                    , updateRelevanceEnds
                    , updateExternalDeadline
                    , updateCompletion
                    ]

        Nothing ->
            Change.emptyFrame
