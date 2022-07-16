module Activity.Activity exposing (..)

import Activity.Evidence as Evidence exposing (..)
import Activity.Template as Template exposing (..)
import Date
import Dict exposing (..)
import External.Commands as Commands exposing (..)
import ExtraCodecs as Codec
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
import Replicated.Codec as Codec exposing (Codec, coreR, coreRW, fieldDict, fieldList, fieldRW, maybeRW)
import Replicated.Reducer.Register as Register exposing (RW)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb(..))
import Replicated.Reducer.RepDict as RepDict exposing (RepDict)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Duration as HumanDuration exposing (..)
import SmartTime.Moment as Moment exposing (..)
import Svg.Styled exposing (..)
import Time
import Time.Extra exposing (..)


type ActivityID
    = BuiltInActivity Template
    | CustomActivity Template (ID CustomActivitySkel)


activityIDCodec : Codec String ActivityID
activityIDCodec =
    Codec.customType
        (\builtInActivity customActivity value ->
            case value of
                BuiltInActivity template ->
                    builtInActivity template

                CustomActivity template customActivityID ->
                    customActivity template customActivityID
        )
        |> Codec.variant1 ( 1, "BuiltInActivity" ) BuiltInActivity Template.codec
        |> Codec.variant2 ( 2, "CustomActivity" ) CustomActivity Template.codec Codec.id
        |> Codec.finishCustomType


{-| What's going on here?
Well, at first you might think this file should be like any other type, like Task for example. You define the type, its decoders, and helper functions, and that's it. This file started out that way too, and it's all here.

The problem with making a Time Tracker is that it's most useful with a huge amount of "default data" , that is, activities that are ready to use out of the box. But... we don't want to store all of this default data! If the user makes no changes to the stock activities, his stored activity database should be empty. We don't want a fresh Profile full of boilerplate. If his list is missing an activity, how would we know if he deleted it, or simply came from a version where it didn't yet exist? We also want to improve the defaults over time, replacing them (on upgrade) with better defaults for each setting the user has not specifically customized. That means we need to keep track of not just the settings, but whether they were modified!

One strategy is omitting the uncustomized data at the Encoder level, and substituting defaults when the Decoder finds nothing there. Our data model would be decluttered, in its JSON form at least. But then our decoded model would be mostly artificial, it'd be hard to distinguish unmodified defaults from deliberately user-preferred values which happen to match the current default (meaning an upgrade or two could silently un-customize his settings), and we wouldn't know if the JSON value being missing was truly "nothing" or an error. This also allows the invalid state of a blank activity list in our model - did it fail to load? Did the user delete all of the activites? It's better that we let [] be the default state and let the user "hide" activities he doesn't want.

Originally this was going to be done with duck typing - the stored record has only the keys that are updated, and is used to "update" the record that holds the defaults, when we want to fetch the full Activity record. But this turns out to be impossible in Elm, as functions can't access record fields they don't specifically ask for in their type signature.

It seems the next best thing is to have an exact replica of the Activity record, where every value is wrapped in a maybe. Then at least blank activities can be represented by a type holding a bunch of nothings. Not as lightweight as I'd prefer, but it seems that other options (like using Dicts) sacrifice more. Also, we can make the default way of getting activities (allActivities) mix the defaults with the customizations and then the rest of the app doesn't have to worry about where it came from.

-}
type alias BuiltInActivitySkel =
    { names : RepList String
    , icon : RW (Maybe Icon)
    , excusable : RW (Maybe Excusable)
    , taskOptional : RW (Maybe Bool)
    , evidence : RepList Evidence
    , backgroundable : RW (Maybe Bool)
    , maxTime : RW (Maybe DurationPerPeriod)
    , hidden : RW (Maybe Bool)
    , externalIDs : RepDict String String
    }


builtInActivitySkelCodec : Codec String BuiltInActivitySkel
builtInActivitySkelCodec =
    Codec.record BuiltInActivitySkel
        |> fieldList ( 1, "names" ) .names Codec.string
        |> maybeRW ( 2, "icon" ) .icon iconCodec
        |> maybeRW ( 3, "excusable" ) .excusable excusableCodec
        |> maybeRW ( 4, "taskOptional" ) .taskOptional Codec.bool
        |> fieldList ( 5, "evidence" ) .evidence Evidence.codec
        |> maybeRW ( 7, "backgroundable" ) .backgroundable Codec.bool
        |> maybeRW ( 8, "maxTime" ) .maxTime durationPerPeriodCodec
        |> maybeRW ( 9, "hidden" ) .hidden Codec.bool
        |> fieldDict ( 12, "externalIDs" ) .externalIDs ( Codec.string, Codec.string )
        |> Codec.finishRecord


