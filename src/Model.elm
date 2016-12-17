module Model exposing (..)

import Routing
import EditDoodle
import Doodle exposing (..)
import List.Extra as List
import ListUtils as List


type alias Model =
    { current : Routing.Route
    , doodles : List Doodle
    , editDoodle : EditDoodle.EditDoodle
    }


initialModel : Routing.Route -> Model
initialModel route =
    { current = route
    , doodles = [ d1 ]
    , editDoodle = emptyDoodle
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
