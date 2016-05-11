module Update (..) where

import Model exposing (Model, decodeBlockTree, decodeState, encodeState)
import Msgs exposing (Msg(..))
import Effects exposing (Effects)
import String exposing (join)
import List exposing (filter)
import Tree
import Task exposing (succeed)


noEffect : Model -> ( Model, Effects Msg )
noEffect model =
  ( model
  , Effects.none
  )


update : Model.Context Msg -> Msg -> Model -> ( Model, Effects Msg )
update context msg model =
  let
    stateChangeEffect model =
      context.socketEvent "update state" (encodeState model)

    stateChange model =
      ( model
      , stateChangeEffect model
      )
  in
    case (Debug.log "ACTION" msg) of
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

      ReceivePersistedState stateString ->
        case (decodeState stateString) of
          Nothing -> noEffect model
          Just s ->
            noEffect
              { model
              | matchPattern = s.matchPattern
              , displayPath = s.displayPath
              , activeBlockPath = s.activeBlockPath
              , highlightedPath = s.highlightedPath
              }

      HighlightBlock idx ->
        stateChange
          { model
            | highlightedPath =
                List.append (Tree.parentPath model.highlightedPath) [idx]
          }

      HighlightNextBlock ->
        case (Tree.nextSibling model.highlightedPath model.blockTree) of
          Nothing ->
            stateChange { model | highlightedPath = model.highlightedPath }

          Just newPath ->
            stateChange { model | highlightedPath = (Debug.log "newPath" newPath) }

      HighlightPreviousBlock ->
        case (Tree.prevSibling model.highlightedPath model.blockTree) of
          Nothing ->
            stateChange { model | highlightedPath = model.highlightedPath }

          Just newPath ->
            stateChange { model | highlightedPath = (Debug.log "newPath" newPath) }

      HighlightFirstChildBlock ->
        case (Tree.firstChild model.highlightedPath model.blockTree) of
          Nothing ->
            stateChange { model | highlightedPath = model.highlightedPath }

          Just newPath ->
            stateChange
              { model
                | highlightedPath = (Debug.log "newPath" newPath)
                , displayPath = model.highlightedPath
              }

      HighlightParentBlock ->
        if List.length model.highlightedPath == 1 then
          -- If an item in the root is highlighted, the user shouldn't
          -- be able to highlight anything above it.
          stateChange model
        else
          case (Tree.parent model.highlightedPath model.blockTree) of
            Nothing ->
              stateChange { model | highlightedPath = model.highlightedPath }

            Just newPath ->
              stateChange
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
          newModel =
            { model
              | activeBlockPath = model.highlightedPath
              , matchPattern = newPattern
            }
        in
          ( newModel
          , Effects.batch
            [ context.socketEvent "update pattern" newPattern
            , stateChangeEffect newModel
            ]
          )

      SetMatchPattern p ->
        stateChange { model | matchPattern = p }

      ClickGo ->
        ( model
        , context.socketEvent "update pattern" model.matchPattern
        )

      UpdatedSearchBox val ->
        noEffect { model | search = val }

      FinishSearch ->
        let
          found =
            Tree.searchForString
            model.displayPath
            model.blockTree
            model.search
          eff =
            case found of
              Nothing -> Effects.task (succeed NoOp)
              Just idx -> Effects.task (succeed (HighlightBlock idx))
        in
          ( {model | search = ""}
          , eff
          )
