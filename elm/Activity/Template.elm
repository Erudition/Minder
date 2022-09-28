module Activity.Template exposing (Template(..), all, codec)

import Helpers exposing (..)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Replicated.Codec as Codec exposing (SymCodec, coreRW, fieldList, fieldRW)
import Replicated.Reducer.Register as Register exposing (RW)
import Replicated.Reducer.RepStore as RepDb exposing (Store(..))
import Replicated.Reducer.RepList as RepList exposing (RepList)


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
    | Projects
    | Research
    | Repair


codec : SymCodec e Template
codec =
    Codec.quickEnum DillyDally allExceptDillyDally


allExceptDillyDally : List Template
allExceptDillyDally =
    [ Apparel, Messaging, Restroom, Grooming, Meal, Supplements, Workout, Shower, Toothbrush, Floss, Wakeup, Sleep, Plan, Configure, Email, Work, Call, Chores, Parents, Prepare, Lover, Driving, Riding, SocialMedia, Pacing, Sport, Finance, Laundry, Bedward, Browse, Fiction, Learning, BrainTrain, Music, Create, Children, Meeting, Cinema, FilmWatching, Series, Broadcast, Theatre, Shopping, VideoGaming, Housekeeping, MealPrep, Networking, Meditate, Homework, Flight, Course, Pet, Presentation, Projects, Research ]


all : List Template
all =
    DillyDally :: allExceptDillyDally
