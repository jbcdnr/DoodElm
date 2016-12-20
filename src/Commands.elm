module Commands exposing (..)

import Json.Decode as Decode exposing (field)
import Json.Encode as Encode
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


doodlesDecoder : Decode.Decoder (List DoodleEntry)
doodlesDecoder =
    Decode.list doodleEntryDecoder


doodleEntryDecoder : Decode.Decoder DoodleEntry
doodleEntryDecoder =
    Decode.map5 DoodleEntry
        (field "id" Decode.int)
        (field "title" Decode.string)
        (field "options" (Decode.list Decode.string))
        (field "choices" (Decode.nullable (Decode.list Decode.bool)))
        (field "name" (Decode.nullable (Decode.string)))



-- ENCODER


doodleEncoder : Doodle -> Encode.Value
doodleEncoder ({ title, options } as doodle) =
    let
        optionsJSON =
            options |> List.map Encode.string |> Encode.list

        encodings =
            [ ( "title", Encode.string title )
            , ( "options", optionsJSON )
            ]
    in
        encodings
            |> Encode.object


choiceEncoder : Int -> ChoicesWithName -> Encode.Value
choiceEncoder id ({ name, choices } as choicesWithName) =
    let
        choicesJSON =
            choices |> List.map Encode.bool |> Encode.list

        encodings =
            [ ( "name", Encode.string name )
            , ( "choices", choicesJSON )
            , ( "doodleid", Encode.int id )
            ]
    in
        Encode.object encodings



-- COMMANDS


fetchAll : Cmd Msg
fetchAll =
    Http.get (pathUrl "doodles_with_choices") doodlesDecoder
        |> Http.send OnFetchAll


create : Doodle -> Cmd Msg
create doodle =
    let
        body =
            [ doodleEncoder doodle ] |> Encode.list |> Http.jsonBody

        idDecoder =
            (Decode.field "id" Decode.int)

        req =
            Http.post (pathUrl "doodles") body idDecoder
    in
        Http.send ReloadDB req



-- add choice


addChoice : Int -> ChoicesWithName -> Cmd Msg
addChoice doodleId choices =
    let
        body =
            choiceEncoder doodleId choices |> Http.jsonBody

        req =
            Http.post (pathUrl "choices") body Decode.int
    in
        Http.send ReloadDB req
