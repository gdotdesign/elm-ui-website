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


horizontalData : List Ui.Chooser.Item
horizontalData =
  [ { id = "left",  label = "left",  value = "left"  }
  , { id = "right", label = "right", value = "right" }
  ]


verticalData : List Ui.Chooser.Item
verticalData =
  [ { id = "top",    label = "top",    value = "top"    }
  , { id = "bottom", label = "bottom", value = "bottom" }
  ]


init : Model
init =
  { dropdownMenu = Ui.DropdownMenu.init ()
  , form =
      Form.init
        { checkboxes =
            [ ( "open", 2, False )
            ]
        , choosers =
            [ ( "horizontal", 0, horizontalData, "", "left"   )
            , ( "vertical",   1, verticalData,   "", "bottom" )
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

    dropdownMenu =
      model.dropdownMenu
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
