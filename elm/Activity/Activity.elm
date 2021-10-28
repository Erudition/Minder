module Activity.Activity exposing (..)

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
    , externalIDs : Dict String String
    }


{-| What's going on here?
Well, at first you might think this file should be like any other type, like Task for example. You define the type, its decoders, and helper functions, and that's it. This file started out that way too, and it's all here.

The problem with making a Time Tracker is that it's most useful with a huge amount of "default data" , that is, activities that are ready to use out of the box. But... we don't want to store all of this default data! If the user makes no changes to the stock activities, his stored activity database should be empty. We don't want a fresh Profile full of boilerplate. If his list is missing an activity, how would we know if he deleted it, or simply came from a version where it didn't yet exist? We also want to improve the defaults over time, replacing them (on upgrade) with better defaults for each setting the user has not specifically customized. That means we need to keep track of not just the settings, but whether they were modified!

One strategy is omitting the uncustomized data at the Encoder level, and substituting defaults when the Decoder finds nothing there. Our data model would be decluttered, in its JSON form at least. But then our decoded model would be mostly artificial, it'd be hard to distinguish unmodified defaults from deliberately user-preferred values which happen to match the current default (meaning an upgrade or two could silently un-customize his settings), and we wouldn't know if the JSON value being missing was truly "nothing" or an error. This also allows the invalid state of a blank activity list in our model - did it fail to load? Did the user delete all of the activites? It's better that we let [] be the default state and let the user "hide" activities he doesn't want.

Originally this was going to be done with duck typing - the stored record has only the keys that are updated, and is used to "update" the record that holds the defaults, when we want to fetch the full Activity record. But this turns out to be impossible in Elm, as functions can't access record fields they don't specifically ask for in their type signature.

It seems the next best thing is to have an exact replica of the Activity record, where every value is wrapped in a maybe. Then at least blank activities can be represented by a type holding a bunch of nothings. Not as lightweight as I'd prefer, but it seems that other options (like using Dicts) sacrifice more. Also, we can make the default way of getting activities (allActivities) mix the defaults with the customizations and then the rest of the app doesn't have to worry about where it came from.

-}
type alias Customizations =
    { names : Maybe (List String)
    , icon : Maybe Icon
    , excusable : Maybe Excusable
    , taskOptional : Maybe Bool
    , evidence : List Evidence
    , category : Maybe Category
    , backgroundable : Maybe Bool
    , maxTime : Maybe DurationPerPeriod
    , hidden : Maybe Bool
    , template : Template
    , id : ActivityID
    , externalIDs : Dict String String
    }


decodeCustomizations : Decode.Decoder Customizations
decodeCustomizations =
    decode Customizations
        |> withPresence "names" (Decode.list Decode.string)
        |> withPresence "icon" decodeIcon
        |> withPresence "excusable" decodeExcusable
        |> withPresence "taskOptional" Decode.bool
        |> withPresenceList "evidence" decodeEvidence
        |> withPresence "category" decodeCategory
        |> withPresence "backgroundable" Decode.bool
        |> withPresence "maxTime" decodeDurationPerPeriod
        |> withPresence "hidden" Decode.bool
        |> Pipeline.required "template" decodeTemplate
        |> Pipeline.required "id" ID.decode
        |> Pipeline.optional "externalIDs" (Decode.dict Decode.string) Dict.empty


encodeCustomizations : Customizations -> Encode.Value
encodeCustomizations record =
    encodeObjectWithoutNothings
        [ normal ( "template", encodeTemplate record.template )
        , normal ( "id", ID.encode record.id )
        , omittable ( "names", Encode.list Encode.string, record.names )
        , omittable ( "icon", encodeIcon, record.icon )
        , omittable ( "excusable", encodeExcusable, record.excusable )
        , omittable ( "taskOptional", Encode.bool, record.taskOptional )
        , omittableList ( "evidence", encodeEvidence, record.evidence )
        , omittable ( "category", encodeCategory, record.category )
        , omittable ( "backgroundable", Encode.bool, record.backgroundable )
        , omittable ( "maxTime", encodeDurationPerPeriod, record.maxTime )
        , omittable ( "hidden", Encode.bool, record.hidden )
        , normal ( "externalIDs", Encode.dict identity Encode.string record.externalIDs )
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


type alias ActivityID =
    ID Activity



-- isStock : Activity -> Bool
-- isStock activity =
--     case activity.id of
--         Stock template ->
--             True
--
--         Custom int ->
--             False


dummy : ActivityID
dummy =
    ID.tag 0


dummyActivity : Activity
dummyActivity =
    defaults DillyDally


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
    Encode.int <| Duration.inMs (dur humanDuration)


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
    | Emoji String


decodeIcon : Decoder Icon
decodeIcon =
    decodeCustom
        [ ( "File", decodeFile )
        , ( "Ion", succeed Ion )
        , ( "Other", succeed Other )
        , ( "Emoji", Decode.map Emoji Decode.string )
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

        Emoji singleEmoji ->
            Encode.string singleEmoji


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
    IntDict Customizations


decodeStoredActivities : Decoder StoredActivities
decodeStoredActivities =
    Decode.map IntDict.fromList <| Decode.list (decodeTuple2 Decode.int decodeCustomizations)


encodeStoredActivities : StoredActivities -> Encode.Value
encodeStoredActivities value =
    Encode.list (encodeTuple2 Encode.int encodeCustomizations) (IntDict.toList value)


allActivities : StoredActivities -> IntDict Activity
allActivities stored =
    let
        stock =
            IntDict.fromList <| List.indexedMap Tuple.pair <| List.map defaults stockActivities

        customized =
            IntDict.map (\_ v -> withTemplate v) stored
    in
    IntDict.union customized stock


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
    , evidence = List.append base.evidence delta.evidence
    , category = over base.category delta.category
    , backgroundable = over base.backgroundable delta.backgroundable
    , maxTime = over base.maxTime delta.maxTime
    , hidden = over base.hidden delta.hidden
    , template = delta.template
    , externalIDs = delta.externalIDs
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
            { names = [ "Restroom", "Toilet", "WC", "Washroom", "Latrine", "Lavatory", "Water Closet" ]
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
            , icon = Emoji "\u{1F9B7}"
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
            , icon = Emoji "\u{1F971}"
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
            , excusable = IndefinitelyExcused
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
            , icon = Emoji "\u{1F9F9}"
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
            , icon = Emoji "\u{1F9F3}"
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
            , icon = Emoji "\u{1F9E0}"
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
            , icon = Emoji "\u{1F91D}"
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
            , icon = Emoji "\u{1F9D8}"
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
            , icon = Emoji "\u{1F913}"
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


showing : Activity -> Bool
showing activity =
    not activity.hidden


getName : Activity -> String
getName activity =
    Maybe.withDefault "?" (List.head activity.names)


getActivity : ActivityID -> IntDict Activity -> Activity
getActivity activityId activities =
    case IntDict.get (ID.read activityId) activities of
        Just activity ->
            activity

        Nothing ->
            defaults DillyDally
