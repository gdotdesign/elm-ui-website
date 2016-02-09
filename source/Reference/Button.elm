module Reference.Button where

import Html exposing (node, div, text, pre, code)
import Signal exposing (forwardTo)
import Effects
import String

import Ui.Container
import Ui.Button
import Ui

import Reference.Form as Form

type Action
  = Form Form.Action
  | Nothing

type alias Model =
  { model : Ui.Button.Model
  , fields : Form.Model
  }

sizeData =
  [ { label = "Medium", value = "medium" }
  , { label = "Big", value = "big" }
  , { label = "Small", value = "small" }
  ]

kindData =
  [ { label = "Primary", value = "primary" }
  , { label = "Secondary", value = "secondary" }
  , { label = "Success", value = "success" }
  , { label = "Danger", value = "danger" }
  , { label = "Warning", value = "warning" }
  ]

init : Model
init =
  { model = { text = "Test", kind = "primary", size = "medium", disabled = False }
  , fields = Form.init { checkboxes = [("disabled", 0, False)]
                         , choosers = [ ("kind", 1, kindData, "", "primary")
                                      , ("size", 3, sizeData, "", "medium")]
                         , inputs = [("text", 2, "Text...", "Test")]
                         }
  }

update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  let
    updatedModel =
      case action of
        Form act ->
          let
            (fields, effect) = Form.update act model.fields
          in
            ({ model | fields = fields }, Effects.map Form effect)
        _ -> (model, Effects.none)
  in
    updatedModel
      |> updateState

updateState (model, effect) =
  let
    updatedButton button =
      { button | disabled = Form.valueOfCheckbox "disabled" False model.fields
               , kind     = Form.valueOfChooser "kind" "primary" model.fields
               , text     = Form.valueOfInput "text" "Test" model.fields
               , size     = Form.valueOfChooser "size" "medium" model.fields
      }
  in
    ({ model | model = updatedButton model.model }, effect)


modelCodeString = """
{ disabled : Bool
, text : String
, kind : String
}
"""

infos =
  [ Ui.title [] [text "Buttons"]
  , div [] [text "Basic buttons for user actions. Handles tabindex and
                  disabled state."]
  , Ui.subTitle [] [text "Model"]
  , pre [] [code [] [text (String.trim modelCodeString)]]
  ]

fields : Signal.Address Action -> Model -> Html.Html
fields address model =
  Form.view (forwardTo address Form) (model.fields)

view : Signal.Address Action -> Model -> Html.Html
view address model =
  Ui.Button.view address Nothing model.model


render address model =
  [ node "ui-playground-viewport" [] [(view address model)]
  , fields address model
  ]
