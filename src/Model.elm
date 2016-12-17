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
    , doodles = Array.empty
    , editDoodle = emptyDoodle
    }
