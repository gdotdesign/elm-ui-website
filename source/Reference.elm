module Reference exposing (..)

import Html.Attributes exposing (href)
import Html exposing (div, span, strong, text, node, a)
import Html.Events exposing (onClick)
import Html.App

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

type Msg
  = ButtonAction Button.Msg
  | ChooserAction Chooser.Msg
  | CalendarAction Calendar.Msg

init : Model
init =
  { button = Button.init
  , chooser = Chooser.init
  , calendar = Calendar.init
  , active = "calendar"
  }

components =
  [ ("button", "Button")
  , ("chooser", "Chooser")
  , ("calendar", "Calendar")
  ]

selectComponent : String -> Model -> Model
selectComponent component model =
  { model | active = component }

update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    ButtonAction act ->
      let
        (button, effect) = Button.update act model.button
      in
        ({ model | button = button }, Cmd.map ButtonAction effect)

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

renderLi (slug, label)  =
  let
    url = "#/reference/" ++ slug
  in
    node "li" [] [a [href url] [text label]]

view : Model -> Html.Html Msg
view model =
  let
    componentView =
      case model.active of
        "button" ->
          Html.App.map ButtonAction (Button.render model.button)
        "chooser" ->
          Html.App.map ChooserAction (Chooser.render model.chooser)
        "calendar" ->
          Html.App.map CalendarAction (Calendar.render model.calendar)
        _ ->
          text "No component is selected! Select one on the right!"
  in
    node "ui-reference" []
      [ node "ul" [] (List.map renderLi components)
      , node "ui-playground" [] [componentView]
      ]
