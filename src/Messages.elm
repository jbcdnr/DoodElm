module Messages exposing (..)

import Navigation
import Model exposing (..)
import EditDoodle
import ShowDoodle
import Doodle exposing (..)
import Http


type Msg
    = ShowList
    | CreateDoodle
    | ToEditDoodle EditDoodle.Msg
    | ToShowDoodle ShowDoodle.Msg
    | OnLocationChange Navigation.Location
    | OnFetchAll (Result Http.Error (List RawDoodleChoice))
