module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Navigation exposing (Location)
import List.Extra as List exposing (getAt)
import ListUtils as List
import Model exposing (..)
import EditDoodle
import ShowDoodle
import Routing exposing (Route(..))
import Messages exposing (Msg(..))
import Doodle exposing (..)
import Commands exposing (..)


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
        ( initialModel currentRoute, fetchAll )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnFetchAll (Err error) ->
            ( model, Cmd.none )

        -- TODO log
        OnFetchAll (Ok newDoodlesRaw) ->
            let
                doodles =
                    digestRawDoodles newDoodlesRaw
            in
                ( { model | doodles = doodles }, Cmd.none )

        OnLocationChange location ->
            let
                newRoute =
                    Routing.parseLocation location
            in
                ( { model | current = newRoute }, Cmd.none )

        ShowList ->
            ( model, Navigation.newUrl "#doodles" )

        CreateDoodle ->
            ( { model | editingDoodle = Just emptyDoodle }, Navigation.newUrl "#new" )

        ToEditDoodle msg ->
            case model.editingDoodle of
                Nothing ->
                    model ! []

                Just d ->
                    let
                        ( newEditDoodle, cmd, res ) =
                            EditDoodle.update msg d
                    in
                        case res of
                            EditDoodle.NoOp ->
                                { model
                                    | editingDoodle = Just newEditDoodle
                                }
                                    ! []

                            EditDoodle.Cancel ->
                                { model
                                    | editingDoodle = Nothing
                                }
                                    ! [ Navigation.newUrl "#doodles/" ]

                            EditDoodle.Save ->
                                let
                                    d =
                                        { newEditDoodle
                                            | id = nextDoodleId model.doodles
                                        }

                                    newDoodleList =
                                        List.append model.doodles [ d ]
                                in
                                    { model
                                        | doodles = newDoodleList
                                        , editingDoodle = Nothing
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
                                            |> List.indexedMap
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

                            ShowDoodle.Quit ->
                                model ! [ Navigation.newUrl "#doodles/" ]



-- UTILS


currentShowDoodle : Model -> Maybe Doodle
currentShowDoodle { current, doodles } =
    case current of
        Show id ->
            findDoodleWithId id doodles

        other ->
            Nothing


findDoodleWithId : Int -> List Doodle -> Maybe Doodle
findDoodleWithId id doodles =
    doodles |> List.filter (\d -> d.id == id) |> List.getAt 0


nextDoodleId : List Doodle -> Int
nextDoodleId doodles =
    (doodles |> List.map .id |> List.maximum |> Maybe.withDefault 0) + 1



-- VIEW


view : Model -> Html Msg
view model =
    let
        container content =
            div [ class "container" ]
                [ div [ class "twelve columns" ]
                    [ h1 [] [ text "DoodElm" ]
                    , content
                    ]
                ]

        content =
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
                            ShowDoodle.view doodle |> Html.map ToShowDoodle

                Routing.Create ->
                    case model.editingDoodle of
                        Nothing ->
                            viewListDoodles model.doodles

                        Just d ->
                            EditDoodle.view d |> Html.map ToEditDoodle
    in
        container content


viewListDoodles : List Doodle -> Html Msg
viewListDoodles doodles =
    let
        listEntry doodle =
            tr [] [ td [] [ a [ href ("#doodles/" ++ toString doodle.id) ] [ text doodle.title ] ] ]

        list =
            table [] (doodles |> List.map listEntry)

        addButton =
            button [ onClick CreateDoodle ] [ text "Create" ]
    in
        div [ id "list-doodles" ] [ list, addButton ]
