module External.Notification exposing (BadgeType(..), CategoryID, Command, Detail(..), Events, MediaInfo, Notification, Path, Priority(..), Privacy(..), UpdateStrategy(..), basic, blank, encodeDuration, encodeMediaInfo, encodeNotification, encodePriority, encodeVibrationPattern)

import Json.Encode as Encode
import Json.Encode.Extra as Encode
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Moment as Moment exposing (Moment)


type alias Notification =
    { id : NotificationID -- 1
    , persistent : Bool -- 2
    , timeout : Duration -- 3
    , update : UpdateStrategy -- 4: not supported in autonotification variables
    , priority : Priority -- 5
    , privacy : Privacy -- 6: not supported in autonotification variables
    , useHTML : Bool -- 7: not supported in autonotification variables
    , title : String -- 8
    , title_expanded : String -- 9
    , body : String -- 10 ("text")
    , body_expanded : String -- 11 ("text expanded")
    , subtext : String -- 12
    , detail : Detail -- 13 & 14: need to be Int?
    , ticker : String -- 15
    , icon : String -- 16
    , status_icon : String -- 17
    , status_text_size : Int -- 18 (in sp)
    , background_color : String -- 19
    , color_from_media : Bool -- 20: not supported in autonotification variables
    , badge : BadgeType -- 21:  not supported in autonotification variables
    , picture : String -- 22
    , picture_skip_cache : Bool -- 23  not supported in autonotification variables
    , picture_expanded_icon : String -- 24
    , media_layout : Bool -- 25 not supported in autonotification variables
    , media : Maybe MediaInfo -- 26
    , url : String --29
    , on_create : Command
    , on_touch : Command
    , on_dismiss : Command
    , dismiss_on_touch : Bool
    , time : Maybe Moment
    , chronometer : Bool
    , countdown : Bool
    , category : CategoryID
    , led_color : String -- AN not supported
    , led_on_duration : Duration -- ms
    , led_off_duration : Duration -- ms
    , progress_max : Int
    , progress_current : Int
    , progress_indeterminate : Bool -- AN not supported
    , sound : Path
    , vibration_pattern : List Duration
    , phone_only : Bool -- AN not supported
    }


blank : Notification
blank =
    { id = ""
    , persistent = False
    , timeout = Duration.zero
    , update = New
    , priority = Default
    , privacy = Public
    , useHTML = False
    , title = ""
    , title_expanded = ""
    , body = ""
    , body_expanded = ""
    , subtext = ""
    , detail = Number 0
    , ticker = ""
    , icon = ""
    , status_icon = ""
    , status_text_size = 0
    , background_color = ""
    , color_from_media = False
    , badge = NoBadge
    , picture = ""
    , picture_skip_cache = False
    , picture_expanded_icon = ""
    , media_layout = False
    , media = Nothing
    , url = ""
    , on_create = ""
    , on_touch = ""
    , on_dismiss = ""
    , dismiss_on_touch = False
    , time = Nothing
    , chronometer = False
    , countdown = False
    , category = ""
    , led_color = ""
    , led_on_duration = Duration.fromMs 1000
    , led_off_duration = Duration.fromMs 1000
    , progress_max = 0
    , progress_current = 0
    , progress_indeterminate = False
    , sound = ""
    , vibration_pattern = []
    , phone_only = False
    }


