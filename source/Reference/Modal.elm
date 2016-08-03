module Reference.Modal exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Container
import Ui.Button
import Ui.Modal

import Html exposing (text)
import Html.App


type alias Model =
  { modal : Ui.Modal.Model
  , form : Form.Model
  }


type Msg
  = Modal Ui.Modal.Msg
  | Form Form.Msg
  | Close
  | Open


init : Model
init =
  { modal = Ui.Modal.init
  , form =
      Form.init
        { checkboxes =
            [ ( "closeable", 1, True )
            , ( "backdrop", 2, True )
            , ( "open", 3, False )
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
update action model =
  case action of
    Close ->
      ( { model | modal = Ui.Modal.close model.modal }, Cmd.none )
        |> updateForm

    Open ->
      ( { model | modal = Ui.Modal.open model.modal }, Cmd.none )
        |> updateForm

    Modal act ->
      ( { model | modal = Ui.Modal.update act model.modal }, Cmd.none )
        |> updateForm

    Form act ->
      let
        ( form, effect ) =
          Form.update act model.form
      in
        ( { model | form = form }, Cmd.map Form effect )
          |> updateState


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, effect ) =
  let
    updatedForm =
      Form.updateCheckbox "open" model.modal.open model.form
  in
    ( { model | form = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedComponent modal =
      { modal
        | closeable = Form.valueOfCheckbox "closeable" False model.form
        , backdrop = Form.valueOfCheckbox "backdrop" False model.form
        , open = Form.valueOfCheckbox "open" False model.form
      }
  in
    ( { model | modal = updatedComponent model.modal }, effect )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Html.App.map Form (Form.view model.form)

    viewModel =
      { content = [ text "This is the content of the modal..." ]
      , title = "Modal"
      , footer =
          [ Ui.Container.rowEnd [] [ Ui.Button.primary "Close" Close ]
          ]
      }

    demo =
      Html.div []
        [ Ui.Modal.view Modal viewModel model.modal
        , Ui.Button.primary "Open Modal" Open
        ]
  in
    Components.Reference.view demo form
