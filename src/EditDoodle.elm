module EditDoodle exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Doodle exposing (..)
import List.Extra as List exposing (getAt, removeAt)
import ListUtils as List exposing (set)
import Checkbox


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


defaultChoice : Doodle -> PeopleChoices
defaultChoice doodle =
    PeopleChoices "" (List.repeat (List.length doodle.options) False)


update : Msg -> Doodle -> ( Doodle, Cmd Msg, Res )
update msg ({ id, title, options, choices, newChoices } as model) =
    case msg of
        SaveButton ->
            if title == "" then model ! [] else
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
            Checkbox.backArrow [ onClick Quit ]

        title =
            input [ placeholder "Title", onInput UpdateTitle, class "title-create"] []

        addButton =
            div [] [ button [ onClick AddOption ] [ text "Add option" ] ]

        optionEntry id name =
            div [ class "edit-option" ]
                [ span []
                    [ input [ type_ "text", placeholder ("Option " ++ toString (id + 1)), onInput (UpdateOption id), value (List.getAt id options |> Maybe.withDefault "") ] []
                    , span [class "delete-cross"] [Checkbox.cross [ onClick (DeleteOption id) ]]
                    ]
                ]

        optionsList =
            options |> List.indexedMap optionEntry

        saveButton =
            div [] [ button [ onClick SaveButton, class "button-primary" ] [ text "Save" ] ]
    in
        div []
            (List.append ((div [class "edit-title"] [ cancelButton, title ])
            :: optionsList)
            [ addButton
            , saveButton ])


(!) : Doodle -> List (Cmd Msg) -> ( Doodle, Cmd Msg, Res )
(!) d cs =
    ( d, Cmd.batch cs, NoOp )
