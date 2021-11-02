module Activity.Timeline exposing (..)

import Activity.Activity exposing (Activity, ActivityID, getActivity)
import Activity.Evidence exposing (..)
import Activity.Switch as Switch exposing (Switch(..), switchToActivity)
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


type alias Timeline =
    List Switch


latestSwitch : Timeline -> Switch
latestSwitch timeline =
    Maybe.withDefault (switchToActivity Moment.zero (ID.tag 0)) (List.head timeline)


currentActivityID : Timeline -> ActivityID
currentActivityID switchList =
    Switch.getActivityID (latestSwitch switchList)


currentActivity : IntDict Activity -> Timeline -> Activity
currentActivity activities switchList =
    getActivity (currentActivityID switchList) activities
