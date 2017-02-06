module Reference exposing (..)

{-| This is a component for display reference for components.
-}
import Html exposing (div, span, strong, text, node)
import Html.Attributes exposing (class)
import Html.Lazy

import Dict exposing (Dict)
import List.Extra
import String
import Regex

import Ui.Helpers.Emitter as Emitter

import Reference.NotificationCenter as NotificationCenter
import Reference.InplaceInput as InplaceInput
import Reference.DropdownMenu as DropdownMenu
import Reference.NumberRange as NumberRange
import Reference.Breadcrumbs as Breadcrumbs
import Reference.ButtonGroup as ButtonGroup
import Reference.ColorFields as ColorFields
import Reference.ColorPicker as ColorPicker
import Reference.SearchInput as SearchInput
import Reference.IconButton as IconButton
import Reference.DatePicker as DatePicker
import Reference.ColorPanel as ColorPanel
import Reference.NumberPad as NumberPad
import Reference.Container as Container
import Reference.FileInput as FileInput
import Reference.Checkbox as Checkbox
import Reference.Textarea as Textarea
import Reference.Calendar as Calendar
import Reference.Ratings as Ratings
import Reference.Chooser as Chooser
import Reference.Slider as Slider
import Reference.Loader as Loader
import Reference.Layout as Layout
import Reference.Header as Header
import Reference.Tagger as Tagger
import Reference.Button as Button
import Reference.Layout as Layout
import Reference.Modal as Modal
import Reference.Input as Input
import Reference.Pager as Pager
import Reference.Tabs as Tabs
import Reference.Time as Time

import Docs.Types exposing (Documentation, Module)

import Components.NavList as NavList exposing (Category)
import Components.Markdown as Markdown

{-| Represenation of a reference.
-}
type alias Model =
  { notificationCenter : NotificationCenter.Model
  , inplaceInput : InplaceInput.Model
  , dropdownMenu : DropdownMenu.Model
  , colorFields : ColorFields.Model
  , colorPicker : ColorPicker.Model
  , buttonGroup : ButtonGroup.Model
  , numberRange : NumberRange.Model
  , searchInput : SearchInput.Model
  , colorPanel : ColorPanel.Model
  , iconButton : IconButton.Model
  , datePicker : DatePicker.Model
  , fileInput : FileInput.Model
  , container : Container.Model
  , numberPad : NumberPad.Model
  , textarea : Textarea.Model
  , checkbox : Checkbox.Model
  , calendar : Calendar.Model
  , ratings : Ratings.Model
  , chooser : Chooser.Model
  , slider : Slider.Model
  , button : Button.Model
  , tagger : Tagger.Model
  , layout : Layout.Model
  , loader : Loader.Model
  , pager : Pager.Model
  , input : Input.Model
  , modal : Modal.Model
  , time : Time.Model
  , tabs : Tabs.Model

  , documentation : Documentation
  , list : NavList.Model
  }


{-| Messages that a reference can receive.
-}
type Msg
  = NotificationCenter NotificationCenter.Msg
  | InplaceInput InplaceInput.Msg
  | DropdownMenu DropdownMenu.Msg
  | ColorPicker ColorPicker.Msg
  | ButtonGroup ButtonGroup.Msg
  | NumberRange NumberRange.Msg
  | SearchInput SearchInput.Msg
  | ColorFields ColorFields.Msg
  | IconButton IconButton.Msg
  | DatePicker DatePicker.Msg
  | ColorPanel ColorPanel.Msg
  | FileInput FileInput.Msg
  | NumberPad NumberPad.Msg
  | Container Container.Msg
  | Calendar Calendar.Msg
  | Textarea Textarea.Msg
  | Checkbox Checkbox.Msg
  | Chooser Chooser.Msg
  | Ratings Ratings.Msg
  | Button Button.Msg
  | Tagger Tagger.Msg
  | Slider Slider.Msg
  | Loader Loader.Msg
  | Layout Layout.Msg
  | Input Input.Msg
  | Modal Modal.Msg
  | Pager Pager.Msg
  | Time Time.Msg
  | Tabs Tabs.Msg

  | List NavList.Msg
  | Navigate String
  | Noop


