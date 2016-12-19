module Commands exposing (..)

import Json.Decode exposing (field)
import Http
import PostgresDB exposing (DoodleEntry)
import Messages exposing (..)
import Doodle exposing (..)


resourceUrl =
    "http://localhost:3000/doodles_with_choices"


doodlesDecoder : Json.Decode.Decoder (List DoodleEntry)
doodlesDecoder =
    Json.Decode.list doodleEntryDecoder


doodleEntryDecoder : Json.Decode.Decoder DoodleEntry
doodleEntryDecoder =
    Json.Decode.map5 DoodleEntry
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
create : Int -> ChoicesWithName -> Cmd Msg
create doodleId choices =
    doodleEncoder doodle
        |> Utils.postJson doodleDecoder resourceUrl
        -- TODO check UID
        |>
            Task.perform Fail CreateDone
--}
