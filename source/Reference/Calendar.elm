module Reference.Calendar exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Calendar

import Ext.Date
import Html

type Msg
  = Calendar Ui.Calendar.Msg
  | Form Form.Msg


type alias Model =
  { calendar : Ui.Calendar.Model
  , form : Form.Model Msg
  }


init : Model
init =
  let
    date = Ext.Date.createDate 1977 5 25
  in
    { calendar =
        Ui.Calendar.init ()
          |> Ui.Calendar.setValue date
    , form =
        Form.init
          { checkboxes =
              [ ( "selectable", 2, True  )
              , ( "disabled",   3, False )
              , ( "readonly",   4, False )
              ]
          , dates =
              [ ( "value", 1, date )
              , ( "date",  0, date )
              ]
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
    Calendar msg ->
      let
        ( calendar, cmd ) =
          Ui.Calendar.update msg model.calendar
      in
        ( { model | calendar = calendar }, Cmd.map Calendar cmd )
          |> updateForm

    Form msg ->
      let
        ( form, cmd ) =
          Form.update msg model.form
      in
        ( { model | form = form }, Cmd.map Form cmd )
          |> updateState


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, cmd ) =
  let
    updatedForm =
      model.form
        |> Form.updateDate "value" model.calendar.value
        |> Form.updateDate "date" model.calendar.date
  in
    ( { model | form = updatedForm }, cmd )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    now =
      Ext.Date.now ()

    updatedComponent calendar =
      { calendar
        | selectable = Form.valueOfCheckbox "selectable" True model.form
        , disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , value = Form.valueOfDate "value" now model.form
        , date = Form.valueOfDate "date" now model.form
      }
  in
    ( { model | calendar = updatedComponent model.calendar }, cmd )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map Form (Form.subscriptions model.form)


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Html.map Calendar (Ui.Calendar.view "en_us" model.calendar)
  in
    Components.Reference.view demo form
