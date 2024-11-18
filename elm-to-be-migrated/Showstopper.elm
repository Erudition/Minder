module ...elm-to-be-migrated.Showstopper exposing (..)

import Activity.HistorySession exposing (HistorySession)
import Browser.Navigation exposing (..)
import Color
import Css
import Dict
import External.Commands exposing (..)
import Html.Styled as SH exposing (Html, div, text)
import Html.Styled.Attributes as SHA exposing (class, css)
import Json.Decode as JD
import Json.Decode.Exploration exposing (..)
import Json.Encode as JE
import NativeScript.Commands exposing (..)
import Parser.Advanced as Parser
import Profile exposing (..)
import Replicated.Codec as Codec
import Replicated.Node.Node as Node
import Replicated.Op.Op as Op
import Replicated.Op.ID as OpID
import OldShared.Model exposing (..)
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
                    [ SH.h1 [] [ SH.text "Showstopper: Identity data is corrupt" ]
                    , viewSavedRon savedRon []
                    ]
    in
    SH.section
        [ class "showstopper"
        , css [ Css.overflow Css.scroll, Css.height (Css.vh 100), Css.backgroundColor (Css.rgb 255 255 255) ] -- override Ionic overflow:hidden on page
        ]
        viewProblem


viewCodecError : String -> Codec.Error String -> List (Html msg)
viewCodecError savedRon codecError =
    [ SH.h1 [] [ SH.text "Showstopper" ]
    , SH.h2 [] [ SH.text "Node failed to decode" ]
    , SH.h3 [] [ SH.text (codecErrorToString codecError) ]
    , viewSavedRon savedRon []
    ]


codecErrorToString codecError =
    Codec.errorToString codecError


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
            SH.pre []
                [ SH.span
                    [ SHA.css [ Css.color (Css.rgb 191 191 191) ] ]
                    [ text (String.fromInt rowNum ++ " ") ]
                , SH.span [] lineContents
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
            SH.span
                [ SHA.css [ Css.backgroundColor (Css.rgb 255 0 0) ]
                , SHA.title
                    (String.join "\n" <| List.map Op.problemToString problemsHere)
                ]
                [ text <| String.fromChar char ]
    in
    SH.section [] linesFormatted


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
    [ SH.h1 [] [ SH.text "Import Warnings Encountered" ]
    , SH.h2 [] [ SH.text "Did not import RON cleanly" ]
    , SH.div [] (List.map viewImportWarning opImportWarningList)
    , viewSavedRon savedRon (List.filterMap keepParseFailure opImportWarningList |> List.concat)
    ]


viewImportWarning importWarning =
    case importWarning of
        Node.ParseFail deadEndList ->
            let
                perDeadEnd deadEnd =
                    SH.pre
                        [ SHA.css
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

        Node.NoSuccessfulOps badFrame ->
            div []
                [ text <| "No ops added to node after processing this frame!"
                , SH.pre [ SHA.css [ Css.color (Css.rgb 200 0 0) ] ] [ text <| badFrame ]
                ]
