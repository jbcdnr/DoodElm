module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Array exposing (Array)
import Navigation exposing (Location)
import Model exposing (..)
import EditDoodle exposing (EditDoodle)
import ShowDoodle
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

        ShowList ->
            ( model, Navigation.newUrl "#doodles" )

        CreateDoodle ->
            ( model, Navigation.newUrl "#new" )

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
                            d =
                                { doodle
                                    | id = nextDoodleId model.doodles
                                }

                            newDoodleList =
                                Array.push d model.doodles
                        in
                            { model
                                | doodles = newDoodleList
                                , editDoodle = newEditDoodle
                            }
                                ! [ Navigation.newUrl "#doodles/" ]

        ToShowDoodle msg ->
            case currentShowDoodle model of
                Nothing ->
                    model ! []

                Just d ->
                    let
                        ( doodle, cmd, res ) =
                            ShowDoodle.update msg d
                    in
                        case res of
                            ShowDoodle.NoOp ->
                                let
                                    updatedDoodles =
                                        model.doodles
                                            |> Array.indexedMap
                                                (\i d ->
                                                    if d.id == doodle.id then
                                                        doodle
                                                    else
                                                        d
                                                )
                                in
                                    { model
                                        | doodles = updatedDoodles
                                    }
                                        ! []

                            ShowDoodle.Quit doodle ->
                                model ! [ Navigation.newUrl "#doodles/" ]



-- UTILS


currentShowDoodle : Model -> Maybe Doodle
currentShowDoodle { current, doodles } =
    case current of
        Show id ->
            findDoodleWithId id doodles

        other ->
            Nothing


findDoodleWithId : Int -> Array Doodle -> Maybe Doodle
findDoodleWithId id doodles =
    doodles |> Array.filter (\d -> d.id == id) |> Array.get 0


nextDoodleId : Array Doodle -> Int
nextDoodleId doodles =
    (doodles |> Array.map .id |> Array.toList |> List.maximum |> Maybe.withDefault 0) + 1



-- VIEW


view : Model -> Html Msg
view model =
    case model.current of
        Routing.NotFound ->
            text "404 Not found"

        Routing.List ->
            viewListDoodles model.doodles

        Routing.Show id ->
            -- TODO
            case (findDoodleWithId id model.doodles) of
                Nothing ->
                    viewListDoodles model.doodles

                Just doodle ->
                    ShowDoodle.view doodle |> Html.map ToShowDoodle

        Routing.Create ->
            EditDoodle.view model.editDoodle |> Html.map ToEditDoodle


viewListDoodles : Array Doodle -> Html Msg
viewListDoodles doodles =
    let
        listEntry doodle =
            div [] [ a [ href ("#doodles/" ++ toString doodle.id) ] [ text doodle.title ] ]

        list =
            doodles |> Array.toList |> List.map listEntry

        addButton =
            button [ onClick CreateDoodle ] [ text "New" ]
    in
        div [] (List.append list [ addButton ])
