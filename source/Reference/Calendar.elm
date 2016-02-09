module Reference.Calendar where

import Html exposing (node, div, text, pre, code)
import Signal exposing (forwardTo)
import Ext.Date
import Effects
import String

import Ui.Calendar
import Ui

import Reference.Form as Form

type Action
  = Form Form.Action
  | Calendar Ui.Calendar.Action

type alias Model =
  { calendar : Ui.Calendar.Model
  , fields : Form.Model
  }


init : Model
init =
  { calendar = Ui.Calendar.init (Ext.Date.now ())
  , fields = Form.init { checkboxes = [ ("disabled", 0, False)
                                      , ("readonly", 0, False)
                                      , ("selectable", 0, True)
                                      ]
                       , choosers = []
                       , inputs = []
                       }
  }

update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  let
    updatedModel =
      case action of
        Calendar act ->
          let
            (calendar, effect) = Ui.Calendar.update act model.calendar
          in
            ({ model | calendar = calendar }, Effects.map Calendar effect)

        Form act ->
          let
            (fields, effect) = Form.update act model.fields
          in
            ({ model | fields = fields }, Effects.map Form effect)
  in
    updatedModel
      |> updateState

updateState (model, effect) =
  let
    updated calendar =
      { calendar | disabled = Form.valueOfCheckbox "disabled" False model.fields
                 , readonly = Form.valueOfCheckbox "readonly" False model.fields
                 , selectable = Form.valueOfCheckbox "selectable" True model.fields
      }
  in
    ({ model | calendar = updated model.calendar }, effect)


fields : Signal.Address Action -> Model -> Html.Html
fields address model =
  Form.view (forwardTo address Form) (model.fields)

view : Signal.Address Action -> Model -> Html.Html
view address model =
  Ui.Calendar.view (forwardTo address Calendar) model.calendar


render address model =
  [ node "ui-playground-viewport" [] [(view address model)]
  , fields address model
  ]
