module Reference.InplaceInput exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.InplaceInput

import Html.Attributes exposing (class)
import Html exposing (div, span, text)

type Msg
  = InplaceInput Ui.InplaceInput.Msg
  | Form Form.Msg


type alias Model =
  { inplaceInput : Ui.InplaceInput.Model
  , form : Form.Model Msg
  }


init : Model
init =
  { inplaceInput =
      Ui.InplaceInput.init ()
        |> Ui.InplaceInput.placeholder "Placeholder..."
  , form =
      Form.init
        { checkboxes =
            [ ( "required", 2, False )
            , ( "disabled", 3, False )
            , ( "readonly", 4, False )
            , ( "ctrl save", 5, False )
            , ( "open", 6, False )
            ]
        , textareas =
            [ ( "value", 0, "Placeholder...", "" ) ]
        , numberRanges = []
        , choosers = []
        , inputs = []
        , colors = []
        , dates = []
        }
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    InplaceInput msg ->
      let
        ( inplaceInput, cmd ) =
          Ui.InplaceInput.update msg model.inplaceInput
      in
        ( { model | inplaceInput = inplaceInput }, Cmd.map InplaceInput cmd )
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
    ( updatedForm, formCmd ) =
      Form.updateCheckbox "open" model.inplaceInput.open model.form
      |> Form.updateTextarea "value" model.inplaceInput.value
  in
    ( { model | form = updatedForm }
    , Cmd.batch [ Cmd.map Form formCmd, cmd ]
    )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    ( inplaceInput, setCmd ) =
      updatedComponent model.inplaceInput

    updatedComponent inplaceInput =
      { inplaceInput
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , required = Form.valueOfCheckbox "required" False model.form
        , ctrlSave = Form.valueOfCheckbox "ctrl save" False model.form
        , open = Form.valueOfCheckbox "open" True model.form
      }
      |> Ui.InplaceInput.setValue (Form.valueOfTextarea "value" "" model.form)

  in
    ( { model | inplaceInput = inplaceInput }
    , Cmd.batch [ cmd, Cmd.map InplaceInput setCmd ]
    )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      div
        [ class "inplace-input" ]
        [ span [] [ text "Click on the content below to edit." ]
        , Html.map InplaceInput (Ui.InplaceInput.view model.inplaceInput)
        ]
  in
    Components.Reference.view demo form
