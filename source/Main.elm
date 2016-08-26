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
import Dom.Scroll
import Dom

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Browser as Browser
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

import Utils.ScrollToTop
import Animation
import Ease

type alias Model =
  { app : Ui.App.Model
  , page : String
  , reference : Reference.Model
  , docs : Documentation.Model
  , route : Route
  , location : Hop.Types.Location
  , scrollToTop : Utils.ScrollToTop.Model
  }


type Msg
  = App Ui.App.Msg
  | Navigate String
  | Reference Reference.Msg
  | Failed Http.Error
  | Loaded Docs.Types.Documentation
  | Docs Documentation.Msg
  | ScrollToTop Utils.ScrollToTop.Msg
  | NoOp



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
    ( updatedModel, Cmd.batch [ cmd
                              , Cmd.map ScrollToTop Utils.ScrollToTop.start
                              ] )


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
    setupAnimation animation =
      Animation.duration 500 animation
      |> Animation.ease Ease.outCubic

    (mod, effect) =
      { app = Ui.App.init
      , page = "reference"
      , reference = Reference.init
      , route = route
      , docs = Documentation.init
      , location = location
      , scrollToTop = Utils.ScrollToTop.init setupAnimation
      }
      |> urlUpdate (route, location)
  in
    ( mod
    , Cmd.batch [Task.perform Failed Loaded (Http.get Docs.Types.decodeDocumentation "/documentation.json")
                ,effect]
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

    ScrollToTop act ->
      let
        (scrollToTop, cmd) = Utils.ScrollToTop.update act model.scrollToTop
      in
        ({ model | scrollToTop = scrollToTop }, Cmd.map ScrollToTop cmd)

    NoOp ->
      model ! []

content model =
  case model.route of
    Home ->
      Pages.Index.view Navigate NoOp

    ReferencePage ->
      Html.App.map Reference (Reference.viewLazy model.reference "app")

    Component comp ->
      Html.App.map Reference (Reference.viewLazy model.reference comp)

    Documentation ->
      Html.App.map Docs (Documentation.view model.docs)

    DocumentationPage page ->
      Html.App.map Docs (Documentation.view model.docs)


view : Model -> Html.Html Msg
view model =
  Ui.App.view App
    model.app
    [ Ui.Header.view
        ([ img [src "/images/logo-small.svg"
               , onClick (Navigate "/")] []
         , Ui.Header.title
            { text = "Elm-UI"
            , action = Just (Navigate "/")
            , link = Just "/"
            , target = "_self"
            }
         , Ui.spacer
         , Ui.Header.iconItem
            { text = "Documentation"
            , action = Just (Navigate "/documentation")
            , link = Just "/documentation"
            , glyph = "bookmark"
            , side = "left"
            , target = "_self"
            }
         , Ui.Header.separator
         , Ui.Header.iconItem
            { text = "Reference"
            , action = Just (Navigate "/reference")
            , link = Just "/reference"
            , glyph = "code"
            , side = "left"
            , target = "_self"
            }
         , Ui.Header.separator
         , Ui.Header.iconItem
            { text = "Github"
            , action = Nothing
            , glyph = "social-github"
            , link = Just "https://github.com/gdotdesign/elm-ui"
            , target = "_blank"
            , side = "left"
            }
         ]
        )
    , content model
    , node "ui-footer" [] []
    ]

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
            , Sub.map ScrollToTop (Utils.ScrollToTop.subscriptions model.scrollToTop)
            , Sub.map Reference (Reference.subscriptions model.reference)
            ]
    }