type alias CustomActivitySkel =
    { template : Template
    , names : RepList String
    , icon : RW (Maybe Icon)
    , excusable : RW (Maybe Excusable)
    , taskOptional : RW (Maybe Bool)
    , evidence : RepList Evidence
    , backgroundable : RW (Maybe Bool)
    , maxTime : RW (Maybe DurationPerPeriod)
    , hidden : RW (Maybe Bool)
    , externalIDs : RepDict String String
    }


customActivitySkelCodec : Codec String CustomActivitySkel
customActivitySkelCodec =
    Codec.record CustomActivitySkel
        |> coreR ( 0, "template" ) .template Template.codec
        |> fieldList ( 1, "names" ) .names Codec.string
        |> maybeRW ( 2, "icon" ) .icon iconCodec
        |> maybeRW ( 3, "excusable" ) .excusable excusableCodec
        |> maybeRW ( 4, "taskOptional" ) .taskOptional Codec.bool
        |> fieldList ( 5, "evidence" ) .evidence Evidence.codec
        |> maybeRW ( 7, "backgroundable" ) .backgroundable Codec.bool
        |> maybeRW ( 8, "maxTime" ) .maxTime durationPerPeriodCodec
        |> maybeRW ( 9, "hidden" ) .hidden Codec.bool
        |> fieldDict ( 12, "externalIDs" ) .externalIDs ( Codec.string, Codec.string )
        |> Codec.finishRecord


unknown =
    BuiltInActivity DillyDally


fromCustom : CustomActivitySkel -> Activity
fromCustom skel =
    let
        base =
            defaults skel.template
    in
    { base
        | names = RepList.listValues skel.names
    }


type Excusable
    = NeverExcused
    | TemporarilyExcused DurationPerPeriod
    | IndefinitelyExcused


excusableCodec : Codec String Excusable
excusableCodec =
    Codec.customType
        (\neverExcused temporarilyExcused indefinitelyExcused value ->
            case value of
                NeverExcused ->
                    neverExcused

                TemporarilyExcused dpp ->
                    temporarilyExcused dpp

                IndefinitelyExcused ->
                    indefinitelyExcused
        )
        |> Codec.variant0 ( 1, "NeverExcused" ) NeverExcused
        |> Codec.variant1 ( 2, "TemporarilyExcused" ) TemporarilyExcused durationPerPeriodCodec
        |> Codec.variant0 ( 3, "IndefinitelyExcused" ) IndefinitelyExcused
        |> Codec.finishCustomType


excusableFor : Activity -> DurationPerPeriod
excusableFor skel =
    case skel.excusable of
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


durationPerPeriodCodec : Codec String DurationPerPeriod
durationPerPeriodCodec =
    Codec.tuple Codec.humanDuration Codec.humanDuration


{-| Icons. For activities, at least.
Is there a standard way to represent Icons of various types like this? If so, need to find and use that.
-}
type Icon
    = File SvgPath
    | Ion
    | Other
    | Emoji String


