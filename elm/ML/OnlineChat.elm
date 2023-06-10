module ML.OnlineChat exposing (..)

import Form.View exposing (State(..))
import Http
import Incubator.Todoist exposing (decodeResponse)
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE exposing (Value)
import Url exposing (Url)


type alias Prediction =
    { initialPrompt : String
    , continuation : String
    , done : Bool
    }


newPrediction prompt =
    { initialPrompt = prompt
    , continuation = ""
    , done = False
    }


{-| Predict via Falcon.
-}
predict : (Result String Prediction -> msg) -> Prediction -> Cmd msg
predict toMsg predictionSoFar =
    Http.post
        { url = "https://api-inference.huggingface.co/models/tiiuae/falcon-7b-instruct"
        , body = Http.jsonBody (JE.object [ ( "inputs", JE.string (predictionSoFar.initialPrompt ++ predictionSoFar.continuation) ), ( "options", JE.object [ ( "wait_for_model", JE.bool True ) ] ) ])
        , expect = expectHFResponse toMsg predictionSoFar
        }


expectHFResponse : (Result String Prediction -> msg) -> Prediction -> Http.Expect msg
expectHFResponse toMsg predictionSoFar =
    let
        decodeResponse =
            JD.list (JD.at [ "generated_text" ] JD.string)
                |> JD.map List.head
                |> JD.map (Maybe.withDefault "")
                |> JD.map toNewPrediction

        charCountBefore =
            String.length (predictionSoFar.initialPrompt ++ predictionSoFar.continuation)

        toNewPrediction latestOutput =
            let
                latestAdditions =
                    String.dropLeft charCountBefore latestOutput
            in
            { initialPrompt = predictionSoFar.initialPrompt
            , continuation = predictionSoFar.continuation ++ latestAdditions
            , done = String.length latestAdditions == 0
            }
    in
    Http.expectStringResponse toMsg <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err ("BadUrl: " ++ url)

                Http.Timeout_ ->
                    Err "Timeout"

                Http.NetworkError_ ->
                    Err "NetworkError"

                Http.BadStatus_ metadata body ->
                    Err <| "ML fetch problem: " ++ metadata.statusText ++ "\n " ++ body

                Http.GoodStatus_ metadata body ->
                    case JD.decodeString decodeResponse body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err (JD.errorToString err)


resultToString : Result String Prediction -> String
resultToString result =
    case result of
        Ok prediction ->
            prediction.continuation

        Err value ->
            value
