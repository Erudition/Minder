module BugReport2 exposing (Moment(..), MomentOrDay(..))


type Moment
    = String


type MomentOrDay
    = AtExactly Moment
    | OnDayOf Moment
