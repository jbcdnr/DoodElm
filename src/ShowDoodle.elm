module ShowDoodle exposing (Msg, Res(..), update, view)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Doodle exposing (Doodle, PeopleChoices)
import Debug exposing (log)
import List.Extra as List
import ListUtils as List


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
                    List.append choices [ newChoices ]

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
                |> List.indexedMap
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
    PeopleChoices "" (List.repeat (List.length doodle.options) False)


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
                            |> List.map (\opt -> th [] [ text opt ])
                       )
                )

        nameInput =
            td [] [ input [ onInput UpdateName, placeholder "Name" ] [] ]

        currentChoicesSelector =
            newChoices.choices
                |> List.indexedMap
                    (\i c -> td [] [ input [ type_ "checkbox", onClick (ToggleChoice i), checked c, disabled False ] [] ])

        saveChoice =
            td [] [ button [ onClick DoneChoices ] [ text "Done" ] ]

        bottomLine =
            tr [] (List.append (nameInput :: currentChoicesSelector) [ saveChoice ])

        countLine =
            tr [] ((td [] []) :: (countPerChoice doodle |> List.map (\c -> td [] [text (toString c)])))

        choicesTable : List (Html Msg) -> Html Msg
        choicesTable content =
            table [] (List.append (headerLine :: content) [ bottomLine, countLine ])

        choiceLine : PeopleChoices -> Html Msg
        choiceLine ({ name, choices } as peopleChoice) =
            tr []
                ((td [] [ text name ])
                    :: (choices
                            |> List.map
                                (\c -> td [] [ input [ type_ "checkbox", checked c, disabled True ] [] ])
                       )
                )
    in
        div [] [ backButton, titleh, choicesTable (doodle.choices |> List.map choiceLine) ]

countPerChoice : Doodle -> List Int
countPerChoice {newChoices, choices} =
    let
        toCount : PeopleChoices -> List Int
        toCount ch = ch.choices |> List.map (\b -> if b then 1 else 0)

        addTuple tuple = let (a,b) = tuple in a + b
        addList l1 l2 = (List.zip l1 l2) |> List.map addTuple
    in
        List.foldl addList (toCount newChoices) (choices |> List.map toCount)


checkbox : Bool -> Bool -> msg -> Html msg
checkbox ch dis msg =
    input [ type_ "checkbox", onClick msg, checked ch, disabled dis ] []


(!) : Doodle -> List (Cmd Msg) -> ( Doodle, Cmd Msg, Res )
(!) d cs =
    ( d, Cmd.batch cs, NoOp )
