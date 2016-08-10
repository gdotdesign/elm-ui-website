module Reference.Checkbox exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Container
import Ui.Checkbox

import Html.Attributes exposing (style)
import Html exposing (div)
import Html.App


type Msg
  = Checkbox Ui.Checkbox.Msg
  | Form Form.Msg


type alias Model =
  { checkbox : Ui.Checkbox.Model
  , form : Form.Model Msg
  }


init : Model
init =
  { checkbox = Ui.Checkbox.init True
  , form =
      Form.init
        { checkboxes =
            [ ( "value", 1, True )
            , ( "disabled", 2, False )
            , ( "readonly", 3, False )
            ]
        , numberRanges = []
        , textareas = []
        , choosers = []
        , colors = []
        , inputs = []
        , dates = []
        }
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Checkbox act ->
      let
        ( checkbox, effect ) =
          Ui.Checkbox.update act model.checkbox
      in
        ( { model | checkbox = checkbox }, Cmd.map Checkbox effect )
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
      Form.updateCheckbox "value" model.checkbox.value model.form
  in
    ( { model | form = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedComponent checkbox =
      { checkbox
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , value = Form.valueOfCheckbox "value" False model.form
      }
  in
    ( { model | checkbox = updatedComponent model.checkbox }, effect )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Ui.Container.row []
        [ Html.App.map Checkbox (Ui.Checkbox.view model.checkbox)
        , Html.App.map Checkbox (Ui.Checkbox.viewRadio model.checkbox)
        , Html.App.map Checkbox (Ui.Checkbox.viewToggle model.checkbox)
        ]
  in
    Components.Reference.view demo form
