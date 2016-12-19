module Messages exposing (..)

import Navigation
import Doodle.Edit
import Doodle.Show


type Msg
    = ShowList
    | ShowDoodle Int
    | CreateDoodle
    | ToEditDoodle Doodle.Edit.Msg
    | ToShowDoodle Doodle.Show.Msg
    | OnLocationChange Navigation.Location
