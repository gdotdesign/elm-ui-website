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
      Ui.Header.view []
        [ Ui.Header.title "Hello World" msg
        , Ui.spacer
        , Ui.Header.item "Home" msg
        , Ui.Header.separator
        , Ui.Header.iconItem "Github" msg "social-github" "left"
        , Ui.Header.separator
        , Ui.Header.icon "navicon-round" msg
        ]
  in
    Components.Reference.view demo (text "")
