module Main (..) where

import StartApp exposing (start)
import Signal exposing (Address, Mailbox)
import Task exposing (Task, andThen)
import Effects exposing (Effects, Never)
import Model exposing (Model, init)
import Update exposing (update)
import Actions exposing (Action)
import View exposing (view)
import SocketIO exposing (io, on)


socket =
  io "" SocketIO.defaultOptions


sockbox : Mailbox String
sockbox =
  Signal.mailbox "null"


port incoming : Task a ()
port incoming =
  socket `andThen` on "test blocks" sockbox.address


blockUpdates =
  Signal.map Actions.ReceiveBlocks sockbox.signal


app =
  StartApp.start
    { init =
        ( init
        , Effects.none
        )
    , view = view
    , update = update
    , inputs = [ blockUpdates ]
    }


main =
  app.html


port tasks : Signal (Task Never ())
port tasks =
  app.tasks
