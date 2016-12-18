module ShowDoodle exposing (Msg, Res(..), update, view)

import Html exposing (Html, div, h3, text, tr, td, th, input, button, table)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (style, placeholder, id, class, disabled)
import List.Extra as List exposing (zip)
import Doodle exposing (Doodle, PeopleChoices)
import DesignRessources exposing (checkbox)


type Msg
    = ToggleChoice Int
    | DoneChoices
    | UpdateName String
    | QuitButton


type Res
    = NoOp
    | Quit


update : Msg -> Doodle -> ( Doodle, Cmd Msg, Res )
update msg ({ id, title, options, choices, newChoices } as model) =
    case msg of
        ToggleChoice id ->
            toggleChoice id model ! []

        DoneChoices ->
            if newChoices.name == "" then
                model ! []
            else
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
            ( Doodle.emptyDoodle, Cmd.none, Quit )


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
            DesignRessources.backArrow [ onClick QuitButton ]

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
                    (\i checked -> td [ style [ ( "text-align", "center" ) ] ] [ checkbox checked (Just (ToggleChoice i)) ])

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
            tr [] ((td [] []) :: (countPerChoice doodle |> List.map (\c -> td [ style [ ( "text-align", "center" ) ] ] [ text (toString c) ])))

        choicesTable : List (Html Msg) -> Html Msg
        choicesTable content =
            table [] (List.append (headerLine :: content) [ bottomLine, countLine ])

        choiceLine : PeopleChoices -> Html Msg
        choiceLine ({ name, choices } as peopleChoice) =
            tr []
                ((td [] [ text name ])
                    :: (choices
                            |> List.map
                                (\checked -> td [ style [ ( "text-align", "center" ) ] ] [ checkbox checked Nothing ])
                       )
                )
    in
        div [ id "show-doodle" ] [ div [ id "header" ] [ backButton, titleh ], choicesTable (doodle.choices |> List.map choiceLine) ]


countPerChoice : Doodle -> List Int
countPerChoice { newChoices, choices } =
    let
        toCount : PeopleChoices -> List Int
        toCount ch =
            ch.choices
                |> List.map
                    (\b ->
                        if b then
                            1
                        else
                            0
                    )

        addTuple tuple =
            let
                ( a, b ) =
                    tuple
            in
                a + b

        addList l1 l2 =
            (List.zip l1 l2) |> List.map addTuple
    in
        List.foldl addList (toCount newChoices) (choices |> List.map toCount)


(!) : Doodle -> List (Cmd Msg) -> ( Doodle, Cmd Msg, Res )
(!) d cs =
    ( d, Cmd.batch cs, NoOp )
