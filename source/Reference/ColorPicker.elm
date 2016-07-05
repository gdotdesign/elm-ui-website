module Reference.ColorPicker exposing (..)

import Components.Form as Form
import Components.Reference
import Ui.Container
import Ui.ColorPicker
import Ui
import Ext.Color exposing (Hsv)
import Color
import Html.App
import Html


type Msg
  = Form Form.Msg
  | ColorPicker Ui.ColorPicker.Msg


type alias Model =
  { model : Ui.ColorPicker.Model
  , fields : Form.Model
  }

hsvColor : Hsv
hsvColor =
  Ext.Color.toHsv Color.yellow

init : Model
init =
  { model = Ui.ColorPicker.init Color.yellow
  , fields =
      Form.init
        { checkboxes =
            [ ( "disabled", 2, False )
            , ( "readonly", 3, False )
            ]
        , choosers = []
        , colors =
            [ ( "value", 0, Color.yellow )]
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

    ColorPicker act ->
      let
        ( colorPicker, effect ) =
          Ui.ColorPicker.update act model.model
      in
        ( { model | model = colorPicker }, Cmd.map ColorPicker effect )
          |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, effect ) =
  let
    updatedForm =
      Form.updateColor "value" (Ext.Color.hsvToRgb model.model.colorPanel.value) model.fields
  in
    ( { model | fields = updatedForm }, effect )



updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    colorPanel =
      model.model.colorPanel

    updatedColorPanel =
      { colorPanel | value = Form.valueOfColor "value" hsvColor model.fields }

    updatedButton button =
      { button
        | disabled = Form.valueOfCheckbox "disabled" False model.fields
        , readonly = Form.valueOfCheckbox "readonly" False model.fields
        , colorPanel = updatedColorPanel
      }
  in
    ( { model | model = updatedButton model.model }, effect )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map ColorPicker (Ui.ColorPicker.subscriptions model.model)
    , Sub.map Form (Form.subscriptions model.fields)
    ]


view : Model -> Html.Html Msg
view model =
  let
    fields =
      Html.App.map Form (Form.view model.fields)

    demo =
      Html.App.map ColorPicker (Ui.ColorPicker.view model.model)
  in
    Components.Reference.view demo fields
