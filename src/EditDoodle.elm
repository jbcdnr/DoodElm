module EditDoodle exposing (..)

import Doodle exposing (..)
import List.Extra as List
import ListUtils as List
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


defaultChoice : Doodle -> PeopleChoices
defaultChoice doodle =
    PeopleChoices "" (List.repeat (List.length doodle.options) False)


update : Msg -> EditDoodle -> ( EditDoodle, Cmd Msg, Res )
update msg ({ id, title, options, choices, newChoices } as model) =
    case msg of
        SaveButton ->
            ( emptyDoodle, Cmd.none, Save { model | newChoices = (defaultChoice model) } )

        Quit ->
            ( emptyDoodle, Cmd.none, Cancel )

        UpdateTitle t ->
            { model | title = t } ! []

        UpdateOption id value ->
            let
                newOptions =
                    List.set id value options
            in
                { model | options = newOptions } ! []

        AddOption ->
            { model | options = List.append options [ "" ] } ! []

        DeleteOption id ->
            let
                newOptions =
                    if List.length options == 1 then
                        options
                    else
                        List.removeAt id options
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
                    [ input [ placeholder ("Option " ++ toString (id + 1)), onInput (UpdateOption id), value (List.getAt id options |> Maybe.withDefault "") ] []
                    , button [ onClick (DeleteOption id) ] [ text "Delete" ]
                    ]
                ]

        optionsList =
            options |> List.indexedMap optionEntry

        saveButton =
            div [] [ button [ onClick SaveButton ] [ text "Save" ] ]
    in
        div [] (List.append (List.append [ cancelButton, title ] optionsList) [ addButton, saveButton ])


(!) : EditDoodle -> List (Cmd Msg) -> ( EditDoodle, Cmd Msg, Res )
(!) d cs =
    ( d, Cmd.batch cs, NoOp )
