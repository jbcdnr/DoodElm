module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = List
    | Create
    | Show Int
    | NotFound


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map Show (s "doodles" </> int)
        , map List (s "doodles")
        , map List (s "")
        , map Create (s "doodles/new")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFound
