module Reference.Header exposing (..)

import Components.Reference

import Ui.Header
import Ui

import Html exposing (text)
import Html.App


view : msg -> Html.Html msg
view msg =
  let
    demo =
      Ui.Header.view
        [ Ui.Header.title { text = "Hello World", action = Just msg }
        , Ui.spacer
        , Ui.Header.item { text = "Home", action = Just msg }
        , Ui.Header.separator
        , Ui.Header.iconItem
          { text = "Github"
          , action = Just msg
          , glyph = "social-github"
          , side = "left"
          }
        , Ui.Header.separator
        , Ui.Header.icon
          { glyph = "navicon-round"
          , action = Just msg
          , size = 24
          }
        ]
  in
    Components.Reference.view demo (text "")
