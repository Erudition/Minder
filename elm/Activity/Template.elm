module Activity.Template exposing (Template(..), codec)

import Helpers exposing (..)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Replicated.Codec as Codec exposing (Codec, essentialWritable, listField, writableField)
import Replicated.Reducer.Register as Register exposing (RW)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb(..))
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


codec : Codec e Template
codec =
    Codec.quickEnum DillyDally [ Apparel, Messaging, Restroom, Grooming, Meal, Supplements, Workout, Shower, Toothbrush, Floss, Wakeup, Sleep, Plan, Configure, Email, Work, Call, Chores, Parents, Prepare, Lover, Driving, Riding, SocialMedia, Pacing, Sport, Finance, Laundry, Bedward, Browse, Fiction, Learning, BrainTrain, Music, Create, Children, Meeting, Cinema, FilmWatching, Series, Broadcast, Theatre, Shopping, VideoGaming, Housekeeping, MealPrep, Networking, Meditate, Homework, Flight, Course, Pet, Presentation, Projects, Research ]
