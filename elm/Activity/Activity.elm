module Activity.Activity exposing (Activity, ActivityId(..), Category(..), Customizations, DurationPerPeriod, Evidence(..), Excusable(..), Icon(..), Moment, StoredActivities, SvgPath, Switch(..), Timeline, allActivities, currentActivity, currentActivityId, decodeActivityId, decodeCategory, decodeCustomizations, decodeDurationPerPeriod, decodeEvidence, decodeExcusable, decodeFile, decodeHumanDuration, decodeIcon, decodeStoredActivities, decodeSwitch, defaults, dummy, encodeActivityId, encodeCategory, encodeCustomizations, encodeDurationPerPeriod, encodeEvidence, encodeExcusable, encodeHumanDuration, encodeIcon, encodeStoredActivities, encodeSwitch, excusableFor, getActivity, getName, isStock, latestSwitch, showing, withTemplate)

import Activity.Template exposing (..)
import Date
import Dict exposing (..)
import External.Commands as Commands exposing (..)
import Ionicon
import Ionicon.Android as Android
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import List.Nonempty exposing (..)
import Porting exposing (..)
import SmartTime.Duration as Duration exposing (..)
import SmartTime.HumanDuration exposing (..)
import Svg.Styled exposing (..)
import Task.TaskMoment exposing (decodeMoment, encodeMoment)
import Time
import Time.Extra exposing (..)


type alias Moment =
    Time.Posix


{-| Definition of an activity.
-}
type alias Activity =
    { names : List String -- TODO should be Translations
    , icon : Icon -- TODO figure out best way to do this. svg file path?
    , excusable : Excusable
    , taskOptional : Bool -- technically they can all be "unplanned"
    , evidence : List Evidence
    , category : Category
    , backgroundable : Bool
    , maxTime : DurationPerPeriod
    , hidden : Bool -- The user can hide any of the "stock" activities they don't use
    , template : Template -- template this activity was derived from, in case we want to propogate changes to defaults
    , id : ActivityId
    }


{-| What's going on here?
Well, at first you might think this file should be like any other type, like Task for example. You define the type, its decoders, and helper functions, and that's it. This file started out that way too, and it's all here.

The problem with making a Time Tracker is that it's most useful with a huge amount of "default data" , that is, activities that are ready to use out of the box. But... we don't want to store all of this default data! If the user makes no changes to the stock activities, his stored activity database should be empty. We don't want a fresh AppData full of boilerplate. If his list is missing an activity, how would we know if he deleted it, or simply came from a version where it didn't yet exist? We also want to improve the defaults over time, replacing them (on upgrade) with better defaults for each setting the user has not specifically customized. That means we need to keep track of not just the settings, but whether they were modified!

One strategy is omitting the uncustomized data at the Encoder level, and substituting defaults when the Decoder finds nothing there. Our data model would be decluttered, in its JSON form at least. But then our decoded model would be mostly artificial, it'd be hard to distinguish unmodified defaults from deliberately user-preferred values which happen to match the current default (meaning an upgrade or two could silently un-customize his settings), and we wouldn't know if the JSON value being missing was truly "nothing" or an error. This also allows the invalid state of a blank activity list in our model - did it fail to load? Did the user delete all of the activites? It's better that we let [] be the default state and let the user "hide" activities he doesn't want.

Originally this was going to be done with duck typing - the stored record has only the keys that are updated, and is used to "update" the record that holds the defaults, when we want to fetch the full Activity record. But this turns out to be impossible in Elm, as functions can't access record fields they don't specifically ask for in their type signature.

It seems the next best thing is to have an exact replica of the Activity record, where every value is wrapped in a maybe. Then at least blank activities can be represented by a type holding a bunch of nothings. Not as lightweight as I'd prefer, but it seems that other options (like using Dicts) sacrifice more. Also, we can make the default way of getting activities (allActivities) mix the defaults with the customizations and then the rest of the app doesn't have to worry about where it came from.

-}
type alias Customizations =
    { names : Maybe (List String)
    , icon : Maybe Icon
    , excusable : Maybe Excusable
    , taskOptional : Maybe Bool
    , evidence : Maybe (List Evidence)
    , category : Maybe Category
    , backgroundable : Maybe Bool
    , maxTime : Maybe DurationPerPeriod
    , hidden : Maybe Bool
    , template : Template
    , id : ActivityId
    }


