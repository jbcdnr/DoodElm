module Messages exposing (..)

import Navigation
import Http
import PostgresDB exposing (DoodleEntry)
import Doodle.Edit
import Doodle.Show


type Msg
    = OnFetchAll (Result Http.Error (List DoodleEntry))
    | ReloadDB (Result Http.Error Int)
    | ShowList
    | ShowDoodle Int
    | CreateDoodle
    | ToEditDoodle Doodle.Edit.Msg
    | ToShowDoodle Doodle.Show.Msg
    | OnLocationChange Navigation.Location
