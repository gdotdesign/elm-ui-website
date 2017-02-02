module Reference.Slider exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Slider

import Html exposing (text)

type Msg
  = Slider Ui.Slider.Msg
  | Form Form.Msg


type alias Model =
  { slider : Ui.Slider.Model
  , form : Form.Model Msg
  }


init : Model
init =
  { slider =
      Ui.Slider.init ()
        |> Ui.Slider.setValue 50
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
update msg_ model =
  case msg_ of
    Form msg ->
      let
        ( form, cmd ) =
          Form.update msg model.form
      in
        ( { model | form = form }, Cmd.map Form cmd )
          |> updateState

    Slider msg ->
      let
        ( slider, cmd ) =
          Ui.Slider.update msg model.slider
      in
        ( { model | slider = slider }, Cmd.map Slider cmd )
          |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, cmd ) =
  let
    updatedForm =
      Form.updateNumberRange "value" model.slider.value model.form
  in
    ( { model | form = updatedForm }, cmd )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
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
    ( { model | slider = updatedComponent model.slider }, cmd )


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
      Html.map Slider (Ui.Slider.view model.slider)
  in
    Components.Reference.view demo form
