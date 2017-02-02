module Reference.Input exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Input

import Html

type Msg
  = Input Ui.Input.Msg
  | Form Form.Msg


type alias Model =
  { input : Ui.Input.Model
  , form : Form.Model Msg
  }


init : Model
init =
  { input =
      Ui.Input.init ()
        |> Ui.Input.placeholder "Placeholder..."
  , form =
      Form.init
        { checkboxes =
            [ ( "disabled", 3, False )
            , ( "readonly", 4, False )
            ]
        , inputs =
            [ ( "value",       0, "Value...",       ""               )
            , ( "placeholder", 1, "Placeholder...", "Placeholder..." )
            ]
        , numberRanges = []
        , textareas = []
        , choosers = []
        , colors = []
        , dates = []
        }
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Input msg ->
      let
        ( input, cmd ) =
          Ui.Input.update msg model.input
      in
        ( { model | input = input }, Cmd.map Input cmd )
          |> updateForm

    Form msg ->
      let
        ( form, cmd ) =
          Form.update msg model.form
      in
        ( { model | form = form }, Cmd.map Form cmd )
          |> updateState


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, cmd ) =
  let
    updatedForm =
      Form.updateInput "value" model.input.value model.form
  in
    ( { model | form = updatedForm }, cmd )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    ( input, setCmd ) =
      updatedComponent model.input

    updatedComponent input =
      { input
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , placeholder = Form.valueOfInput "placeholder" "" model.form
      }
        |> Ui.Input.setValue (Form.valueOfInput "value" "" model.form)
  in
    ( { model | input = input }
    , Cmd.batch [ cmd, Cmd.map Input setCmd ]
    )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Html.map Input (Ui.Input.view model.input)
  in
    Components.Reference.view demo form
