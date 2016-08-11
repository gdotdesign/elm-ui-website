module Reference.Textarea exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Textarea

import Ext.Date

import Html.App
import Html


type Msg
  = Textarea Ui.Textarea.Msg
  | Form Form.Msg


type alias Model =
  { textarea : Ui.Textarea.Model
  , form : Form.Model Msg
  }


init : Model
init =
  { textarea = Ui.Textarea.init "Some content..." "Placeholder..."
  , form =
      Form.init
        { checkboxes =
            [ ( "disabled", 4, False )
            , ( "readonly", 5, False )
            , ( "enter allowed", 3, True)
            ]
        , inputs =
            [ ( "value", 2, "Value...", "Some content..." )
            , ( "placeholder", 1, "Placeholder...", "Placeholder..." )
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
    Textarea act ->
      let
        ( textarea, effect ) =
          Ui.Textarea.update act model.textarea
      in
        ( { model | textarea = textarea }, Cmd.map Textarea effect )
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
      Form.updateInput "value" model.textarea.value model.form
  in
    ( { model | form = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedComponent textarea =
      { textarea
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , placeholder = Form.valueOfInput "placeholder" "" model.form
        , enterAllowed = Form.valueOfCheckbox "enter allowed" False model.form
        , value = Form.valueOfInput "value" "" model.form
      }
  in
    ( { model | textarea = updatedComponent model.textarea }, effect )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Html.App.map Textarea (Ui.Textarea.view model.textarea)
  in
    Components.Reference.view demo form
