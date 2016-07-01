module Reference exposing (..)

import Html.Attributes exposing (href)
import Html exposing (div, span, strong, text, node, a)
import Html.Events exposing (onClick)
import Html.App

import Ui.Helpers.Emitter as Emitter
import Ui.Container
import Ui.Button
import Ui.App
import Ui

import Reference.ColorPanel as ColorPanel
import Reference.Calendar as Calendar
import Reference.Chooser as Chooser
import Reference.Button as Button

type alias Model =
  { button : Button.Model
  , chooser : Chooser.Model
  , calendar : Calendar.Model
  , colorPanel : ColorPanel.Model
  }

type Msg
  = ButtonAction Button.Msg
  | ChooserAction Chooser.Msg
  | CalendarAction Calendar.Msg
  | ColorPanelAction ColorPanel.Msg
  | Navigate String

init : Model
init =
  { button = Button.init
  , chooser = Chooser.init
  , calendar = Calendar.init
  , colorPanel = ColorPanel.init
  }

components =
  [ ("/reference/button", "Button")
  , ("/reference/chooser", "Chooser")
  , ("/reference/calendar", "Calendar")
  , ("/reference/color-panel", "ColorPanel")
  ]

update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    Navigate url ->
      (model, Emitter.sendString "navigation" url)

    ButtonAction act ->
      let
        (button, effect) = Button.update act model.button
      in
        ({ model | button = button }, Cmd.map ButtonAction effect)

    ColorPanelAction act ->
      let
        (colorPanel, effect) = ColorPanel.update act model.colorPanel
      in
        ({ model | colorPanel = colorPanel }, Cmd.map ColorPanelAction effect)

    CalendarAction act ->
      let
        (calendar, effect) = Calendar.update act model.calendar
      in
        ({ model | calendar = calendar }, Cmd.map CalendarAction effect)

    ChooserAction act ->
      let
        (chooser, effect) = Chooser.update act model.chooser
      in
        ({ model | chooser = chooser }, Cmd.map ChooserAction effect)

renderLi (url, label)  =
  node "li" [] [a [onClick (Navigate url)] [text label]]

subscriptions model =
  Sub.map ColorPanelAction (ColorPanel.subscriptions model.colorPanel)

view : Model -> String ->Html.Html Msg
view model active =
  let
    componentView =
      case active of
        "button" ->
          Html.App.map ButtonAction (Button.render model.button)
        "chooser" ->
          Html.App.map ChooserAction (Chooser.render model.chooser)
        "calendar" ->
          Html.App.map CalendarAction (Calendar.render model.calendar)
        "color-panel" ->
          Html.App.map ColorPanelAction (ColorPanel.render model.colorPanel)
        _ ->
          text "No component is selected! Select one on the right!"
  in
    node "ui-reference" []
      [ node "ul" [] (List.map renderLi components)
      , node "ui-playground" [] [componentView]
      ]
