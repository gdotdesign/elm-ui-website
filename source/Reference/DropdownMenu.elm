module Reference.DropdownMenu exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Helpers.Dropdown
import Ui.DropdownMenu
import Ui.Chooser
import Ui.Button
import Ui.Icons
import Ui

import Html.Events exposing (onClick)
import Html exposing (node, text)

type Msg
  = DropdownMenu Ui.DropdownMenu.Msg
  | Form Form.Msg
  | CloseMenu
  | Nothing


type alias Model =
  { dropdownMenu : Ui.DropdownMenu.Model
  , form : Form.Model Msg
  }


directionData : List Ui.Chooser.Item
directionData =
  [ { id = "horizontal", label = "horizontal", value = "horizontal"  }
  , { id = "vertical",   label = "vertical",   value = "vertical"    }
  ]


sideData : List Ui.Chooser.Item
sideData =
  [ { id = "positive", label = "positive", value = "positive" }
  , { id = "negative", label = "negative", value = "negative" }
  ]


init : Model
init =
  { dropdownMenu = Ui.DropdownMenu.init ()
  , form =
      Form.init
        { checkboxes =
            [ ( "open", 3, False )
            ]
        , choosers =
            [ ( "direction", 0, directionData, "", "vertical" )
            , ( "alingTo",   1, sideData,      "", "positive" )
            , ( "favoring",  2, sideData,      "", "positive" )
            ]
        , numberRanges = []
        , textareas = []
        , colors = []
        , inputs = []
        , dates = []
        }
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Form msg ->
      let
        ( form, cmd ) =
          Form.update msg model.form
      in
        ( { model | form = form }, Cmd.map Form cmd )
          |> updateState

    DropdownMenu msg ->
      let
        dropdownMenu =
          Ui.DropdownMenu.update msg model.dropdownMenu
      in
        ( { model | dropdownMenu = dropdownMenu }, Cmd.none )
          |> updateForm

    CloseMenu ->
      ( { model | dropdownMenu = Ui.Helpers.Dropdown.close model.dropdownMenu }
      , Cmd.none )
        |> updateForm

    _ ->
      ( model, Cmd.none )


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, cmd ) =
  let
    updatedForm =
      Form.updateCheckbox "open" model.dropdownMenu.dropdown.open model.form
  in
    ( { model | form = updatedForm }, cmd )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    toggleFunction =
      if Form.valueOfCheckbox "open" False model.form then
        Ui.Helpers.Dropdown.open
      else
        Ui.Helpers.Dropdown.close

    direction =
      case Form.valueOfChooser "direction" "vertical" model.form of
        "horizontal" -> Ui.Helpers.Dropdown.Horizontal
        _ -> Ui.Helpers.Dropdown.Vertical

    favoring =
      case Form.valueOfChooser "favoring" "positive" model.form of
        "negative" -> Ui.Helpers.Dropdown.Top
        _ -> Ui.Helpers.Dropdown.Bottom

    alignTo =
      case Form.valueOfChooser "alignTo" "positive" model.form of
        "negative" -> Ui.Helpers.Dropdown.Top
        _ -> Ui.Helpers.Dropdown.Bottom

    dropdownMenu =
      model.dropdownMenu
        |> Ui.Helpers.Dropdown.alignTo alignTo
        |> Ui.Helpers.Dropdown.favoring favoring
        |> Ui.Helpers.Dropdown.direction direction
        |> toggleFunction
  in
    ( { model | dropdownMenu = dropdownMenu }, cmd )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map DropdownMenu (Ui.DropdownMenu.subscriptions model.dropdownMenu)
    , Sub.map Form (Form.subscriptions model.form)
    ]


viewModel : Ui.DropdownMenu.ViewModel Msg
viewModel =
  { address = DropdownMenu
  , element =
      Ui.Button.view
        Nothing
        { disabled = False
        , readonly = False
        , kind = "primary"
        , size = "medium"
        , text = "Open"
        }
  , items =
      [ Ui.DropdownMenu.item [ onClick CloseMenu ]
          [ Ui.Icons.calendar []
          , node "span" [] [ text "Calendar" ]
          ]
      , Ui.DropdownMenu.item [ onClick CloseMenu ]
          [ Ui.Icons.search []
          , node "span" [] [ text "Search" ]
          ]
      ]
  }


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Ui.DropdownMenu.view viewModel model.dropdownMenu
  in
    Components.Reference.view demo form
