module Update (..) where

import Model exposing (Model, decodeBlockTree)
import Actions exposing (Action(..))
import Effects exposing (Effects)
import String exposing (join)
import List exposing (filter)
import Tree


noEffect : Model -> ( Model, Effects Action )
noEffect model =
  ( model
  , Effects.none
  )


update : Model.Context Action -> Action -> Model -> ( Model, Effects Action )
update context action model =
  case (Debug.log "ACTION" action) of
    NoOp ->
      noEffect model

    ReceiveBlocks s ->
      let
        decoded =
          decodeBlockTree s
      in
        case decoded of
          Ok rootBlock ->
            noEffect { model | blockTree = rootBlock }

          Err msg ->
            noEffect { model | errorMessage = msg }

    ReceiveResults s ->
      noEffect { model | testOutput = s }

    HighlightBlock idx ->
      noEffect
        { model
          | highlightedPath =
              List.append (Tree.parentPath model.highlightedPath) [idx]
        }

    HighlightNextBlock ->
      case (Tree.nextSibling model.highlightedPath model.blockTree) of
        Nothing ->
          noEffect { model | highlightedPath = model.highlightedPath }

        Just newPath ->
          noEffect { model | highlightedPath = (Debug.log "newPath" newPath) }

    HighlightPreviousBlock ->
      case (Tree.prevSibling model.highlightedPath model.blockTree) of
        Nothing ->
          noEffect { model | highlightedPath = model.highlightedPath }

        Just newPath ->
          noEffect { model | highlightedPath = (Debug.log "newPath" newPath) }

    HighlightFirstChildBlock ->
      case (Tree.firstChild model.highlightedPath model.blockTree) of
        Nothing ->
          noEffect { model | highlightedPath = model.highlightedPath }

        Just newPath ->
          noEffect
            { model
              | highlightedPath = (Debug.log "newPath" newPath)
              , displayPath = model.highlightedPath
            }

    HighlightParentBlock ->
      if List.length model.highlightedPath == 1 then
        -- If an item in the root is highlighted, the user shouldn't
        -- be able to highlight anything above it.
        noEffect model
      else
        case (Tree.parent model.highlightedPath model.blockTree) of
          Nothing ->
            noEffect { model | highlightedPath = model.highlightedPath }

          Just newPath ->
            noEffect
              { model
                | highlightedPath = (Debug.log "newPath" newPath)
                , displayPath = Tree.parentPath newPath
              }

    ActivateHighlight ->
      let
        pathValues =
          Tree.valuesForPath model.highlightedPath model.blockTree

        filtered =
          Maybe.map
            (filter
              (\p ->
                if p == "root" || p == "All Tests" then
                  False
                else
                  True
              )
            )
            pathValues

        newPattern =
          join " " (Maybe.withDefault [] filtered)
      in
        ( { model
            | activeBlockPath = model.highlightedPath
            , matchPattern = newPattern
          }
        , context.socketEvent "update pattern" newPattern
        )

    SetMatchPattern p ->
      noEffect { model | matchPattern = p }

    ClickGo ->
      ( model
      , context.socketEvent "update pattern" model.matchPattern
      )