{-| Initializes a reference.
-}
init : Model
init =
  { notificationCenter = NotificationCenter.init
  , inplaceInput = InplaceInput.init
  , dropdownMenu = DropdownMenu.init
  , numberRange = NumberRange.init
  , colorFields = ColorFields.init
  , colorPicker = ColorPicker.init
  , buttonGroup = ButtonGroup.init
  , searchInput = SearchInput.init
  , iconButton = IconButton.init
  , colorPanel = ColorPanel.init
  , datePicker = DatePicker.init
  , fileInput = FileInput.init
  , container = Container.init
  , numberPad = NumberPad.init
  , checkbox = Checkbox.init
  , textarea = Textarea.init
  , calendar = Calendar.init
  , ratings = Ratings.init
  , chooser = Chooser.init
  , slider = Slider.init
  , layout = Layout.init
  , button = Button.init
  , loader = Loader.init
  , tagger = Tagger.init
  , pager = Pager.init
  , input = Input.init
  , modal = Modal.init
  , time = Time.init
  , tabs = Tabs.init

  , list = NavList.init "reference" "Search modules..." navItems
  , documentation =
    { modules = [] }
  }


{-| Sets the documentation of a reference.
-}
setDocumentation : Documentation -> Model -> Model
setDocumentation docs model =
  { model | documentation = docs }


{-| Items for the navigation list.
-}
navItems : List Category
navItems =
  let
    convert dictList =
      Dict.toList dictList
        |> List.map (\(url, (name, _)) -> { label = name, href = url })
  in
    [ ( "Components",     convert components    )
    , ( "Helpers",        convert helpers       )
    , ( "Native Modules", convert nativeModules )
    , ( "Extensions",     convert extensions    )
    ]


{-| Component category items.
-}
components : Dict String (String, Bool)
components =
  Dict.fromList
    [ ( "ui",                  ( "Ui",                    False ) )
    , ( "breadcrumbs",         ( "Ui.Breadcrumbs",        True  ) )
    , ( "button",              ( "Ui.Button",             True  ) )
    , ( "button-group",        ( "Ui.ButtonGroup",        True  ) )
    , ( "calendar",            ( "Ui.Calendar",           True  ) )
    , ( "checkbox",            ( "Ui.Checkbox",           True  ) )
    , ( "chooser",             ( "Ui.Chooser",            True  ) )
    , ( "color-fields",        ( "Ui.ColorFields",        True  ) )
    , ( "color-panel",         ( "Ui.ColorPanel",         True  ) )
    , ( "color-picker",        ( "Ui.ColorPicker",        True  ) )
    , ( "container",           ( "Ui.Container",          True  ) )
    , ( "date-picker",         ( "Ui.DatePicker",         True  ) )
    , ( "dropdown-menu",       ( "Ui.DropdownMenu",       True  ) )
    , ( "fab",                 ( "Ui.Fab",                False ) )
    , ( "file-input",          ( "Ui.FileInput",          True  ) )
    , ( "header",              ( "Ui.Header",             True  ) )
    , ( "icon-button",         ( "Ui.IconButton",         True  ) )
    , ( "icons",               ( "Ui.Icons",              False ) )
    , ( "image",               ( "Ui.Image",              False ) )
    , ( "inplace-input",       ( "Ui.InplaceInput",       True  ) )
    , ( "input",               ( "Ui.Input",              True  ) )
    , ( "layout",              ( "Ui.Layout",             True  ) )
    , ( "link",                ( "Ui.Link",               False ) )
    , ( "loader",              ( "Ui.Loader",             True  ) )
    , ( "modal",               ( "Ui.Modal",              True  ) )
    , ( "notification-center", ( "Ui.NotificationCenter", True  ) )
    , ( "number-pad",          ( "Ui.NumberPad",          True  ) )
    , ( "number-range",        ( "Ui.NumberRange",        True  ) )
    , ( "pager",               ( "Ui.Pager",              True  ) )
    , ( "ratings",             ( "Ui.Ratings",            True  ) )
    , ( "scrolled-panel",      ( "Ui.ScrolledPanel",      True  ) )
    , ( "search-input",        ( "Ui.SearchInput",        True  ) )
    , ( "slider",              ( "Ui.Slider",             True  ) )
    , ( "tabs",                ( "Ui.Tabs",               True  ) )
    , ( "tagger",              ( "Ui.Tagger",             True  ) )
    , ( "textarea",            ( "Ui.Textarea",           True  ) )
    , ( "time",                ( "Ui.Time",               True  ) )
    ]


{-| Native module category items.
-}
nativeModules : Dict String (String, Bool)
nativeModules =
  Dict.fromList
    [ ( "native/file-manager", ( "Ui.Native.FileManager", False ) )
    , ( "native/scrolls",      ( "Ui.Native.Scrolls",     False ) )
    , ( "native/uid",          ( "Ui.Native.Uid",         False ) )
    ]


