module Main exposing (..)

import Hop.Matchers exposing (match1, match2, str)
import Hop.Types
import Hop

import Navigation
import Task
import Dict

import Html.Attributes exposing (href, class, src)
import Html.Events exposing (onClick)
import Html exposing (node, div, span, strong, text, a, img)
import Html.App

import Ui.Helpers.Emitter as Emitter
import Ui.Container
import Ui.Header
import Ui.Button
import Ui.App
import Ui

import Reference
import Debug exposing (log)

import Docs.Types
import Http

type alias Model =
  { app : Ui.App.Model
  , page : String
  , reference : Reference.Model
  , route : Route
  , location : Hop.Types.Location
  }


type Msg
  = App Ui.App.Msg
  | Navigate String
  | Reference Reference.Msg
  | Failed Http.Error
  | Loaded Docs.Types.Documentation



-------------- ROUTING ---------------------------------------------------------


type Route
  = Component String
  | Home
  | Documentation


matchers : List (Hop.Types.PathMatcher Route)
matchers =
  [ match1 Home ""
  , match1 Documentation "/documentation"
  , match2 Component "/reference/" str
  ]


urlParser : Navigation.Parser ( Route, Hop.Types.Location )
urlParser =
  Navigation.makeParser (.href >> Hop.matchUrl routerConfig)


urlUpdate : ( Route, Hop.Types.Location ) -> Model -> ( Model, Cmd Msg )
urlUpdate ( route, location ) model =
  ( { model | route = route, location = location }, Cmd.none )


routerConfig : Hop.Types.Config Route
routerConfig =
  { hash = False
  , basePath = ""
  , matchers = matchers
  , notFound = Home
  }



--------------------------------------------------------------------------------


pages : List ( String, String )
pages =
  [ ( "/", "Home" )
  , ( "/documentation", "Documentation" )
  , ( "/reference/button", "Reference" )
  ]


init : ( Route, Hop.Types.Location ) -> ( Model, Cmd Msg )
init ( route, location ) =
  ( { app = Ui.App.init "Elm-UI"
    , page = "reference"
    , reference = Reference.init
    , route = route
    , location = location
    }
  , Task.perform Failed Loaded (Http.get Docs.Types.decodeDocumentation "/documentation.json")
  )


component payload =
  payload.params
    |> Dict.get "component"
    |> Maybe.withDefault ""


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Failed _ ->
      (model, Cmd.none)

    Loaded docs ->
      ({ model | reference = Reference.setDocumentation docs model.reference }, Cmd.none)

    Navigate path ->
      let
        _ =
          log "a" (Hop.makeUrl routerConfig path)

        command =
          Hop.makeUrl routerConfig path
            |> Navigation.newUrl
      in
        ( model, command )

    Reference act ->
      let
        ( reference, effect ) =
          Reference.update act model.reference
      in
        ( { model | reference = reference }, Cmd.map Reference effect )

    App act ->
      let
        ( app, effect ) =
          Ui.App.update act model.app
      in
        ( { model | app = app }, Cmd.map App effect )


home : Html.Html Msg
home =
  Ui.Container.column []
    [ node "ui-hero"
        []
        [ node "ui-hero-title" [] [ text "Elm-UI" ]
        , node "ui-hero-subtitle" [] [ text "A user interface library and framework!" ]
        , node "terminal"
            []
            [ node "terminal-header" [] []
            , node "terminal-code"
                []
                [ text "$ npm install elm-ui -g"
                , text "\n$ elm-ui init my-awesome-elm-project"
                , text "\n$ cd my-awesome-elm-project"
                , text "\n$ elm-ui install"
                , text "\n$ elm-ui server"
                ]
            ]
        ]
    , node "ui-section"
        []
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
            , img [ src "images/errors.png" ] []
            ]
        ]
    , node "ui-section"
        []
        [ Ui.Container.row []
            [ text "Sass" ]
        ]
    , node "ui-section"
        []
        [ Ui.Container.row []
            [ text "Building" ]
        , Ui.Container.row []
            [ text "Development Server" ]
        , Ui.Container.row []
            [ text "Lost of components" ]
        ]
    ]


content model =
  case log "a" model.route of
    Home ->
      home

    Component comp ->
      Html.App.map Reference (Reference.view model.reference comp)

    Documentation ->
      text ""


view : Model -> Html.Html Msg
view model =
  Ui.App.view App
    model.app
    [ Ui.Header.view []
        ([ Ui.Header.title [] [ text "Elm-UI" ]
         ]
          ++ (viewHeader model)
        )
    , content model
    , node "ui-footer" [] []
    ]


renderHeader model ( page, label ) =
  node "ui-header-item"
    []
    [ a [ onClick (Navigate page) ]
        [ span [] [ text label ]
        ]
    ]


viewHeader model =
  List.map (renderHeader model) pages


main =
  Navigation.program urlParser
    { init = init
    , view = view
    , update = update
    , urlUpdate = urlUpdate
    , subscriptions =
        \model ->
          Sub.batch
            [ Emitter.listenString "navigation" Navigate
            , Sub.map Reference (Reference.subscriptions model.reference)
            ]
    }
