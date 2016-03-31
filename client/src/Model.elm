module Model (..) where

import Json.Decode as D exposing (string, succeed, decodeString, list, (:=), Decoder, andThen)
import Json.Decode.Extra exposing ((|:))


type SubTests
  = SubTests (List TestBlock)


type alias TestBlock =
  { name : String
  , children : SubTests
  }


type alias Model =
  { testBlocks : List TestBlock
  , matchPattern : String
  , testOutput : String
  , errorMessage : String
  , displayPath : List Int
  , activeBlockPath : List Int
  , hoveringBlockPath : List Int
  }


subTestDecoder : Decoder SubTests
subTestDecoder =
  D.map SubTests (list (succeed () `andThen` \() -> testBlockDecoder))


testBlockDecoder : Decoder TestBlock
testBlockDecoder =
  succeed TestBlock
    |: ("name" := string)
    |: ("children" := subTestDecoder)


init =
  { testBlocks = []
  , matchPattern = ""
  , testOutput = ""
  , errorMessage = ""
  , displayPath = []
  , activeBlock = [ "All tests" ]
  , hoveringBlockPath = []
  }


decodeTestBlocks : String -> Result String (List TestBlock)
decodeTestBlocks str =
  decodeString (list testBlockDecoder) str
