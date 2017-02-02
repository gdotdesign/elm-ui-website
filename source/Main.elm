module Main exposing (..)

{-| Website for Elm-UI.
-}
import UrlParser exposing (Parser, (</>))
import Navigation

import Ext.Date
import Task
import Date
import Dict

import Html exposing (node, div, span, text, a, img)
import Html.Attributes exposing (href, src)
import Html.Events exposing (onClick)
import Html.Lazy
import Html

import Dom.Scroll
import Dom

import Ui.Helpers.Emitter as Emitter
import Ui.Container
import Ui.Header
import Ui.Button
import Ui.Layout
import Ui

import Documentation
import Reference
import Icons

import Pages.Index

import Docs.Types
import Http

import Utils.ScrollToTop
import Animation
import Ease

{-| Model for the main.
-}
type alias Model =
  { reference : Reference.Model
  , docs : Documentation.Model
  , route : Route
  , scrollToTop : Utils.ScrollToTop.Model
  }


{-| Messages that the main can receive.
-}
type Msg
  = Loaded (Result Http.Error Docs.Types.Documentation)
  | ScrollToTop Utils.ScrollToTop.Msg
  | Navigation Navigation.Location
  | Reference Reference.Msg
  | Docs Documentation.Msg
  | Navigate String
  | NoOp


{-| Route type.
-}
type Route
  = DocumentationPage String String
  | ReferenceComponent String
  | ReferencePage
  | Home


{-| Route parser.
-}
routes : Parser (Route -> msg) msg
routes =
  UrlParser.oneOf
    [ UrlParser.map
      (\a b -> ReferenceComponent (a ++ "/" ++ b))
      (UrlParser.s "reference" </> UrlParser.string </> UrlParser.string)

    , UrlParser.map
      DocumentationPage
      (UrlParser.s "documentation" </> UrlParser.string </> UrlParser.string)

    , UrlParser.map
      ReferenceComponent
      (UrlParser.s "reference" </> UrlParser.string)

    , UrlParser.map
      ReferencePage
      (UrlParser.s "reference")

    , UrlParser.map
      Home
      UrlParser.top
    ]


{-| Initializes the main.
-}
init : Navigation.Location -> (Model, Cmd Msg)
init data =
  let
    setupAnimation animation =
      Animation.duration 500 animation
        |> Animation.ease Ease.outCubic

    ( model, cmd ) =
      { scrollToTop = Utils.ScrollToTop.init setupAnimation
      , reference = Reference.init
      , docs = Documentation.init
      , route = Home
      }
      |> update (Navigation data)

    documentationLoadCmd =
      Http.get "/documentation.json" Docs.Types.decodeDocumentation
      |> Http.send Loaded
  in
    ( model, Cmd.batch [ documentationLoadCmd ,cmd ] )


{-| Subscriptions for the website.
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map ScrollToTop (Utils.ScrollToTop.subscriptions model.scrollToTop)
    , Sub.map Reference (Reference.subscriptions model.reference)
    , Emitter.listenString "navigation" Navigate
    ]


{-| Updates the main.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case Debug.log "" msg_ of
    Navigation location ->
      case UrlParser.parsePath routes location of
        Just route ->
          let
            documentationCmd =
              case route of
                DocumentationPage category page ->
                  Cmd.map Docs (Documentation.load (category ++ "/" ++ page))

                _ -> Cmd.none
          in
            ( { model | route = route }
            , Cmd.batch
              [ Cmd.map ScrollToTop Utils.ScrollToTop.start
              , documentationCmd
              ]
            )

        Nothing ->
          ( model, Cmd.none )

    Loaded result ->
      case result of
        Ok docs ->
          ( { model
              | reference = Reference.setDocumentation docs model.reference
            }
          , Cmd.none
          )

        Err _ ->
          ( model, Cmd.none )

    Navigate path ->
      ( model, Navigation.newUrl path )

    Reference msg ->
      let
        ( reference, cmd ) =
          Reference.update msg model.reference
      in
        ( { model | reference = reference }, Cmd.map Reference cmd )

    Docs msg ->
      let
        ( docs, cmd ) =
          Documentation.update msg model.docs
      in
        ( { model | docs = docs }, Cmd.map Docs cmd )

    ScrollToTop msg ->
      let
        ( scrollToTop, cmd ) = Utils.ScrollToTop.update msg model.scrollToTop
      in
        ( { model | scrollToTop = scrollToTop }, Cmd.map ScrollToTop cmd )

    NoOp ->
      ( model, Cmd.none )


{-| Content for the main area.
-}
content : Model -> Html.Html Msg
content model =
  case model.route of
    DocumentationPage category page ->
      Html.map Docs (Documentation.view (category ++ "/" ++ page) model.docs)

    ReferencePage ->
      Html.map Reference (Reference.viewLazy model.reference "breadcrumbs")

    ReferenceComponent comp ->
      Html.map Reference (Reference.viewLazy model.reference comp)

    Home ->
      Pages.Index.view Navigate NoOp


{-| The header.
-}
header : Html.Html Msg
header =
  Html.Lazy.lazy
    Ui.Header.view
    [ img [src "/images/logo-small.svg"
          , onClick (Navigate "/")] []
    , Ui.Header.title
       { text = "Elm-UI"
       , action = Just (Navigate "/")
       , link = Just "/"
       , target = "_self"
       }
    , Ui.Header.spacer
    , Ui.Header.iconItem
       { text = "Documentation"
       , action = Just (Navigate "/documentation/getting-started/setup")
       , link = Just "/documentation/getting-started/setup"
       , glyph = Icons.bookmark []
       , side = "left"
       , target = "_self"
       }
    , Ui.Header.separator
    , Ui.Header.iconItem
       { text = "Reference"
       , action = Just (Navigate "/reference")
       , link = Just "/reference"
       , glyph = Icons.code []
       , side = "left"
       , target = "_self"
       }
    , Ui.Header.separator
    , Ui.Header.iconItem
       { text = "Github"
       , action = Nothing
       , glyph = Icons.github []
       , link = Just "https://github.com/gdotdesign/elm-ui"
       , target = "_blank"
       , side = "left"
       }
    ]


{-| The footer.
-}
footer : Html.Html Msg
footer =
  Html.Lazy.lazy3
    node
    "ui-footer"
    []
    [ node "div"
      []
      [ node "a" [ href "https://github.com/gdotdesign/elm-ui" ]
        [ Icons.github []
        , span [] [ text "Code on Github" ]
        ]
      , node "span" [] [ text "|" ]
      , node "span" []
        [ text (toString (Date.year (Ext.Date.now ()))) ]
      ]
    ]


{-| Renders the website.
-}
view : Model -> Html.Html Msg
view model =
  Ui.Layout.website
    [ header        ]
    [ content model ]
    [ footer        ]


{-| The main.
-}
main : Program Never Model Msg
main =
  Navigation.program Navigation
    { subscriptions = subscriptions
    , update = update
    , init = init
    , view = view
    }
