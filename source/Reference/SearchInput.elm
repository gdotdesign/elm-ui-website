module Reference.SearchInput exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.SearchInput

import Ext.Date

import Html.App
import Html


type Msg
  = SearchInput Ui.SearchInput.Msg
  | Form Form.Msg


type alias Model =
  { input : Ui.SearchInput.Model
  , form : Form.Model Msg
  }


init : Model
init =
  let
    input = Ui.SearchInput.init 0 "Placeholder..."
  in
    { input = Ui.SearchInput.setValue "Some content..." input
    , form =
        Form.init
          { checkboxes =
              [ ( "disabled", 3, False )
              , ( "readonly", 4, False )
              ]
          , inputs =
              [ ( "value", 0, "Value...", "Some content..." )
              , ( "placeholder", 0, "Placeholder...", "Placeholder..." )
              ]
          , numberRanges = []
          , textareas = []
          , choosers = []
          , colors = []
          , dates = []
          }
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    SearchInput act ->
      let
        ( input, effect ) =
          Ui.SearchInput.update act model.input
      in
        ( { model | input = input }, Cmd.map SearchInput effect )
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
      Form.updateInput "value" model.input.value model.form
  in
    ( { model | form = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedComponent input =
      let
        updatedInput subInput =
          { subInput | placeholder = Form.valueOfInput "placeholder" "" model.form }
      in
        { input
          | disabled = Form.valueOfCheckbox "disabled" False model.form
          , readonly = Form.valueOfCheckbox "readonly" False model.form
          , input = updatedInput input.input
        } |> Ui.SearchInput.setValue (Form.valueOfInput "value" "" model.form)
  in
    ( { model | input = updatedComponent model.input }, effect )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Html.App.map SearchInput (Ui.SearchInput.view model.input)
  in
    Components.Reference.view demo form
