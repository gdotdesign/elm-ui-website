module Components.Terminal exposing (..)

{-| View for rendering a terminal window.
-}
import Html exposing (node, text)


{-| Renders a terminal window with the given lines.
-}
view : List String -> Html.Html msg
view lines =
  let
    prefixLine index line =
      if index == 0 then
        "$ " ++ line
      else
        "\n$ " ++ line

    prefixedLines =
      List.indexedMap prefixLine lines
        |> List.map text
  in
    node "ui-terminal"
      []
      [ node "ui-terminal-header"
          []
          [ node "ui-terminal-button" [] []
          , node "ui-terminal-button" [] []
          , node "ui-terminal-button" [] []
          ]
      , node "ui-terminal-code"
          []
          prefixedLines
      ]
