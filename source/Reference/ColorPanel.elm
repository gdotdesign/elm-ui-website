module Reference.ColorPanel exposing (..)

import Html exposing (node, div, text, pre, code)
import Html.App

import String
import Color

import Ui.Container
import Ui.ColorPanel
import Ui

import Reference.Form as Form exposing (valueOfCheckbox, valueOfInput)

type Msg
  = Form Form.Msg
  | ColorPanel Ui.ColorPanel.Msg

type alias Model =
  { model : Ui.ColorPanel.Model
  , fields : Form.Model
  }

init =
  { model = Ui.ColorPanel.init Color.yellow
  , fields = Form.init { checkboxes = [ ("disabled", 1, False)
                                      , ("readonly", 0, False)
                                      ]
                         , choosers = []
                         , inputs = []
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

    ColorPanel act ->
      let
        (colorPanel, effect) = Ui.ColorPanel.update act model.model
      in
        ({ model | model = colorPanel }, Cmd.map ColorPanel effect)
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


modelCodeString = """"""

playground children =
  node "docs-playground" [] children

infos =
  [ Ui.title [] [text "ColorPanel"]
  , div [] [text "..."]
  , Ui.title [] [text "Model"]
  , pre [] [code [] [text (String.trim modelCodeString)]]
  ]

subscriptions model =
  Sub.map ColorPanel (Ui.ColorPanel.subscriptions model.model)

fields model =
  Html.App.map Form (Form.view model.fields)

view model =
  Html.App.map ColorPanel (Ui.ColorPanel.view model.model)

render model =
  node "div" []
    [ node "ui-playground-viewport" [] [(view model)]
    , fields model
    ]
