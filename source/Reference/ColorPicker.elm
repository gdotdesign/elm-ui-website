module Reference.ColorPicker exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.ColorPicker

import Ext.Color exposing (Hsv)
import Color
import Html

type Msg
  = ColorPicker Ui.ColorPicker.Msg
  | Form Form.Msg


type alias Model =
  { colorPicker : Ui.ColorPicker.Model
  , form : Form.Model Msg
  }


hsvColor : Hsv
hsvColor =
  Ext.Color.toHsv Color.black


init : Model
init =
  { colorPicker = Ui.ColorPicker.init ()
  , form =
      Form.init
        { checkboxes =
            [ ( "disabled", 2, False )
            , ( "readonly", 3, False )
            ]
        , colors =
            [ ( "value", 0, Color.black ) ]
        , numberRanges = []
        , textareas = []
        , choosers = []
        , inputs = []
        , dates = []
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

    ColorPicker msg ->
      let
        ( colorPicker, cmd ) =
          Ui.ColorPicker.update msg model.colorPicker
      in
        ( { model | colorPicker = colorPicker }, Cmd.map ColorPicker cmd )
          |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, cmd ) =
  let
    updatedForm =
      Form.updateColor "value"
        (Ext.Color.hsvToRgb model.colorPicker.colorPanel.value)
        model.form
  in
    ( { model | form = updatedForm }, cmd )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    color =
      Form.valueOfColor "value" hsvColor model.form
        |> Ext.Color.hsvToRgb

    ( updatedColorPicker, setCmd ) =
      Ui.ColorPicker.setValue color model.colorPicker

    updatedComponent =
      { updatedColorPicker
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
      }
  in
    ( { model | colorPicker = updatedComponent }
    , Cmd.batch
      [ Cmd.map ColorPicker setCmd
      , cmd
      ]
    )


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
      Form.view Form model.form

    demo =
      Html.map ColorPicker (Ui.ColorPicker.view model.colorPicker)
  in
    Components.Reference.view demo form
