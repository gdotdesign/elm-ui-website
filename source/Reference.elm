module Reference exposing (..)

import Html.Attributes exposing (href)
import Html exposing (div, span, strong, text, node, a)
import Html.Events exposing (onClick)
import Html.App

import List.Extra
import Markdown
import String
import Regex

import Ui.Helpers.Emitter as Emitter
import Ui.Container
import Ui.Button
import Ui.App
import Ui

import Reference.ColorPanel as ColorPanel
import Reference.Calendar as Calendar
import Reference.Chooser as Chooser
import Reference.Button as Button

import Docs.Types exposing (Documentation)

type alias Model =
  { button : Button.Model
  , chooser : Chooser.Model
  , calendar : Calendar.Model
  , colorPanel : ColorPanel.Model
  , documentation : Documentation
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
  , documentation = { modules = [] }
  }

setDocumentation docs model =
  { model | documentation = docs }

components =
  [ ("/reference/button", "Ui.Button")
  , ("/reference/chooser", "Ui.Chooser")
  , ("/reference/calendar", "Ui.Calendar")
  , ("/reference/color-panel", "Ui.ColorPanel")
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

findDocumentation name docs =
  List.Extra.find (\mod -> mod.name == name) docs.modules

myOptions =
  let
    options =
      Markdown.defaultOptions
  in
    { options | defaultHighlighting = Just "elm" }

processType definition =
  let
   code = String.split "," definition
     |> List.map String.trim
     |> String.join "\n, "
     |> Regex.replace Regex.All (Regex.regex "\\s}") (\_ -> "\n}")
  in
    "```\n" ++ code ++ "\n```"

renderDocumentation mod =
  let
    renderDefinition def =
      String.split "->" def
      |> List.map String.trim
      |> List.map (\item -> "-> " ++ item)
      |> List.map (\item -> node "span" [] [text item])

    renderAlias alias =
      node "ui-docs-entity" []
        [ node "ui-docs-entity-title" []
          [ node "div" [] [text alias.name]
          ]
        , node "ui-docs-entity-description" []
          [ Markdown.toHtmlWith myOptions [] alias.comment
          , Markdown.toHtmlWith myOptions [] (processType alias.definition)
          ]
        ]

    renderFunction function =
      node "ui-docs-entity" []
        [ node "ui-docs-entity-title" []
          [ node "div" [] [ text function.name ]
          , node "div" [] [ text ":" ]
          , node "div" [] (renderDefinition function.definition)
          ]
        , node "ui-docs-entity-description" []
          [ Markdown.toHtmlWith myOptions [] function.comment
          ]
        ]

    aliases =
      List.map renderAlias mod.aliases

    functions =
      List.map renderFunction mod.functions
  in
    node "ui-docs" []
      (aliases ++ functions)

documentation name docs =
  findDocumentation name docs
  |> Maybe.map renderDocumentation
  |> Maybe.withDefault (text "")

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

    docs =
      case active of
        "button" -> documentation "Ui.Button" model.documentation
        "color-panel" -> documentation "Ui.ColorPanel" model.documentation
        "calendar" -> documentation "Ui.Calendar" model.documentation
        _ -> text ""
  in
    node "ui-reference" []
      [ node "ul" [] (List.map renderLi components)
      , node "ui-reference-content" []
        [ componentView
        , docs
        ]
      ]
