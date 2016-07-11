module Reference.InplaceInput exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.InplaceInput

import Ext.Date

import Html.App
import Html


type Msg
  = InplaceInput Ui.InplaceInput.Msg
  | Form Form.Msg


type alias Model =
  { inplaceInput : Ui.InplaceInput.Model
  , form : Form.Model
  }


init : Model
init =
  { inplaceInput = Ui.InplaceInput.init "Some content..." "Placeholder..."
  , form =
      Form.init
        { checkboxes =
            [ ( "required", 2, False )
            , ( "disabled", 3, False )
            , ( "readonly", 4, False )
            , ( "ctrlSave", 5, False )
            , ( "open", 6, False )
            ]
        , textareas =
            [ ( "value", 0, "Placeholder...", "Some content..." )]
        , numberRanges = []
        , choosers = []
        , inputs = []
        , colors = []
        , dates = []
        }
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    InplaceInput act ->
      let
        ( inplaceInput, effect ) =
          Ui.InplaceInput.update act model.inplaceInput
      in
        ( { model | inplaceInput = inplaceInput }, Cmd.map InplaceInput effect )
          |> updateForm

    Form act ->
      let
        ( form, effect ) =
          Form.update act model.form
      in
        ( { model | form = form }, Cmd.map Form effect )
          |> updateState


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, effect ) =
  let
    updatedForm =
      Form.updateCheckbox "open" model.inplaceInput.open model.form
      |> Form.updateTextarea "value" model.inplaceInput.value
  in
    ( { model | form = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedComponent inplaceInput =
      { inplaceInput
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , required = Form.valueOfCheckbox "required" False model.form
        , ctrlSave = Form.valueOfCheckbox "ctrlSave" False model.form
        , open = Form.valueOfCheckbox "open" True model.form
      }
      |> Ui.InplaceInput.setValue (Form.valueOfTextarea "value" "" model.form)

  in
    ( { model | inplaceInput = updatedComponent model.inplaceInput }, effect )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Html.App.map Form (Form.view model.form)

    demo =
      Html.App.map InplaceInput (Ui.InplaceInput.view model.inplaceInput)
  in
    Components.Reference.view demo form
