module Pages.Index exposing (..)

import Html.Attributes exposing (src, class)
import Html exposing (node, text, img)

import Components.Terminal as Terminal
import Components.Markdown as Markdown

import Ui.Button
import Ui

hero : (String -> msg) -> msg -> Html.Html msg
hero msg noop =
  let
    url = "/documentation/getting-started/setup"
  in
    node "ui-hero"
      []
      [ node "ui-hero-title"
          []
          [ img [ src "/images/logo.svg" ] []
          , text "Elm-UI"
          ]
      , node "ui-hero-subtitle"
          []
          [ text "A user interface library and framework for Elm!" ]
      , Ui.link (Just (msg url)) (Just url) "_self"
          [ Ui.Button.primaryBig "Get Started" noop ]
      , Terminal.view
          [ "npm install elm-ui -g"
          , "----------------------------------"
          , "elm-ui init my-project"
          , "cd my-project"
          , "elm-ui install"
          , "elm-ui server"
          , "> Listening on localhost:8001..."
          ]
      ]


browser : String -> Html.Html msg
browser url =
  node "ui-browser"
    []
    [ node "ui-browser-title" [] []
    , node "ui-browser-content"
        []
        [ img [ src url ] [] ]
    ]


section : String -> String -> String -> Html.Html msg
section title content image =
  node "ui-section"
    []
    [ node "ui-section-container"
        []
        [ node "ui-section-content" []
            [ node "ui-section-title" [] [ text title ]
            , Markdown.view content
            ]
        , img [src image] []
        ]
    ]


worklfowContent : String
worklfowContent =
  """
Elm-UI gives you the perfect tools, so you can focus on your code instead of the environment:
- Colored **error-messages** displayed in the browser
- Development server with built-in **live reload**
- **Scaffolding** to quickly start a new projects
- **Building and minifying** your final files
- **Environment configurations**
"""

componentLibraryContent : String
componentLibraryContent =
  """
With a plethora of components you can build a wide variety of single-page
apps.
- They have **disabled** and **readonly** states
- They can be controlled by **keyboard**
- **25+** components
"""


view : (String -> msg) -> msg -> Html.Html msg
view navigateMsg noop =
  node "ui-index"
    []
    [ hero navigateMsg noop
    , section "Development Workflow" worklfowContent "/images/workflow.svg"
    , section "Component Library" componentLibraryContent "/images/components.png"
    , node "div"
      [ class "cta" ]
      [ node "span" [] [ text "Interested?" ]
      , Ui.Button.primaryBig "Get Started" (navigateMsg "/documentation/getting-started/setup")
      ]
    ]
