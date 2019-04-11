module Activity exposing (Activity, ActivityId, Category(..), Customizations, Duration, DurationPerPeriod, Evidence(..), Excusable(..), Icon(..), SvgPath, Template(..), decodeCustomizations, decodeEvidence, decodeIcon, encodeActivity, encodeIcon, fromTemplate, getName, init, justTemplate, showing, withTemplate)

import Date
import Dict exposing (..)
import Ionicon
import Ionicon.Android as Android
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Porting exposing (..)
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
    }


{-| What's going on here?
Well, at first you might think this file should be like any other type, like Task for example. You define the type, its decoders, and helper functions, and that's it. This file started out that way too, and it's all here.

The problem with making a Time Tracker is that it's most useful with a huge amount of "default data", that is, activities that are ready to use out of the box. But... we don't want to store all of this default data! If the user makes no changes to the stock activities, his stored activity database should be empty. We don't want a fresh AppData full of boilerplate. If his list is missing an activity, how would we know if he deleted it, or simply came from a version where it didn't yet exist? We also want to improve the defaults over time, replacing them (on upgrade) with better defaults for each setting the user has not specifically customized. That means we need to keep track of not just the settings, but whether they were modified!

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
    }


type StoredActivity
    = Stock Template Customizations
    | Custom Template Customizations


justTemplate : Template -> Customizations
justTemplate activityTemplate =
    Customizations Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing activityTemplate


decodeCustomizations : Decode.Decoder Customizations
decodeCustomizations =
    let
        assumeNothing fieldName decoder =
            Pipeline.optional fieldName (Decode.maybe decoder) Nothing
    in
    decode Activity
        |> assumeNothing "names" Decode.list Decode.string
        |> assumeNothing "icon" decodeIcon
        |> assumeNothing "taskOptional" Decode.bool
        |> assumeNothing "evidence" (Decode.list decodeEvidence)
        |> assumeNothing "category" decodeCategory
        |> assumeNothing "backgroundable" Decode.bool
        |> assumeNothing "maxTime" decodeDurationPerPeriod
        |> assumeNothing "hidden" Decode.bool
        |> Pipeline.required "template" decodeTemplate


encodeActivity : a -> Encode.Value
encodeActivity a =
    Encode.object []



-- encodeTask : Activity -> Encode.Value
-- encodeTask record =
--     Encode.object
--         [ ( "names", Encode.list Encode.string record.names )
--         , ( "icon", encodeIcon <| record.icon )
--         , ( "taskOptional", Encode.bool <| record.taskOptional )
--         , ( "evidence", Encode.list encodeEvidence record.evidence )
--         , ( "category", encodeCategory <| record.category )
--         , ( "backgroundable", Encode.bool record.history )
--         , ( "maxTime", encodeDurationPerParent <| record.maxTime )
--         , ( "hidden", Encode.bool <| record.hidden )
--         , ( "template", encodeTemplate <| record.template )
--         ]


type alias ActivityId =
    Int


type Evidence
    = Evidence


decodeEvidence : Decoder Evidence
decodeEvidence =
    decodeCustom [ ( "Evidence", succeed Evidence ) ]


type Excusable
    = NeverExcused
    | TemporarilyExcused DurationPerPeriod
    | IndefinitelyExcused


{-| We could have both durations share a combined Interval, e.g. "50 minutes per 60 minutes", without losing any information, but it's more human friendly to say e.g. "50 minutes per hour" when we can.

Making Invalid States Unrepresentable: is there anyway to guarantee (via the type system) that the second duration is at least as large as the first?

Using a Custom type instead of a type alias: considering it, but it'd just have one value, meaning a tag that you'd always need to tack on, and there's not likely to be another type out there with the same structure that it could get mixed up with.

-}
type alias DurationPerPeriod =
    ( Duration, Duration )


{-| Duration: How long something lasts, e.g. "5 minutes".

Seems like there ought to be a more native way to represent Durations... but all the Time-related packages out there seem to ignore this use case, focusing instead on moments. Maybe I should add it to one of them?

-}
type alias Duration =
    ( Int, Interval )


