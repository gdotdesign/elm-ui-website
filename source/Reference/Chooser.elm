module Reference.Chooser exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Chooser

import Html.App
import Html


type Msg
  = Chooser Ui.Chooser.Msg
  | Form Form.Msg


type alias Model =
  { model : Ui.Chooser.Model
  , form : Form.Model
  }


data : List Ui.Chooser.Item
data =
  [ { label = "Star Wars: Episode I", value = "star_wars_1" }
  , { label = "Star Wars: Episode II", value = "star_wars_2" }
  , { label = "Star Wars: Episode III", value = "star_wars_3" }
  , { label = "Star Wars: Episode IV", value = "star_wars_4" }
  , { label = "Star Wars: Episode V", value = "star_wars_5" }
  , { label = "Star Wars: Episode VI", value = "star_wars_6" }
  , { label = "Star Wars: Episode VII", value = "star_wars_7" }
  ]


init : Model
init =
  let
    placeholder =
      "Select a movie you will..."
  in
    { model = Ui.Chooser.init data placeholder ""
    , form =
        Form.init
          { inputs =
              [ ( "placeholder", 0, placeholder, placeholder )
              ]
          , checkboxes =
              [ ( "closeOnSelect", 1, False )
              , ( "deselectable", 2, False )
              , ( "searchable", 3, False )
              , ( "multiple", 4, False )
              , ( "readonly", 7, False )
              , ( "disabled", 6, False )
              , ( "open", 5, False )
              ]
          , choosers = []
          , colors = []
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

    Chooser act ->
      let
        ( chooser, effect ) =
          Ui.Chooser.update act model.model
      in
        ( { model | model = chooser }, Cmd.map Chooser effect )
          |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, effect ) =
  let
    updatedForm =
      Form.updateCheckbox "open" model.model.open model.form
  in
    ( { model | form = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedButton button =
      { button
        | closeOnSelect = Form.valueOfCheckbox "closeOnSelect" False model.form
        , deselectable = Form.valueOfCheckbox "deselectable" False model.form
        , searchable = Form.valueOfCheckbox "searchable" False model.form
        , placeholder = Form.valueOfInput "placeholder" "" model.form
        , disabled = Form.valueOfCheckbox "disabled" False model.form
        , multiple = Form.valueOfCheckbox "multiple" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , open = Form.valueOfCheckbox "open" False model.form
      }
  in
    ( { model | model = updatedButton model.model }, effect )


view : Model -> Html.Html Msg
view model =
  let
    demo =
      Html.App.map Chooser (Ui.Chooser.view model.model)

    form =
      Html.App.map Form (Form.view model.form)
  in
    Components.Reference.view demo form
