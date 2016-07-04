module Reference.FileInput exposing (..)

import Html exposing (div)
import Html.App

import String
import Color

import Ui.FileInput
import Ui.Container
import Ui

import Components.Form as Form exposing (valueOfCheckbox, valueOfInput)
import Components.Reference

type Msg
  = Form Form.Msg
  | FileInput Ui.FileInput.Msg

type alias Model =
  { model : Ui.FileInput.Model
  , fields : Form.Model
  }

init =
  { model = Ui.FileInput.init "*"
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

    FileInput act ->
      let
        (component, effect) = Ui.FileInput.update act model.model
      in
        ({ model | model = component }, Cmd.map FileInput effect)
          |> updateFields

updateFields (model, effect) =
  (model, effect)

updateState (model, effect) =
  let
    updatedModel component =
      { component | disabled = valueOfCheckbox "disabled" False model.fields
                  , readonly = valueOfCheckbox "readonly" False model.fields
      }
  in
    ({ model | model = updatedModel model.model }, effect)

view model =
  let
    fields =
      Html.App.map Form (Form.view model.fields)

    demo =
      div []
        [ Html.App.map FileInput (Ui.FileInput.view model.model)
        , Html.App.map FileInput (Ui.FileInput.viewDetails model.model)
        ]
  in
    Components.Reference.view demo fields
