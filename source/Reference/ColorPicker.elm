module Reference.ColorPicker exposing (..)

import Components.Form as Form
import Components.Reference
import Ui.Container
import Ui.ColorPicker
import Ui
import String
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


init : Model
init =
  { model = Ui.ColorPicker.init Color.yellow
  , fields =
      Form.init
        { checkboxes =
            [ ( "disabled", 1, False )
            , ( "readonly", 0, False )
            ]
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

    ColorPicker act ->
      let
        ( colorPicker, effect ) =
          Ui.ColorPicker.update act model.model
      in
        ( { model | model = colorPicker }, Cmd.map ColorPicker effect )
          |> updateFields


updateFields : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateFields ( model, effect ) =
  ( model, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedButton button =
      { button
        | disabled = Form.valueOfCheckbox "disabled" False model.fields
        , readonly = Form.valueOfCheckbox "readonly" False model.fields
      }
  in
    ( { model | model = updatedButton model.model }, effect )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map ColorPicker (Ui.ColorPicker.subscriptions model.model)


view : Model -> Html.Html Msg
view model =
  let
    fields =
      Html.App.map Form (Form.view model.fields)

    demo =
      Html.App.map ColorPicker (Ui.ColorPicker.view model.model)
  in
    Components.Reference.view demo fields
