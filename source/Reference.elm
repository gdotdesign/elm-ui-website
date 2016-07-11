module Reference exposing (..)

import Html exposing (div, span, strong, text, node, a)
import Html.Attributes exposing (classList, class)
import Html.Events exposing (onClick)
import Html.App

import List.Extra
import String
import Regex
import Dict

import Ui.Helpers.Emitter as Emitter
import Ui.Container
import Ui.Button
import Ui.App
import Ui

import Reference.InplaceInput as InplaceInput
import Reference.DropdownMenu as DropdownMenu
import Reference.ButtonGroup as ButtonGroup
import Reference.ColorPicker as ColorPicker
import Reference.IconButton as IconButton
import Reference.DatePicker as DatePicker
import Reference.ColorPanel as ColorPanel
import Reference.NumberPad as NumberPad
import Reference.Container as Container
import Reference.FileInput as FileInput
import Reference.Checkbox as Checkbox
import Reference.Calendar as Calendar
import Reference.Chooser as Chooser
import Reference.Button as Button
import Reference.Input as Input

import Docs.Types exposing (Documentation)

import Components.Markdown as Markdown
import Components.NavList as NavList

type alias Model =
  { input : Input.Model
  , button : Button.Model
  , chooser : Chooser.Model
  , checkbox : Checkbox.Model
  , calendar : Calendar.Model
  , fileInput : FileInput.Model
  , container : Container.Model
  , numberPad : NumberPad.Model
  , colorPanel : ColorPanel.Model
  , iconButton : IconButton.Model
  , datePicker : DatePicker.Model
  , colorPicker : ColorPicker.Model
  , buttonGroup : ButtonGroup.Model
  , inplaceInput : InplaceInput.Model
  , dropdownMenu : DropdownMenu.Model
  , documentation : Documentation
  , list : NavList.Model
  }

type Msg
  = ButtonAction Button.Msg
  | DatePicker DatePicker.Msg
  | ChooserAction Chooser.Msg
  | CalendarAction Calendar.Msg
  | FileInputAction FileInput.Msg
  | ColorPanelAction ColorPanel.Msg
  | ColorPickerAction ColorPicker.Msg
  | ButtonGroupAction ButtonGroup.Msg
  | InplaceInput InplaceInput.Msg
  | DropdownMenu DropdownMenu.Msg
  | IconButton IconButton.Msg
  | NumberPad NumberPad.Msg
  | Container Container.Msg
  | Checkbox Checkbox.Msg
  | Input Input.Msg
  | List NavList.Msg
  | Navigate String

init : Model
init =
  { input = Input.init
  , button = Button.init
  , chooser = Chooser.init
  , checkbox = Checkbox.init
  , calendar = Calendar.init
  , fileInput = FileInput.init
  , container = Container.init
  , numberPad = NumberPad.init
  , iconButton = IconButton.init
  , colorPanel = ColorPanel.init
  , datePicker = DatePicker.init
  , colorPicker = ColorPicker.init
  , buttonGroup = ButtonGroup.init
  , inplaceInput = InplaceInput.init
  , dropdownMenu = DropdownMenu.init
  , documentation = { modules = [] }
  , list = NavList.init "reference" "Search modules..." navItems
  }

setDocumentation docs model =
  { model | documentation = docs }

navItems =
  let
    convert dictList =
      Dict.toList dictList
        |> List.map (\(url, (name, _)) -> { label = name, href = url })
  in
    [ ("Components", convert components)
    , ("Helpers", convert helpers)
    , ("Native Modules", convert nativeModules)
    , ("Extensions", convert extensions)
    ]

