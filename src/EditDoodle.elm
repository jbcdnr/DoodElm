module EditDoodle
    exposing
        ( Msg
        , EditDoodle
        , update
        , view
        , Res(..)
        )

import Doodle exposing (..)
import Array exposing (Array)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)


type Msg
    = SaveButton
    | Quit
    | UpdateTitle String
    | UpdateOption Int String
    | AddOption
    | DeleteOption Int


type Res
    = NoOp
    | Save Doodle
    | Cancel


type alias EditDoodle =
    Doodle


update : Msg -> EditDoodle -> ( EditDoodle, Cmd Msg, Res )
update msg ({ id, title, options, choices, newChoices } as model) =
    case msg of
        SaveButton ->
            ( model, Cmd.none, Save model )

        Quit ->
            ( model, Cmd.none, Cancel )

        UpdateTitle t ->
            { model | title = t } ! []

        UpdateOption id value ->
            let
                newOptions =
                    Array.set id value options
            in
                { model | options = newOptions } ! []

        AddOption ->
            { model | options = Array.push "" options } ! []

        DeleteOption id ->
            let
                newOptions =
                    if Array.length options == 1 then
                        options
                    else
                        Array.append (Array.slice 0 id options) (Array.slice (id + 1) (Array.length options) options)
            in
                { model | options = newOptions } ! []


view : EditDoodle -> Html Msg
view ({ id, title, options, choices, newChoices } as doodle) =
    let
        cancelButton =
            div [] [ button [ onClick Quit ] [ text "Cancel" ] ]

        title =
            div [] [ input [ placeholder "Title", onInput UpdateTitle ] [] ]

        addButton =
            div [] [ button [ onClick AddOption ] [ text "Add" ] ]

        optionEntry id name =
            div []
                [ span []
                    [ input [ placeholder ("Option " ++ toString (id + 1)), onInput (UpdateOption id), value (Array.get id options |> Maybe.withDefault "") ] []
                    , button [ onClick (DeleteOption id) ] [ text "Delete" ]
                    ]
                ]

        optionsList =
            options |> Array.toList |> List.indexedMap optionEntry

        saveButton =
            div [] [ button [ onClick SaveButton ] [ text "Save" ] ]
    in
        div [] (List.append (List.append [ cancelButton, title ] optionsList) [ addButton, saveButton ])


(!) : EditDoodle -> List (Cmd Msg) -> ( EditDoodle, Cmd Msg, Res )
(!) d cs =
    ( d, Cmd.batch cs, NoOp )
