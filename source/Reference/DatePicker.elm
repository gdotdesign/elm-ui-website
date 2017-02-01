module Reference.DatePicker exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.DatePicker

import Ext.Date
import Html

type Msg
  = DatePicker Ui.DatePicker.Msg
  | Form Form.Msg


type alias Model =
  { datePicker : Ui.DatePicker.Model
  , form : Form.Model Msg
  }


init : Model
init =
  let
    date =
      Ext.Date.createDate 1980 5 17

    datePicker =
      Ui.DatePicker.init ()
      |> Ui.DatePicker.setValue date
  in
    { datePicker = { datePicker | format = "%B %e, %Y" }
    , form =
        Form.init
          { checkboxes =
              [ ( "close on select", 1, False )
              , ( "disabled", 2, False )
              , ( "readonly", 3, False )
              ]
          , dates =
              [ ( "value", 0, date ) ]
          , numberRanges = []
          , textareas = []
          , choosers = []
          , colors = []
          , inputs = []
          }
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Form msg ->
      let
        ( form, cmd ) =
          Form.update msg model.form
      in
        ( { model | form = form }, Cmd.map Form cmd )
          |> updateState

    DatePicker msg ->
      let
        ( datePicker, cmd ) =
          Ui.DatePicker.update msg model.datePicker
      in
        ( { model | datePicker = datePicker }, Cmd.map DatePicker cmd )
          |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, cmd ) =
  let
    updatedForm =
      Form.updateDate "value" model.datePicker.calendar.value model.form
  in
    ( { model | form = updatedForm }, cmd )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    calendar =
      model.datePicker.calendar

    updatedCalendar =
      { calendar | value = Form.valueOfDate "value" (Ext.Date.now ()) model.form }

    updatedComponent datePicker =
      { datePicker
        | closeOnSelect = Form.valueOfCheckbox "close on select" False model.form
        , disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , calendar = updatedCalendar
      }
  in
    ( { model | datePicker = updatedComponent model.datePicker }, cmd )


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
      Form.view Form model.form

    demo =
      Html.map DatePicker (Ui.DatePicker.view "en_us" model.datePicker)
  in
    Components.Reference.view demo form
