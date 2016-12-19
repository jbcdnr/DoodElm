module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Navigation exposing (Location)
import List.Extra as List
import ListUtils as List
import Models exposing (..)
import Doodle.Edit as Edit
import Doodle.Show as Show
import Routing exposing (Route(..))
import Messages exposing (Msg(..))
import Doodle exposing (..)
import Commands exposing (..)
import Debug
import PostgresDB


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

        OnFetchAll (Ok newDoodlesRaw) ->
            let
                doodles =
                    PostgresDB.digestEntryDoodles newDoodlesRaw
            in
                ( { model | doodles = doodles }, Cmd.none )

        OnSentNewDoodle res ->
            let
                _ =
                    Debug.log (toString res)
            in
                ( model, fetchAll )

        OnLocationChange location ->
            let
                newRoute =
                    Routing.parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )

        ShowList ->
            ( model, Navigation.newUrl "#doodles" )

        ShowDoodle id ->
            case findDoodleWithId id model.doodles of
                Nothing ->
                    model ! []

                Just doodle ->
                    ( { model
                        | showCurrentChoice = Just (ChoicesWithName "" (emptyChoicesFromDoodle doodle))
                      }
                    , Navigation.newUrl ("#doodles/" ++ (toString id))
                    )

        CreateDoodle ->
            ( { model | editCurrent = Just emptyDoodle }, Navigation.newUrl "#new" )

        ToEditDoodle msg ->
            case model.editCurrent of
                Nothing ->
                    model ! []

                Just d ->
                    let
                        ( newEditDoodle, cmd, res ) =
                            Edit.update msg d
                    in
                        case res of
                            Edit.NoOp ->
                                { model
                                    | editCurrent = Just newEditDoodle
                                }
                                    ! []

                            Edit.Cancel ->
                                { model
                                    | editCurrent = Nothing
                                }
                                    ! [ Navigation.newUrl "#doodles/" ]

                            Edit.Save ->
                                { model
                                    | editCurrent = Nothing
                                }
                                    ! [ create d, Navigation.newUrl "#doodles/" ]

        ToShowDoodle msg ->
            case ( model.showCurrentChoice, model.route ) of
                ( Just choices, Show id ) ->
                    let
                        ( newChoices, cmd, res ) =
                            Show.update msg choices
                    in
                        case res of
                            Show.NoOp ->
                                { model | showCurrentChoice = Just newChoices } ! [ cmd |> Cmd.map ToShowDoodle ]

                            Show.SaveChoice choiceToAdd ->
                                let
                                    updatedDoodles =
                                        model.doodles
                                            |> List.updateIf
                                                (\d -> d.id == id)
                                                (\d -> { d | choices = (List.append d.choices [ choiceToAdd ]) })
                                in
                                    { model
                                        | showCurrentChoice = Just newChoices
                                        , doodles = updatedDoodles
                                    }
                                        ! [ cmd |> Cmd.map ToShowDoodle ]

                            Show.Quit ->
                                model ! [ Navigation.newUrl "#doodles/" ]

                other ->
                    model ! []



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
            case model.route of
                Routing.NotFound ->
                    text "404 Not found"

                Routing.List ->
                    viewListDoodles model.doodles

                Routing.Show id ->
                    viewShowDoodlePage model id

                Routing.Create ->
                    case model.editCurrent of
                        Nothing ->
                            viewListDoodles model.doodles

                        Just d ->
                            Edit.view d |> Html.map ToEditDoodle
    in
        container content


viewListDoodles : List Doodle -> Html Msg
viewListDoodles doodles =
    let
        listEntry doodle =
            tr [] [ td [] [ span [ class "link", onClick (ShowDoodle doodle.id) ] [ text doodle.title ] ] ]

        list =
            table [] (doodles |> List.sortBy .id |> List.map listEntry)

        addButton =
            button [ onClick CreateDoodle ] [ text "Create" ]
    in
        div [ id "list-doodles" ] [ list, addButton ]


viewShowDoodlePage : Model -> Int -> Html Msg
viewShowDoodlePage model id =
    case ( findDoodleWithId id model.doodles, model.showCurrentChoice ) of
        ( Just doodle, Just choices ) ->
            Show.view doodle choices |> Html.map ToShowDoodle

        other ->
            viewListDoodles model.doodles
