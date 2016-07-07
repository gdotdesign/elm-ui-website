module Reference.FileInput exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.FileInput

import Html exposing (div)
import Html.App


type Msg
  = FileInput Ui.FileInput.Msg
  | Form Form.Msg


type alias Model =
  { fileInput : Ui.FileInput.Model
  , form : Form.Model
  }


init : Model
init =
  { fileInput = Ui.FileInput.init "*"
  , form =
      Form.init
        { checkboxes =
            [ ( "disabled", 1, False )
            , ( "readonly", 0, False )
            ]
        , choosers = []
        , colors = []
        , inputs = []
        , dates = []
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

    FileInput act ->
      let
        ( fileInput, effect ) =
          Ui.FileInput.update act model.fileInput
      in
        ( { model | fileInput = fileInput }, Cmd.map FileInput effect )


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, effect ) =
  ( model, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedComponent component =
      { component
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
      }
  in
    ( { model | fileInput = updatedComponent model.fileInput }, effect )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Html.App.map Form (Form.view model.form)

    demo =
      div []
        [ Html.App.map FileInput (Ui.FileInput.view model.fileInput)
        , Html.App.map FileInput (Ui.FileInput.viewDetails model.fileInput)
        ]
  in
    Components.Reference.view demo form
