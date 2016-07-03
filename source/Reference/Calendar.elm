module Reference.Calendar exposing (..)

import Components.Form as Form
import Components.Reference
import Ui.Calendar
import Ext.Date
import Html.App
import Html


type Msg
  = Form Form.Msg
  | Calendar Ui.Calendar.Msg


type alias Model =
  { calendar : Ui.Calendar.Model
  , form : Form.Model
  }


init : Model
init =
  let
    now =
      Ext.Date.now ()
  in
    { calendar = Ui.Calendar.init now
    , form =
        Form.init
          { checkboxes =
              [ ( "selectable", 2, True )
              , ( "disabled", 3, False )
              , ( "readonly", 4, False )
              ]
          , dates =
              [ ( "value", 1, now )
              , ( "date", 0, now )
              ]
          , choosers = []
          , inputs = []
          }
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Calendar act ->
      let
        ( calendar, effect ) =
          Ui.Calendar.update act model.calendar
      in
        ( { model | calendar = calendar }, Cmd.map Calendar effect )
          |> updateForm

    Form act ->
      let
        ( form, effect ) =
          Form.update act model.form
      in
        ( { model | form = form }, Cmd.map Form effect )
          |> updateState


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, effect ) =
  let
    updatedForm =
      Form.updateDate "date" model.calendar.date model.form
        |> Form.updateDate "value" model.calendar.value
  in
    ( { model | form = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    now =
      Ext.Date.now ()

    updated calendar =
      { calendar
        | selectable = Form.valueOfCheckbox "selectable" True model.form
        , disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , value = Form.valueOfDate "value" now model.form
        , date = Form.valueOfDate "date" now model.form
      }
  in
    ( { model | calendar = updated model.calendar }, effect )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Html.App.map Form (Form.view model.form)

    demo =
      Html.App.map Calendar (Ui.Calendar.view "en_us" model.calendar)
  in
    Components.Reference.view demo form
