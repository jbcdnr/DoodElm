module Commands exposing (..)

import Doodle exposing (..)
import List.Extra as List exposing (find, updateIf)
import Json.Decode exposing (field)
import Http
import Messages exposing (..)


resourceUrl =
    "http://localhost:3000/doodles"


digestRawDoodles : List RawDoodleChoice -> List Doodle
digestRawDoodles raws =
    raws
        |> List.foldl
            (\raw doodles ->
                let
                    { id, title, options, choices, name } =
                        raw

                    alreadyExisting =
                        doodles |> List.find (\d -> d.id == id)

                    peopleChoices =
                        PeopleChoices name choices
                in
                    case alreadyExisting of
                        Nothing ->
                            ({ id = id, title = title, options = options, choices = [ peopleChoices ], newChoices = (PeopleChoices "" (List.repeat (List.length options) False)) }) :: doodles

                        Just existing ->
                            doodles |> List.updateIf (\d -> d.id == id) (\_ -> { existing | choices = (peopleChoices :: existing.choices) })
            )
            []


doodlesDecoder : Json.Decode.Decoder (List RawDoodleChoice)
doodlesDecoder =
    Json.Decode.list rawDoodleDecoder


rawDoodleDecoder : Json.Decode.Decoder RawDoodleChoice
rawDoodleDecoder =
    Json.Decode.map5 RawDoodleChoice
        (field "id" Json.Decode.int)
        (field "title" Json.Decode.string)
        (field "options" (Json.Decode.list Json.Decode.string))
        (field "choices" (Json.Decode.list Json.Decode.bool))
        (field "name" (Json.Decode.string))


fetchAll : Cmd Msg
fetchAll =
    Http.get resourceUrl doodlesDecoder
        |> Http.send OnFetchAll



{--

create : Doodle -> Cmd Msg
create doodle =
    doodleEncoder doodle
        |> Utils.postJson doodleDecoder resourceUrl
        -- TODO check UID
        |>
            Task.perform Fail CreateDone



-- add choice


create : Int -> PeopleChoices -> Cmd Msg
create doodleId choices =
    doodleEncoder doodle
        |> Utils.postJson doodleDecoder resourceUrl
        -- TODO check UID
        |>
            Task.perform Fail CreateDone

--}
