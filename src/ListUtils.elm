module ListUtils exposing (set, exists)

import List.Extra as List


set : Int -> a -> List a -> List a
set index value ls =
    case List.setAt index value ls of
        Just list ->
            list

        Nothing ->
            ls


exists : (a -> Bool) -> List a -> Bool
exists predicate list =
    case list of
        head :: tail ->
            if predicate head then
                True
            else
                exists predicate tail

        [] ->
            False
