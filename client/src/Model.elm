module Model (..) where

import Json.Decode as D exposing (string, succeed, decodeString, list, int, (:=), Decoder, andThen)
import Json.Encode as E
import Json.Decode.Extra exposing ((|:))
import Tree exposing (Tree(Node, Leaf), Path)
import Effects exposing (Effects)


type alias Block =
  Tree String


type alias Model =
  { blockTree : Block
  , matchPattern : String
  , testOutput : String
  , errorMessage : String
  , displayPath : Path
  , activeBlockPath : Path
  , highlightedPath : Path
  }


type alias PersistedState =
  { matchPattern : String
  , displayPath : Path
  , activeBlockPath : Path
  , highlightedPath : Path
  }


stateDecoder : Decoder PersistedState
stateDecoder =
  succeed PersistedState
    |: ("matchPattern" := string)
    |: ("displayPath" := (list int))
    |: ("activeBlockPath" := (list int))
    |: ("highlightedPath" := (list int))

decodeState : String -> Maybe PersistedState
decodeState str =
  decodeString stateDecoder str
  |> Result.toMaybe

encodeState : Model -> String
encodeState model =
  E.encode 0 <|
  E.object
    [ ("matchPattern", E.string model.matchPattern)
    , ("displayPath", E.list (List.map E.int model.displayPath))
    , ("activeBlockPath", E.list (List.map E.int model.activeBlockPath))
    , ("highlightedPath", E.list (List.map E.int model.highlightedPath))
    ]

-- Bound helper functions and values that aren't serializable,
-- But need to be passed around to multiple places.
type alias Context a =
  { socketEvent : String -> String -> Effects a
  }


blockDecoder : Decoder Block
blockDecoder =
  let
    basedOnChildren ch =
      case ch of
        [] ->
          succeed Leaf
            |: ("name" := string)

        _ ->
          succeed Node
            |: ("name" := string)
            |: D.map
                (\children -> (Leaf "All Tests") :: children)
                ("children" := list blockDecoder)
  in
    ("children" := list D.value) `andThen` basedOnChildren


init : Model
init =
  { blockTree = Leaf "No Tests"
  , matchPattern = ""
  , testOutput = ""
  , errorMessage = ""
  , displayPath = []
  , activeBlockPath = [ 0 ]
  , highlightedPath = [ 0 ]
  }


decodeBlockTree : String -> Result String Block
decodeBlockTree str =
  decodeString
    (list blockDecoder
      |> D.map (\blocks -> Node "root" ((Leaf "All Tests") :: blocks))
    )
    str