decodeCustomizations : Decode.Decoder Customizations
decodeCustomizations =
    decode Customizations
        |> ifPresent "names" (Decode.list Decode.string)
        |> ifPresent "icon" decodeIcon
        |> ifPresent "excusable" decodeExcusable
        |> ifPresent "taskOptional" Decode.bool
        |> ifPresent "evidence" (Decode.list decodeEvidence)
        |> ifPresent "category" decodeCategory
        |> ifPresent "backgroundable" Decode.bool
        |> ifPresent "maxTime" decodeDurationPerPeriod
        |> ifPresent "hidden" Decode.bool
        |> Pipeline.required "template" decodeTemplate
        |> Pipeline.required "id" decodeActivityId


encodeCustomizations : Customizations -> Encode.Value
encodeCustomizations record =
    Encode.object <|
        omitNothings
            [ normal ( "template", encodeTemplate record.template )
            , normal ( "stock", encodeActivityId record.id )
            , omittable ( "names", Encode.list Encode.string, record.names )
            , omittable ( "icon", encodeIcon, record.icon )
            , omittable ( "excusable", encodeExcusable, record.excusable )
            , omittable ( "taskOptional", Encode.bool, record.taskOptional )
            , omittable ( "evidence", Encode.list encodeEvidence, record.evidence )
            , omittable ( "category", encodeCategory, record.category )
            , omittable ( "backgroundable", Encode.bool, record.backgroundable )
            , omittable ( "maxTime", encodeDurationPerPeriod, record.maxTime )
            , omittable ( "hidden", Encode.bool, record.hidden )
            ]



-- encodeTask : Activity -> Encode.Value
-- encodeTask record =
--     Encode.object
--         [ ( "names" , Encode.list Encode.string record.names )
--         , ( "icon" , encodeIcon <| record.icon )
--         , ( "taskOptional" , Encode.bool <| record.taskOptional )
--         , ( "evidence" , Encode.list encodeEvidence record.evidence )
--         , ( "category" , encodeCategory <| record.category )
--         , ( "backgroundable" , Encode.bool record.history )
--         , ( "maxTime" , encodeDurationPerParent <| record.maxTime )
--         , ( "hidden" , Encode.bool <| record.hidden )
--         , ( "template" , encodeTemplate <| record.template )
--         ]


type ActivityId
    = Stock Template
    | Custom Int


encodeActivityId : ActivityId -> Encode.Value
encodeActivityId v =
    case v of
        Stock template ->
            Encode.object [ ( "Stock", encodeTemplate template ) ]

        Custom num ->
            Encode.object [ ( "Custom", Encode.int num ) ]


decodeActivityId : Decoder ActivityId
decodeActivityId =
    oneOf
        [ field "Stock" (Decode.map Stock decodeTemplate)
        , field "Custom" (Decode.map Custom Decode.int)
        ]


isStock : Activity -> Bool
isStock activity =
    case activity.id of
        Stock template ->
            True

        Custom int ->
            False


dummy : ActivityId
dummy =
    Stock DillyDally


type Switch
    = Switch Moment ActivityId


decodeSwitch : Decoder Switch
decodeSwitch =
    subtype2 Switch "Time" decodeMoment "Activity" decodeActivityId


encodeSwitch : Switch -> Encode.Value
encodeSwitch (Switch time activityId) =
    Encode.object [ ( "Time", encodeMoment time ), ( "Activity", encodeActivityId activityId ) ]


type Evidence
    = Evidence


decodeEvidence : Decoder Evidence
decodeEvidence =
    decodeCustom [ ( "Evidence", succeed Evidence ) ]


encodeEvidence : Evidence -> Encode.Value
encodeEvidence v =
    case v of
        Evidence ->
            Encode.string "Evidence"


type Excusable
    = NeverExcused
    | TemporarilyExcused DurationPerPeriod
    | IndefinitelyExcused


