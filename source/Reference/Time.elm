module Reference.Time exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Time

import Ext.Date exposing (now, previousMonth)

import Html.Attributes exposing (id)
import Html exposing (div)


type Msg
  = Form Form.Msg
  | Time Ui.Time.Msg


type alias Model =
  { time : Ui.Time.Model
  , form : Form.Model Msg
  }

init : Model
init =
  let
    date = previousMonth (now ())
  in
    { time = Ui.Time.init date
    , form =
        Form.init
          { numberRanges = []
          , checkboxes = []
          , textareas = []
          , choosers = []
          , colors = []
          , inputs = []
          , dates = [( "date", 0, date )]
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

    _ ->
      ( model, Cmd.none )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedComponent time =
      { time
        | date = Form.valueOfDate "date" (now ()) model.form
      }
  in
    ( { model | time = updatedComponent model.time }, effect )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      div [ id "time-demo" ]
        [ Ui.Time.view model.time
        ]
  in
    Components.Reference.view demo form