{-| Helper category items.
-}
helpers : Dict String (String, Bool)
helpers =
  Dict.fromList
    [ ( "helpers/drag",            ( "Ui.Helpers.Drag",          False ) )
    , ( "helpers/dropdown",        ( "Ui.Helpers.Dropdown",      False ) )
    , ( "helpers/emitter",         ( "Ui.Helpers.Emitter",       False ) )
    , ( "helpers/env",             ( "Ui.Helpers.Env",           False ) )
    , ( "helpers/intendable",      ( "Ui.Helpers.Intendable",    False ) )
    , ( "helpers/periodic-update", ("Ui.Helpers.PeriodicUpdate", False))
    , ( "helpers/picker",          ( "Ui.Helpers.Picker",        False ) )
    , ( "helpers/ripple",          ( "Ui.Helpers.Ripple",        False ) )
    ]


{-| Extension category items.
-}
extensions : Dict String (String, Bool)
extensions =
  Dict.fromList
    [ ( "ext/color",           ( "Ext.Color",           False ) )
    , ( "ext/number",          ( "Ext.Number",          False ) )
    , ( "ext/date",            ( "Ext.Date",            False ) )
    , ( "html/events/extra",   ( "Html.Events.Extra",   False ) )
    , ( "html/events/options", ( "Html.Events.Options", False ) )
    ]