decodeExcusable : Decoder Excusable
decodeExcusable =
    decodeCustom
        [ ( "NeverExcused", succeed NeverExcused )
        , ( "TemporarilyExcused", Decode.map TemporarilyExcused decodeDurationPerPeriod )
        , ( "IndefinitelyExcused", succeed IndefinitelyExcused )
        ]


encodeExcusable : Excusable -> Encode.Value
encodeExcusable v =
    case v of
        NeverExcused ->
            Encode.string "NeverExcused"

        TemporarilyExcused dpp ->
            Encode.string "TemporarilyExcused"

        IndefinitelyExcused ->
            Encode.string "IndefinitelyExcused"


excusableFor : Activity -> DurationPerPeriod
excusableFor activity =
    case activity.excusable of
        NeverExcused ->
            ( Minutes 0, Minutes 0 )

        TemporarilyExcused durationPerPeriod ->
            durationPerPeriod

        IndefinitelyExcused ->
            ( Hours 24, Hours 24 )


{-| We could have both durations share a combined Interval, e.g. "50 minutes per 60 minutes" , without losing any information, but it's more human friendly to say e.g. "50 minutes per hour" when we can.

Making Invalid States Unrepresentable: is there anyway to guarantee (via the type system) that the second duration is at least as large as the first?

Using a Custom type instead of a type alias: considering it, but it'd just have one value, meaning a tag that you'd always need to tack on, and there's not likely to be another type out there with the same structure that it could get mixed up with.

-}
type alias DurationPerPeriod =
    ( HumanDuration, HumanDuration )


encodeDurationPerPeriod : DurationPerPeriod -> Encode.Value
encodeDurationPerPeriod tuple =
    homogeneousTuple2AsArray encodeHumanDuration tuple


decodeDurationPerPeriod : Decode.Decoder DurationPerPeriod
decodeDurationPerPeriod =
    arrayAsTuple2 decodeHumanDuration decodeHumanDuration


encodeHumanDuration : HumanDuration -> Encode.Value
encodeHumanDuration humanDuration =
    Encode.int <| Duration.inMs (toDuration humanDuration)


decodeHumanDuration : Decode.Decoder HumanDuration
decodeHumanDuration =
    let
        convertAndNormalize durationAsInt =
            inLargestExactUnits (fromInt durationAsInt)
    in
    Decode.map convertAndNormalize Decode.int



-- interpretDuration : HumanDuration ->


{-| Icons. For activities, at least.
Is there a standard way to represent Icons of various types like this? If so, need to find and use that.
-}
type Icon
    = File SvgPath
    | Ion
    | Other


decodeIcon : Decoder Icon
decodeIcon =
    decodeCustom
        [ ( "File", decodeFile )
        , ( "Ion", succeed Ion )
        , ( "Other", succeed Other )
        ]


decodeFile : Decoder Icon
decodeFile =
    Decode.map File Decode.string


encodeIcon : Icon -> Encode.Value
encodeIcon v =
    case v of
        File path ->
            Encode.string "File"

        Ion ->
            Encode.string "Ion"

        Other ->
            Encode.string "Other"


{-| Icon files (scalable vector graphics, please!) location
-}
type alias SvgPath =
    String


type Category
    = Transit
    | Entertainment
    | Hygiene
    | Slacking
    | Communication


encodeCategory : Category -> Decode.Value
encodeCategory v =
    case v of
        Transit ->
            Encode.string "Transit"

        Entertainment ->
            Encode.string "Entertainment"

        Hygiene ->
            Encode.string "Hygiene"

        Slacking ->
            Encode.string "Slacking"

        Communication ->
            Encode.string "Communication"


decodeCategory : Decoder Category
decodeCategory =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "Transit" ->
                        Decode.succeed Transit

                    "Entertainment" ->
                        Decode.succeed Entertainment

                    "Hygiene" ->
                        Decode.succeed Hygiene

                    "Slacking" ->
                        Decode.succeed Slacking

                    "Communication" ->
                        Decode.succeed Communication

                    _ ->
                        Decode.fail "Invalid Category"
            )


type alias StoredActivities =
    List Customizations


decodeStoredActivities : Decoder StoredActivities
decodeStoredActivities =
    Decode.list decodeCustomizations