{-| Icons. For activities, at least.
Is there a standard way to represent Icons of various types like this? If so, need to find an use that.
-}
type Icon
    = File SvgPath
    | Ion
    | Other


decodeIcon : Decoder Icon
decodeIcon =
    decodeCustom
        [ ( "File", Decode.string )
        , ( "Ion", succeed Ion )
        , ( "Other", succeed Other )
        ]


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


type Template
    = DillyDally
    | Apparel
    | Messaging
    | Restroom
    | Grooming
    | Meal
    | Supplements
    | Workout
    | Shower
    | Toothbrush
    | Floss
    | Wakeup
    | Sleep
    | Plan
    | Configure
    | Email
    | Work
    | Call
    | Chores
    | Parents
    | Prepare
    | Lover
    | Driving
    | Riding
    | SocialMedia
    | Pacing
    | Sport
    | Finance
    | Laundry
    | Bedward
    | Browse
    | Fiction
    | Learning
    | BrainTrain
    | Music
    | Create
    | Children
    | Meeting
    | Cinema
    | FilmWatching
    | Series
    | Broadcast
    | Theatre
    | Shopping
    | VideoGaming
    | Housekeeping
    | MealPrep
    | Networking
    | Meditate
    | Homework
    | Flight
    | Course
    | Pet
    | Presentation


type alias UserActivities =
    List Customizations


allActivities : UserActivities -> List Activity
allActivities stored =
    let
        userActivities =
            List.map withTemplate stored
    in
    stockActivities ++ userActivities


stockActivities : List StoredActivity
stockActivities =
    let
        stockFromTemplate template =
            Stock template (defaults template)
    in
    List.map stockFromTemplate [ DillyDally, Apparel, Messaging, Restroom, Grooming, Meal, Supplements, Workout, Shower, Toothbrush, Floss, Wakeup, Sleep, Plan, Configure, Email, Work, Call, Chores, Parents, Prepare, Lover, Driving, Riding, SocialMedia, Pacing, Sport, Finance, Laundry, Bedward, Browse, Fiction, Learning, BrainTrain, Music, Create, Children, Meeting, Cinema, FilmWatching, Series, Broadcast, Theatre, Shopping, VideoGaming, Housekeeping, MealPrep, Networking, Meditate, Homework, Flight, Course, Pet, Presentation ]


