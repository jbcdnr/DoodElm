module Doodle exposing (Doodle, emptyDoodle, PeopleChoices, Choices)

import List.Extra as List


type alias Doodle =
    { id : Int
    , title : String
    , options : List String
    , choices : List PeopleChoices
    , newChoices : PeopleChoices
    }


emptyDoodle =
    Doodle 0 "" (List.repeat 3 "") [] (PeopleChoices "" [])


type alias PeopleChoices =
    { name : String
    , choices : Choices
    }


type alias Choices =
    List Bool
