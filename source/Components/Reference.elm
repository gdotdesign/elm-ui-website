module Components.Reference exposing (..)

{-| Functions for rendering reference pages.
-}
import Html exposing (node, text)


{-| Rendes a demo area for a component.
-}
view : Html.Html msg -> Html.Html msg -> Html.Html msg
view component fields =
  node "ui-reference-demo"
    []
    [ node "ui-reference-demo-viewport" [] [ component ]
    , fields
    ]
