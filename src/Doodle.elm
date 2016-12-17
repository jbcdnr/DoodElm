module Doodle exposing (..)

import Array exposing (Array)


type alias Doodle =
    { id : Int
    , title : String
    , options : Array String
    , choices : Array PeopleChoices
    , newChoices : PeopleChoices
    }


emptyDoodle =
    Doodle 0 "" (Array.repeat 3 "") Array.empty (PeopleChoices "" Array.empty)


type alias PeopleChoices =
    { name : String
    , choices : Choices
    }


type alias Choices =
    Array Bool
