module ListUtils exposing (set)

import List.Extra as List


set : Int -> a -> List a -> List a
set index value ls =
    case List.setAt index value ls of
        Just list ->
            list

        Nothing ->
            ls


contains : (a -> Bool) -> List a -> Bool
contains pred ls =
    case ls of
        head :: tail ->
            if pred head then
                True
            else
                contains pred tail

        [] ->
            False
