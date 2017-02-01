module Reference.Tabs exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Tabs
import Ui

import Html exposing (text)


type Msg
  = Tabs Ui.Tabs.Msg
  | Form Form.Msg


type alias Model =
  { tabs : Ui.Tabs.Model
  , form : Form.Model Msg
  }


init : Model
init =
  { tabs = Ui.Tabs.init ()
  , form =
      Form.init
        { checkboxes =
            [ ( "disabled", 2, False )
            , ( "readonly", 3, False )
            ]
        , inputs = []
        , numberRanges =
            [ ( "selected", 1, 0, "", 0, 2, 0, 0.01 )
            ]
        , textareas = []
        , choosers = []
        , colors = []
        , dates = []
        }
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Tabs act ->
      let
        ( tabs, effect ) =
          Ui.Tabs.update act model.tabs
      in
        ( { model | tabs = tabs }, Cmd.map Tabs effect )
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
      Form.updateNumberRange "selected" (toFloat model.tabs.selected) model.form
  in
    ( { model | form = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedComponent tabs =
      { tabs
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , selected = round (Form.valueOfNumberRange "selected" 0 model.form)
      }
  in
    ( { model | tabs = updatedComponent model.tabs }, effect )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map Form (Form.subscriptions model.form)


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    tabs =
      [ ( "Tab 1", text "Tab 1 Contents" )
      , ( "Tab 2", text "Tab 2 Contents" )
      , ( "Tab 3", text "Tab 3 Contents" )
      ]

    demo =
      Ui.Tabs.view { address = Tabs, contents = tabs } model.tabs
  in
    Components.Reference.view demo form
