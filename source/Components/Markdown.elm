module Components.Markdown exposing (..)

import Html.Attributes exposing (class)
import Html

import Markdown


elmOptions : Markdown.Options
elmOptions =
  let
    options =
      Markdown.defaultOptions
  in
    { options | defaultHighlighting = Just "elm" }


viewSmall : String -> Html.Html msg
viewSmall contents =
  Markdown.toHtmlWith elmOptions [ class "markdown-small" ] contents


view : String -> Html.Html msg
view contents =
  Markdown.toHtmlWith elmOptions [ class "markdown-medium" ] contents
