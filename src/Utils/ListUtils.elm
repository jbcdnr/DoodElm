module ListUtils exposing (set)

import List.Extra as List


set : Int -> a -> List a -> List a
set index value ls =
    case List.setAt index value ls of
        Just list ->
            list

        Nothing ->
            ls
