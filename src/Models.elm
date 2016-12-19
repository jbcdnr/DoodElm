module Models exposing (Model, initialModel, findDoodleWithId, nextDoodleId)

import Routing
import Doodle.Show
import Doodle exposing (..)


type alias Model =
    { route : Routing.Route
    , doodles : List Doodle
    , showCurrentChoice : Maybe Doodle.Show.Model
    , editCurrent : Maybe Doodle
    }


initialModel : Routing.Route -> Model
initialModel route =
    { route = route
    , doodles = [ d1, d2, d3 ]
    , showCurrentChoice = Nothing
    , editCurrent = Nothing
    }


findDoodleWithId : Int -> List Doodle -> Maybe Doodle
findDoodleWithId id doodles =
    doodles |> List.filter (\d -> d.id == id) |> List.head


nextDoodleId : List Doodle -> Int
nextDoodleId doodles =
    (doodles |> List.map .id |> List.maximum |> Maybe.withDefault 0) + 1


d1 =
    Doodle 1
        "Menu"
        [ "Vegetarian", "Meat", "Fish", "Vegan", "Other" ]
        [ ChoicesWithName "JB" [ False, True, False, False, False ]
        , ChoicesWithName "Alexis" [ True, False, False, False, False ]
        , ChoicesWithName "Prisca" [ False, False, False, False, True ]
        ]


d2 =
    Doodle 10
        "Sport"
        [ "Volley", "Foot", "Tennis", "Yoga", "Fencing" ]
        [ ChoicesWithName "JB" [ False, True, False, False, False ]
        , ChoicesWithName "Alexis" [ True, False, False, False, False ]
        , ChoicesWithName "Prisca" [ False, False, False, False, True ]
        ]


d3 =
    Doodle 100
        "Holidays"
        [ "Iceland", "Nepal", "USA", "Switzerland", "France" ]
        [ ChoicesWithName "JB" [ False, True, False, False, False ]
        , ChoicesWithName "Alexis" [ True, False, False, False, False ]
        , ChoicesWithName "Prisca" [ False, False, False, False, True ]
        ]