components =
  Dict.fromList
    [ ("app", ("Ui.App", False))
    , ("button", ("Ui.Button", True))
    , ("button-group", ("Ui.ButtonGroup", True))
    , ("calendar", ("Ui.Calendar", True))
    , ("checkbox", ("Ui.Checkbox", True))
    , ("chooser", ("Ui.Chooser", True))
    , ("color-panel", ("Ui.ColorPanel", True))
    , ("color-picker", ("Ui.ColorPicker", True))
    , ("container", ("Ui.Container", True))
    , ("date-picker", ("Ui.DatePicker", True))
    , ("dropdown-menu", ("Ui.DropdownMenu", True))
    , ("file-input", ("Ui.FileInput", True))
    , ("icon-button", ("Ui.IconButton", True))
    , ("image", ("Ui.Image", False))
    , ("inplace-input", ("Ui.InplaceInput", True))
    , ("input", ("Ui.Input", True))
    , ("layout", ("Ui.Layout", True))
    , ("loader", ("Ui.Loader", True))
    , ("modal", ("Ui.Modal", True))
    , ("notification-center", ("Ui.NotificationCenter", True))
    , ("number-pad", ("Ui.NumberPad", True))
    ]

nativeModules =
  Dict.fromList
    [ ("native/file-manager", ("Ui.Native.FileManager", False))
    , ("native/browser", ("Ui.Native.Browser", False))
    , ("native/dom", ("Ui.Native.Dom", False))
    , ("native/local-storage", ("Ui.Native.LocalStorage", False))
    , ("native/scrolls", ("Ui.Native.Scrolls", False))
    ]

helpers =
  Dict.fromList
    [ ("helpers/drag", ("Ui.Helpers.Drag", False))
    , ("helpers/emitter", ("Ui.Helpers.Emitter", False))
    , ("helpers/env", ("Ui.Helpers.Env", False))
    , ("helpers/dropdown", ("Ui.Helpers.Dropdown", False))
    , ("helpers/intendable", ("Ui.Helpers.Intendable", False))
    ]

