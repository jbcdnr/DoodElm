module PostgresDB exposing (DoodleEntry, digestEntryDoodles)

import List.Extra as List
import Doodle exposing (..)


type alias DoodleEntry =
    { id : Int
    , title : String
    , options : List String
    , choices : Maybe (List Bool)
    , name : Maybe String
    }


digestEntryDoodles : List DoodleEntry -> List Doodle
digestEntryDoodles raws =
    raws
        |> List.foldr
            (\raw doodles ->
                let
                    { id, title, options, choices, name } =
                        raw

                    alreadyExisting =
                        doodles |> List.find (\d -> d.id == id)

                    maybePeopleChoices =
                        Maybe.map2 ChoicesWithName name choices
                in
                    case maybePeopleChoices of
                        Nothing ->
                            ({ id = id, title = title, options = options, choices = [] }) :: doodles

                        Just peopleChoices ->
                            case alreadyExisting of
                                Nothing ->
                                    ({ id = id, title = title, options = options, choices = [ peopleChoices ] }) :: doodles

                                Just existing ->
                                    doodles
                                        |> List.updateIf
                                            (\d -> d.id == id)
                                            (\_ -> { existing | choices = (peopleChoices :: existing.choices) })
            )
            []
