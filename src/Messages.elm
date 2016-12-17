module Messages exposing (..)

import Navigation
import Model exposing (..)
import EditDoodle


type Msg
    = ShowDoodle Int
    | ShowList
    | CreateDoodle
    | ToEditDoodle EditDoodle.Msg
    | ToggleChoice Int
    | DoneChoices
    | UpdateName String
    | OnLocationChange Navigation.Location
