module Main where

import Signal exposing (forwardTo)
import StartApp
import Effects
import Task
import Hop

import Html.Attributes exposing (href, class, src)
import Html exposing (node, div, span, strong, text, a, img)

import Ui.Container
import Ui.Button
import Ui.App
import Ui

type alias Model =
  { app : Ui.App.Model
  , page : String
  }

type Action
  = App Ui.App.Action
  | Navigate String Hop.Payload

routes : List (String, Hop.Payload -> Action)
routes =
  List.map (\(page, _) -> ("/" ++ page, (Navigate page))) pages

pages : List (String, String)
pages =
  [ ("home", "Home")
  , ("documentation", "Documentation")
  , ("reference", "Reference")
  ]

router : Hop.Router Action
router =
  Hop.new
    { routes = routes
    , notFoundAction = (Navigate "home")
    }

init : Model
init =
  { app = Ui.App.init "Elm-UI"
  , page = "home"
  }

update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Navigate page _ ->
      ({ model | page = page }, Effects.none)

    App act ->
      let
        (app, effect) = Ui.App.update act model.app
      in
        ({ model | app = app }, Effects.map App effect)

home : Html.Html
home =
  Ui.Container.column []
    [ div []
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
      , Ui.Container.row []
        [ text "Beautiful error messages"
        , img [src "images/errors.png"] []
        ]
      , Ui.Container.row []
        [ text "Sass" ]
      , Ui.Container.row []
        [ text "Building" ]
      , Ui.Container.row []
        [ text "Development Server" ]
      , Ui.Container.row []
        [ text "Lost of components" ]
      ]
    ]

content model =
  case model.page of
    "documentation" -> text ""
    "home" -> home
    _ -> text ""

view : Signal.Address Action -> Model -> Html.Html
view address model =
  Ui.App.view (forwardTo address App) model.app
    [ Ui.header []
      [ Ui.Container.view { align = "stretch"
                          , direction = "row"
                          , compact = True } []
        ([ Ui.headerIcon "code-working" False []
         , Ui.headerTitle [] [text "Elm-UI"]
         ] ++ (viewHeader model))
      ]
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
      [ a [href ("#/" ++ page)] [text label]
      ]

viewHeader model =
  List.map (renderHeader model) pages

app =
  StartApp.start { init = (init, Effects.none)
                 , update = update
                 , view = view
                 , inputs = [ router.signal ]
                 }

main =
  app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
