module Commands exposing (..)

import Json.Decode exposing (field)
import Json.Encode
import Http
import PostgresDB exposing (DoodleEntry)
import Messages exposing (..)
import Doodle exposing (..)
import Debug


rootUrl =
    "http://localhost:3000/"


pathUrl : String -> String
pathUrl p =
    rootUrl ++ p



-- DECODER


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



-- ENCODER


doodleEncoder : Doodle -> Json.Encode.Value
doodleEncoder ({ title, options } as doodle) =
    let
        optionsJSON =
            options |> List.map Json.Encode.string |> Json.Encode.list

        encodings =
            [ ( "title", Json.Encode.string title )
            , ( "options", optionsJSON )
            ]
    in
        encodings
            |> Json.Encode.object



-- COMMANDS


fetchAll : Cmd Msg
fetchAll =
    Http.get (pathUrl "doodles_with_choices") doodlesDecoder
        |> Http.send OnFetchAll


create : Doodle -> Cmd Msg
create doodle =
    let
        body =
            [ doodleEncoder doodle ] |> Json.Encode.list |> Http.jsonBody

        idDecoder =
            (Json.Decode.field "id" Json.Decode.int)

        req =
            Http.post (pathUrl "doodles") body idDecoder
    in
        Http.send OnSentNewDoodle req



{--
-- add choice
create : Int -> ChoicesWithName -> Cmd Msg
create doodleId choices =
    doodleEncoder doodle
        |> Utils.postJson doodleDecoder resourceUrl
        -- TODO check UID
        |>
            Task.perform Fail CreateDone
--}
