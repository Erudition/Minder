module Activity.Switch exposing (Switch, codec, getActivityID, getInstanceID, getMoment, newSwitch, switchToActivity)

import Activity.Activity exposing (Activity, ActivityID)
import Activity.Evidence exposing (..)
import Activity.Template exposing (..)
import Date
import Dict exposing (..)
import External.Commands as Commands exposing (..)
import ExtraCodecs as Codec
import Helpers exposing (..)
import ID exposing (ID)
import IntDict exposing (IntDict)
import Ionicon
import Ionicon.Android as Android
import List.Nonempty exposing (..)
import Replicated.Codec as Codec exposing (Codec, coreR, coreRW, fieldDict, fieldList, fieldR, fieldRW)
import Replicated.Reducer.Register as Register exposing (RW)
import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Duration as HumanDuration exposing (..)
import SmartTime.Moment as Moment exposing (..)
import Task.AssignedAction exposing (AssignedActionID)


type Switch
    = Switch SwitchSkel


type alias SwitchSkel =
    { moment : Moment
    , newActivity : ActivityID
    , newActionMaybe : Maybe AssignedActionID
    }


codec : Codec String Switch
codec =
    let
        skelCodec : Codec String SwitchSkel
        skelCodec =
            Codec.record SwitchSkel
                |> coreR ( 1, "moment" ) .moment Codec.moment
                |> coreR ( 2, "newActivity" ) .newActivity Codec.id
                |> fieldR ( 3, "newActionMaybe" ) .newActionMaybe (Codec.maybe Codec.id) Nothing
                |> Codec.finishRecord
    in
    Codec.map Switch (\(Switch skel) -> skel) skelCodec



--
-- encodeSwitch : Switch -> Encode.Value
-- encodeSwitch (Switch time activityId instanceIDMaybe) =
--     let
--         optionals =
--             case instanceIDMaybe of
--                 Just instanceID ->
--                     [ ( "Instance", Task.AssignedAction.encodeAssignedActionID instanceID ) ]
--
--                 Nothing ->
--                     []
--     in
--     Encode.object <| [ ( "Time", encodeMoment time ), ( "Activity", ID.encode activityId ) ] ++ optionals


switchToActivity : Moment -> ActivityID -> Switch
switchToActivity moment activityID =
    Switch (SwitchSkel moment activityID Nothing)


newSwitch : Moment -> ActivityID -> Maybe AssignedActionID -> Switch
newSwitch moment activityID instanceIDMaybe =
    Switch (SwitchSkel moment activityID instanceIDMaybe)


getActivityID : Switch -> ActivityID
getActivityID (Switch { newActivity }) =
    newActivity


getMoment : Switch -> Moment
getMoment (Switch { moment }) =
    moment


getInstanceID : Switch -> Maybe AssignedActionID
getInstanceID (Switch { newActionMaybe }) =
    newActionMaybe