encodeNotification : Notification -> Encode.Value
encodeNotification v =
    Encode.object
        [ ( "id", Encode.string v.id )
        , ( "persistent", Encode.bool v.persistent )
        , ( "timeout", encodeTimeout v.timeout )
        , ( "update"
          , case v.update of
                New ->
                    Encode.string "New"

                Replace ->
                    Encode.string "Replace"

                Append ->
                    Encode.string "Append"
          )
        , ( "priority", encodePriority v.priority )
        , ( "privacy"
          , case v.privacy of
                Public ->
                    Encode.string "Public"

                Private ->
                    Encode.string "Private"

                PrivateWithPublicVersion publicversion ->
                    Encode.string "PrivateWithPublicVersion"

                Secret ->
                    Encode.string "Secret"
          )
        , ( "useHTML", Encode.bool v.useHTML )
        , ( "title", Encode.string v.title )
        , ( "title_expanded", Encode.string v.title_expanded )
        , ( "body", Encode.string v.body )
        , ( "body_expanded", Encode.string v.body_expanded )
        , ( "subtext", Encode.string v.subtext )
        , ( "detail"
          , case v.detail of
                Number n ->
                    Encode.int n

                Info s ->
                    Encode.string s
          )
        , ( "ticker", Encode.string v.ticker )
        , ( "icon", Encode.string v.icon )
        , ( "status_icon", Encode.string v.status_icon )
        , ( "status_text_size", Encode.int v.status_text_size )
        , ( "background_color", Encode.string v.background_color )
        , ( "color_from_media", Encode.bool v.color_from_media )
        , ( "badge"
          , case v.badge of
                NoBadge ->
                    Encode.string "NoBadge"

                SmallIcon ->
                    Encode.string "SmallIcon"

                LargeIcon ->
                    Encode.string "LargeIcon"
          )
        , ( "picture", Encode.string v.picture )
        , ( "picture_skip_cache", Encode.bool v.picture_skip_cache )
        , ( "picture_expanded_icon", Encode.string v.picture_expanded_icon )
        , ( "media_layout", Encode.bool v.media_layout )
        , ( "media", Encode.maybe encodeMediaInfo v.media )
        , ( "url", Encode.string v.url )
        , ( "on_create", Encode.string v.on_create )
        , ( "on_touch", Encode.string v.on_touch )
        , ( "on_dismiss", Encode.string v.on_dismiss )
        , ( "dismiss_on_touch", Encode.bool v.dismiss_on_touch )
        , ( "time", Encode.maybe Encode.int <| Maybe.map Moment.toUnixTimeInt v.time )
        , ( "chronometer", Encode.bool v.chronometer )
        , ( "countdown", Encode.bool v.countdown )
        , ( "category", Encode.string v.category )
        , ( "led_color", Encode.string v.led_color )
        , ( "led_on_duration", encodeDuration v.led_on_duration )
        , ( "led_off_duration", encodeDuration v.led_off_duration )
        , ( "progress_max", Encode.int v.progress_max )
        , ( "progress_current", Encode.int v.progress_current )
        , ( "progress_indeterminate", Encode.bool v.progress_indeterminate )
        , ( "sound", Encode.string v.sound )
        , ( "vibration_pattern", encodeVibrationPattern v.vibration_pattern )
        , ( "phone_only", Encode.bool v.phone_only )
        ]


type alias Command =
    String


type alias NotificationID =
    String


type alias Path =
    String


type alias CategoryID =
    String


type Priority
    = Default
    | Low
    | High
    | Min
    | Max


encodePriority : Priority -> Encode.Value
encodePriority v =
    case v of
        Default ->
            Encode.int 0

        Low ->
            Encode.int -1

        High ->
            Encode.int 1

        Min ->
            Encode.int -2

        Max ->
            Encode.int 2


type Privacy
    = Public
    | Private
    | PrivateWithPublicVersion Notification
    | Secret


type UpdateStrategy
    = New
    | Replace
    | Append


type Detail
    = Number Int
    | Info String


type BadgeType
    = NoBadge
    | SmallIcon
    | LargeIcon


type alias MediaInfo =
    { title : String
    }


encodeMediaInfo : MediaInfo -> Encode.Value
encodeMediaInfo v =
    Encode.object
        [ ( "title", Encode.string v.title )
        ]


type alias Events msg =
    { onCreate : Maybe msg --27
    , onTouch : Maybe msg --28
    , onDismiss : Maybe msg --30
    }


encodeDuration : Duration -> Encode.Value
encodeDuration dur =
    Encode.int (Duration.inMs dur)


type alias Timeout =
    Duration


encodeTimeout : Duration -> Encode.Value
encodeTimeout dur =
    Encode.int (Duration.inSecondsRounded dur)


encodeVibrationPattern : List Duration -> Encode.Value
encodeVibrationPattern durs =
    Encode.string <| String.concat <| List.map (String.fromInt << Duration.inMs) durs



-- Funcs---------------------------------------------------------------------------NOTE


basic : String -> Duration -> String -> String -> Notification
basic id timeout title body =
    { blank | title = title, body = body, id = id, timeout = timeout }
