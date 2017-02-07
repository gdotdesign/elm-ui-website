module Reference.NumberPad exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.NumberPad

import Html exposing (text)

type Msg
  = NumberPad Ui.NumberPad.Msg
  | Form Form.Msg


type alias Model =
  { numberPad : Ui.NumberPad.Model
  , form : Form.Model Msg
  }


init : Model
init =
  { numberPad =
      Ui.NumberPad.init ()
        |> Ui.NumberPad.setValue 42
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
            , ( "affix",  2, "Affix...",  "" )
            ]
        , checkboxes =
            [ ( "disabled", 4, False )
            , ( "readonly", 5, False )
            , ( "format",   3, True  )
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

    NumberPad msg ->
      let
        ( numberPad, cmd ) =
          Ui.NumberPad.update msg model.numberPad
      in
        ( { model | numberPad = numberPad }, Cmd.map NumberPad cmd )
        |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, cmd ) =
  let
    ( updatedForm, formCmd ) =
      Form.updateNumberRange "value"
        (toFloat model.numberPad.value)
        model.form
  in
    ( { model | form = updatedForm }
    , Cmd.batch [ Cmd.map Form formCmd, cmd ]
    )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    updatedComponent numberPad =
      { numberPad
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , value = round (Form.valueOfNumberRange "value" 0 model.form)
        , format = Form.valueOfCheckbox "format" False model.form
        , prefix = Form.valueOfInput "prefix" "" model.form
        , affix = Form.valueOfInput "affix" "" model.form
      }
  in
    ( { model | numberPad = updatedComponent model.numberPad }, cmd )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map Form (Form.subscriptions model.form)


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Ui.NumberPad.view
        { bottomLeft = text "", bottomRight = text "", address = NumberPad }
        model.numberPad
  in
    Components.Reference.view demo form
