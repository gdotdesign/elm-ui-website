module Reference.DatePicker exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.DatePicker

import Ext.Date

import Html.App
import Html


type Msg
  = DatePicker Ui.DatePicker.Msg
  | Form Form.Msg


type alias Model =
  { datePicker : Ui.DatePicker.Model
  , form : Form.Model
  }


init : Model
init =
  let
    datePicker =
      Ui.DatePicker.init (Ext.Date.now ())
  in
    { datePicker = { datePicker | format = "%B %e, %Y" }
    , form =
        Form.init
          { checkboxes =
              [ ( "disabled", 2, False )
              , ( "readonly", 3, False )
              ]
          , dates =
              [ ( "value", 0, (Ext.Date.now ()) ) ]
          , textareas = []
          , choosers = []
          , colors = []
          , inputs = []
          }
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Form act ->
      let
        ( form, effect ) =
          Form.update act model.form
      in
        ( { model | form = form }, Cmd.map Form effect )
          |> updateState

    DatePicker act ->
      let
        ( datePicker, effect ) =
          Ui.DatePicker.update act model.datePicker
      in
        ( { model | datePicker = datePicker }, Cmd.map DatePicker effect )
          |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, effect ) =
  let
    updatedForm =
      Form.updateDate "value" model.datePicker.calendar.value model.form
  in
    ( { model | form = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    calendar =
      model.datePicker.calendar

    updatedCalendar =
      { calendar | value = Form.valueOfDate "value" (Ext.Date.now ()) model.form }

    updatedComponent datePicker =
      { datePicker
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , calendar = updatedCalendar
      }
  in
    ( { model | datePicker = updatedComponent model.datePicker }, effect )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map DatePicker (Ui.DatePicker.subscriptions model.datePicker)
    , Sub.map Form (Form.subscriptions model.form)
    ]


view : Model -> Html.Html Msg
view model =
  let
    form =
      Html.App.map Form (Form.view model.form)

    demo =
      Html.App.map DatePicker (Ui.DatePicker.view "en_us" model.datePicker)
  in
    Components.Reference.view demo form
