module Main exposing (..)

import Task
--import Hop
import Dict

import Html.Attributes exposing (href, class, src)
import Html.Events exposing (onClick)
import Html exposing (node, div, span, strong, text, a, img)
import Html.App

import Ui.Container
import Ui.Header
import Ui.Button
import Ui.App
import Ui

import Reference

type alias Model =
  { app : Ui.App.Model
  , page : String
  , reference : Reference.Model
  }

type Msg
  = App Ui.App.Msg
  | Navigate String
  --| NavigateReference Hop.Payload
  | Reference Reference.Msg

--routes : List (String, Hop.Payload -> Action)
--routes =
--  ( [("/reference/:component", NavigateReference)]
--    ++ (List.map (\(page, _) -> ("/" ++ page, (Navigate page))) pages))

pages : List (String, String)
pages =
  [ ("home", "Home")
  , ("documentation", "Documentation")
  , ("reference", "Reference")
  ]

--router : Hop.Router Action
--router =
--  Hop.new
--    { routes = routes
--    , notFoundAction = (Navigate "home")
--    }

init : Model
init =
  { app = Ui.App.init "Elm-UI"
  , page = "reference"
  , reference = Reference.init
  }

component payload =
  payload.params
    |> Dict.get "component"
    |> Maybe.withDefault ""

update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    Navigate page ->
      ({ model | page = page
               , reference = Reference.selectComponent "" model.reference }
               , Cmd.none)

    --NavigateReference payload ->
    --  ( { model | page = "reference"
    --            , reference = Reference.selectComponent (component payload) model.reference }
    --  , Cmd.none)

    Reference act ->
      let
        (reference, effect) = Reference.update act model.reference
      in
        ({ model | reference = reference }, Cmd.map Reference effect)

    App act ->
      let
        (app, effect) = Ui.App.update act model.app
      in
        ({ model | app = app }, Cmd.map App effect)

home : Html.Html Msg
home =
  Ui.Container.column []
    [ node "ui-hero" []
      [ Ui.title [] [text "Elm-UI"]
      , Ui.subTitle [] [text "A user interface library and web app framework!"]
      , node "pre" []
        [ node "code" []
          [ text "npm install elm-ui -g"
          , text "\nelm-ui init my-awesome-elm-project"
          , text "\ncd my-awesome-elm-project"
          , text "\nelm-ui install"
          , text "\nelm-ui server"
          ]
        ]
      ]
    , node "ui-section" []
      [ Ui.Container.row []
        [ div []
          [ text """
## Development Workflow
Elm-UI gives you the perfect tools so you can focus on the code instead of the environment:
- Development server with **live reload**
- Colored **errors messages** displayed in the browser
- **Scaffolding** to quickly start a new project
- **Building and minifying** your final files
- **Environment configurations**
"""
          ]
        , img [src "images/errors.png"] []
        ]
      ]
    , node "ui-section" []
      [ Ui.Container.row []
        [ text "Sass" ]
      ]
    , node "ui-section" []
      [ Ui.Container.row []
        [ text "Building" ]
      , Ui.Container.row []
        [ text "Development Server" ]
      , Ui.Container.row []
        [ text "Lost of components" ]
      ]
    ]

content model =
  case model.page of
    "reference" -> Html.App.map Reference (Reference.view model.reference)
    "documentation" -> text ""
    "home" -> home
    _ -> text ""

view : Model -> Html.Html Msg
view model =
  Ui.App.view App model.app
    [ Ui.Header.view []
      ([ Ui.Header.icon "code-working" False []
       , Ui.Header.title [] [text "Elm-UI"]
       ] ++ (viewHeader model))
    , content model
    ]

renderHeader model (page, label) =
  let
    className =
      if page == model.page then
        "active"
      else
        ""
  in
    node "ui-header-item" [class className]
      [ a [onClick (Navigate page)]
        [ span [] [text label]
        ]
      ]

viewHeader model =
  List.map (renderHeader model) pages

main =
  Html.App.program
    { init = ( init, Cmd.none )
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }

