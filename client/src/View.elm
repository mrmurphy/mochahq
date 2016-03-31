module View (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import EasyEvents exposing (onEnterPress, onInput)
import Model exposing (SubTests(SubTests))


topBar address model =
  div
    [ class
        ("topBar"
          ++ if model.errorMessage /= "" then
              " error"
             else
              ""
        )
    ]
    [ div
        [ class "logo" ]
        [ span [ class "logoText1" ] [ text "Test" ]
        , span [ class "logoText2" ] [ text "HQ" ]
        ]
    , div [ class "spacer" ] []
      -- , div
      --     [ class "patternWrapper" ]
      --     [ label [] [ text "pattern:" ]
      --     , input [ type' "text" ] []
      --     ]
    , div [ class "errorMessage" ] [ text model.errorMessage ]
    , button [] [ text "Go!" ]
    ]


block address activeBlock blockModel =
  div
    [ class
        <| (if activeBlock == blockModel.name then
              "active "
            else
              ""
           )
        ++ "block"
    ]
    [ text blockModel.name ]


blockList address model =
  let
    allBlocks =
      { name = "All tests", children = (SubTests []) } :: model.testBlocks
  in
    div
      [ class "blockList" ]
      <| List.map
          (block address model.activeBlock)
          allBlocks


view address model =
  div
    [ class "layout" ]
    [ topBar address model
    , div
        [ class "main" ]
        [ blockList address model
        , div [ class "detail" ] [ text (toString model) ]
        ]
    ]
