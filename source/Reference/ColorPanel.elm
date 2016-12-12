module Reference.ColorPanel exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.ColorPanel
import Ui

import Ext.Color exposing (Hsv)
import Color

import Html


type Msg
  = ColorPanel Ui.ColorPanel.Msg
  | Form Form.Msg


type alias Model =
  { colorPanel : Ui.ColorPanel.Model
  , form : Form.Model Msg
  }


hsvColor : Hsv
hsvColor =
  Ext.Color.toHsv Color.yellow


init : Model
init =
  { colorPanel =
      Ui.ColorPanel.init ()
        -- |> Ui.ColorPanel.setValue Color.yellow
  , form =
      Form.init
        { checkboxes =
            [ ( "disabled", 1, False )
            , ( "readonly", 2, False )
            ]
        , colors =
            [ ( "value", 0, Color.yellow ) ]
        , numberRanges = []
        , textareas = []
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
        ( form, effect ) =
          Form.update act model.form
      in
        ( { model | form = form }, Cmd.map Form effect )
          |> updateState

    ColorPanel act ->
      let
        ( colorPanel, effect ) =
          Ui.ColorPanel.update act model.colorPanel
      in
        ( { model | colorPanel = colorPanel }, Cmd.map ColorPanel effect )
          |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, effect ) =
  let
    updatedForm =
      Form.updateColor "value"
        (Ext.Color.hsvToRgb model.colorPanel.value)
        model.form
  in
    ( { model | form = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedComponent colorPanel =
      { colorPanel
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , value = Form.valueOfColor "value" hsvColor model.form
      }
  in
    ( { model | colorPanel = updatedComponent model.colorPanel }, effect )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map ColorPanel (Ui.ColorPanel.subscriptions model.colorPanel)
    , Sub.map Form (Form.subscriptions model.form)
    ]


view : Model -> Html.Html Msg
view model =
  let
    demo =
      Html.map ColorPanel (Ui.ColorPanel.view model.colorPanel)

    form =
      Form.view Form model.form
  in
    Components.Reference.view demo form
