module Msgs (..) where

import Model exposing (PersistedState)

type Msg
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
  | UpdatedSearchBox String
  | FinishSearch
