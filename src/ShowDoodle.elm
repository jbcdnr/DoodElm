module ShowDoodle exposing (Msg, Res(..), update, view)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Doodle exposing (Doodle, PeopleChoices)
import Array exposing (Array)
import Debug exposing (log)


type Msg
    = ToggleChoice Int
    | DoneChoices
    | UpdateName String
    | QuitButton


type Res
    = NoOp
    | Quit Doodle


update : Msg -> Doodle -> ( Doodle, Cmd Msg, Res )
update msg ({ id, title, options, choices, newChoices } as model) =
    case msg of
        ToggleChoice id ->
            toggleChoice id model ! []

        DoneChoices ->
            let
                cs =
                    Array.push newChoices choices

                emptyChoices =
                    defaultChoice model
            in
                { model | choices = cs, newChoices = emptyChoices } ! []

        UpdateName name ->
            let
                renamed =
                    { newChoices | name = name }
            in
                { model | newChoices = renamed } ! []

        QuitButton ->
            ( Doodle.emptyDoodle, Cmd.none, Quit model )


toggleChoice : Int -> Doodle -> Doodle
toggleChoice id ({ newChoices } as doodle) =
    let
        new =
            newChoices.choices
                |> Array.indexedMap
                    (\i c ->
                        if i == id then
                            not c
                        else
                            c
                    )
    in
        { doodle | newChoices = { newChoices | choices = new } }


defaultChoice : Doodle -> PeopleChoices
defaultChoice doodle =
    PeopleChoices "" (Array.repeat (Array.length doodle.options) False)


view : Doodle -> Html Msg
view ({ title, options, choices, newChoices } as doodle) =
    let
        backButton =
            button [ onClick QuitButton ] [ text "Back" ]

        titleh =
            h1 [] [ text title ]

        headerLine =
            tr []
                ((th [] [ text "Name" ])
                    :: (options
                            |> Array.map (\opt -> th [] [ text opt ])
                            |> Array.toList
                       )
                )

        nameInput =
            td [] [ input [ onInput UpdateName, placeholder "Name" ] [] ]

        currentChoicesSelector =
            newChoices.choices
                |> Array.indexedMap
                    (\i c -> td [] [ input [ type_ "checkbox", onClick (ToggleChoice i), checked c, disabled False ] [] ])
                |> Array.toList

        saveChoice =
            td [] [ button [ onClick DoneChoices ] [ text "Done" ] ]

        bottomLine =
            tr [] (List.append (nameInput :: currentChoicesSelector) [ saveChoice ])

        choicesTable : List (Html Msg) -> Html Msg
        choicesTable content =
            table [] (List.append (headerLine :: content) [ bottomLine ])

        choiceLine : PeopleChoices -> Html Msg
        choiceLine ({ name, choices } as peopleChoice) =
            tr []
                ((td [] [ text name ])
                    :: (choices
                            |> Array.map
                                (\c -> td [] [ input [ type_ "checkbox", checked c, disabled True ] [] ])
                            |> Array.toList
                       )
                )
    in
        div [] [ backButton, titleh, choicesTable (doodle.choices |> Array.map choiceLine |> Array.toList) ]


checkbox : Bool -> Bool -> msg -> Html msg
checkbox ch dis msg =
    input [ type_ "checkbox", onClick msg, checked ch, disabled dis ] []


(!) : Doodle -> List (Cmd Msg) -> ( Doodle, Cmd Msg, Res )
(!) d cs =
    ( d, Cmd.batch cs, NoOp )
