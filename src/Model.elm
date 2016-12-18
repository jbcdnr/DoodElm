module Model exposing (Model, initialModel)

import Routing
import EditDoodle
import Doodle exposing (..)


type alias Model =
    { current : Routing.Route
    , doodles : List Doodle
    , editingDoodle : Maybe Doodle
    }


initialModel : Routing.Route -> Model
initialModel route =
    { current = route
    , doodles = [ d1, d2, d3 ]
    , editingDoodle = Nothing
    }


d1 =
    Doodle 1
        "Menu"
        [ "Vegetarian", "Meat", "Fish", "Vegan", "Other" ]
        [ PeopleChoices "JB" [ False, True, False, False, False ]
        , PeopleChoices "Alexis" [ True, False, False, False, False ]
        , PeopleChoices "Prisca" [ False, False, False, False, True ]
        ]
        (PeopleChoices "" (List.repeat 5 False))


d2 =
    Doodle 10
        "Sport"
        [ "Volley", "Foot", "Tennis", "Yoga", "Fencing" ]
        [ PeopleChoices "JB" [ False, True, False, False, False ]
        , PeopleChoices "Alexis" [ True, False, False, False, False ]
        , PeopleChoices "Prisca" [ False, False, False, False, True ]
        ]
        (PeopleChoices "" (List.repeat 5 False))


d3 =
    Doodle 100
        "Holidays"
        [ "Iceland", "Nepal", "USA", "Switzerland", "France" ]
        [ PeopleChoices "JB" [ False, True, False, False, False ]
        , PeopleChoices "Alexis" [ True, False, False, False, False ]
        , PeopleChoices "Prisca" [ False, False, False, False, True ]
        ]
        (PeopleChoices "" (List.repeat 5 False))
