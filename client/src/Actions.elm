module Actions (..) where


type Action
  = NoOp
  | ReceiveBlocks String
  | ReceiveResults String
  | HighlightNextBlock
  | HighlightPreviousBlock
  | HighlightFirstChildBlock
  | HighlightParentBlock
  | HighlightBlock Int
  | ActivateHighlight
  | SetMatchPattern String
  | ClickGo
