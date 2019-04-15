module Trackable.Property exposing (Trackable)

import List.Nonempty exposing (..)


type alias Trackable meta property =
    { current : property
    , meta : meta
    , history : TrackedValues meta property
    , origin : property
    , back : Int -> property
    }


type alias TrackedValues meta property =
    Nonempty ( meta, property )


init : meta -> property -> Trackable meta property
init meta property =
    let
        historyList =
            fromElement ( meta, property )
    in
    builder historyList


builder : TrackedValues meta property -> Trackable meta property
builder historyList =
    { current = Tuple.second (head historyList)
    , meta = Tuple.first (head historyList)
    , history = historyList
    , origin = Tuple.second (get -1 historyList)
    , back = goBack historyList
    }


goBack : TrackedValues meta property -> Int -> property
goBack historyList count =
    Tuple.second (get (count - 1) historyList)


push : Trackable meta property -> ( meta, property ) -> Trackable meta property
push { history } newValue =
    builder (cons newValue history)


changes : Trackable meta property -> List ( meta, property )
changes { history } =
    history
        |> toList
        |> List.reverse
        |> List.drop 1
        |> List.reverse
