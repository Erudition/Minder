module Activity.Switch exposing (Switch, decodeSwitch, encodeSwitch, getActivityID, getInstanceID, getMoment, newSwitch, switchToActivity)

import Activity.Activity exposing (Activity, ActivityID)
import Activity.Evidence exposing (..)
import Activity.Template exposing (..)
import Date
import Dict exposing (..)
import External.Commands as Commands exposing (..)
import Helpers exposing (..)
import ID exposing (ID)
import IntDict exposing (IntDict)
import Ionicon
import Ionicon.Android as Android
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import List.Nonempty exposing (..)
import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Duration as HumanDuration exposing (..)
import SmartTime.Moment as Moment exposing (..)
import Task.Instance exposing (InstanceID)


type Switch
    = Switch Moment ActivityID (Maybe InstanceID)


decodeSwitch : Decoder Switch
decodeSwitch =
    decode Switch
        |> required "Time" decodeMoment
        |> required "Activity" ID.decode
        |> optional "Instance" (nullable Task.Instance.decodeInstanceID) Nothing


encodeSwitch : Switch -> Encode.Value
encodeSwitch (Switch time activityId instanceIDMaybe) =
    let
        optionals =
            case instanceIDMaybe of
                Just instanceID ->
                    [ ( "Instance", Task.Instance.encodeInstanceID instanceID ) ]

                Nothing ->
                    []
    in
    Encode.object <| [ ( "Time", encodeMoment time ), ( "Activity", ID.encode activityId ) ] ++ optionals


switchToActivity : Moment -> ActivityID -> Switch
switchToActivity moment activityID =
    Switch moment activityID Nothing


newSwitch : Moment -> ActivityID -> Maybe InstanceID -> Switch
newSwitch moment activityID instanceIDMaybe =
    Switch moment activityID instanceIDMaybe


getActivityID : Switch -> ActivityID
getActivityID (Switch _ activityID _) =
    activityID


getMoment : Switch -> Moment
getMoment (Switch moment _ _) =
    moment


getInstanceID : Switch -> Maybe InstanceID
getInstanceID (Switch _ _ instanceIDMaybe) =
    instanceIDMaybe
