module Reference.SearchInput exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.SearchInput

import Html

type Msg
  = SearchInput Ui.SearchInput.Msg
  | Form Form.Msg


type alias Model =
  { input : Ui.SearchInput.Model
  , form : Form.Model Msg
  }


init : Model
init =
  let
    input =
      Ui.SearchInput.init ()
        |> Ui.SearchInput.placeholder "Placeholder..."
  in
    { input = input
    , form =
        Form.init
          { checkboxes =
              [ ( "disabled", 3, False )
              , ( "readonly", 4, False )
              ]
          , inputs =
              [ ( "value",       0, "Value...",       ""               )
              , ( "placeholder", 0, "Placeholder...", "Placeholder..." )
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
    SearchInput msg ->
      let
        ( input, cmd ) =
          Ui.SearchInput.update msg model.input
      in
        ( { model | input = input }, Cmd.map SearchInput cmd )
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
      Form.updateInput "value" model.input.value model.form
  in
    ( { model | form = updatedForm }
    , Cmd.batch [ Cmd.map Form formCmd, cmd ]
    )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    ( input, setCmd ) =
      updatedComponent model.input

    updatedComponent input =
      let
        updatedInput subInput =
          { subInput | placeholder = Form.valueOfInput "placeholder" "" model.form }
      in
        { input
          | disabled = Form.valueOfCheckbox "disabled" False model.form
          , readonly = Form.valueOfCheckbox "readonly" False model.form
          , input = updatedInput input.input
        } |> Ui.SearchInput.setValue (Form.valueOfInput "value" "" model.form)
  in
    ( { model | input = input }
    , Cmd.batch [ cmd, Cmd.map SearchInput setCmd ]
    )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Html.map SearchInput (Ui.SearchInput.view model.input)
  in
    Components.Reference.view demo form
