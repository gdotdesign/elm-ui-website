module Reference.Header exposing (..)

import Components.Reference
import Icons

import Ui.Header
import Ui

import Html exposing (text)

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
        , Ui.Header.spacer
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
          , glyph = Icons.github []
          , side = "left"
          }
        , Ui.Header.separator
        , Ui.Header.icon
          { glyph = Icons.navicon []
          , action = Just msg
          , link = Nothing
          , target = ""
          , size = 24
          }
        ]
  in
    Components.Reference.view demo (text "")
