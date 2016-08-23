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
        [ Ui.Header.title
          { text = "Hello World"
          , action = Just msg
          , link = Nothing
          , target = ""
          }
        , Ui.spacer
        , Ui.Header.item
          { text = "Home"
          , action = Just msg
          , link = Nothing
          , target = ""
          }
        , Ui.Header.separator
        , Ui.Header.iconItem
          { text = "Github"
          , action = Just msg
          , link = Nothing
          , target = ""
          , glyph = "social-github"
          , side = "left"
          }
        , Ui.Header.separator
        , Ui.Header.icon
          { glyph = "navicon-round"
          , action = Just msg
          , link = Nothing
          , target = ""
          , size = 24
          }
        ]
  in
    Components.Reference.view demo (text "")
