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


sockbox : Mailbox String
sockbox =
  Signal.mailbox "null"


port incomingSock : Task a ()
port incomingSock =
  socket `andThen` on "test blocks" sockbox.address


port arrowKeyPressed : Signal String


blockUpdates =
  Signal.map Actions.ReceiveBlocks sockbox.signal


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


app =
  StartApp.start
    { init =
        ( init
        , Effects.none
        )
    , view = view
    , update = update
    , inputs = [ blockUpdates, arrowKeyPresses ]
    }


main =
  app.html


port tasks : Signal (Task Never ())
port tasks =
  app.tasks
