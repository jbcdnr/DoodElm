module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Array exposing (Array)
import Navigation
import EditDoodle
import Model exposing (..)
import EditDoodle exposing (EditDoodle)


main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }



-- MODEL


type alias Model =
    { current : CurrentPage
    , doodles : Array Doodle
    , editDoodle : EditDoodle
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( model
    , Cmd.none
    )


model =
    Model ListDoodles Array.empty emptyDoodle



-- UPDATE


type Msg
    = SelectDoodle Int
    | BackToList
    | CreateDoodle
    | ToEditDoodle EditDoodle.Msg
    | ToggleChoice Int
    | DoneChoices
    | UpdateName String
    | UrlChange Navigation.Location


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange location ->
            ( model, Cmd.none )

        -- TODO
        SelectDoodle id ->
            let
                doodle =
                    findDoodleWithId id model.doodles
            in
                case doodle of
                    Just d ->
                        ( { model | current = Show d.id }, Cmd.none )

                    Nothing ->
                        ( model, Cmd.none )

        BackToList ->
            ( { model | current = ListDoodles }, Cmd.none )

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
                            , current = ListDoodles
                        }
                            ! []

                    EditDoodle.Save doodle ->
                        let
                            newDoodleList =
                                Array.push doodle model.doodles
                        in
                            { model
                                | doodles = newDoodleList
                                , editDoodle = newEditDoodle
                                , current = ListDoodles
                            }
                                ! []

        ToggleChoice choice ->
            case model.current of
                Create ->
                    ( model, Cmd.none )

                ListDoodles ->
                    ( model, Cmd.none )

                Show id ->
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
                Create ->
                    ( model, Cmd.none )

                ListDoodles ->
                    ( model, Cmd.none )

                Show doodleId ->
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
                Create ->
                    ( model, Cmd.none )

                ListDoodles ->
                    ( model, Cmd.none )

                Show id ->
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
        ListDoodles ->
            viewListDoodles model.doodles

        Show id ->
            case (findDoodleWithId id model.doodles) of
                Nothing ->
                    viewListDoodles model.doodles

                Just doodle ->
                    viewDoodle doodle

        Create ->
            EditDoodle.view model.editDoodle |> Html.map ToEditDoodle


viewListDoodles : Array Doodle -> Html Msg
viewListDoodles doodles =
    let
        listEntry doodle =
            button [ onClick (SelectDoodle d.id) ] [ text d.title ]

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
            button [ onClick BackToList ] [ text "Back" ]

        title =
            h1 [] [ text doodle.title ]

        {--options =
    previousChoices =
    current = --}
    in
        div [] (backButton :: title :: [])