{-| Updates a reference.
-}
update : Msg -> Model -> (Model, Cmd Msg)
update msg_ model =
  case msg_ of
    Navigate url ->
      ( model, Emitter.sendString "navigation" url )

    Button msg ->
      let
        ( button, cmd ) = Button.update msg model.button
      in
        ( { model | button = button }, Cmd.map Button cmd )

    ColorPanel msg ->
      let
        ( colorPanel, cmd ) = ColorPanel.update msg model.colorPanel
      in
        ( { model | colorPanel = colorPanel }, Cmd.map ColorPanel cmd )

    ColorPicker msg ->
      let
        ( colorPicker, cmd ) = ColorPicker.update msg model.colorPicker
      in
        ( { model | colorPicker = colorPicker }, Cmd.map ColorPicker cmd )

    ColorFields msg ->
      let
        ( colorFields, cmd ) = ColorFields.update msg model.colorFields
      in
        ( { model | colorFields = colorFields }, Cmd.map ColorFields cmd )

    Calendar msg ->
      let
        ( calendar, cmd ) = Calendar.update msg model.calendar
      in
        ( { model | calendar = calendar }, Cmd.map Calendar cmd )

    Chooser msg ->
      let
        ( chooser, cmd ) = Chooser.update msg model.chooser
      in
        ( { model | chooser = chooser }, Cmd.map Chooser cmd )

    FileInput msg ->
      let
        ( fileInput, cmd ) = FileInput.update msg model.fileInput
      in
        ( { model | fileInput = fileInput }, Cmd.map FileInput cmd )

    ButtonGroup msg ->
      let
        ( buttonGroup, cmd ) = ButtonGroup.update msg model.buttonGroup
      in
        ( { model | buttonGroup = buttonGroup }, Cmd.map ButtonGroup cmd )

    Checkbox msg ->
      let
        ( checkbox, cmd ) = Checkbox.update msg model.checkbox
      in
        ( { model | checkbox = checkbox }, Cmd.map Checkbox cmd )

    Container msg ->
      let
        (container, cmd) = Container.update msg model.container
      in
        ({ model | container = container }, Cmd.map Container cmd)

    DatePicker msg ->
      let
        ( datePicker, cmd) = DatePicker.update msg model.datePicker
      in
        ( { model | datePicker = datePicker }, Cmd.map DatePicker cmd )

    DropdownMenu msg ->
      let
        ( dropdownMenu, cmd ) = DropdownMenu.update msg model.dropdownMenu
      in
        ( { model | dropdownMenu = dropdownMenu }, Cmd.map DropdownMenu cmd )

    IconButton msg ->
      let
        ( iconButton, cmd ) = IconButton.update msg model.iconButton
      in
        ( { model | iconButton = iconButton }, Cmd.map IconButton cmd )

    InplaceInput msg ->
      let
        ( inplaceInput, cmd ) = InplaceInput.update msg model.inplaceInput
      in
        ( { model | inplaceInput = inplaceInput }, Cmd.map InplaceInput cmd )

    Input msg ->
      let
        ( input, cmd ) = Input.update msg model.input
      in
        ( { model | input = input }, Cmd.map Input cmd )

    NumberPad msg ->
      let
        ( numberPad, cmd ) = NumberPad.update msg model.numberPad
      in
        ( { model | numberPad = numberPad }, Cmd.map NumberPad cmd )

    List msg ->
      let
        ( list, cmd ) = NavList.update msg model.list
      in
        ( { model | list = list }, Cmd.map List cmd )

    Layout msg ->
      let
        ( layout, cmd ) = Layout.update msg model.layout
      in
        ( { model | layout = layout }, Cmd.map Layout cmd )

    Loader msg ->
      let
        ( loader, cmd ) = Loader.update msg model.loader
      in
        ( { model | loader = loader }, Cmd.map Loader cmd )

    Modal msg ->
      let
        ( modal, cmd ) = Modal.update msg model.modal
      in
        ( { model | modal = modal }, Cmd.map Modal cmd )

    NumberRange msg ->
      let
        ( numberRange, cmd ) = NumberRange.update msg model.numberRange
      in
        ( { model | numberRange = numberRange }, Cmd.map NumberRange cmd )

    Pager msg ->
      let
        ( pager, cmd ) = Pager.update msg model.pager
      in
        ( { model | pager = pager }, Cmd.map Pager cmd )

    Ratings msg ->
      let
        ( ratings, cmd ) = Ratings.update msg model.ratings
      in
        ( { model | ratings = ratings }, Cmd.map Ratings cmd )

    Slider msg ->
      let
        ( slider, cmd ) = Slider.update msg model.slider
      in
        ( { model | slider = slider }, Cmd.map Slider cmd )

    SearchInput msg ->
      let
        ( searchInput, cmd ) = SearchInput.update msg model.searchInput
      in
        ( { model | searchInput = searchInput }, Cmd.map SearchInput cmd )

    Textarea msg ->
      let
        ( textarea, cmd ) = Textarea.update msg model.textarea
      in
        ( { model | textarea = textarea }, Cmd.map Textarea cmd )

    NotificationCenter msg ->
      let
        ( notificationCenter, cmd )
          = NotificationCenter.update msg model.notificationCenter
      in
        ( { model | notificationCenter = notificationCenter }
        , Cmd.map NotificationCenter cmd
        )

    Time msg ->
      let
        ( time, cmd ) = Time.update msg model.time
      in
        ( { model | time = time }, Cmd.map Time cmd )

    Tabs msg ->
      let
        ( tabs, cmd ) = Tabs.update msg model.tabs
      in
        ( { model | tabs = tabs }, Cmd.map Tabs cmd )

    Tagger msg ->
      let
        ( tagger, cmd ) = Tagger.update msg model.tagger
      in
        ( { model | tagger = tagger }, Cmd.map Tagger cmd )

    Noop ->
      ( model, Cmd.none )


{-| Subscriptions for a reference.
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ Sub.map DropdownMenu (DropdownMenu.subscriptions model.dropdownMenu)
  , Sub.map ColorPicker (ColorPicker.subscriptions model.colorPicker)
  , Sub.map ColorFields (ColorFields.subscriptions model.colorFields)
  , Sub.map NumberRange (NumberRange.subscriptions model.numberRange)
  , Sub.map ButtonGroup (ButtonGroup.subscriptions model.buttonGroup)
  , Sub.map ColorPanel (ColorPanel.subscriptions model.colorPanel)
  , Sub.map DatePicker (DatePicker.subscriptions model.datePicker)
  , Sub.map IconButton (IconButton.subscriptions model.iconButton)
  , Sub.map Container (Container.subscriptions model.container)
  , Sub.map NumberPad (NumberPad.subscriptions model.numberPad)
  , Sub.map Calendar (Calendar.subscriptions model.calendar)
  , Sub.map Chooser (Chooser.subscriptions model.chooser)
  , Sub.map Ratings (Ratings.subscriptions model.ratings)
  , Sub.map Layout (Layout.subscriptions model.layout)
  , Sub.map Loader (Loader.subscriptions model.loader)
  , Sub.map Tagger (Tagger.subscriptions model.tagger)
  , Sub.map Slider (Slider.subscriptions model.slider)
  , Sub.map Button (Button.subscriptions model.button)
  , Sub.map Pager (Pager.subscriptions model.pager)
  , Sub.map Tabs (Tabs.subscriptions model.tabs)
  , Sub.map Time (Time.subscriptions model.time)
  ]