encodeStoredActivities : StoredActivities -> Encode.Value
encodeStoredActivities =
    Encode.list encodeCustomizations


allActivities : StoredActivities -> List Activity
allActivities stored =
    let
        customizedActivities =
            List.map withTemplate stored

        remainingActivities =
            List.map defaults (List.filter templateMissing stockActivities)

        customizedStockActivities =
            List.filter isStock customizedActivities

        templatesCovered =
            List.map .template customizedStockActivities

        templateMissing template =
            not (List.member template templatesCovered)
    in
    customizedActivities ++ remainingActivities


{-| Get a full activity from the saved version (which only contains the user's modifications to the default template).
It would be so much easier if i could just do { base | skel } like I originally wanted, when Customizations was just { template } with whatever extra fields the user overrode. Had to make it a maybe-ified carbon copy because updating a record with another (sub)record like { base | skel } isn't allowed...
-}
withTemplate : Customizations -> Activity
withTemplate delta =
    let
        base =
            defaults delta.template

        over b s =
            Maybe.withDefault b s
    in
    { names = over base.names delta.names
    , icon = over base.icon delta.icon
    , excusable = over base.excusable delta.excusable
    , taskOptional = over base.taskOptional delta.taskOptional
    , evidence = over base.evidence delta.evidence
    , category = over base.category delta.category
    , backgroundable = over base.backgroundable delta.backgroundable
    , maxTime = over base.maxTime delta.maxTime
    , hidden = over base.hidden delta.hidden
    , template = delta.template
    , id = delta.id
    }


defaults : Template -> Activity
defaults startWith =
    case startWith of
        DillyDally ->
            { names = [ "Nothing", "Dilly-dally", "Distracted" ]
            , icon = File "shrugging-attempt.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Minutes 0, Hours 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Apparel ->
            { names = [ "Appareling", "Dressing", "Getting Dressed", "Dressing Up" ]
            , icon = File "shirt.svg"
            , excusable = TemporarilyExcused ( Minutes 10, Hours 3 )
            , taskOptional = True
            , evidence = []
            , category = Hygiene
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Messaging ->
            { names = [ "Messaging", "Texting", "Chatting", "Text Messaging" ]
            , icon = File "messaging.svg"
            , excusable = TemporarilyExcused ( Minutes 5, Minutes 30 )
            , taskOptional = True
            , evidence = []
            , category = Communication
            , backgroundable = False
            , maxTime = ( Hours 2, Hours 5 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Restroom ->
            { names = [ "Restroom", "Toilet", "WC", "Washroom", "Latrine", "Lavatory", "Water Closet" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Minutes 15, Hours 2 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Minutes 20, Hours 2 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Grooming ->
            { names = [ "Grooming", "Tending", "Groom" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Meal ->
            { names = [ "Meal", "Eating", "Food", "Lunch", "Dinner", "Breakfast" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Minutes 35, Hours 3 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Supplements ->
            { names = [ "Supplements", "Pills", "Medication" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Workout ->
            { names = [ "Workout", "Working Out", "Work Out" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Minutes 10, Hours 3 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Shower ->
            { names = [ "Shower", "Bathing", "Showering" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Minutes 20, Hours 18 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Toothbrush ->
            { names = [ "Toothbrush", "Teeth", "Brushing Teeth", "Teethbrushing" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Floss ->
            { names = [ "Floss", "Flossing" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Wakeup ->
            { names = [ "Wakeup", "Waking Up", "Wakeup Walk" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Minutes 12, Hours 15 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Sleep ->
            { names = [ "Sleep", "Sleeping" ]
            , icon = File "unknown.svg"
            , excusable = IndefinitelyExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Plan ->
            { names = [ "Plan", "Planning", "Plans" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Minutes 15, Hours 2 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Configure ->
            { names = [ "Configure", "Configuring", "Configuration" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Minutes 30, Hours 5 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Email ->
            { names = [ "Email", "E-Mail", "E-mail", "Emailing", "E-mails", "Emails", "E-mailing" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Minutes 10, Hours 2 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Work ->
            { names = [ "Work", "Working", "Listings Work" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Hours 1, Hours 12 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 8, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Call ->
            { names = [ "Call", "Calling", "Phone Call", "Phone", "Phone Calls", "Calling", "Voice Call", "Voice Chat", "Video Call" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Minutes 35, Hours 4 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Chores ->
            { names = [ "Chore", "Chores" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Parents ->
            { names = [ "Parents", "Parent" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Hours 1, Hours 12 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Prepare ->
            { names = [ "Prepare", "Preparing", "Preparation" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Minutes 30, Hours 24 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Lover ->
            { names = [ "Lover", "S.O.", "Partner" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Hours 2, Hours 8 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Driving ->
            { names = [ "Driving", "Drive" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Hours 1, Hours 6 )
            , taskOptional = True
            , evidence = []
            , category = Transit
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Riding ->
            { names = [ "Riding", "Ride", "Passenger" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Minutes 30, Hours 8 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Minutes 30, Hours 5 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        SocialMedia ->
            { names = [ "Social Media" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Minutes 10, Hours 4 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Pacing ->
            { names = [ "Pacing", "Pace" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Sport ->
            { names = [ "Sport", "Sports", "Playing Sports" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Finance ->
            { names = [ "Finance", "Financial" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Laundry ->
            { names = [ "Laundry" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Bedward ->
            { names = [ "Bedward", "Bedward-bound", "Going to Bed" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Browse ->
            { names = [ "Browse", "Browsing" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Fiction ->
            { names = [ "Fiction", "Reading Fiction" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Learning ->
            { names = [ "Learn", "Learning" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        BrainTrain ->
            { names = [ "Brain Training", "Braining", "Brain Train", "Mental Math Practice" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Minutes 30, Days 1 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Music ->
            { names = [ "Music", "Music Listening" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Create ->
            { names = [ "Create", "Creating", "Creation", "Making" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Children ->
            { names = [ "Children", "Kids" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Meeting ->
            { names = [ "Meeting", "Meet", "Meetings" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Cinema ->
            { names = [ "Cinema", "Movies", "Movie Theatre", "Movie Theater" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        FilmWatching ->
            { names = [ "Films", "Film Watching", "Watching Movies" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Series ->
            { names = [ "Series", "TV Shows", "TV Series" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Broadcast ->
            { names = [ "Broadcast" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Theatre ->
            { names = [ "Theatre", "Play", "Play/Musical", "Drama" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Shopping ->
            { names = [ "Shopping", "Shop" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        VideoGaming ->
            { names = [ "Video", "Video Gaming", "Gaming" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Housekeeping ->
            { names = [ "Housekeeping" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        MealPrep ->
            { names = [ "Meal Prep", "Cooking", "Food making" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( Minutes 45, Hours 3 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Networking ->
            { names = [ "Networking" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Meditate ->
            { names = [ "Meditate", "Meditation", "Meditating" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Homework ->
            { names = [ "Homework", "Schoolwork" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Flight ->
            { names = [ "Flight", "Aviation", "Flying", "Airport" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Course ->
            { names = [ "Course", "Courses", "Classes", "Class" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Pet ->
            { names = [ "Pet", "Pets", "Pet Care" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }

        Presentation ->
            { names = [ "Presentation", "Presenting", "Present" ]
            , icon = File "presentation.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , id = Stock startWith
            }


showing : Activity -> Bool
showing activity =
    not activity.hidden


getName : Activity -> String
getName activity =
    Maybe.withDefault "?" (List.head activity.names)


type alias Timeline =
    List Switch


latestSwitch : Timeline -> Switch
latestSwitch timeline =
    Maybe.withDefault (Switch (Time.millisToPosix 0) (Stock DillyDally)) (List.head timeline)


currentActivityId : Timeline -> ActivityId
currentActivityId switchList =
    let
        getId (Switch _ activityId) =
            activityId
    in
    getId (latestSwitch switchList)


currentActivity : List Activity -> Timeline -> Activity
currentActivity activities switchList =
    getActivity activities (currentActivityId switchList)


getActivity : List Activity -> ActivityId -> Activity
getActivity activities activityId =
    let
        matches act =
            act.id == activityId
    in
    Maybe.withDefault (defaults DillyDally) (List.head (List.filter matches activities))
