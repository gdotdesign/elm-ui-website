module Pages.Index exposing (..)

{-| This module holds the content for the main page.
-}
import Html.Attributes exposing (src, class)
import Html exposing (node, text, img)

import Components.Markdown as Markdown

import Ui.Button
import Ui.Link

{-| Renders the hero section.
-}
hero : (String -> msg) -> msg -> Html.Html msg
hero msg noop =
  let
    setupUrl = "/documentation/getting-started/setup"
    refernceUrl = "/reference/ui"
  in
    node "ui-hero" []
      [ node "ui-hero-title" []
          [ img [ src "/images/logo.svg" ] []
          , text "Elm-UI"
          ]
      , node "ui-hero-subtitle" []
          [ text "UI library for making web applications with Elm!" ]
      , node "ui-hero-buttons" []
        [ Ui.Link.view
          { msg = Just (msg setupUrl)
          , url = Just setupUrl
          , target = Nothing
          , contents =
            [ Ui.Button.view
              noop
              { text = "Get Started"
              , readonly = False
              , disabled = False
              , kind = "primary"
              , size = "medium"
              }
            ]
          }
        , Ui.Link.view
          { msg = Just (msg refernceUrl)
          , url = Just refernceUrl
          , target = Nothing
          , contents =
            [ Ui.Button.view
              noop
              { text = "Component Reference"
              , disabled = False
              , readonly = False
              , kind = "primary"
              , size = "medium"
              }
            ]
          }
        ]
      ]


{-| Renders a section with the given content.
-}
section : String -> String -> String -> Html.Html msg
section title content image =
  node "ui-section" []
    [ node "ui-section-container"[]
      [ node "ui-section-content" []
        [ node "ui-section-title" [] [ text title ]
        , Markdown.view content
        ]
      , img [src image] []
      ]
    ]


{-| Content for the section.
-}
componentLibraryContent : String
componentLibraryContent =
  """
  With a plethora of components you can build a wide variety of single-page
  apps.
  - They have **disabled** and **readonly** states
  - They can be controlled by **keyboard**
  - More than **25+** components
  """


{-| Renders the index page.
-}
view : (String -> msg) -> msg -> Html.Html msg
view navigateMsg noop =
  node "ui-index"
    []
    [ hero navigateMsg noop
    , section "Component Library" componentLibraryContent "/images/components.png"
    , node "ui-cta" []
      [ node "span" [] [ text "Interested?" ]
      , Ui.Button.view
        (navigateMsg "/documentation/getting-started/setup")
        { text = "Get Started"
        , disabled = False
        , readonly = False
        , kind = "primary"
        , size = "medium"
        }
      ]
    ]
