module Main (..) where

import StartApp exposing (start)
import Signal exposing (Address, Mailbox)
import Task exposing (Task, andThen)
import Effects exposing (Effects, Never)
import Model exposing (Model, init)
import Update exposing (update)
import Actions exposing (..)
import View exposing (view)
import SocketIO exposing (io, on)
import Tree exposing (pathToString)


socket =
  io "" SocketIO.defaultOptions


sockbox : Mailbox Action
sockbox =
  Signal.mailbox NoOp


port socketOnPersistedState : Task a ()
port socketOnPersistedState =
  let
    addr =
      Signal.forwardTo sockbox.address Actions.ReceivePersistedState
  in
    socket `andThen` on "persisted state" addr

port socketOnTestBlocks : Task a ()
port socketOnTestBlocks =
  let
    addr =
      Signal.forwardTo sockbox.address Actions.ReceiveBlocks
  in
    socket `andThen` on "test blocks" addr


port socketOnTestResults : Task a ()
port socketOnTestResults =
  let
    addr =
      Signal.forwardTo sockbox.address Actions.ReceiveResults
  in
    socket `andThen` on "test results" addr


port arrowKeyPressed : Signal String


arrowKeyPresses =
  Signal.map
    (\code ->
      case code of
        "ArrowUp" ->
          HighlightPreviousBlock

        "ArrowDown" ->
          HighlightNextBlock

        "ArrowRight" ->
          HighlightFirstChildBlock

        "ArrowLeft" ->
          HighlightParentBlock

        _ ->
          NoOp
    )
    arrowKeyPressed


port focusChanges : Signal String
port focusChanges =
  Signal.map .highlightedPath app.model
    |> Signal.dropRepeats
    |> Signal.map (\focusPath -> "#block-" ++ (pathToString focusPath))


socketEvent : String -> String -> Effects Action
socketEvent event payload =
  socket
    `Task.andThen` (SocketIO.emit event payload)
    |> Task.map (always NoOp)
    |> Effects.task


context : Model.Context Action
context =
  { socketEvent = socketEvent
  }


app =
  StartApp.start
    { init =
        ( init
        , Effects.none
        )
    , view = view
    , update = update context
    , inputs = [ sockbox.signal, arrowKeyPresses ]
    }


main =
  app.html


port testOutputChange : Signal String
port testOutputChange =
  Signal.dropRepeats <| Signal.map .testOutput app.model

port tasks : Signal (Task Never ())
port tasks =
  app.tasks
