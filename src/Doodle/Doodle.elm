module Doodle exposing (..)


type alias Doodle =
    { id : Int
    , title : String
    , options : List String
    , choices : List ChoicesWithName
    }


emptyDoodle =
    Doodle 0 "" (List.repeat 3 "") []


type alias Choices =
    List Bool


type alias ChoicesWithName =
    { name : String
    , choices : Choices
    }


emptyChoices : Int -> Choices
emptyChoices count =
    List.repeat count False


emptyChoicesFromDoodle : Doodle -> Choices
emptyChoicesFromDoodle doodle =
    List.repeat (List.length doodle.options) False
