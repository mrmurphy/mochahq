module Tree (..) where

import List exposing (head, drop, reverse, append, map)
import String
import Char


type Tree a
  = Node a (List (Tree a))
  | Leaf a


type alias Path =
  List Int


value : Tree a -> a
value tree =
  case tree of
    Node val _ ->
      val

    Leaf val ->
      val


child : Int -> Tree a -> Maybe (Tree a)
child idx tree =
  case tree of
    Leaf _ ->
      Nothing

    Node _ children ->
      head (drop idx children)


subtree : Path -> Tree a -> Maybe (Tree a)
subtree path tree =
  case path of
    [] ->
      Just tree

    idx :: restOfPath ->
      Maybe.andThen
        (child idx tree)
        (\child' -> subtree restOfPath child')


isLeaf : Path -> Tree a -> Bool
isLeaf path tree =
  (subtree path tree)
    |> Maybe.map
        (\t ->
          case t of
            Node _ _ ->
              False

            Leaf _ ->
              True
        )
    |> Maybe.withDefault False


isNode : Path -> Tree a -> Bool
isNode path tree =
  (subtree path tree)
    |> Maybe.map
        (\t ->
          case t of
            Node _ _ ->
              True

            Leaf _ ->
              False
        )
    |> Maybe.withDefault False


valuesForPath : Path -> Tree a -> Maybe (List a)
valuesForPath path tree =
  case path of
    [] ->
      Just [ value tree ]

    idx :: restOfPath ->
      (child idx tree)
      `Maybe.andThen`
      (\child' -> valuesForPath restOfPath child')
      `Maybe.andThen`
      (\childValues -> Just ((value tree) :: childValues))



{- This allows for easy mapping over children at a certain node -}


mapChildren : (Int -> Tree a -> b) -> Path -> Tree a -> List b
mapChildren transform path tree =
  case (subtree path tree) of
    Nothing ->
      []

    Just subtree' ->
      case subtree' of
        Leaf _ ->
          []

        Node _ children ->
          List.indexedMap transform children


childValues : Tree a -> List a
childValues tree =
  case tree of
    Leaf _ -> []
    Node _ children -> List.map value children


at : Path -> Tree a -> Maybe a
at path tree =
  case (subtree path tree) of
    Nothing ->
      Nothing

    Just tree ->
      Just (value tree)


parentPath : Path -> Path
parentPath path =
  case path of
    [] ->
      []

    _ ->
      reverse (drop 1 (reverse path))


firstChildPath : Path -> Path
firstChildPath path =
  append path [ 0 ]


incrementPath : Path -> Path
incrementPath path =
  case (reverse path) of
    [] ->
      []

    idx :: rest ->
      reverse ((idx + 1) :: rest)


decrementPath : Path -> Path
decrementPath path =
  case (reverse path) of
    [] ->
      []

    idx :: rest ->
      reverse
        ((if idx > 0 then
            idx - 1
          else
            0
         )
          :: rest
        )


nextSibling : Path -> Tree a -> Maybe Path
nextSibling path tree =
  let
    newPath =
      incrementPath path
  in
    case (subtree newPath tree) of
      Nothing ->
        Nothing

      _ ->
        Just newPath


parent : Path -> Tree a -> Maybe Path
parent path tree =
  let
    newPath =
      parentPath path
  in
    case (subtree newPath tree) of
      Nothing ->
        Nothing

      _ ->
        Just newPath


firstChild : Path -> Tree a -> Maybe Path
firstChild path tree =
  let
    newPath =
      firstChildPath path
  in
    case (subtree newPath tree) of
      Nothing ->
        Nothing

      _ ->
        Just newPath


prevSibling : Path -> Tree a -> Maybe Path
prevSibling path tree =
  let
    newPath =
      decrementPath path
  in
    case (subtree newPath tree) of
      Nothing ->
        Nothing

      _ ->
        Just newPath


pathToString : Path -> String
pathToString path =
  map toString path
    |> String.join "-"


-- Functions specific to certain kinds of trees

searchForString : Path -> Tree String -> String -> Maybe Int
searchForString path tree caseSensitiveTerm =
  let
    lower : String -> String
    lower str = String.map Char.toLower str

    search : List String -> String -> Maybe Int
    search values term =
      let
        searchResults = List.foldl
          (\val memo ->
            if memo.foundIndex /= -1 then
              memo
            else
              if String.contains (lower term) (lower val) then
                {curIndex = memo.curIndex + 1, foundIndex = memo.curIndex}
              else
                {curIndex = memo.curIndex + 1, foundIndex = -1}
          ) {curIndex = 0, foundIndex = -1} values
      in
        case searchResults.foundIndex of
          -1 -> Nothing
          other -> Just other

  in
    Maybe.andThen (subtree path tree)
    (\subTree ->
      search (childValues subTree) caseSensitiveTerm
    )
