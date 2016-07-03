module Reference exposing (..)

import Html.Attributes exposing (classList, class)
import Html exposing (div, span, strong, text, node, a)
import Html.Events exposing (onClick)
import Html.App

import List.Extra
import Markdown
import String
import Regex
import Dict

import Ui.Helpers.Emitter as Emitter
import Ui.Container
import Ui.Button
import Ui.App
import Ui

import Reference.ColorPicker as ColorPicker
import Reference.ColorPanel as ColorPanel
import Reference.Calendar as Calendar
import Reference.Chooser as Chooser
import Reference.Button as Button

import Docs.Types exposing (Documentation)

import Components.NavList as NavList

type alias Model =
  { button : Button.Model
  , chooser : Chooser.Model
  , calendar : Calendar.Model
  , colorPanel : ColorPanel.Model
  , colorPicker : ColorPicker.Model
  , documentation : Documentation
  , list : NavList.Model
  }

type Msg
  = ButtonAction Button.Msg
  | ChooserAction Chooser.Msg
  | CalendarAction Calendar.Msg
  | ColorPanelAction ColorPanel.Msg
  | ColorPickerAction ColorPicker.Msg
  | List NavList.Msg
  | Navigate String

init : Model
init =
  { button = Button.init
  , chooser = Chooser.init
  , calendar = Calendar.init
  , colorPanel = ColorPanel.init
  , colorPicker = ColorPicker.init
  , documentation = { modules = [] }
  , list = NavList.init "reference" "Search modules..." navItems
  }

setDocumentation docs model =
  { model | documentation = docs }

navItems =
  Dict.toList components
  |> List.map (\(url, (name, _)) -> { label = name, href = url })

components =
  Dict.fromList
    [ ("button", ("Ui.Button", True))
    , ("chooser", ("Ui.Chooser", True))
    , ("calendar", ("Ui.Calendar", True))
    , ("color-panel", ("Ui.ColorPanel", True))
    , ("color-picker", ("Ui.ColorPicker", True))
    , ("ext-color", ("Ext.Color", False))
    , ("ext-number", ("Ext.Number", False))
    , ("ext-date", ("Ext.Date", False))
    , ("native/file-manager", ("Ui.Native.FileManager", False))
    , ("native/browser", ("Ui.Native.Browser", False))
    , ("native/dom", ("Ui.Native.Dom", False))
    , ("native/local-storage", ("Ui.Native.LocalStorage", False))
    , ("native/scrolls", ("Ui.Native.Scrolls", False))
    , ("helpers/drag", ("Ui.Helpers.Drag", False))
    , ("helpers/emitter", ("Ui.Helpers.Emitter", False))
    , ("helpers/env", ("Ui.Helpers.Env", False))
    , ("helpers/dropdown", ("Ui.Helpers.Dropdown", False))
    , ("helpers/intendable", ("Ui.Helpers.Intendable", False))
    , ("html/events/geometry", ("Html.Events.Geometry", False))
    , ("html/events/extra", ("Html.Events.Extra", False))
    , ("html/events/options", ("Html.Events.Options", False))
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

    ColorPickerAction act ->
      let
        (colorPicker, effect) = ColorPicker.update act model.colorPicker
      in
        ({ model | colorPicker = colorPicker }, Cmd.map ColorPickerAction effect)

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

    List act ->
      let
        (list, effect) = NavList.update act model.list
      in
        ({ model | list = list }, Cmd.map List effect)

subscriptions model =
  Sub.batch
  [ Sub.map ColorPanelAction (ColorPanel.subscriptions model.colorPanel)
  , Sub.map ColorPickerAction (ColorPicker.subscriptions model.colorPicker)
  ]

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
     |> Regex.replace Regex.All (Regex.regex "\\s\\)") (\_ -> "\n)")
  in
    "```\n" ++ code ++ "\n```"

renderDocumentation mod =
  let
    renderDefinition def =
      String.split "->" def
      |> List.map String.trim
      |> List.indexedMap (\index item -> if index /= 0 then "-> " ++ item else item)
      |> List.map (\item -> node "span" [] [text item])

    renderAlias alias =
      node "ui-docs-entity" []
        [ node "ui-docs-entity-title" []
          [ node "div" [] [text ("type alias " ++ alias.name)]
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

documentation docs name =
  findDocumentation name docs
  |> Maybe.map renderDocumentation
  |> Maybe.withDefault (text "")

view : Model -> String ->Html.Html Msg
view model active =
  let
    componentView =
      case active of
        "button" ->
          Html.App.map ButtonAction (Button.view model.button)
        "chooser" ->
          Html.App.map ChooserAction (Chooser.view model.chooser)
        "calendar" ->
          Html.App.map CalendarAction (Calendar.view model.calendar)
        "color-panel" ->
          Html.App.map ColorPanelAction (ColorPanel.render model.colorPanel)
        "color-picker" ->
          Html.App.map ColorPickerAction (ColorPicker.render model.colorPicker)
        _ ->
          text ""

    docs =
      case Dict.get active components of
        Just (label, haveDemo) ->
          let
            (title, className) =
              if haveDemo then
                ("Documentation", "upcase")
              else
                (label, "")
          in
            [ node "ui-reference-title" [class className] [ text title ]
            , documentation model.documentation label
            ]
        _ ->
          [ ]

    content =
      case Dict.get active components of
        Just (label, haveDemo) ->
          if haveDemo then
            [ node "ui-reference-title" [] [ text label ]
            , componentView
            ]
          else
            []
        _ ->
          [ text "No component is selected!" ]
  in
    node "ui-reference" []
      [ Html.App.map List (NavList.view active model.list)
      , node "ui-reference-content" [] (content ++ docs)
      ]
