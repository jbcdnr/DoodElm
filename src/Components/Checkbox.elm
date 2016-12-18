module Checkbox exposing (checkbox, cross)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import Html exposing (Html)
import Html.Events exposing (onClick)


greenColor =
    "#2ecc71"


greyColor =
    "#bdc3c7"


checkbox : Bool -> Maybe msg -> Html msg
checkbox checked actionable =
    let
        color =
            if checked then
                greenColor
            else
                greyColor

        ( enabled, action ) =
            case actionable of
                Nothing ->
                    ( False, [] )

                Just msg ->
                    ( True, [ onClick msg ] )

        circleSvg =
            if enabled then
                [ circle [ cx "50", cy "50", r "45", stroke color, strokeWidth "3", fill "none" ] [] ]
            else
                []
    in
        svg (List.append [ viewBox "0 0 100 100", width "30" ] action)
            (List.append circleSvg
                [ line [ x1 "25", y1 "52", x2 "45", y2 "72", stroke color, strokeWidth "3" ] []
                , line [ x1 "45", y1 "72", x2 "75", y2 "32", stroke color, strokeWidth "3" ] []
                ]
            )


cross : List (Html.Attribute msg) -> Html msg
cross attrs =
    svg (List.append [ viewBox "0 0 100 100", width "20" ] attrs)
        [ line [ x1 "10", y1 "10", x2 "90", y2 "90", stroke "#e74c3c", strokeWidth "3" ] []
        , line [ x1 "10", y1 "90", x2 "90", y2 "10", stroke "#e74c3c", strokeWidth "3" ] []
        ]
