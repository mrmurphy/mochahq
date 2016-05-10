module Actions (..) where

import Model exposing (PersistedState)

type Action
  = NoOp
  | ReceiveBlocks String
  | ReceiveResults String
  | ReceivePersistedState String
  | HighlightNextBlock
  | HighlightPreviousBlock
  | HighlightFirstChildBlock
  | HighlightParentBlock
  | HighlightBlock Int
  | ActivateHighlight
  | SetMatchPattern String
  | ClickGo
