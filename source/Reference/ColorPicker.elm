module Reference.ColorPicker exposing (..)

import Html.App
import Html

import String
import Color

import Ui.Container
import Ui.ColorPicker
import Ui

import Components.Form as Form exposing (valueOfCheckbox, valueOfInput)
import Components.Reference

type Msg
  = Form Form.Msg
  | ColorPicker Ui.ColorPicker.Msg

type alias Model =
  { model : Ui.ColorPicker.Model
  , fields : Form.Model
  }

init =
  { model = Ui.ColorPicker.init Color.yellow
  , fields = Form.init { checkboxes = [ ("disabled", 1, False)
                                      , ("readonly", 0, False)
                                      ]
                         , choosers = []
                         , inputs = []
                         , dates = []
                         }
  }

update action model =
  case action of
    Form act ->
      let
        (fields, effect) = Form.update act model.fields
      in
        ({ model | fields = fields }, Cmd.map Form effect)
          |> updateState

    ColorPicker act ->
      let
        (colorPicker, effect) = Ui.ColorPicker.update act model.model
      in
        ({ model | model = colorPicker }, Cmd.map ColorPicker effect)
          |> updateFields

updateFields (model, effect) =
  (model, effect)

updateState (model, effect) =
  let
    updatedButton button =
      { button | disabled = valueOfCheckbox "disabled" False model.fields
               , readonly = valueOfCheckbox "readonly" False model.fields
      }
  in
    ({ model | model = updatedButton model.model }, effect)


subscriptions model =
  Sub.map ColorPicker (Ui.ColorPicker.subscriptions model.model)

fields model =
  Html.App.map Form (Form.view model.fields)

view model =
  Html.App.map ColorPicker (Ui.ColorPicker.view model.model)

render model =
  Components.Reference.view (view model) (fields model)
