module View (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import EasyEvents exposing (onEnterPress, onInput, onSpecificKeyPress)
import Tree exposing (Tree(Leaf), pathToString)
import Model exposing (Model)
import Signal exposing (Address)
import List exposing (reverse, head, length, drop)
import Maybe
import Actions exposing (..)
import String
import Json.Encode as Json


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
        [ span [ class "logoText1" ] [ text "Mocha" ]
        , span [ class "logoText2" ] [ text "HQ" ]
        ]
    , div
        [ class "patternWrapper" ]
        [ label [] [ text "pattern:" ]
        , input
          [ type' "text"
          , id "patternInput"
          , value model.matchPattern
          , onInput address SetMatchPattern
          ] []
        ]
    , div [ class "errorMessage" ] [ text model.errorMessage ]
    , button [] [ text "Go!" ]
    ]


block : Address Action -> Model -> List Html
block address model =
  let
    activeBlockIndex =
      if model.displayPath == model.activeBlockPath then
        0
      else if (length model.displayPath < length model.activeBlockPath) then
        Maybe.withDefault 0 (head (drop (length model.displayPath) model.activeBlockPath))
      else
        Maybe.withDefault 0 (head (reverse model.activeBlockPath))

    highlightBlockIndex =
      if model.displayPath == model.highlightedPath then
        0
      else
        Maybe.withDefault -1 (head (reverse model.highlightedPath))

    renderBlock index child =
      let
        classes =
          ((if index == activeBlockIndex then
              "active "
            else
              ""
           )
            ++ "block"
          )

        onEnter =
          onEnterPress address ActivateHighlight

        id =
          "block-"
            ++ (pathToString (List.append model.displayPath [ index ]))
      in
        case child of
          Tree.Leaf name ->
            button
              [ class classes, onEnter, Html.Attributes.id id ]
              [ i [ class "icon left ion-ios-star" ] []
              , span [ class "blockText" ] [ text name ]
              ]

          Tree.Node name _ ->
            button
              [ class classes, onEnter, Html.Attributes.id id ]
              [ i [ class "icon left ion-ios-circle-outline" ] []
              , span [ class "blockText" ] [ text name ]
              , span [ class "spacer" ] []
              , i [ class "icon right ion-ios-arrow-forward" ] []
              ]
  in
    Tree.mapChildren renderBlock model.displayPath model.blockTree


view address model =
  div
    [ class "layout" ]
    [ topBar address model
    , div
        [ class "main" ]
        [ div
            [ class "blockList"
            ]
            <| block address model
        , div
            [ class "detailWrapper" ]
            [ pre
                [ class "detail", property "innerHTML" (Json.string model.testOutput) ]
                []
            ]
        ]
    ]
