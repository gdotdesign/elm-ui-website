module Reference.Slider exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Slider

import Html exposing (text)
import Html.App


type Msg
  = Slider Ui.Slider.Msg
  | Form Form.Msg


type alias Model =
  { slider : Ui.Slider.Model
  , form : Form.Model Msg
  }


init : Model
init =
  { slider = Ui.Slider.init 50
  , form =
      Form.init
        { numberRanges =
            [ ( "value", 1, 50, "", 0, 100, 0, 1)
            ]
        , textareas = []
        , colors = []
        , dates = []
        , inputs = []
        , checkboxes =
            [ ( "disabled", 3, False )
            , ( "readonly", 4, False )
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

    Slider act ->
      let
        ( slider, effect ) =
          Ui.Slider.update act model.slider
      in
        ( { model | slider = slider }, Cmd.map Slider effect )
          |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, effect ) =
  let
    updatedForm =
      Form.updateNumberRange "value" model.slider.value model.form
  in
    ( { model | form = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    value =
      Form.valueOfNumberRange "value" 0 model.form

    updatedComponent slider =
      { slider
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
      }
      |> Ui.Slider.setValue value
  in
    ( { model | slider = updatedComponent model.slider }, effect )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map Slider (Ui.Slider.subscriptions model.slider)
    , Sub.map Form (Form.subscriptions model.form)
    ]


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Html.App.map Slider (Ui.Slider.view model.slider)
  in
    Components.Reference.view demo form
