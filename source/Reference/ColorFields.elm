module Reference.ColorFields exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.ColorFields

import Ext.Color exposing (Hsv)
import Color
import Html

type Msg
  = ColorFields Ui.ColorFields.Msg
  | Form Form.Msg


type alias Model =
  { colorFields : Ui.ColorFields.Model
  , form : Form.Model Msg
  }


hsvColor : Hsv
hsvColor =
  Ext.Color.toHsv Color.black


init : Model
init =
  { colorFields = Ui.ColorFields.init ()
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

    ColorFields msg ->
      let
        ( colorFields, cmd ) =
          Ui.ColorFields.update msg model.colorFields
      in
        ( { model | colorFields = colorFields }, Cmd.map ColorFields cmd )
          |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, cmd ) =
  let
    updatedForm =
      Form.updateColor "value"
        (Ext.Color.hsvToRgb model.colorFields.value)
        model.form
  in
    ( { model | form = updatedForm }, cmd )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    color =
      Form.valueOfColor "value" hsvColor model.form

    ( updatedComponent, setCmd ) =
      Ui.ColorFields.setValue color model.colorFields

    finalComponent =
      { updatedComponent
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
      }
  in
    ( { model | colorFields = finalComponent }
    , Cmd.batch
      [ Cmd.map ColorFields setCmd
      , cmd
      ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map Form (Form.subscriptions model.form)


view : Model -> Html.Html Msg
view model =
  let
    demo =
      Html.map ColorFields (Ui.ColorFields.view model.colorFields)

    form =
      Form.view Form model.form
  in
    Components.Reference.view demo form
