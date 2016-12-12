module Reference.DropdownMenu exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Helpers.Dropdown
import Ui.DropdownMenu
import Ui.IconButton
import Ui.Chooser
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
  [ { label = "left", value = "left" }
  , { label = "right", value = "right" }
  ]


verticalData : List Ui.Chooser.Item
verticalData =
  [ { label = "top", value = "top" }
  , { label = "bottom", value = "bottom" }
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
            [ ( "horizontal", 0, horizontalData, "", "left" )
            , ( "vertical", 1, verticalData, "", "bottom" )
            ]
        , numberRanges = []
        , textareas = []
        , colors = []
        , inputs = []
        , dates = []
        }
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Form act ->
      let
        ( form, effect ) =
          Form.update act model.form
      in
        ( { model | form = form }, Cmd.map Form effect )
          |> updateState

    DropdownMenu act ->
      let
        dropdownMenu =
          Ui.DropdownMenu.update act model.dropdownMenu
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
updateForm ( model, effect ) =
  let
    updatedForm =
      Form.updateCheckbox "open" model.dropdownMenu.dropdown.open model.form
  in
    ( { model | form = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  ( model, effect )
  {-let
    -- sides =
    --  model.dropdownMenu.favoredSides

    -- updatedSides =
    --  { horizontal = Form.valueOfChooser "horizontal" "left" model.form
    --  , vertical = Form.valueOfChooser "vertical" "bottom" model.form
    --  }

    updatedComponent dropdown =
      { dropdown
        | open = Form.valueOfCheckbox "open" False model.form
      }
  in
    ( { model | dropdownMenu = updatedComponent model.dropdownMenu }, effect )
  -}


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map DropdownMenu (Ui.DropdownMenu.subscriptions model.dropdownMenu)
    ]


viewModel : Ui.DropdownMenu.ViewModel Msg
viewModel =
  { element =
      Ui.IconButton.secondary "Open"
        "chevron-down"
        "right"
        Nothing
  , address =
      DropdownMenu
  , items =
      [ Ui.DropdownMenu.item [ onClick CloseMenu ]
          [ Ui.icon "android-download" True []
          , node "span" [] [ text "Download" ]
          ]
      , Ui.DropdownMenu.item [ onClick CloseMenu ]
          [ Ui.icon "trash-b" True []
          , node "span" [] [ text "Delete" ]
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
