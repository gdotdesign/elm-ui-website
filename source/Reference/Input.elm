module Reference.Input exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Input

import Ext.Date

import Html.App
import Html


type Msg
  = Input Ui.Input.Msg
  | Form Form.Msg


type alias Model =
  { input : Ui.Input.Model
  , form : Form.Model Msg
  }


init : Model
init =
  { input = Ui.Input.init "Some content..." "Placeholder..."
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
    Input act ->
      let
        ( input, effect ) =
          Ui.Input.update act model.input
      in
        ( { model | input = input }, Cmd.map Input effect )
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
      { input
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , placeholder = Form.valueOfInput "placeholder" "" model.form
        , value = Form.valueOfInput "value" "" model.form
      }
  in
    ( { model | input = updatedComponent model.input }, effect )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Html.App.map Input (Ui.Input.view model.input)
  in
    Components.Reference.view demo form
