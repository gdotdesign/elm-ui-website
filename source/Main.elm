module Main exposing (..)

import Hop.Matchers exposing (match1, match2)
import Hop.Types
import Hop

import Combine exposing (Parser)
import Navigation
import Task
import Dict

import Html.Attributes exposing (href, class, src, target)
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
import Documentation

import Pages.Index

import Docs.Types
import Http

type alias Model =
  { app : Ui.App.Model
  , page : String
  , reference : Reference.Model
  , docs : Documentation.Model
  , route : Route
  , location : Hop.Types.Location
  }


type Msg
  = App Ui.App.Msg
  | Navigate String
  | Reference Reference.Msg
  | Failed Http.Error
  | Loaded Docs.Types.Documentation
  | Docs Documentation.Msg



-------------- ROUTING ---------------------------------------------------------


type Route
  = Component String
  | Home
  | Documentation
  | DocumentationPage String
  | ReferencePage


all : Parser String
all =
  Combine.regex ".+"

matchers : List (Hop.Types.PathMatcher Route)
matchers =
  [ match1 Home ""
  , match2 Component "/reference/" all
  , match2 DocumentationPage "/documentation/" all
  , match1 ReferencePage "/reference"
  , match1 Documentation "/documentation"
  ]


urlParser : Navigation.Parser ( Route, Hop.Types.Location )
urlParser =
  Navigation.makeParser (.href >> Hop.matchUrl routerConfig)


urlUpdate : ( Route, Hop.Types.Location ) -> Model -> ( Model, Cmd Msg )
urlUpdate ( route, location ) model =
  let
    updatedModel =
      { model | route = route, location = location }

    cmd =
      case route of
        Documentation ->
          Cmd.map Docs (Documentation.load "index")

        DocumentationPage page ->
          Cmd.map Docs (Documentation.load page)
        _ -> Cmd.none
  in
    ( updatedModel, cmd )


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
  [ ( "/documentation", "Documentation" )
  , ( "/reference", "Reference" )
  ]


init : ( Route, Hop.Types.Location ) -> ( Model, Cmd Msg )
init ( route, location ) =
  let
    (mod, effect) =
      { app = Ui.App.init "Elm-UI"
      , page = "reference"
      , reference = Reference.init
      , route = route
      , docs = Documentation.init
      , location = location
      }
      |> urlUpdate (route, location)
  in
    ( mod
    , Cmd.batch [Task.perform Failed Loaded (Http.get Docs.Types.decodeDocumentation "/documentation.json")
                , effect]
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

    Docs act ->
      let
        ( docs, effect ) =
          Documentation.update act model.docs
      in
        ( { model | docs = docs }, Cmd.map Docs effect )

    App act ->
      let
        ( app, effect ) =
          Ui.App.update act model.app
      in
        ( { model | app = app }, Cmd.map App effect )



content model =
  case model.route of
    Home ->
      Pages.Index.view Navigate

    ReferencePage ->
      Html.App.map Reference (Reference.view model.reference "")

    Component comp ->
      Html.App.map Reference (Reference.view model.reference comp)

    Documentation ->
      Html.App.map Docs (Documentation.view model.docs)

    DocumentationPage page ->
      Html.App.map Docs (Documentation.view model.docs)


view : Model -> Html.Html Msg
view model =
  Ui.App.view App
    model.app
    [ Ui.Header.view []
        ([ Ui.Header.title [ onClick (Navigate "/")]
            [img [src "/images/logo-small.svg"] []
            , text "Elm-UI"
            ]

         ]
          ++ (viewHeader model)
          ++
          [ renderHeaderLink "Github" "social-github" "https://github.com/gdotdesign/elm-ui"
          ]
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

renderHeaderLink label glyph link =
  node "ui-header-item"
    []
    [ a [ href link, target "_blank" ]
        [ Ui.icon glyph False []
        , span [] [ text label ]
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
