module Main exposing (Route(..), routeParser)

import Url.Parser exposing ((</>), (<?>), Parser, fragment, int, map, oneOf, s, string)
import Url.Parser.Query as Query


type Route
    = Topic String
    | Blog Int
    | User String
    | Comment String Int
    | BlogQuery (Maybe String)
    | Location String (Maybe String)


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map Topic (s "topic" </> string)
        , map Blog (s "blog" </> int)
        , map User (s "user" </> string)
        , map Comment (s "user" </> string </> s "comment" </> int)
        , map BlogQuery (s "blog" <?> Query.string "q")
        , map Location (string </> fragment identity)
        ]
