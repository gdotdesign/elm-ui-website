module Components.Reference exposing (..)

import Html exposing (node, text)


view : Html.Html msg -> Html.Html msg -> Html.Html msg
view component fields =
  node "ui-reference-content"
    []
    [ node "ui-reference-title" [] [ text "Demo" ]
    , node "ui-reference-demo"
        []
        [ node "ui-reference-demo-viewport" [] [ component ]
        , fields
        ]
    , node "ui-reference-title" [] [ text "Documentation" ]
    ]
