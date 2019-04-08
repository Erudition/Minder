module Activity exposing (Activity, ActivityId, ActivityTemplate(..), Category(..), Duration, DurationPerPeriod, Evidence(..), Excusable(..), Icon(..), SvgPath, decodeActivity, encodeActivity, fromTemplate, getName, showing)

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
    , template : ActivityTemplate -- template this activity was derived from, in case we want to propogate changes to defaults
    }


type alias ActivitySkeleton =
    { names : Maybe (List String)
    , icon : Maybe Icon
    , excusable : Maybe Excusable
    , taskOptional : Maybe Bool
    , evidence : Maybe (List Evidence)
    , category : Maybe Category
    , backgroundable : Maybe Bool
    , maxTime : Maybe DurationPerPeriod
    , hidden : Maybe Bool
    , template : ActivityTemplate
    }


justTemplate : ActivityTemplate -> ActivitySkeleton
justTemplate activityTemplate =
    ActivitySkeleton Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing activityTemplate


decodeActivity : Decoder Activity
decodeActivity =
    Decode.succeed (fromTemplate DillyDally)



-- decodeActivity : Decode.Decoder Activity
-- decodeActivity =
--     decode Activity
--         |> Pipeline.required "names" Decode.list Decode.string
--         |> Pipeline.required "icon" decodeIcon
--         |> Pipeline.required "taskOptional" Decode.bool
--         |> Pipeline.required "evidence" (Decode.list decodeEvidence)
--         |> Pipeline.required "category" decodeCategory
--         |> Pipeline.required "backgroundable" Decode.bool
--         |> Pipeline.required "maxTime" decodeDurationPerPeriod
--         |> Pipeline.required "hidden" Decode.bool
--         |> Pipeline.required "template" decodeTemplate
--
--


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


type ActivityTemplate
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


init : List ActivitySkeleton
init =
    List.map justTemplate [ DillyDally, Apparel, Messaging, Restroom, Grooming, Meal, Supplements, Workout, Shower, Toothbrush, Floss, Wakeup, Sleep, Plan, Configure, Email, Work, Call, Chores, Parents, Prepare, Lover, Driving, Riding, SocialMedia, Pacing, Sport, Finance, Laundry, Bedward, Browse, Fiction, Learning, BrainTrain, Music, Create, Children, Meeting, Cinema, FilmWatching, Series, Broadcast, Theatre, Shopping, VideoGaming, Housekeeping, MealPrep, Networking, Meditate, Homework, Flight, Course, Pet, Presentation ]


{-| Get a full activity from the saved version (which only contains the user's modifications to the default template).
It would be so much easier if i could just do { base | skel } like I originally wanted, when ActivitySkeleton was just { template } with whatever extra fields the user overrode. Had to make it a maybe-ified carbon copy because updating a record with another (sub)record like { base | skel } isn't allowed...
-}
withTemplate : ActivitySkeleton -> Activity
withTemplate ({ template } as skel) =
    let
        base =
            fromTemplate template

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
    , template = template
    }


fromTemplate : ActivityTemplate -> Activity
fromTemplate startingtemplate =
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
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
            , template = startingtemplate
            }


showing : Activity -> Bool
showing activity =
    not activity.hidden


getName : Activity -> String
getName activity =
    Maybe.withDefault "?" (List.head activity.names)
