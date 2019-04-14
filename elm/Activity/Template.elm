module Activity.Template exposing (Template(..), decodeTemplate, encodeTemplate, stockActivities)

import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Porting exposing (..)


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


decodeTemplate : Decoder Template
decodeTemplate =
    decodeCustomFlat
        [ ( "DillyDally", DillyDally )
        , ( "Apparel", Apparel )
        , ( "Messaging", Messaging )
        , ( "Restroom", Restroom )
        , ( "Grooming", Grooming )
        , ( "Meal", Meal )
        , ( "Supplements", Supplements )
        , ( "Workout", Workout )
        , ( "Shower", Shower )
        , ( "Toothbrush", Toothbrush )
        , ( "Floss", Floss )
        , ( "Wakeup", Wakeup )
        , ( "Sleep", Sleep )
        , ( "Plan", Plan )
        , ( "Configure", Configure )
        , ( "Email", Email )
        , ( "Work", Work )
        , ( "Call", Call )
        , ( "Chores", Chores )
        , ( "Parents", Parents )
        , ( "Prepare", Prepare )
        , ( "Lover", Lover )
        , ( "Driving", Driving )
        , ( "Riding", Riding )
        , ( "SocialMedia", SocialMedia )
        , ( "Pacing", Pacing )
        , ( "Sport", Sport )
        , ( "Finance", Finance )
        , ( "Laundry", Laundry )
        , ( "Bedward", Bedward )
        , ( "Browse", Browse )
        , ( "Fiction", Fiction )
        , ( "Learning", Learning )
        , ( "BrainTrain", BrainTrain )
        , ( "Music", Music )
        , ( "Create", Create )
        , ( "Children", Children )
        , ( "Meeting", Meeting )
        , ( "Cinema", Cinema )
        , ( "FilmWatching", FilmWatching )
        , ( "Series", Series )
        , ( "Broadcast", Broadcast )
        , ( "Theatre", Theatre )
        , ( "Shopping", Shopping )
        , ( "VideoGaming", VideoGaming )
        , ( "Housekeeping", Housekeeping )
        , ( "MealPrep", MealPrep )
        , ( "Networking", Networking )
        , ( "Meditate", Meditate )
        , ( "Homework", Homework )
        , ( "Flight", Flight )
        , ( "Course", Course )
        , ( "Pet", Pet )
        , ( "Presentation", Presentation )
        ]


encodeTemplate : Template -> Encode.Value
encodeTemplate v =
    case v of
        DillyDally ->
            Encode.string "DillyDally"

        Apparel ->
            Encode.string "Apparel"

        Messaging ->
            Encode.string "Messaging"

        Restroom ->
            Encode.string "Restroom"

        Grooming ->
            Encode.string "Grooming"

        Meal ->
            Encode.string "Meal"

        Supplements ->
            Encode.string "Supplements"

        Workout ->
            Encode.string "Workout"

        Shower ->
            Encode.string "Shower"

        Toothbrush ->
            Encode.string "Toothbrush"

        Floss ->
            Encode.string "Floss"

        Wakeup ->
            Encode.string "Wakeup"

        Sleep ->
            Encode.string "Sleep"

        Plan ->
            Encode.string "Plan"

        Configure ->
            Encode.string "Configure"

        Email ->
            Encode.string "Email"

        Work ->
            Encode.string "Work"

        Call ->
            Encode.string "Call"

        Chores ->
            Encode.string "Chores"

        Parents ->
            Encode.string "Parents"

        Prepare ->
            Encode.string "Prepare"

        Lover ->
            Encode.string "Lover"

        Driving ->
            Encode.string "Driving"

        Riding ->
            Encode.string "Riding"

        SocialMedia ->
            Encode.string "SocialMedia"

        Pacing ->
            Encode.string "Pacing"

        Sport ->
            Encode.string "Sport"

        Finance ->
            Encode.string "Finance"

        Laundry ->
            Encode.string "Laundry"

        Bedward ->
            Encode.string "Bedward"

        Browse ->
            Encode.string "Browse"

        Fiction ->
            Encode.string "Fiction"

        Learning ->
            Encode.string "Learning"

        BrainTrain ->
            Encode.string "BrainTrain"

        Music ->
            Encode.string "Music"

        Create ->
            Encode.string "Create"

        Children ->
            Encode.string "Children"

        Meeting ->
            Encode.string "Meeting"

        Cinema ->
            Encode.string "Cinema"

        FilmWatching ->
            Encode.string "FilmWatching"

        Series ->
            Encode.string "Series"

        Broadcast ->
            Encode.string "Broadcast"

        Theatre ->
            Encode.string "Theatre"

        Shopping ->
            Encode.string "Shopping"

        VideoGaming ->
            Encode.string "VideoGaming"

        Housekeeping ->
            Encode.string "Housekeeping"

        MealPrep ->
            Encode.string "MealPrep"

        Networking ->
            Encode.string "Networking"

        Meditate ->
            Encode.string "Meditate"

        Homework ->
            Encode.string "Homework"

        Flight ->
            Encode.string "Flight"

        Course ->
            Encode.string "Course"

        Pet ->
            Encode.string "Pet"

        Presentation ->
            Encode.string "Presentation"


stockActivities : List Template
stockActivities =
    [ DillyDally, Apparel, Messaging, Restroom, Grooming, Meal, Supplements, Workout, Shower, Toothbrush, Floss, Wakeup, Sleep, Plan, Configure, Email, Work, Call, Chores, Parents, Prepare, Lover, Driving, Riding, SocialMedia, Pacing, Sport, Finance, Laundry, Bedward, Browse, Fiction, Learning, BrainTrain, Music, Create, Children, Meeting, Cinema, FilmWatching, Series, Broadcast, Theatre, Shopping, VideoGaming, Housekeeping, MealPrep, Networking, Meditate, Homework, Flight, Course, Pet, Presentation ]
