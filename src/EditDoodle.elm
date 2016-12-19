module EditDoodle exposing (Msg, Res(..), update, view)

import Html exposing (Html, div, input, button, text, span)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (class, placeholder, type_, value)
import Doodle exposing (Doodle, PeopleChoices, emptyDoodle)
import List.Extra as List exposing (getAt, removeAt)
import ListUtils as List exposing (set)
import DesignRessources exposing (backArrow)


type Msg
    = SaveButton
    | Quit
    | UpdateTitle String
    | UpdateOption Int String
    | AddOption
    | DeleteOption Int


type Res
    = NoOp
    | Save
    | Cancel


update : Msg -> Doodle -> ( Doodle, Cmd Msg, Res )
update msg ({ id, title, options, choices, newChoices } as model) =
    case msg of
        SaveButton ->
            if title == "" then
                model ! []
            else
                ( { model | newChoices = (defaultChoice model) }, Cmd.none, Save )

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


view : Doodle -> Html Msg
view ({ id, title, options, choices, newChoices } as doodle) =
    let
        cancelButton =
            DesignRessources.backArrow [ onClick Quit ]

        title =
            input [ placeholder "Title", onInput UpdateTitle, class "title" ] []

        addButton =
            div [] [ button [ onClick AddOption ] [ text "Add option" ] ]

        optionEntry id name =
            div [ class "edit-option" ]
                [ span []
                    [ input [ type_ "text", placeholder ("Option " ++ toString (id + 1)), onInput (UpdateOption id), value (List.getAt id options |> Maybe.withDefault "") ] []
                    , span [ class "delete-cross" ] [ DesignRessources.cross [ onClick (DeleteOption id) ] ]
                    ]
                ]

        optionsList =
            options |> List.indexedMap optionEntry

        saveButton =
            div [] [ button [ onClick SaveButton, class "button-primary" ] [ text "Save" ] ]
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


defaultChoice : Doodle -> PeopleChoices
defaultChoice doodle =
    PeopleChoices "" (List.repeat (List.length doodle.options) False)


(!) : Doodle -> List (Cmd Msg) -> ( Doodle, Cmd Msg, Res )
(!) d cs =
    ( d, Cmd.batch cs, NoOp )
