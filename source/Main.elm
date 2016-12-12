module Main exposing (..)

import UrlParser exposing (Parser, (</>))
import Navigation

import Ext.Date
import Task
import Date
import Dict

import Html exposing (node, div, span, strong, text, a, img)
import Html.Attributes exposing (href, class, src, target)
import Html.Events exposing (onClick)
import Html
import Dom.Scroll
import Dom

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Browser as Browser
import Ui.Container
import Ui.Header
import Ui.Button
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
  { page : String
  , reference : Reference.Model
  , docs : Documentation.Model
  , route : Route
  , scrollToTop : Utils.ScrollToTop.Model
  }


type Msg
  = Navigate String
  | Reference Reference.Msg
  | Loaded (Result Http.Error Docs.Types.Documentation)
  | Docs Documentation.Msg
  | ScrollToTop Utils.ScrollToTop.Msg
  | Navigation Navigation.Location
  | NoOp



-------------- ROUTING ---------------------------------------------------------


type Route
  = Component String
  | Home
  | DocumentationPage String String
  | ReferencePage

routes : Parser (Route -> msg) msg
routes =
  UrlParser.oneOf
    [ UrlParser.map Component (UrlParser.s "reference" </> UrlParser.string)
    , UrlParser.map DocumentationPage (UrlParser.s "documentation" </> UrlParser.string </> UrlParser.string)
    , UrlParser.map ReferencePage (UrlParser.s "reference")
    , UrlParser.map Home UrlParser.top
    ]

--------------------------------------------------------------------------------


pages : List ( String, String )
pages =
  [ ( "/documentation", "Documentation" )
  , ( "/reference", "Reference" )
  ]


init : Navigation.Location -> (Model, Cmd Msg)
init data =
  let
    setupAnimation animation =
      Animation.duration 500 animation
      |> Animation.ease Ease.outCubic

    (mod, effect) =
      { page = "reference"
      , reference = Reference.init
      , route = Home
      , docs = Documentation.init
      , scrollToTop = Utils.ScrollToTop.init setupAnimation
      }
      |> update (Navigation data)

    cmd =
      Http.get "/documentation.json" Docs.Types.decodeDocumentation
      |> Http.send Loaded
  in
    ( mod
    , Cmd.batch [cmd
                ,effect]
    )


component payload =
  payload.params
    |> Dict.get "component"
    |> Maybe.withDefault ""


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Navigation location ->
      case UrlParser.parsePath routes location of
        Just route ->
          let
            updatedModel =
              { model | route = route }

            cmd =
              case route of
                DocumentationPage category page ->
                  Cmd.map Docs (Documentation.load (category ++ "/" ++ page))

                _ -> Cmd.none
          in
            ( updatedModel, Cmd.batch [ cmd
                                      , Cmd.map ScrollToTop Utils.ScrollToTop.start
                                      ] )
        Nothing ->
          ( model, Cmd.none )

    Loaded result ->
      case result of
        Ok docs ->
          ({ model | reference = Reference.setDocumentation docs model.reference }, Cmd.none)
        Err _ ->
          (model, Cmd.none)

    Navigate path ->
      let
        command =
          Navigation.newUrl path
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
      Html.map Reference (Reference.viewLazy model.reference "app")

    Component comp ->
      Html.map Reference (Reference.viewLazy model.reference comp)

    DocumentationPage category page ->
      Html.map Docs (Documentation.view (category ++ "/" ++ page) model.docs)


view : Model -> Html.Html Msg
view model =
  node "ui-app" []
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
            , action = Just (Navigate "/documentation/getting-started/setup")
            , link = Just "/documentation/getting-started/setup"
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
    , node "ui-footer" []
      [ node "div"
        []
        [ node "a" [ href "https://github.com/gdotdesign/elm-ui" ]
          [ Ui.icon "social-github" False []
          , span [] [ text "Code on Github" ]
          ]
        , node "span" [] [ text "|" ]
        , node "span" []
          [ text (toString (Date.year (Ext.Date.now ()))) ]
        ]
      ]
    ]

main =
  Navigation.program Navigation
    { init = init
    , view = view
    , update = update
    , subscriptions =
        \model ->
          Sub.batch
            [ Emitter.listenString "navigation" Navigate
            , Sub.map ScrollToTop (Utils.ScrollToTop.subscriptions model.scrollToTop)
            , Sub.map Reference (Reference.subscriptions model.reference)
            ]
    }