iconCodec : Codec e Icon
iconCodec =
    Codec.customType
        (\file ion other emoji value ->
            case value of
                File svgpath ->
                    file svgpath

                Ion ->
                    ion

                Other ->
                    other

                Emoji emojiString ->
                    emoji emojiString
        )
        |> Codec.variant1 ( 1, "File" ) File Codec.string
        |> Codec.variant0 ( 2, "Ion" ) Ion
        |> Codec.variant0 ( 3, "Other" ) Other
        |> Codec.variant1 ( 4, "Emoji" ) Emoji Codec.string
        |> Codec.finishCustomType


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
    , externalIDs : Dict String String
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
            , externalIDs = Dict.empty
            }

        Apparel ->
            { names = [ "Appareling", "Dressing", "Getting Dressed", "Dressing Up" ]
            , icon = File "shirt.svg"
            , excusable = TemporarilyExcused ( Minutes 5, Hours 3 )
            , taskOptional = True
            , evidence = []
            , category = Hygiene
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Messaging ->
            { names = [ "Messaging", "Texting", "Chatting", "Text Messaging" ]
            , icon = File "messaging.svg"
            , excusable = TemporarilyExcused ( Minutes 7, Minutes 30 )
            , taskOptional = True
            , evidence = []
            , category = Communication
            , backgroundable = False
            , maxTime = ( Hours 2, Hours 5 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Restroom ->
            { names = [ "Restroom", "Toilet", "WC", "Washroom", "Latrine", "Lavatory", "Water Closet", "Bathroom" ]
            , icon = Emoji "🚽"
            , excusable = TemporarilyExcused ( Minutes 15, Hours 2 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Minutes 20, Hours 2 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Grooming ->
            { names = [ "Grooming", "Tending", "Groom", "Personal Care" ]
            , icon = Emoji "💈"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Meal ->
            { names = [ "Meal", "Eating", "Food", "Lunch", "Dinner", "Breakfast" ]
            , icon = Emoji "🍽"
            , excusable = TemporarilyExcused ( Minutes 40, Hours 3 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Supplements ->
            { names = [ "Supplements", "Pills", "Medication" ]
            , icon = Emoji "💊"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Workout ->
            { names = [ "Workout", "Working Out", "Work Out" ]
            , icon = Emoji "💪"
            , excusable = TemporarilyExcused ( Minutes 12, Hours 3 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Shower ->
            { names = [ "Shower", "Bathing", "Showering" ]
            , icon = Emoji "🚿"
            , excusable = TemporarilyExcused ( Minutes 25, Hours 18 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Toothbrush ->
            { names = [ "Toothbrush", "Teeth", "Brushing Teeth", "Teethbrushing" ]
            , icon = Emoji "\u{1FAA5}"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Floss ->
            { names = [ "Floss", "Flossing" ]
            , icon = Emoji "🦷"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Wakeup ->
            { names = [ "Wakeup", "Waking Up", "Wakeup Walk" ]
            , icon = Emoji "🥱"
            , excusable = TemporarilyExcused ( Minutes 12, Hours 15 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Sleep ->
            { names = [ "Sleep", "Sleeping" ]
            , icon = Emoji "💤"
            , excusable = TemporarilyExcused ( Hours 10, Hours 20 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Plan ->
            { names = [ "Plan", "Planning", "Plans" ]
            , icon = Emoji "📅"
            , excusable = TemporarilyExcused ( Minutes 20, Hours 3 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Configure ->
            { names = [ "Configure", "Configuring", "Configuration" ]
            , icon = Emoji "🔧"
            , excusable = TemporarilyExcused ( Minutes 15, Hours 5 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Email ->
            { names = [ "Email", "E-Mail", "E-mail", "Emailing", "E-mails", "Emails", "E-mailing" ]
            , icon = Emoji "📧"
            , excusable = TemporarilyExcused ( Minutes 15, Hours 4 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Work ->
            { names = [ "Work", "Working", "Listings Work" ]
            , icon = Emoji "💼"
            , excusable = TemporarilyExcused ( Hours 1, Hours 12 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 8, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Call ->
            { names = [ "Call", "Calling", "Phone Call", "Phone", "Phone Calls", "Calling", "Voice Call", "Voice Chat", "Video Call" ]
            , icon = Emoji "🗣"
            , excusable = TemporarilyExcused ( Minutes 35, Hours 4 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Chores ->
            { names = [ "Chore", "Chores" ]
            , icon = Emoji "🧹"
            , excusable = TemporarilyExcused ( Minutes 25, Hours 4 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Parents ->
            { names = [ "Parents", "Parent" ]
            , icon = Emoji "👫"
            , excusable = TemporarilyExcused ( Hours 1, Hours 12 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Prepare ->
            { names = [ "Prepare", "Preparing", "Preparation" ]
            , icon = Emoji "🧳"
            , excusable = NeverExcused
            , taskOptional = False
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Minutes 30, Hours 24 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Lover ->
            { names = [ "Lover", "S.O.", "Partner" ]
            , icon = Emoji "💋"
            , excusable = TemporarilyExcused ( Hours 2, Hours 8 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Driving ->
            { names = [ "Driving", "Drive" ]
            , icon = Emoji "🚗"
            , excusable = TemporarilyExcused ( Hours 1, Hours 6 )
            , taskOptional = True
            , evidence = []
            , category = Transit
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Riding ->
            { names = [ "Riding", "Ride", "Passenger" ]
            , icon = Emoji "💺"
            , excusable = TemporarilyExcused ( Minutes 30, Hours 8 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Minutes 30, Hours 5 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        SocialMedia ->
            { names = [ "Social Media" ]
            , icon = Emoji "👁"
            , excusable = TemporarilyExcused ( Minutes 20, Hours 4 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Pacing ->
            { names = [ "Pacing", "Pace" ]
            , icon = Emoji "🚶"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Sport ->
            { names = [ "Sport", "Sports", "Playing Sports" ]
            , icon = Emoji "⛹"
            , excusable = TemporarilyExcused ( Minutes 20, Hours 8 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Finance ->
            { names = [ "Finance", "Financial", "Finances" ]
            , icon = Emoji "💸"
            , excusable = TemporarilyExcused ( Minutes 20, Hours 16 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Laundry ->
            { names = [ "Laundry" ]
            , icon = Emoji "👕"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Bedward ->
            { names = [ "Bedward", "Bedward-bound", "Going to Bed" ]
            , icon = Emoji "🛏"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Browse ->
            { names = [ "Browse", "Browsing" ]
            , icon = Emoji "📑"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Fiction ->
            { names = [ "Fiction", "Reading Fiction" ]
            , icon = Emoji "🐉"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Learning ->
            { names = [ "Learn", "Learning", "Reading", "Read", "Book", "Books" ]
            , icon = Emoji "🧠"
            , excusable = TemporarilyExcused ( Minutes 15, Hours 10 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        BrainTrain ->
            { names = [ "Brain Training", "Braining", "Brain Train", "Mental Math Practice" ]
            , icon = Emoji "💡"
            , excusable = TemporarilyExcused ( Minutes 30, Hours 20 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Music ->
            { names = [ "Music", "Music Listening" ]
            , icon = Emoji "🎧"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Create ->
            { names = [ "Create", "Creating", "Creation", "Making" ]
            , icon = Emoji "🛠"
            , excusable = TemporarilyExcused ( Minutes 35, Hours 16 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Children ->
            { names = [ "Children", "Kids" ]
            , icon = Emoji "🚸"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = True
            , template = startWith
            , externalIDs = Dict.empty
            }

        Meeting ->
            { names = [ "Meeting", "Meet", "Meetings" ]
            , icon = Emoji "👥"
            , excusable = TemporarilyExcused ( Minutes 35, Hours 8 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Cinema ->
            { names = [ "Cinema", "Movies", "Movie Theatre", "Movie Theater" ]
            , icon = Emoji "🎟"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        FilmWatching ->
            { names = [ "Films", "Film Watching", "Watching Movies" ]
            , icon = Emoji "🎞"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Series ->
            { names = [ "Series", "TV Shows", "TV Series" ]
            , icon = Emoji "📺"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Broadcast ->
            { names = [ "Broadcast" ]
            , icon = Emoji "📻"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Theatre ->
            { names = [ "Theatre", "Play", "Play/Musical", "Drama" ]
            , icon = Emoji "🎭"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Shopping ->
            { names = [ "Shopping", "Shop" ]
            , icon = Emoji "🛍"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        VideoGaming ->
            { names = [ "Video", "Video Gaming", "Gaming" ]
            , icon = Emoji "🎮"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Housekeeping ->
            { names = [ "Housekeeping" ]
            , icon = Emoji "🏠"
            , excusable = TemporarilyExcused ( Minutes 20, Hours 6 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        MealPrep ->
            { names = [ "Meal Prep", "Cooking", "Food making" ]
            , icon = Emoji "🍳"
            , excusable = TemporarilyExcused ( Minutes 45, Hours 6 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Networking ->
            { names = [ "Networking" ]
            , icon = Emoji "🤝"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Meditate ->
            { names = [ "Meditate", "Meditation", "Meditating" ]
            , icon = Emoji "🧘"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Homework ->
            { names = [ "Homework", "Schoolwork" ]
            , icon = Emoji "📝"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Flight ->
            { names = [ "Flight", "Aviation", "Flying", "Airport" ]
            , icon = Emoji "✈"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Course ->
            { names = [ "Course", "Courses", "Classes", "Class" ]
            , icon = Emoji "📔"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Pet ->
            { names = [ "Pet", "Pets", "Pet Care" ]
            , icon = Emoji "🐶"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Presentation ->
            { names = [ "Presentation", "Presenting", "Present" ]
            , icon = Emoji "📊"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Projects ->
            { names = [ "Project", "Projects", "Project Work", "Fun Project" ]
            , icon = Emoji "🌟"
            , excusable = TemporarilyExcused ( Minutes 40, Hours 4 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 2, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Research ->
            { names = [ "Research", "Researching", "Looking Stuff Up", "Evaluating" ]
            , icon = Emoji "🤓"
            , excusable = TemporarilyExcused ( Minutes 10, Hours 3 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 6, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }

        Repair ->
            { names = [ "Repair", "Fix", "Fixing", "Fixing stuff" ]
            , icon = Emoji "🔧"
            , excusable = TemporarilyExcused ( Minutes 10, Hours 3 )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( Hours 8, Days 1 )
            , hidden = False
            , template = startWith
            , externalIDs = Dict.empty
            }


showing : Activity -> Bool
showing act =
    not act.hidden


getName : Activity -> String
getName act =
    Maybe.withDefault "?" (List.head act.names)
