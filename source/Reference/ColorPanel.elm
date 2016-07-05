module Reference.ColorPanel exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.ColorPanel
import Ui

import Ext.Color exposing (Hsv)
import Color

import Html.App
import Html


type Msg
  = Form Form.Msg
  | ColorPanel Ui.ColorPanel.Msg


type alias Model =
  { model : Ui.ColorPanel.Model
  , fields : Form.Model
  }

hsvColor : Hsv
hsvColor =
  Ext.Color.toHsv Color.yellow

init : Model
init =
  { model = Ui.ColorPanel.init Color.yellow
  , fields =
      Form.init
        { checkboxes =
            [ ( "disabled", 1, False )
            , ( "readonly", 2, False )
            ]
        , colors =
            [ ( "value", 0, Color.yellow) ]
        , choosers = []
        , inputs = []
        , dates = []
        }
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Form act ->
      let
        ( fields, effect ) =
          Form.update act model.fields
      in
        ( { model | fields = fields }, Cmd.map Form effect )
          |> updateState

    ColorPanel act ->
      let
        ( colorPanel, effect ) =
          Ui.ColorPanel.update act model.model
      in
        ( { model | model = colorPanel }, Cmd.map ColorPanel effect )
          |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, effect ) =
  let
    updatedForm =
      Form.updateColor "value" (Ext.Color.hsvToRgb model.model.value) model.fields
  in
    ( { model | fields = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedModel colorPanel =
      { colorPanel
        | disabled = Form.valueOfCheckbox "disabled" False model.fields
        , readonly = Form.valueOfCheckbox "readonly" False model.fields
        , value = Form.valueOfColor "value" hsvColor model.fields
      }
  in
    ( { model | model = updatedModel model.model }, effect )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map ColorPanel (Ui.ColorPanel.subscriptions model.model)
    , Sub.map Form (Form.subscriptions model.fields)
    ]


view : Model -> Html.Html Msg
view model =
  let
    demo =
      Html.App.map ColorPanel (Ui.ColorPanel.view model.model)

    fields =
      Html.App.map Form (Form.view model.fields)
  in
    Components.Reference.view demo fields
