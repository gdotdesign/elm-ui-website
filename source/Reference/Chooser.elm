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
  { chooser : Ui.Chooser.Model
  , form : Form.Model
  }


data : List Ui.Chooser.Item
data =
  [ { label = "I - The Phantom Menace", value = "star_wars_1" }
  , { label = "II - Attack of the Clones", value = "star_wars_2" }
  , { label = "III - Revenge of the Sith", value = "star_wars_3" }
  , { label = "IV - A New Hope", value = "star_wars_4" }
  , { label = "V - The Empire Strikes Back", value = "star_wars_5" }
  , { label = "VI - Return of the Jedi", value = "star_wars_6" }
  , { label = "VII - The Force Awakens", value = "star_wars_7" }
  ]


init : Model
init =
  let
    placeholder =
      "Select a movie you will..."
  in
    { chooser = Ui.Chooser.init data placeholder ""
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
          Ui.Chooser.update act model.chooser
      in
        ( { model | chooser = chooser }, Cmd.map Chooser effect )
          |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, effect ) =
  let
    updatedForm =
      Form.updateCheckbox "open" model.chooser.open model.form
  in
    ( { model | form = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedComponent chooser =
      { chooser
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
    ( { model | chooser = updatedComponent model.chooser }, effect )


view : Model -> Html.Html Msg
view model =
  let
    demo =
      Html.App.map Chooser (Ui.Chooser.view model.chooser)

    form =
      Html.App.map Form (Form.view model.form)
  in
    Components.Reference.view demo form
