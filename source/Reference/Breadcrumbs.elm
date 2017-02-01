module Reference.Breadcrumbs exposing (..)

import Components.Reference
import Icons

import Html exposing (text)

import Ui.Breadcrumbs
import Ui

view : msg -> Html.Html msg
view msg =
  let
    demo =
      Ui.Breadcrumbs.view
        (text "|")
        [ { contents = [ text "Home" ]
          , target = Nothing
          , msg = Just msg
          , url = Nothing
          }
        , { contents = [ text "Posts" ]
          , target = Nothing
          , msg = Just msg
          , url = Nothing
          }
        , { contents = [ text "Github" ]
          , target = Just "_blank"
          , msg = Nothing
          , url = Just "http://www.github.com"
          }
        , { contents = [ text "Inert" ]
          , target = Nothing
          , msg = Nothing
          , url = Nothing
          }
        ]
  in
    Components.Reference.view demo (text "")
