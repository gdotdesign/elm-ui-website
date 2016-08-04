module Reference.NumberPad exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.NumberPad

import Html exposing (text)
import Html.App


type Msg
  = NumberPad Ui.NumberPad.Msg
  | Form Form.Msg


type alias Model =
  { numberPad : Ui.NumberPad.Model
  , form : Form.Model
  }


init : Model
init =
  { numberPad = Ui.NumberPad.init 42
  , form =
      Form.init
        { numberRanges =
            [ ( "value", 1, 42, "", 0, (1 / 0), 0, 1)
            ]
        , textareas = []
        , colors = []
        , dates = []
        , inputs =
            [ ( "prefix", 1, "Prefix...", "" )
            , ( "affix", 2, "Affix...", "" )
            ]
        , checkboxes =
            [ ( "disabled", 4, False )
            , ( "readonly", 5, False )
            , ( "format", 3, True)
            ]
        , choosers =
            []
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

    NumberPad act ->
      let
        ( numberPad, effect ) =
          Ui.NumberPad.update act model.numberPad
      in
        ( { model | numberPad = numberPad }, Cmd.map NumberPad effect )
        |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, effect ) =
  let
    updatedForm =
      Form.updateNumberRange "value"
        (toFloat model.numberPad.value)
        model.form
  in
    ( { model | form = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedComponent numberPad =
      { numberPad
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , format = Form.valueOfCheckbox "format" False model.form
        , value = round (Form.valueOfNumberRange "value" 0 model.form)
        , prefix = Form.valueOfInput "prefix" "" model.form
        , affix = Form.valueOfInput "affix" "" model.form
      }
  in
    ( { model | numberPad = updatedComponent model.numberPad }, effect )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map Form (Form.subscriptions model.form)


view : Model -> Html.Html Msg
view model =
  let
    form =
      Html.App.map Form (Form.view model.form)

    demo =
      Ui.NumberPad.view
        { bottomLeft = text "", bottomRight = text "" }
        NumberPad
        model.numberPad
  in
    Components.Reference.view demo form
