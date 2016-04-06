module Actions (..) where


type Action
  = NoOp
  | ReceiveBlocks String
  | HighlightNextBlock
  | HighlightPreviousBlock
  | HighlightFirstChildBlock
  | HighlightParentBlock
  | ActivateHighlight
  | SetMatchPattern String
