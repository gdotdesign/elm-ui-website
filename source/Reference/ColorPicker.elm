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
  = ColorPicker Ui.ColorPicker.Msg
  | Form Form.Msg


type alias Model =
  { colorPicker : Ui.ColorPicker.Model
  , form : Form.Model
  }


hsvColor : Hsv
hsvColor =
  Ext.Color.toHsv Color.yellow


init : Model
init =
  { colorPicker = Ui.ColorPicker.init Color.yellow
  , form =
      Form.init
        { checkboxes =
            [ ( "disabled", 2, False )
            , ( "readonly", 3, False )
            ]
        , choosers = []
        , colors =
            [ ( "value", 0, Color.yellow ) ]
        , inputs = []
        , dates = []
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

    ColorPicker act ->
      let
        ( colorPicker, effect ) =
          Ui.ColorPicker.update act model.colorPicker
      in
        ( { model | colorPicker = colorPicker }, Cmd.map ColorPicker effect )
          |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, effect ) =
  let
    updatedForm =
      Form.updateColor "value"
        (Ext.Color.hsvToRgb model.colorPicker.colorPanel.value)
        model.form
  in
    ( { model | form = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    colorPanel =
      model.colorPicker.colorPanel

    updatedColorPanel =
      { colorPanel | value = Form.valueOfColor "value" hsvColor model.form }

    updatedComponent colorPicker =
      { colorPicker
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , colorPanel = updatedColorPanel
      }
  in
    ( { model | colorPicker = updatedComponent model.colorPicker }, effect )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map ColorPicker (Ui.ColorPicker.subscriptions model.colorPicker)
    , Sub.map Form (Form.subscriptions model.form)
    ]


view : Model -> Html.Html Msg
view model =
  let
    form =
      Html.App.map Form (Form.view model.form)

    demo =
      Html.App.map ColorPicker (Ui.ColorPicker.view model.colorPicker)
  in
    Components.Reference.view demo form
