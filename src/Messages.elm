module Messages exposing (..)

import Navigation
import Model exposing (..)
import EditDoodle
import ShowDoodle


type Msg
    = ShowList
    | CreateDoodle
    | ToEditDoodle EditDoodle.Msg
    | ToShowDoodle ShowDoodle.Msg
    | OnLocationChange Navigation.Location
