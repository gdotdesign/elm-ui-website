module Reference.Loader exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Chooser
import Ui.Loader

import Html exposing (text)
import Html.App


type Msg
  = Loader Ui.Loader.Msg
  | Form Form.Msg


type alias Model =
  { loader : Ui.Loader.Model
  , form : Form.Model
  }


init : Model
init =
  let
    loader =
      Ui.Loader.init 200
  in
    { loader = { loader | loading = True, shown = True }
    , form =
        Form.init
          { numberRanges = []
          , checkboxes = []
          , textareas = []
          , inputs = []
          , colors = []
          , dates = []
          , choosers =
              [ ( "view", 0, viewData, "", "bar" )
              ]
          }
    }


viewData : List Ui.Chooser.Item
viewData =
  [ { label = "Bar", value = "bar" }
  , { label = "Overlay", value = "overlay" }
  ]


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

    _ ->
      ( model, Cmd.none )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedComponent loader =
      loader
  in
    ( { model | loader = updatedComponent model.loader }, effect )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Html.App.map Form (Form.view model.form)

    demo =
      case Form.valueOfChooser "view" "bar" model.form of
        "bar" ->
          Ui.Loader.barView model.loader

        "overlay" ->
          Ui.Loader.overlayView model.loader

        _ ->
          text ""
  in
    Components.Reference.view demo form
