module Activity.Switch exposing (Switch, decodeSwitch, encodeSwitch, getActivityID, getMoment, switchToActivity)

import Activity.Activity exposing (Activity, ActivityID)
import Activity.Evidence exposing (..)
import Activity.Template exposing (..)
import Date
import Dict exposing (..)
import External.Commands as Commands exposing (..)
import ID exposing (ID)
import IntDict exposing (IntDict)
import Ionicon
import Ionicon.Android as Android
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import List.Nonempty exposing (..)
import Porting exposing (..)
import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Duration as HumanDuration exposing (..)
import SmartTime.Moment as Moment exposing (..)
import Svg.Styled exposing (..)
import Time
import Time.Extra exposing (..)


type Switch
    = Switch Moment ActivityID


decodeSwitch : Decoder Switch
decodeSwitch =
    subtype2 Switch "Time" decodeMoment "Activity" ID.decode


encodeSwitch : Switch -> Encode.Value
encodeSwitch (Switch time activityId) =
    Encode.object [ ( "Time", encodeMoment time ), ( "Activity", ID.encode activityId ) ]


switchToActivity : Moment -> ActivityID -> Switch
switchToActivity moment activityID =
    Switch moment activityID


getActivityID : Switch -> ActivityID
getActivityID (Switch _ activityID) =
    activityID


getMoment : Switch -> Moment
getMoment (Switch moment _) =
    moment
