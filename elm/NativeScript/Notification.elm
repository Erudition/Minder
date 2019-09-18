module NativeScript.Notification exposing (Action, BadgeType(..), ButtonType(..), ChannelID, Command, Detail(..), EncodedNotification, Events, Importance(..), LEDcolor, MediaInfo, Notification, NotificationID, Path, Privacy(..), ProgressBar(..), RepeatEvery(..), ResourceURL, Sound(..), Thumbnail(..), Timeout, UpdateStrategy(..), WebURL, basic, blank, encode, encodeAction, encodeDuration, encodeExpiresAfter, encodeImportance, encodeMediaInfo, encodevibratePattern)

import Json.Encode as Encode
import Json.Encode.Extra as Encode
import Porting exposing (normal, omittable, omittableList)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Moment as Moment exposing (Moment)


type alias Notification =
    { -- Default is (Channel). Set the channel name for Android API >= 26, which is shown when the user longpresses a notification. (Android Only)
      channel : ChannelID

    -- A number so you can easily distinguish your notifications. Will be generated if not set.
    , id : Maybe NotificationID

    -- The title which is shown in the statusbar. Default not set.
    , title : Maybe String

    -- Shown below the title on iOS, and next to the App name on Android. Default not set. All android and iOS >= 10 only.
    , subtitle : Maybe String -- or "subtext"?

    -- The text below the title. If not provided, the subtitle or title (in this order or priority) will be swapped for it on iOS, as iOS won't display notifications without a body. Default not set on Android, ' ' on iOS, as otherwise the notification won't show up at all.
    , body : Maybe String

    -- Default is (false). Set whether this is an ongoing notification. Ongoing notifications cannot be dismissed by the user, so your application must take care of canceling them. (Android Only)
    , ongoing : Maybe Bool -- aka persistent

    -- Allow more than 1 line of the body text to show in the notification centre. Mutually exclusive with image. Default false. (Android Only)
    , bigTextStyle : Maybe Bool

    -- An array of atmost 5 messages that would be displayed using android's notification inboxStyle. Note: The array would be trimed from the top if the messages exceed five. Default not set
    , groupedMessages : Maybe (List String)

    -- On Android you can show a different text in the statusbar, instead of the body. Default not set, so body is used.
    -- Now used for accesibility (screen readers)
    , ticker : Maybe String

    -- A Moment indicating when the notification should be shown. Default not set (the notification will be shown immediately).
    , at : Maybe Moment

    -- On iOS (and some Android devices) you see a number on top of the app icon. On most Android devices you'll see this number in the notification center. Default not set (0).
    , badge : Maybe Int

    -- Notification sound. For custom notification sound (iOS only), copy the file to App_Resources/iOS. Set this to "default" (or do not set at all) in order to use default OS sound. Set this to null to suppress sound.
    , sound : Maybe Sound

    -- Set to one of second, minute, hour, day, week, month, year if you want a recurring notification.
    , interval : Maybe RepeatEvery

    -- On Android you can set a custom icon in the system tray. Pass in res://filename (without the extension) which lives in App_Resouces/Android/drawable folders. If not passed, we'll look there for a file named ic_stat_notify.png. By default the app icon is used. Android < Lollipop (21) only (see silhouetteIcon below).
    , icon : Maybe Path -- 16

    -- Same as icon, but for Android >= Lollipop (21). Should be an alpha-only image. Defaults to res://ic_stat_notify_silhouette, or the app icon if not present.
    , silhouetteIcon : Maybe Path

    -- URL (http..) of the image to use as an expandable notification image. On Android this is mutually exclusive with bigTextStyle.
    , image : Maybe Path

    -- Custom thumbnail/icon to show in the notification center (to the right) on Android, this can be either: true (if you want to use the image as the thumbnail), a resource URL (that lives in the App_Resouces/Android/drawable folders, e.g.: res://filename), or a http URL from anywhere on the web. (Android Only). Default not set.
    , thumbnail : Maybe Thumbnail

    -- Default is false. Set to true to always show the notification. Note that on iOS < 10 this is ignored (the notification is not shown), and on newer Androids it's currently ignored as well (the notification always shows, per platform default).
    , forceShowWhenInForeground : Maybe Bool

    -- Enable the notification LED light on Android (if supported by the device), this can be either: true (if you want to use the default color), or a custom color for the notification LED light (if supported by the device). (Android Only). Default not set.
    , notificationLed : Maybe LEDcolor

    -- Add an array of NotificationAction objects (see below) to add buttons or text input to a notification.
    , actions : List Action

    ------  That's it for the original plugin support
    , importance : Maybe Importance -- ADDED BY ME

    -- Notification Timeout
    , expiresAfter : Maybe Duration -- ADDED BY ME

    -- Empty list for no vibrate, Nothing for default behavior
    , vibratePattern : Maybe (List ( VibratorOff, VibratorOn )) -- ADDED BY ME
    , autoCancel : Maybe Bool -- ADDED BY ME
    , progress : Maybe ProgressBar -- ADDED BY ME
    , channelDescription : Maybe String -- ADDED BY ME
    , when : Maybe Moment -- ADDED BY ME
    , chronometer : Maybe Bool -- ADDED BY ME

    -- Newer Android: What group should this notification be bundled into? For example, if your app has a messaging system, the recent messages can be bundled together, even from different people (which could mean different notification channels), and summarized with a groupSummary-type notification. Warning: If group is not specified, Android will bundle up your notifications into one big "group" if there are more than 3 of them in the drawer. To avoid this, specify a unique group for notifications you don't want bundled.
    , group : Maybe GroupKey

    -- Specify that the notification should be used as the summary of all other notifications in its group. Notifications sharing the group may be bundled inside this one.
    , isGroupSummary : Maybe Bool

    -- Specify that the notification should be used as the summary of all other notifications in its group. Notifications sharing the group may be bundled inside this one.
    , groupAlertBehavior : Maybe Int
    , sortKey : Maybe String
    , accentColor : Maybe String

    ------ End of features added by me
    , update : Maybe UpdateStrategy -- NOT YET SUPPORTED
    , privacy : Maybe Privacy -- NOT YET SUPPORTED
    , useHTML : Maybe Bool -- NOT YET SUPPORTED
    , title_expanded : Maybe String -- ?
    , body_expanded : Maybe String -- ?
    , detail : Maybe Detail -- NOT YET SUPPORTED
    , status_icon : Maybe String -- NOT YET SUPPORTED
    , status_text_size : Maybe Int -- NOT YET SUPPORTED (in sp units)
    , background_color : Maybe String -- NOT YET SUPPORTED
    , color_from_media : Maybe Bool -- NOT YET SUPPORTED
    , picture_skip_cache : Maybe Bool -- NOT YET SUPPORTED
    , picture_expanded_icon : Maybe String -- NOT YET SUPPORTED
    , media_layout : Maybe Bool -- NOT YET SUPPORTED
    , media : Maybe MediaInfo -- NOT YET SUPPORTED
    , url : Maybe String -- NOT YET SUPPORTED
    , on_create : Maybe Command -- NOT YET SUPPORTED
    , on_touch : Maybe Command -- NOT YET SUPPORTED
    , on_dismiss : Maybe Command -- NOT YET SUPPORTED
    , countdown : Maybe Bool -- NOT YET SUPPORTED
    , led_on_duration : Maybe Duration -- NOT YET SUPPORTED ms
    , led_off_duration : Maybe Duration -- NOT YET SUPPORTED ms
    , phone_only : Maybe Bool -- NOT YET SUPPORTED
    }


blank : ChannelID -> Notification
blank channel =
    { channel = channel, id = Nothing, title = Nothing, subtitle = Nothing, body = Nothing, ongoing = Nothing, bigTextStyle = Nothing, groupedMessages = Nothing, ticker = Nothing, at = Nothing, badge = Nothing, sound = Nothing, interval = Nothing, icon = Nothing, silhouetteIcon = Nothing, image = Nothing, thumbnail = Nothing, forceShowWhenInForeground = Nothing, notificationLed = Nothing, actions = [], expiresAfter = Nothing, update = Nothing, importance = Nothing, privacy = Nothing, useHTML = Nothing, title_expanded = Nothing, body_expanded = Nothing, detail = Nothing, status_icon = Nothing, status_text_size = Nothing, background_color = Nothing, color_from_media = Nothing, picture_skip_cache = Nothing, picture_expanded_icon = Nothing, media_layout = Nothing, media = Nothing, url = Nothing, on_create = Nothing, on_touch = Nothing, on_dismiss = Nothing, autoCancel = Nothing, chronometer = Nothing, countdown = Nothing, led_on_duration = Nothing, led_off_duration = Nothing, progress = Nothing, vibratePattern = Nothing, phone_only = Nothing, channelDescription = Nothing, when = Nothing, group = Nothing, groupAlertBehavior = Nothing, isGroupSummary = Nothing, sortKey = Nothing, accentColor = Nothing }


encode : Notification -> EncodedNotification
encode v =
    Porting.encodeObjectWithoutNothings
        [ omittable ( "id", Encode.int, v.id )
        , omittable ( "at", Encode.float << Moment.toJSTime, v.at )
        , omittable ( "ongoing", Encode.bool, v.ongoing )
        , omittable ( "expiresAfter", encodeExpiresAfter, v.expiresAfter )
        , omittable ( "importance", encodeImportance, v.importance )
        , omittable ( "title", Encode.string, v.title )
        , omittable ( "title_expanded", Encode.string, v.title_expanded )
        , omittable ( "body", Encode.string, v.body )
        , omittable ( "bigTextStyle", Encode.bool, v.bigTextStyle )
        , omittable ( "subtitle", Encode.string, v.subtitle )
        , omittable ( "ticker", Encode.string, v.ticker )
        , omittable ( "icon", Encode.string, v.icon )
        , omittable ( "status_icon", Encode.string, v.status_icon )
        , omittable ( "status_text_size", Encode.int, v.status_text_size )
        , omittable ( "color", Encode.string, v.accentColor )
        , omittable ( "color_from_media", Encode.bool, v.color_from_media )
        , omittable ( "badge", Encode.int, v.badge )
        , omittable ( "image", Encode.string, v.image )
        , omittable ( "picture_skip_cache", Encode.bool, v.picture_skip_cache )
        , omittable ( "picture_expanded_icon", Encode.string, v.picture_expanded_icon )
        , omittable ( "media_layout", Encode.bool, v.media_layout )
        , omittable ( "media", encodeMediaInfo, v.media )
        , omittable ( "url", Encode.string, v.url )
        , omittable ( "on_create", Encode.string, v.on_create )
        , omittable ( "on_touch", Encode.string, v.on_touch )
        , omittable ( "on_dismiss", Encode.string, v.on_dismiss )
        , omittable ( "autoCancel", Encode.bool, v.autoCancel )
        , omittable ( "chronometer", Encode.bool, v.chronometer )
        , omittable ( "countdown", Encode.bool, v.countdown )
        , normal ( "channel", Encode.string v.channel )
        , omittable ( "channelDescription", Encode.string, v.channelDescription )
        , omittable ( "notificationLed", Encode.string, v.notificationLed )
        , omittable ( "led_on_duration", encodeDuration, v.led_on_duration )
        , omittable ( "led_off_duration", encodeDuration, v.led_off_duration )
        , omittable ( "sound", encodeSound, v.sound )
        , omittable ( "vibratePattern", encodevibratePattern, v.vibratePattern )
        , omittable ( "phone_only", Encode.bool, v.phone_only )
        , omittable ( "groupedMessages", Encode.list Encode.string, v.groupedMessages )
        , omittable ( "group", \(GroupKey s) -> Encode.string s, v.group )
        , omittable ( "interval", encodeRepeatEvery, v.interval )
        , omittable ( "icon", Encode.string, v.icon )
        , omittable ( "silhouetteIcon", Encode.string, v.silhouetteIcon )
        , omittable ( "thumbnail", encodeThumbnail, v.thumbnail )
        , omittable ( "forceShowWhenInForeground", Encode.bool, v.forceShowWhenInForeground )
        , omittableList ( "actions", encodeAction, v.actions )
        , omittable ( "progress", encodeProgress, v.progress )
        , omittable ( "progressMax", encodeProgressMax, v.progress )
        , omittable ( "when", Encode.float << Moment.toJSTime, v.when )
        , omittable ( "chronometer", Encode.bool, v.chronometer )
        , omittable ( "sortKey", Encode.string, v.sortKey )
        ]


type alias Command =
    String


type Thumbnail
    = UsePicture
    | FromResource ResourceURL
    | FromWeb WebURL


encodeThumbnail : Thumbnail -> Encode.Value
encodeThumbnail v =
    case v of
        UsePicture ->
            Encode.bool True

        FromResource link ->
            Encode.string link

        FromWeb link ->
            Encode.string link



-- TODO use URL type


type alias NotificationID =
    Int


type Sound
    = DefaultSound
    | Silent
    | CustomSound Path


type GroupKey
    = GroupKey String


encodeSound : Sound -> Encode.Value
encodeSound v =
    case v of
        DefaultSound ->
            Encode.string "default"

        Silent ->
            Encode.null

        CustomSound path ->
            Encode.string path


type alias Path =
    String


type alias ResourceURL =
    String


type alias WebURL =
    String


type alias ChannelID =
    String


type alias LEDcolor =
    String


type Importance
    = Default
    | Low
    | High
    | Min
    | Max


encodeImportance : Importance -> Encode.Value
encodeImportance v =
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


type ProgressBar
    = Indeterminate
    | Progress Int Int


encodeProgress : ProgressBar -> Encode.Value
encodeProgress v =
    case v of
        Indeterminate ->
            Encode.int 0

        Progress current _ ->
            Encode.int current


encodeProgressMax : ProgressBar -> Encode.Value
encodeProgressMax v =
    case v of
        Indeterminate ->
            Encode.null

        Progress _ progressMax ->
            Encode.int progressMax


type RepeatEvery
    = Second
    | Minute
    | Hour
    | Day
    | Week
    | Month
    | Year


encodeRepeatEvery : RepeatEvery -> Encode.Value
encodeRepeatEvery v =
    case v of
        Second ->
            Encode.string "second"

        Minute ->
            Encode.string "minute"

        Hour ->
            Encode.string "hour"

        Day ->
            Encode.string "day"

        Week ->
            Encode.string "week"

        Month ->
            Encode.string "month"

        Year ->
            Encode.string "year"


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


encodeExpiresAfter : Duration -> Encode.Value
encodeExpiresAfter dur =
    Encode.int (Duration.inMs dur)


type alias VibratorOff =
    Duration



-- Should help explain what's going on


type alias VibratorOn =
    Duration


encodevibratePattern : List ( VibratorOff, VibratorOn ) -> Encode.Value
encodevibratePattern durs =
    let
        unbundlePair ( silence, vibration ) =
            [ silence, vibration ]

        flattenedList =
            List.concat <| List.map unbundlePair durs

        intList =
            List.map Duration.inMs flattenedList
    in
    Encode.list Encode.int intList



-- Actions -----------------------------------------------------------------------NOTE


type alias Action =
    { id : String -- An id so you can easily distinguish your actions.
    , button : ButtonType -- Either button or input.
    , launch : Bool -- Launch the app when the action completes.
    }


type ButtonType
    = Button String
    | Input String String


encodeAction : Action -> Encode.Value
encodeAction v =
    Encode.object <|
        [ ( "id", Encode.string v.id )
        , ( "launch", Encode.bool v.launch )
        ]
            ++ (case v.button of
                    Button label ->
                        [ ( "type", Encode.string "button" )
                        , ( "title", Encode.string label )
                        ]

                    Input textPlaceholder submitLabel ->
                        [ ( "type", Encode.string "input" )
                        , ( "placeholder", Encode.string textPlaceholder )
                        , ( "submitLabel", Encode.string submitLabel )
                        ]
               )



-- Funcs---------------------------------------------------------------------------NOTE


basic : ChannelID -> NotificationID -> Duration -> String -> String -> Notification
basic channel id expires title body =
    let
        base =
            blank channel
    in
    { base | title = Just title, body = Just body, id = Just id, expiresAfter = Just expires }


type alias EncodedNotification =
    Encode.Value
