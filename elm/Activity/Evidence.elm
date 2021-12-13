module Activity.Evidence exposing (AppDescriptor, Device, Evidence(..), StepsPerMinute, decodeEvidence, encodeEvidence)

import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Helpers exposing (..)


type Evidence
    = UsingApp AppDescriptor (Maybe Device)
    | StepCountPace StepsPerMinute


type alias AppDescriptor =
    { package : String
    , name : String
    }


type alias StepsPerMinute =
    Int


type alias Device =
    String


decodeEvidence : Decoder Evidence
decodeEvidence =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "UsingApp" ->
                        Decode.succeed (UsingApp (AppDescriptor "" "") Nothing)

                    "StepCountPace" ->
                        Decode.succeed (StepCountPace 0)

                    _ ->
                        Decode.fail "Invalid Evidence"
            )


encodeEvidence : Evidence -> Encode.Value
encodeEvidence v =
    case v of
        UsingApp _ _ ->
            Encode.string "UsingApp"

        StepCountPace pace ->
            Encode.string "StepCountPace"
