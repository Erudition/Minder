module BugReport exposing (..)

import Json.Decode as Decode exposing (..)

import BugReport2 exposing (..)

-- type alias Moment = String


decodeOnDayOf : Decoder MomentOrDay
decodeOnDayOf =
  Decode.map OnDayOf (thing)

thing = Decode.field "moment" decodeMoment


decodeMoment : Decode.Decoder Moment
decodeMoment = string
