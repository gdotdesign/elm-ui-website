module Components.Markdown exposing (..)

{-| Functions for rendering markdown.
-}
import Html.Attributes exposing (class)
import Html

import Markdown

{-| Options for markdown.
-}
elmOptions : Markdown.Options
elmOptions =
  let
    options =
      Markdown.defaultOptions
  in
    { options | defaultHighlighting = Just "elm" }


{-| Renders a small markdown content.
-}
viewSmall : String -> Html.Html msg
viewSmall contents =
  Markdown.toHtmlWith elmOptions [ class "markdown-small" ] contents


{-| Renders medium markdown content.
-}
view : String -> Html.Html msg
view contents =
  Markdown.toHtmlWith elmOptions [ class "markdown-medium" ] contents
