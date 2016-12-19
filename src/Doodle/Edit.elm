module Doodle.Edit exposing (Msg, Res(..), update, view, Model)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Doodle exposing (..)
import List.Extra as List
import ListUtils as List
import Graphics


type Msg
    = OnSaveButton
    | OnQuit
    | UpdateTitle String
    | UpdateOption Int String
    | AddOption
    | DeleteOption Int


type Res
    = NoOp
    | Save
    | Cancel


type alias Model =
    Doodle


update : Msg -> Model -> ( Model, Cmd Msg, Res )
update msg ({ id, title, options, choices } as model) =
    case msg of
        OnSaveButton ->
            if title == "" then
                model ! NoOp
            else
                model ! Save

        OnQuit ->
            model ! Cancel

        UpdateTitle t ->
            { model | title = t } ! NoOp

        UpdateOption id value ->
            let
                newOptions =
                    List.set id value options
            in
                { model | options = newOptions } ! NoOp

        AddOption ->
            { model | options = List.append options [ "" ] } ! NoOp

        DeleteOption id ->
            let
                newOptions =
                    if List.length options == 1 then
                        options
                    else
                        List.removeAt id options
            in
                { model | options = newOptions } ! NoOp


view : Doodle -> Html Msg
view ({ id, title, options, choices } as doodle) =
    let
        cancelButton =
            Graphics.backArrow [ onClick OnQuit ]

        title =
            input [ placeholder "Title", onInput UpdateTitle, class "title" ] []

        addButton =
            div [] [ button [ onClick AddOption ] [ text "Add option" ] ]

        optionEntry id name =
            div [ class "edit-option" ]
                [ span []
                    [ input [ type_ "text", placeholder ("Option " ++ toString (id + 1)), onInput (UpdateOption id), value (List.getAt id options |> Maybe.withDefault "") ] []
                    , span [ class "delete-cross" ] [ Graphics.cross [ onClick (DeleteOption id) ] ]
                    ]
                ]

        optionsList =
            options |> List.indexedMap optionEntry

        saveButton =
            div [] [ button [ onClick OnSaveButton, class "button-primary" ] [ text "Save" ] ]
    in
        div [ Html.Attributes.id "edit-doodle" ]
            (List.append
                ((div [ Html.Attributes.id "header" ] [ cancelButton, title ])
                    :: optionsList
                )
                [ addButton
                , saveButton
                ]
            )


(!) : Doodle -> Res -> ( Doodle, Cmd Msg, Res )
(!) d res =
    ( d, Cmd.none, res )
