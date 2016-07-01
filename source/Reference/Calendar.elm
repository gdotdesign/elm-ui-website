module Reference.Calendar exposing (..)

import Html exposing (node, div, text, pre, code)
import Html.App
import Ext.Date
import String

import Ui.Calendar
import Ui

import Reference.Form as Form
import Components.Reference

type Msg
  = Form Form.Msg
  | Calendar Ui.Calendar.Msg

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

update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  let
    updatedModel =
      case action of
        Calendar act ->
          let
            (calendar, effect) = Ui.Calendar.update act model.calendar
          in
            ({ model | calendar = calendar }, Cmd.map Calendar effect)

        Form act ->
          let
            (fields, effect) = Form.update act model.fields
          in
            ({ model | fields = fields }, Cmd.map Form effect)
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


fields : Model -> Html.Html Msg
fields model =
  Html.App.map Form (Form.view model.fields)

view : Model -> Html.Html Msg
view model =
  Html.App.map Calendar (Ui.Calendar.view "en_us" model.calendar)


render model =
  Components.Reference.view (view model) (fields model)
