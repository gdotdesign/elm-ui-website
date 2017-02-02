module Reference.NumberRange exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.NumberRange

import Html exposing (text)

type Msg
  = NumberRange Ui.NumberRange.Msg
  | Form Form.Msg


type alias Model =
  { numberRange : Ui.NumberRange.Model
  , form : Form.Model Msg
  }


init : Model
init =
  { numberRange = Ui.NumberRange.init ()
  , form =
      Form.init
        { numberRanges =
            [ ( "value",     1, 42,   "", 0,        (1 / 0), 0, 1   )
            , ( "drag step", 3, 1,    "", 0,        (1 / 0), 2, 0.1 )
            , ( "round",     4, 0,    "", 0,        20,      0, 1   )
            , ( "min",       5, 0,    "", -(1 / 0), 0,       0, 1   )
            , ( "max",       6, 1000, "", 0,        (1 / 0), 0, 1   )
            ]
        , textareas = []
        , colors = []
        , dates = []
        , inputs =
            [ ( "affix", 2, "Affix...", "" )
            ]
        , checkboxes =
            [ ( "disabled", 7, False )
            , ( "readonly", 8, False )
            , ( "editing",  9, False )
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

    NumberRange msg ->
      let
        ( numberRange, cmd ) =
          Ui.NumberRange.update msg model.numberRange
      in
        ( { model | numberRange = numberRange }, Cmd.map NumberRange cmd )
          |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, cmd ) =
  let
    ( updatedForm, formCmd ) =
      model.form
        |> Form.updateCheckbox "editing" model.numberRange.editing
        |> Form.updateNumberRange "value" model.numberRange.value
  in
    ( { model | form = updatedForm }
    , Cmd.batch [ Cmd.map Form formCmd, cmd ]
    )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    ( numberRange, setCmd ) =
      updatedComponent model.numberRange

    updatedComponent numberRange =
      { numberRange
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , editing = Form.valueOfCheckbox "editing" False model.form
        , round = round (Form.valueOfNumberRange "round" 0 model.form)
        , dragStep = Form.valueOfNumberRange "drag step" 0 model.form
        , min = Form.valueOfNumberRange "min" 0 model.form
        , max = Form.valueOfNumberRange "max" 0 model.form
        , affix = Form.valueOfInput "affix" "" model.form
      }
      |> Ui.NumberRange.setValue (Form.valueOfNumberRange "value" 0 model.form)
  in
    ( { model | numberRange = numberRange }
    , Cmd.batch [ cmd, Cmd.map NumberRange setCmd ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map NumberRange (Ui.NumberRange.subscriptions model.numberRange)
    , Sub.map Form (Form.subscriptions model.form)
    ]


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Html.map NumberRange (Ui.NumberRange.view model.numberRange)
  in
    Components.Reference.view demo form
