module Reference.Chooser exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Helpers.Dropdown
import Ui.Chooser

import Html

type Msg
  = Chooser Ui.Chooser.Msg
  | Form Form.Msg


type alias Model =
  { chooser : Ui.Chooser.Model
  , form : Form.Model Msg
  }


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map Chooser (Ui.Chooser.subscriptions model.chooser)


data : List Ui.Chooser.Item
data =
  [ { id = "1", label = "I - The Phantom Menace",      value = "star_wars_1" }
  , { id = "2", label = "II - Attack of the Clones",   value = "star_wars_2" }
  , { id = "3", label = "III - Revenge of the Sith",   value = "star_wars_3" }
  , { id = "4", label = "IV - A New Hope",             value = "star_wars_4" }
  , { id = "5", label = "V - The Empire Strikes Back", value = "star_wars_5" }
  , { id = "6", label = "VI - Return of the Jedi",     value = "star_wars_6" }
  , { id = "7", label = "VII - The Force Awakens",     value = "star_wars_7" }
  , { id = "7", label = "VII - The Last Jedi",         value = "star_wars_8" }
  ]


init : Model
init =
  let
    placeholder =
      "Select a movie you will..."
  in
    { chooser =
        Ui.Chooser.init ()
          |> Ui.Chooser.placeholder placeholder
          |> Ui.Chooser.items data
    , form =
        Form.init
          { inputs =
              [ ( "placeholder", 0, placeholder, placeholder )
              ]
          , checkboxes =
              [ ( "close on select", 1, False )
              , ( "deselectable",    2, False )
              , ( "searchable",      3, False )
              , ( "multiple",        4, False )
              , ( "readonly",        7, False )
              , ( "disabled",        6, False )
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
    Form msg ->
      let
        ( form, cmd ) =
          Form.update msg model.form
      in
        ( { model | form = form }, Cmd.map Form cmd )
          |> updateState

    Chooser msg ->
      let
        ( chooser, cmd ) =
          Ui.Chooser.update msg model.chooser
      in
        ( { model | chooser = chooser }, Cmd.map Chooser cmd )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    updatedComponent chooser =
      { chooser
        | closeOnSelect = Form.valueOfCheckbox "close on select" False model.form
        , deselectable = Form.valueOfCheckbox "deselectable" False model.form
        , searchable = Form.valueOfCheckbox "searchable" False model.form
        , placeholder = Form.valueOfInput "placeholder" "" model.form
        , disabled = Form.valueOfCheckbox "disabled" False model.form
        , multiple = Form.valueOfCheckbox "multiple" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
      }

  in
    ( { model | chooser = updatedComponent model.chooser }, cmd )


view : Model -> Html.Html Msg
view model =
  let
    demo =
      Html.map Chooser (Ui.Chooser.view model.chooser)

    form =
      Form.view Form model.form
  in
    Components.Reference.view demo form
