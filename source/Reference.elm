module Reference where

import Signal exposing (forwardTo)
import Effects

import Html.Attributes exposing (href)
import Html exposing (div, span, strong, text, node, a)
import Html.Events exposing (onClick)

import Ui.Container
import Ui.Button
import Ui.App
import Ui

import Reference.Calendar as Calendar
import Reference.Chooser as Chooser
import Reference.Button as Button

type alias Model =
  { button : Button.Model
  , chooser : Chooser.Model
  , calendar : Calendar.Model
  , active : String
  }

type Action
  = ButtonAction Button.Action
  | ChooserAction Chooser.Action
  | CalendarAction Calendar.Action

init : Model
init =
  { button = Button.init
  , chooser = Chooser.init
  , calendar = Calendar.init
  , active = ""
  }

components =
  [ ("button", "Button")
  , ("chooser", "Chooser")
  , ("calendar", "Calendar")
  ]

selectComponent : String -> Model -> Model
selectComponent component model =
  { model | active = component }

update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    ButtonAction act ->
      let
        (button, effect) = Button.update act model.button
      in
        ({ model | button = button }, Effects.map ButtonAction effect)

    CalendarAction act ->
      let
        (calendar, effect) = Calendar.update act model.calendar
      in
        ({ model | calendar = calendar }, Effects.map CalendarAction effect)

    ChooserAction act ->
      let
        (chooser, effect) = Chooser.update act model.chooser
      in
        ({ model | chooser = chooser }, Effects.map ChooserAction effect)

renderLi (slug, label)  =
  let
    url = "#/reference/" ++ slug
  in
    node "li" [] [a [href url] [text label]]

view : Signal.Address Action -> Model -> Html.Html
view address model =
  let
    componentView =
      case model.active of
        "button" ->
          Button.render (forwardTo address ButtonAction) model.button
        "chooser" ->
          Chooser.render (forwardTo address ChooserAction) model.chooser
        "calendar" ->
          Calendar.render (forwardTo address CalendarAction) model.calendar
        _ ->
          [text "No component is selected! Select one on the right!"]
  in
    node "ui-reference" []
      [ node "ul" [] (List.map renderLi components)
      , node "ui-playground" [] componentView
      ]
