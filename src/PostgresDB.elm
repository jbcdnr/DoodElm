module PostgresDB exposing (DoodleEntry, digestEntryDoodles)

import List.Extra as List
import Doodle exposing (..)


type alias DoodleEntry =
    { id : Int
    , title : String
    , options : List String
    , choices : List Bool
    , name : String
    }


digestEntryDoodles : List DoodleEntry -> List Doodle
digestEntryDoodles raws =
    raws
        |> List.foldl
            (\raw doodles ->
                let
                    { id, title, options, choices, name } =
                        raw

                    alreadyExisting =
                        doodles |> List.find (\d -> d.id == id)

                    peopleChoices =
                        ChoicesWithName name choices
                in
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
