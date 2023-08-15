module Task.Series exposing (..)

import ID exposing (ID)


type alias SeriesMemberID =
    ( ID Series, SeriesIndex )


memberIDToString : SeriesMemberID -> String
memberIDToString ( seriesID, seriesIndex ) =
    ID.toString seriesID ++ " " ++ String.fromInt seriesIndex


type alias SeriesIndex =
    Int


{-| Defines the way a series can regularly recur.
-}
type alias Series =
    { rules : () }



-- TODO
