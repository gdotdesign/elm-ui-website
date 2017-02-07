module Reference.Textarea exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Textarea

import Html


type Msg
  = Textarea Ui.Textarea.Msg
  | Form Form.Msg


type alias Model =
  { textarea : Ui.Textarea.Model
  , form : Form.Model Msg
  }


init : Model
init =
  { textarea =
      Ui.Textarea.init ()
        |> Ui.Textarea.placeholder "Placeholder..."
  , form =
      Form.init
        { checkboxes =
            [ ( "disabled", 4,      False )
            , ( "readonly", 5,      False )
            , ( "enter allowed", 3, True  )
            ]
        , inputs =
            [ ( "placeholder", 1, "Placeholder...", "Placeholder..." )
            ]
        , textareas =
            [ ( "value", 2, "Value...", "" )
            ]
        , numberRanges = []
        , choosers = []
        , colors = []
        , dates = []
        }
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Textarea msg ->
      let
        ( textarea, cmd ) =
          Ui.Textarea.update msg model.textarea
      in
        ( { model | textarea = textarea }, Cmd.map Textarea cmd )
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
      Form.updateTextarea "value" model.textarea.value model.form
  in
    ( { model | form = updatedForm }
    , Cmd.batch [ Cmd.map Form formCmd, cmd ]
    )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( ({ textarea } as model), cmd ) =
  let
    value =
      Form.valueOfTextarea "value" "" model.form

    ( updatedComponent, setCmd ) =
      { textarea
        | enterAllowed = Form.valueOfCheckbox "enter allowed" False model.form
        , disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , placeholder = Form.valueOfInput "placeholder" "" model.form
      }
      |> Ui.Textarea.setValue value
  in
    ( { model | textarea = updatedComponent }
    , Cmd.batch [ Cmd.map Textarea setCmd, cmd ]
    )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Html.map Textarea (Ui.Textarea.view model.textarea)
  in
    Components.Reference.view demo form