{-| Finds a module in the documentation with the given name.
-}
findDocumentation : String -> Documentation -> Maybe Module
findDocumentation name docs =
  List.Extra.find (\mod -> mod.name == name) docs.modules


{-| Processes a type definition.
-}
processType : String -> String
processType definition =
  let
   code = String.split "," definition
     |> List.map String.trim
     |> String.join "\n, "
     |> Regex.replace Regex.All (Regex.regex "\\s}") (\_ -> "\n}")
     |> Regex.replace Regex.All (Regex.regex "\\s\\)") (\_ -> "\n)")
  in
    "```\n" ++ code ++ "\n```"


{-| Renders documentation for a module.
-}
renderDocumentation : Module -> Html.Html Msg
renderDocumentation mod =
  let
    description =
      mod.comment
      |> String.split "#"
      |> List.head
      |> Maybe.withDefault ""
      |> Markdown.view

    renderDefinition definition =
      definition
      |> String.split "->"
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


{-| Renders documentation for the given module.
-}
documentation : Documentation -> String -> Html.Html Msg
documentation docs name =
  findDocumentation name docs
  |> Maybe.map (Html.Lazy.lazy renderDocumentation)
  |> Maybe.withDefault (text "")


{-| Renders the reference lazily.
-}
viewLazy : Model -> String -> Html.Html Msg
viewLazy model active =
  Html.Lazy.lazy2 view model active


{-| Renders the reference.
-}
view : Model -> String -> Html.Html Msg
view model active =
  let
    allPages =
      Dict.union components extensions
      |> Dict.union nativeModules
      |> Dict.union helpers

    componentView =
      case active of
        "dropdown-menu" ->
          Html.map DropdownMenu (DropdownMenu.view model.dropdownMenu)

        "inplace-input" ->
          Html.map InplaceInput (InplaceInput.view model.inplaceInput)

        "color-fields" ->
          Html.map ColorFields (ColorFields.view model.colorFields)

        "color-picker" ->
          Html.map ColorPicker (ColorPicker.view model.colorPicker)

        "button-group" ->
          Html.map ButtonGroup (ButtonGroup.view model.buttonGroup)

        "number-range" ->
          Html.map NumberRange (NumberRange.view model.numberRange)

        "search-input" ->
          Html.map SearchInput (SearchInput.view model.searchInput)

        "color-panel" ->
          Html.map ColorPanel (ColorPanel.view model.colorPanel)

        "date-picker" ->
          Html.map DatePicker (DatePicker.view model.datePicker)

        "icon-button" ->
          Html.map IconButton (IconButton.view model.iconButton)

        "file-input" ->
          Html.map FileInput (FileInput.view model.fileInput)

        "container" ->
          Html.map Container (Container.view model.container)

        "number-pad" ->
          Html.map NumberPad (NumberPad.view model.numberPad)

        "checkbox" ->
          Html.map Checkbox (Checkbox.view model.checkbox)

        "calendar" ->
          Html.map Calendar (Calendar.view model.calendar)

        "textarea" ->
          Html.map Textarea (Textarea.view model.textarea)

        "chooser" ->
          Html.map Chooser (Chooser.view model.chooser)

        "ratings" ->
          Html.map Ratings (Ratings.view model.ratings)

        "button" ->
          Html.map Button (Button.view model.button)

        "slider" ->
          Html.map Slider (Slider.view model.slider)

        "layout" ->
          Html.map Layout (Layout.view model.layout)

        "loader" ->
          Html.map Loader (Loader.view model.loader)

        "tagger" ->
          Html.map Tagger (Tagger.view model.tagger)

        "modal" ->
          Html.map Modal (Modal.view model.modal)

        "pager" ->
          Html.map Pager (Pager.view model.pager)

        "input" ->
          Html.map Input (Input.view model.input)

        "time" ->
          Html.map Time (Time.view model.time)

        "tabs" ->
          Html.map Tabs (Tabs.view model.tabs)

        "breadcrumbs" ->
          Breadcrumbs.view Noop

        "header" ->
          Header.view Noop

        "notification-center" ->
          Html.map
            NotificationCenter
            (NotificationCenter.view model.notificationCenter)

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
      [ Html.map List (NavList.view active model.list)
      , node "ui-reference-content" [] (content ++ docs)
      ]
