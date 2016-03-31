module Update (..) where

import Model exposing (Model, decodeTestBlocks)
import Actions exposing (Action(..))
import Effects exposing (Effects)


noEffect : Model -> ( Model, Effects Action )
noEffect model =
  ( model
  , Effects.none
  )


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    NoOp ->
      noEffect model

    ReceiveBlocks s ->
      let
        decoded =
          decodeTestBlocks s
      in
        case decoded of
          Ok blocks ->
            noEffect { model | testBlocks = blocks }

          Err msg ->
            noEffect { model | errorMessage = msg }