extensions =
  Dict.fromList
    [ ("ext-color", ("Ext.Color", False))
    , ("ext-number", ("Ext.Number", False))
    , ("ext-date", ("Ext.Date", False))
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

    FileInputAction act ->
      let
        (fileInput, effect) = FileInput.update act model.fileInput
      in
        ({ model | fileInput = fileInput }, Cmd.map FileInputAction effect)

    ButtonGroupAction act ->
      let
        (buttonGroup, effect) = ButtonGroup.update act model.buttonGroup
      in
        ({ model | buttonGroup = buttonGroup }, Cmd.map ButtonGroupAction effect)

    Checkbox act ->
      let
        (checkbox, effect) = Checkbox.update act model.checkbox
      in
        ({ model | checkbox = checkbox }, Cmd.map Checkbox effect)

    Container act ->
      let
        (container, effect) = Container.update act model.container
      in
        ({ model | container = container }, Cmd.map Container effect)

    DatePicker act ->
      let
        (datePicker, effect) = DatePicker.update act model.datePicker
      in
        ({ model | datePicker = datePicker }, Cmd.map DatePicker effect)

    DropdownMenu act ->
      let
        (dropdownMenu, effect) = DropdownMenu.update act model.dropdownMenu
      in
        ({ model | dropdownMenu = dropdownMenu }, Cmd.map DropdownMenu effect)

    IconButton act ->
      let
        (iconButton, effect) = IconButton.update act model.iconButton
      in
        ({ model | iconButton = iconButton }, Cmd.map IconButton effect)

    InplaceInput act ->
      let
        (inplaceInput, effect) = InplaceInput.update act model.inplaceInput
      in
        ({ model | inplaceInput = inplaceInput }, Cmd.map InplaceInput effect)

    Input act ->
      let
        (input, effect) = Input.update act model.input
      in
        ({ model | input = input }, Cmd.map Input effect)

    NumberPad act ->
      let
        (numberPad, effect) = NumberPad.update act model.numberPad
      in
        ({ model | numberPad = numberPad }, Cmd.map NumberPad effect)

    List act ->
      let
        (list, effect) = NavList.update act model.list
      in
        ({ model | list = list }, Cmd.map List effect)

subscriptions model =
  Sub.batch
  [ Sub.map ColorPanelAction (ColorPanel.subscriptions model.colorPanel)
  , Sub.map ColorPickerAction (ColorPicker.subscriptions model.colorPicker)
  , Sub.map DropdownMenu (DropdownMenu.subscriptions model.dropdownMenu)
  , Sub.map NumberPad (NumberPad.subscriptions model.numberPad)
  ]

findDocumentation name docs =
  List.Extra.find (\mod -> mod.name == name) docs.modules

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
    description =
      String.split "#" mod.comment
      |> List.head
      |> Maybe.withDefault ""
      |> Markdown.view

    renderDefinition def =
      String.split "->" def
      |> List.map String.trim
      |> List.indexedMap (\index item -> if index /= 0 then "-> " ++ item else item)
      |> List.map (\item -> node "span" [] [text item])

    renderAlias alias =
      node "ui-docs-entity" []
        [ node "ui-docs-entity-title" []
          [ node "div" []
              [ node "strong" [] [text "type alias"]
              , text alias.name
              ]
          ]
        , node "ui-docs-entity-description" []
          [ Markdown.viewSmall alias.comment
          , Markdown.viewSmall (processType alias.definition)
          ]
        ]

    renderType msg =
      node "ui-docs-entity" []
        [ node "ui-docs-entity-title" []
          [ node "div" []
              [ node "strong" [] [text "type"]
              , text msg.name
              ]
          ]
        , node "ui-docs-entity-description" []
          [ Markdown.viewSmall msg.comment
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
          [ Markdown.viewSmall function.comment
          ]
        ]

    types =
      case mod.types of
        [] -> []
        _ ->
          [title "Types"] ++ List.map renderType mod.types

    aliases =
      case mod.aliases of
        [] -> []
        _ ->
          [title "Type Aliases"] ++ List.map renderAlias mod.aliases

    functions =
      case mod.functions of
        [] -> []
        _ ->
          [title "Functions"] ++ List.map renderFunction mod.functions

    title value =
      node "ui-docs-title" [] [text value]
  in
    node "ui-docs" []
      ([description] ++ aliases ++ types ++ functions)

documentation docs name =
  findDocumentation name docs
  |> Maybe.map renderDocumentation
  |> Maybe.withDefault (text "")

view : Model -> String ->Html.Html Msg
view model active =
  let
    allPages =
      Dict.union components extensions
      |> Dict.union nativeModules
      |> Dict.union helpers

    componentView =
      case active of
        "button" ->
          Html.App.map ButtonAction (Button.view model.button)
        "chooser" ->
          Html.App.map ChooserAction (Chooser.view model.chooser)
        "calendar" ->
          Html.App.map CalendarAction (Calendar.view model.calendar)
        "color-panel" ->
          Html.App.map ColorPanelAction (ColorPanel.view model.colorPanel)
        "color-picker" ->
          Html.App.map ColorPickerAction (ColorPicker.view model.colorPicker)
        "file-input" ->
          Html.App.map FileInputAction (FileInput.view model.fileInput)
        "button-group" ->
          Html.App.map ButtonGroupAction (ButtonGroup.view model.buttonGroup)
        "checkbox" ->
          Html.App.map Checkbox (Checkbox.view model.checkbox)
        "container" ->
          Html.App.map Container (Container.view model.container)
        "date-picker" ->
          Html.App.map DatePicker (DatePicker.view model.datePicker)
        "dropdown-menu" ->
          Html.App.map DropdownMenu (DropdownMenu.view model.dropdownMenu)
        "icon-button" ->
          Html.App.map IconButton (IconButton.view model.iconButton)
        "inplace-input" ->
          Html.App.map InplaceInput (InplaceInput.view model.inplaceInput)
        "input" ->
          Html.App.map Input (Input.view model.input)
        "number-pad" ->
          Html.App.map NumberPad (NumberPad.view model.numberPad)
        _ ->
          text ""

    docs =
      case Dict.get active allPages of
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
      case Dict.get active allPages of
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
