module Showstopper exposing (..)

import Activity.HistorySession exposing (HistorySession(..))
import Browser.Navigation exposing (..)
import Css
import Dict
import External.Commands exposing (..)
import Html.Styled as H exposing (Html, div, text)
import Html.Styled.Attributes as HA exposing (class)
import Json.Decode as JD
import Json.Decode.Exploration exposing (..)
import NativeScript.Commands exposing (..)
import Parser.Advanced as Parser
import Profile exposing (..)
import Replicated.Codec as Codec
import Replicated.Node.Node as Node
import Replicated.Op.Op as Op
import Replicated.Op.OpID as OpID
import Shared.Model exposing (..)
import SmartTime.Human.Duration exposing (HumanDuration(..))
import Url


type Msg
    = TryAgain


type InitFailure
    = ImportFail (List Node.OpImportWarning)
    | DecodeNodeFail (Codec.Error String)
    | OtherFail Node.InitError


type alias ShowstopperDetails =
    { savedRon : String
    , problem : InitFailure
    , url : Url.Url
    }


type alias OpParserDeadEnd =
    Parser.DeadEnd Op.Context Op.Problem


view : ShowstopperDetails -> Html Msg
view { savedRon, problem } =
    let
        viewProblem =
            case problem of
                ImportFail opImportWarningList ->
                    viewImportWarnings savedRon opImportWarningList

                OtherFail (Node.BadRon opImportWarningList) ->
                    -- TODO do we really need both of these
                    viewImportWarnings savedRon opImportWarningList

                DecodeNodeFail codecError ->
                    viewCodecError savedRon codecError

                OtherFail Node.DecodingOldIdentityProblem ->
                    [ H.h1 [] [ H.text "Showstopper: Identity data is corrupt" ]
                    , viewSavedRon savedRon []
                    ]
    in
    H.section [ class "showstopper" ]
        viewProblem


viewCodecError : String -> Codec.Error String -> List (Html msg)
viewCodecError savedRon codecError =
    [ H.h1 [] [ H.text "Showstopper" ]
    , H.h2 [] [ H.text "Node failed to decode" ]
    , H.h3 [] [ H.text (codecErrorToString codecError) ]
    , viewSavedRon savedRon []
    ]


codecErrorToString codecError =
    case codecError of
        Codec.CustomError string ->
            string

        Codec.DataCorrupted ->
            "Data Corrupted"

        Codec.SerializerOutOfDate ->
            "Serializer Out Of Date"

        Codec.ObjectNotFound opID ->
            "Object Not Found: " ++ OpID.toString opID

        Codec.FailedToDecodeRoot root ->
            "Failed to decode root. Problem is probably nested deeper:        " ++ root

        Codec.JDError jdError ->
            JD.errorToString jdError


viewSavedRon : String -> List OpParserDeadEnd -> Html msg
viewSavedRon savedRon deadEndList =
    let
        lines =
            String.lines savedRon

        linesWithRowNum =
            List.indexedMap (\n l -> ( n + 1, l )) lines

        linesFormatted =
            List.map formatLine linesWithRowNum

        formatLine ( rowNum, lineText ) =
            case List.filter (\{ row } -> row == rowNum) deadEndList of
                [] ->
                    -- no problems on this line
                    showLine rowNum [ text lineText ]

                deadEndsThisRow ->
                    showLine rowNum (splitLine deadEndsThisRow lineText)

        showLine rowNum lineContents =
            H.pre []
                [ H.span
                    [ HA.css [ Css.color (Css.rgb 191 191 191) ] ]
                    [ text (String.fromInt rowNum ++ " ") ]
                , H.span [] lineContents
                ]

        splitLine deadEndsThisRow lineText =
            -- TODO don't add new text node for every single char
            List.indexedMap (checkDeadEndColumn deadEndsThisRow) (String.toList lineText ++ [ '⇤' ])

        checkDeadEndColumn deadEndsThisRow colMinusOne char =
            case List.filter (\d -> d.col == colMinusOne + 1) deadEndsThisRow of
                [] ->
                    text <| String.fromChar char

                deadEndsThisColumn ->
                    showProblemColumn (List.map .problem deadEndsThisColumn) char

        showProblemColumn problemsHere char =
            H.span
                [ HA.css [ Css.backgroundColor (Css.rgb 255 0 0) ]
                , HA.title
                    (String.join "\n" <| List.map Op.problemToString problemsHere)
                ]
                [ text <| String.fromChar char ]
    in
    H.section [] linesFormatted


deadEndToString : OpParserDeadEnd -> String
deadEndToString { row, col, problem, contextStack } =
    Op.problemToString problem ++ " at row " ++ String.fromInt row ++ ", col " ++ String.fromInt col ++ ", while parsing " ++ Op.contextStackToString contextStack


viewImportWarnings savedRon opImportWarningList =
    let
        keepParseFailure warning =
            case warning of
                Node.ParseFail deadEndList ->
                    Just deadEndList

                _ ->
                    Nothing
    in
    [ H.h1 [] [ H.text "Import Warnings Encountered" ]
    , H.h2 [] [ H.text "Did not import RON cleanly" ]
    , H.div [] (List.map viewImportWarning opImportWarningList)
    , viewSavedRon savedRon (List.filterMap keepParseFailure opImportWarningList |> List.concat)
    ]


viewImportWarning importWarning =
    case importWarning of
        Node.ParseFail deadEndList ->
            let
                perDeadEnd deadEnd =
                    H.pre
                        [ HA.css
                            [ Css.border3 (Css.px 2) Css.solid (Css.rgb 255 0 0)
                            , Css.backgroundColor (Css.rgb 255 0 0)
                            ]
                        ]
                        [ text (deadEndToString deadEnd) ]
            in
            div [] (List.map perDeadEnd deadEndList)

        Node.UnknownReference opID ->
            div []
                [ text <| "I don't recognize the OpID: " ++ OpID.toString opID
                ]

        Node.EmptyChunk ->
            div []
                [ text <| "I encountered an empty Chunk"
                ]