{-| Get a full activity from the saved version (which only contains the user's modifications to the default template).
It would be so much easier if i could just do { base | skel } like I originally wanted, when Customizations was just { template } with whatever extra fields the user overrode. Had to make it a maybe-ified carbon copy because updating a record with another (sub)record like { base | skel } isn't allowed...
-}
withTemplate : Template -> Customizations -> Activity
withTemplate template skel =
    let
        base =
            defaults template

        over b s =
            Maybe.withDefault b s
    in
    { names = over base.names skel.names
    , icon = over base.icon skel.icon
    , excusable = over base.excusable skel.excusable
    , taskOptional = over base.taskOptional skel.taskOptional
    , evidence = over base.evidence skel.evidence
    , category = over base.category skel.category
    , backgroundable = over base.backgroundable skel.backgroundable
    , maxTime = over base.maxTime skel.maxTime
    , hidden = over base.hidden skel.hidden
    }


defaults : Template -> Activity
defaults startingtemplate =
    case startingtemplate of
        DillyDally ->
            { names = [ "Nothing", "Dilly-dally", "Distracted" ]
            , icon = File "dillydally.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Apparel ->
            { names = [ "Appareling", "Dressing", "Getting Dressed" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( ( 15, Minute ), ( 3, Hour ) )
            , taskOptional = True
            , evidence = []
            , category = Hygiene
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Messaging ->
            { names = [ "Messaging", "Texting", "Chatting" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( ( 10, Minute ), ( 1, Hour ) )
            , taskOptional = True
            , evidence = []
            , category = Communication
            , backgroundable = False
            , maxTime = ( ( 2, Hour ), ( 5, Hour ) )
            , hidden = False
            }

        Restroom ->
            { names = [ "Restroom", "Toilet", "WC" ]
            , icon = File "unknown.svg"
            , excusable = TemporarilyExcused ( ( 20, Minute ), ( 2, Hour ) )
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Grooming ->
            { names = [ "Grooming", "Tending", "" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Meal ->
            { names = [ "Meal", "Eating", "Food" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Supplements ->
            { names = [ "Supplements", "Pills", "Medication" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Workout ->
            { names = [ "Workout", "Working Out", "" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Shower ->
            { names = [ "Shower", "Bathing", "Showering" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Toothbrush ->
            { names = [ "Toothbrush", "Teeth", "" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Floss ->
            { names = [ "Floss", "Flossing", "" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Wakeup ->
            { names = [ "Wakeup", "Waking Up", "" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Sleep ->
            { names = [ "Sleep", "Sleeping", "" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Plan ->
            { names = [ "Plan", "Planning", "" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Configure ->
            { names = [ "Configure", "Configuring", "" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Email ->
            { names = [ "Email", "E-Mail", "E-mail", "Emailing" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Work ->
            { names = [ "Work", "Working", "" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Call ->
            { names = [ "Call", "Calling", "Phone Call", "Phone" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Chores ->
            { names = [ "Chore", "Chores", "" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Parents ->
            { names = [ "Parents", "Parent Time", "" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Prepare ->
            { names = [ "Prepare", "Preparing", "Preparation" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Lover ->
            { names = [ "Lover", "S.O.", "Partner Time" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Driving ->
            { names = [ "Driving", "Drive", "" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Transit
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Riding ->
            { names = [ "Riding", "Ride", "Passenger" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        SocialMedia ->
            { names = [ "Social Media" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Pacing ->
            { names = [ "Pacing", "Pace" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Sport ->
            { names = [ "Sport", "Sports", "Playing Sports" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Finance ->
            { names = [ "Finance", "Financial", "" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Laundry ->
            { names = [ "Laundry" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Bedward ->
            { names = [ "Bedward", "Bedward-bound", "Going to Bed" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Browse ->
            { names = [ "Browse", "Browsing" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Fiction ->
            { names = [ "Fiction", "Reading Fiction" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Learning ->
            { names = [ "Learn", "Learning" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        BrainTrain ->
            { names = [ "Brain Training", "Braining", "Brain Train" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Music ->
            { names = [ "Music", "Music Listening" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Create ->
            { names = [ "Create", "Creating", "Creation", "Making" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Children ->
            { names = [ "Children", "Kids", "" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Meeting ->
            { names = [ "Meeting", "Meet", "Meetings" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Cinema ->
            { names = [ "Cinema", "Movies", "Movie Theatre", "Movie Theater" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        FilmWatching ->
            { names = [ "Films", "Film Watching", "Watching Movies" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Series ->
            { names = [ "Series", "TV Shows", "TV Series" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Broadcast ->
            { names = [ "Broadcast", "", "" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Theatre ->
            { names = [ "Theatre", "Play", "Play/Musical", "Drama" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Shopping ->
            { names = [ "Shopping", "Shop" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        VideoGaming ->
            { names = [ "Video", "Video Gaming", "Gaming" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Housekeeping ->
            { names = [ "Housekeeping" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        MealPrep ->
            { names = [ "Meal Prep", "Cooking", "Food making" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Networking ->
            { names = [ "Networking" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Meditate ->
            { names = [ "Meditate", "Meditation", "Meditating" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Homework ->
            { names = [ "Homework", "Schoolwork" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Flight ->
            { names = [ "Flight", "Aviation", "Flying", "Airport" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Course ->
            { names = [ "Course", "Courses", "Classes", "Class" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Pet ->
            { names = [ "Pet", "Pets", "Pet Care" ]
            , icon = File "unknown.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }

        Presentation ->
            { names = [ "Presentation", "Presenting", "Present" ]
            , icon = File "presentation.svg"
            , excusable = NeverExcused
            , taskOptional = True
            , evidence = []
            , category = Slacking
            , backgroundable = False
            , maxTime = ( ( 30, Minute ), ( 1, Hour ) )
            , hidden = False
            }


showing : Activity -> Bool
showing activity =
    not activity.hidden


getName : Activity -> String
getName activity =
    Maybe.withDefault "?" (List.head activity.names)
