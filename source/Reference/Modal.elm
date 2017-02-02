module Reference.Modal exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Container
import Ui.Button
import Ui.Modal

import Html exposing (text)

type alias Model =
  { modal : Ui.Modal.Model
  , form : Form.Model Msg
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
            [ ( "closable", 1, True  )
            , ( "backdrop", 2, True  )
            , ( "open",     3, False )
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
    Close ->
      ( { model | modal = Ui.Modal.close model.modal }, Cmd.none )
        |> updateForm

    Open ->
      ( { model | modal = Ui.Modal.open model.modal }, Cmd.none )
        |> updateForm

    Modal msg ->
      ( { model | modal = Ui.Modal.update msg model.modal }, Cmd.none )
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
      Form.updateCheckbox "open" model.modal.open model.form
  in
    ( { model | form = updatedForm }, cmd )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    updatedComponent modal =
      { modal
        | closable = Form.valueOfCheckbox "closable" False model.form
        , backdrop = Form.valueOfCheckbox "backdrop" False model.form
        , open = Form.valueOfCheckbox "open" False model.form
      }
  in
    ( { model | modal = updatedComponent model.modal }, cmd )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    viewModel =
      { contents = [ text "This is the content of the modal..." ]
      , title = "Modal"
      , address = Modal
      , footer =
          [ Ui.Container.rowEnd []
            [ Ui.Button.view Close
              { disabled = False
              , readonly = False
              , kind = "primary"
              , size = "medium"
              , text = "Close"
              }
            ]
          ]
      }

    demo =
      Html.div []
        [ Ui.Modal.view viewModel model.modal
        , Ui.Button.view Open
          { disabled = False
          , readonly = False
          , text = "Open Modal"
          , kind = "primary"
          , size = "medium"
          }
        ]
  in
    Components.Reference.view demo form
