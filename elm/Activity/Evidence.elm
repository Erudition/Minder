module Activity.Evidence exposing (AppDescriptor, Device, Evidence(..), StepsPerMinute, codec)

import Helpers exposing (..)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Replicated.Codec as Codec exposing (Codec, PrimitiveCodec, coreRW, fieldList, fieldRW)


type Evidence
    = UsingApp AppDescriptor (Maybe Device)
    | StepCountPace StepsPerMinute


codec : Codec.NullCodec e Evidence
codec =
    Codec.customType
        (\usingApp stepCountPace value ->
            case value of
                UsingApp appDescriptor deviceMaybe ->
                    usingApp appDescriptor deviceMaybe

                StepCountPace stepsPerMinute ->
                    stepCountPace stepsPerMinute
        )
        |> Codec.variant2 ( 1, "UsingApp" ) UsingApp appDescriptorCodec (Codec.maybe Codec.string)
        |> Codec.variant1 ( 2, "StepCountPace" ) StepCountPace Codec.int
        |> Codec.finishCustomType


type alias AppDescriptor =
    { package : String
    , name : String
    }


appDescriptorCodec : Codec e ( String, String ) Codec.SoloObject AppDescriptor
appDescriptorCodec =
    Codec.record AppDescriptor
        |> Codec.coreR ( 1, "package" ) .package Codec.string (\( p, n ) -> p)
        |> Codec.coreR ( 2, "name" ) .name Codec.string (\( p, n ) -> n)
        |> Codec.finishSeededRecord


type alias StepsPerMinute =
    Int


type alias Device =
    String
