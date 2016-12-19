module Doodle.Show exposing (Msg, Res(..), update, view, Model)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import List.Extra as List
import Doodle exposing (..)
import Graphics


type Msg
    = ToggleChoice Int
    | DoneChoices
    | UpdateName String
    | OnQuitButton


type Res
    = NoOp
    | SaveChoice ChoicesWithName
    | Quit


type alias Model =
    ChoicesWithName


update : Msg -> Model -> ( Model, Cmd Msg, Res )
update msg ({ name, choices } as model) =
    case msg of
        ToggleChoice id ->
            let
                newChoices =
                    List.updateAt id (not) choices |> Maybe.withDefault choices
            in
                { model | choices = newChoices } ! NoOp

        DoneChoices ->
            if name == "" then
                model ! NoOp
            else
                let
                    empty =
                        ChoicesWithName ""
                            (emptyChoices (List.length choices))
                in
                    empty ! (SaveChoice model)

        UpdateName newName ->
            { model | name = newName } ! NoOp

        OnQuitButton ->
            model ! Quit


view : Doodle -> Model -> Html Msg
view ({ title, options, choices } as doodle) newChoices =
    let
        backButton =
            Graphics.backArrow [ onClick OnQuitButton ]

        titleh =
            h3 [] [ text title ]

        headerLine =
            tr []
                ((th [] [ text "Name" ])
                    :: (options
                            |> List.map (\opt -> th [ style [ ( "text-align", "center" ) ] ] [ text opt ])
                       )
                )

        nameInput =
            td [] [ input [ onInput UpdateName, placeholder "Name" ] [] ]

        currentChoicesSelector =
            newChoices.choices
                |> List.indexedMap
                    (\i checked -> td [ style [ ( "text-align", "center" ) ] ] [ Graphics.checkbox checked (Just (ToggleChoice i)) ])

        saveChoice =
            td []
                [ button
                    (List.append [ onClick DoneChoices, class "button-primary" ]
                        (if newChoices.name == "" then
                            [ disabled True ]
                         else
                            []
                        )
                    )
                    [ text "Add" ]
                ]

        bottomLine =
            tr [ id "choice" ] (List.append (nameInput :: currentChoicesSelector) [ saveChoice ])

        countLine =
            tr [] ((td [] []) :: (countPerChoice newChoices choices |> List.map (\c -> td [ style [ ( "text-align", "center" ) ] ] [ text (toString c) ])))

        choicesTable : List (Html Msg) -> Html Msg
        choicesTable content =
            table [] (List.append (headerLine :: content) [ bottomLine, countLine ])

        choiceLine : ChoicesWithName -> Html Msg
        choiceLine ({ name, choices } as peopleChoice) =
            tr []
                ((td [] [ text name ])
                    :: (choices
                            |> List.map
                                (\checked -> td [ style [ ( "text-align", "center" ) ] ] [ Graphics.checkbox checked Nothing ])
                       )
                )
    in
        div [ id "show-doodle" ] [ div [ id "header" ] [ backButton, titleh ], choicesTable (doodle.choices |> List.map choiceLine) ]


countPerChoice : ChoicesWithName -> List ChoicesWithName -> List Int
countPerChoice newChoice choices =
    let
        toCount : ChoicesWithName -> List Int
        toCount ch =
            ch.choices
                |> List.map
                    (\b ->
                        if b then
                            1
                        else
                            0
                    )

        addTuple (( a, b ) as tuple) =
            a + b

        addList l1 l2 =
            (List.zip l1 l2) |> List.map addTuple
    in
        List.foldl addList (toCount newChoice) (choices |> List.map toCount)


(!) : Model -> Res -> ( Model, Cmd Msg, Res )
(!) d res =
    ( d, Cmd.none, res )
