module Reference.FileInput exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.FileInput

import Html exposing (div)

type Msg
  = FileInput Ui.FileInput.Msg
  | Form Form.Msg


type alias Model =
  { fileInput : Ui.FileInput.Model
  , form : Form.Model Msg
  }


init : Model
init =
  { fileInput = Ui.FileInput.init ()
  , form =
      Form.init
        { checkboxes =
            [ ( "disabled", 1, False )
            , ( "readonly", 0, False )
            ]
        , numberRanges = []
        , textareas = []
        , choosers = []
        , colors = []
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

    FileInput msg ->
      let
        ( fileInput, cmd ) =
          Ui.FileInput.update msg model.fileInput
      in
        ( { model | fileInput = fileInput }, Cmd.map FileInput cmd )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    updatedComponent component =
      { component
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
      }
  in
    ( { model | fileInput = updatedComponent model.fileInput }, cmd )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      div []
        [ Html.map FileInput (Ui.FileInput.view model.fileInput)
        , Html.map FileInput (Ui.FileInput.viewDetails model.fileInput)
        ]
  in
    Components.Reference.view demo form
