module Reference.ColorPanel exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.ColorPanel

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
  Ext.Color.toHsv Color.black


init : Model
init =
  { colorPanel = Ui.ColorPanel.init ()
  , form =
      Form.init
        { checkboxes =
            [ ( "disabled", 1, False )
            , ( "readonly", 2, False )
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

    ColorPanel msg ->
      let
        ( colorPanel, cmd ) =
          Ui.ColorPanel.update msg model.colorPanel
      in
        ( { model | colorPanel = colorPanel }, Cmd.map ColorPanel cmd )
          |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, cmd ) =
  let
    updatedForm =
      Form.updateColor "value"
        (Ext.Color.hsvToRgb model.colorPanel.value)
        model.form
  in
    ( { model | form = updatedForm }, cmd )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    color =
      Form.valueOfColor "value" hsvColor model.form
        |> Ext.Color.hsvToRgb

    ( updatedColorPanel, setCmd ) =
      Ui.ColorPanel.setValue color model.colorPanel

    updatedComponent =
      { updatedColorPanel
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
      }
  in
    ( { model | colorPanel = updatedComponent }
    , Cmd.batch
      [ Cmd.map ColorPanel setCmd
      , cmd
      ]
    )


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
