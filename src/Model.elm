module Model exposing (..)

import Array exposing (Array)
import Routing
import EditDoodle
import Doodle exposing (..)


type alias Model =
    { current : Routing.Route
    , doodles : Array Doodle
    , editDoodle : EditDoodle.EditDoodle
    }


initialModel : Routing.Route -> Model
initialModel route =
    { current = route
    , doodles = Array.fromList [ d1 ]
    , editDoodle = emptyDoodle
    }


d1 =
    Doodle 1
        "Menu"
        (Array.fromList [ "Vegetarian", "Meat", "Fish", "Vegan", "Other" ])
        ([ PeopleChoices "JB" (Array.fromList [ False, True, False, False, False ])
         , PeopleChoices "Alexis" (Array.fromList [ True, False, False, False, False ])
         , PeopleChoices "Prisca" (Array.fromList [ False, False, False, False, True ])
         ]
            |> Array.fromList
        )
        (PeopleChoices "" (Array.repeat 5 False))
