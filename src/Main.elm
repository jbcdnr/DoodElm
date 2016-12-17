module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Array exposing (Array)
import Navigation exposing (Location)
import Model exposing (..)
import EditDoodle exposing (EditDoodle)
import Routing exposing (Route(..))
import Messages exposing (Msg(..))
import Doodle exposing (..)


main =
    Navigation.program OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            Routing.parseLocation location
    in
        ( initialModel currentRoute, Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnLocationChange location ->
            let
                newRoute =
                    Routing.parseLocation location
            in
                ( { model | current = newRoute }, Cmd.none )

        -- TODO
        ShowDoodle id ->
            ( model, Navigation.newUrl <| "#doodles/" ++ toString id )

        ShowList ->
            ( model, Navigation.newUrl "#doodles" )

        CreateDoodle ->
            let
                newDoodle =
                    Doodle -1 "" (Array.repeat 2 "") Array.empty (PeopleChoices "" Array.empty)
            in
                ( { model | current = Create }, Cmd.none )

        ToEditDoodle msg ->
            let
                ( newEditDoodle, cmd, res ) =
                    EditDoodle.update msg model.editDoodle
            in
                case res of
                    EditDoodle.NoOp ->
                        { model
                            | editDoodle = newEditDoodle
                        }
                            ! []

                    EditDoodle.Cancel ->
                        { model
                            | editDoodle = newEditDoodle
                        }
                            ! [ Navigation.newUrl "#doodles/" ]

                    EditDoodle.Save doodle ->
                        let
                            newDoodleList =
                                Array.push doodle model.doodles
                        in
                            { model
                                | doodles = newDoodleList
                                , editDoodle = newEditDoodle
                            }
                                ! [ Navigation.newUrl "#doodles/" ]

        ToggleChoice choice ->
            case model.current of
                Routing.Create ->
                    ( model, Cmd.none )

                Routing.List ->
                    ( model, Cmd.none )

                Routing.NotFound ->
                    ( model, Cmd.none )

                -- TODO
                Routing.Show id ->
                    case (findDoodleWithId id model.doodles) of
                        Nothing ->
                            ( model, Cmd.none )

                        Just doodle ->
                            let
                                namedChoices =
                                    doodle.newChoices

                                newChoices =
                                    namedChoices.choices
                                        |> Array.indexedMap
                                            (\i c ->
                                                if i == id then
                                                    not c
                                                else
                                                    c
                                            )

                                newDoodle =
                                    { doodle | newChoices = { namedChoices | choices = newChoices } }
                            in
                                ( { model | doodles = updateWithId newDoodle model.doodles }, Cmd.none )

        DoneChoices ->
            case model.current of
                Routing.Create ->
                    ( model, Cmd.none )

                Routing.NotFound ->
                    ( model, Cmd.none )

                -- TODO
                Routing.List ->
                    ( model, Cmd.none )

                Routing.Show doodleId ->
                    case (findDoodleWithId doodleId model.doodles) of
                        Nothing ->
                            ( model, Cmd.none )

                        Just doodle ->
                            if doodle.newChoices.name == "" then
                                ( model, Cmd.none )
                            else
                                let
                                    choices =
                                        Array.push doodle.newChoices doodle.choices

                                    newDoodle =
                                        { doodle | choices = choices, newChoices = defaultChoice doodle }

                                    updatedDoodleList =
                                        updateWithId newDoodle model.doodles
                                in
                                    ( { model | doodles = updatedDoodleList }, Cmd.none )

        UpdateName name ->
            case model.current of
                Routing.Create ->
                    ( model, Cmd.none )

                Routing.NotFound ->
                    ( model, Cmd.none )

                -- TODO
                Routing.List ->
                    ( model, Cmd.none )

                Routing.Show id ->
                    let
                        newDoodles =
                            model.doodles
                                |> mapForId id
                                    (\d ->
                                        let
                                            ch =
                                                d.newChoices
                                        in
                                            { d | newChoices = { ch | name = name } }
                                    )
                    in
                        ( { model | doodles = newDoodles }, Cmd.none )


findDoodleWithId : Int -> Array Doodle -> Maybe Doodle
findDoodleWithId id doodles =
    doodles |> Array.filter (\d -> d.id == id) |> Array.get 0


updateWithId value array =
    array
        |> Array.map
            (\v ->
                if v.id == value.id then
                    value
                else
                    v
            )


mapForId id f array =
    array
        |> Array.map
            (\v ->
                if v.id == id then
                    (f v)
                else
                    v
            )


nextDoodleId : Array Doodle -> Int
nextDoodleId doodles =
    (doodles |> Array.map .id |> Array.toList |> List.maximum |> Maybe.withDefault 0) + 1


deleteAtIndex : Int -> Array a -> Array a
deleteAtIndex n arr =
    Array.append (Array.slice 0 n arr) (Array.slice (n + 1) (Array.length arr) arr)


defaultChoice : Doodle -> PeopleChoices
defaultChoice doodle =
    PeopleChoices "" (Array.repeat (Array.length doodle.options) False)



-- VIEW


view : Model -> Html Msg
view model =
    case model.current of
        Routing.NotFound ->
            text "404 Not found"

        Routing.List ->
            viewListDoodles model.doodles

        Routing.Show id ->
            case (findDoodleWithId id model.doodles) of
                Nothing ->
                    viewListDoodles model.doodles

                Just doodle ->
                    viewDoodle doodle

        Routing.Create ->
            EditDoodle.view model.editDoodle |> Html.map ToEditDoodle


viewListDoodles : Array Doodle -> Html Msg
viewListDoodles doodles =
    let
        listEntry doodle =
            button [ onClick (ShowDoodle doodle.id) ] [ text doodle.title ]

        list =
            doodles |> Array.toList |> List.map listEntry

        addButton =
            button [ onClick CreateDoodle ] [ text "New" ]
    in
        div [] (List.append list [ addButton ])


viewDoodle : Doodle -> Html Msg
viewDoodle doodle =
    let
        backButton =
            button [ onClick ShowList ] [ text "Back" ]

        title =
            h1 [] [ text doodle.title ]

        {--options =
    previousChoices =
    current = --}
    in
        div [] (backButton :: title :: [])
