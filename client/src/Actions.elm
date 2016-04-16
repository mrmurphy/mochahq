module Actions (..) where


type Action
  = NoOp
  | ReceiveBlocks String
  | ReceiveResults String
  | HighlightNextBlock
  | HighlightPreviousBlock
  | HighlightFirstChildBlock
  | HighlightParentBlock
  | ActivateHighlight
  | SetMatchPattern String
  | ClickGo
