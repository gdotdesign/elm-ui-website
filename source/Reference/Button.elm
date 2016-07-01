module Reference.Button exposing (..)

import Html exposing (node, div, text, pre, code)
import Html.App
import String

import Ui.Container
import Ui.Button
import Ui

import Reference.Form as Form

import Components.Reference

type Msg
  = Form Form.Msg
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
  { model = { text = "Test", kind = "primary", size = "medium", disabled = False, readonly = False }
  , fields = Form.init { checkboxes = [("disabled", 0, False)]
                         , choosers = [ ("kind", 1, kindData, "", "primary")
                                      , ("size", 3, sizeData, "", "medium")]
                         , inputs = [("text", 2, "Text...", "Test")]
                         }
  }

update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  let
    updatedModel =
      case action of
        Form act ->
          let
            (fields, effect) = Form.update act model.fields
          in
            ({ model | fields = fields }, Cmd.map Form effect)
        _ -> (model, Cmd.none)
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

fields : Model -> Html.Html Msg
fields model =
  Html.App.map Form (Form.view model.fields)

view : Model -> Html.Html Msg
view model =
  Ui.Button.view Nothing model.model


render model =
  Components.Reference.view (view model) (fields model)
