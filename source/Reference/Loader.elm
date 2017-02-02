module Reference.Loader exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Chooser
import Ui.Loader

import Html exposing (text)

type Msg
  = Loader Ui.Loader.Msg
  | Form Form.Msg


type alias Model =
  { loader : Ui.Loader.Model
  , form : Form.Model Msg
  }


init : Model
init =
  let
    loader =
      Ui.Loader.init ()
      |> Ui.Loader.timeout 200
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
  [ { id = "bar",     label = "Bar",     value = "bar"     }
  , { id = "overlay", label = "Overlay", value = "overlay" }
  ]


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

    _ ->
      ( model, Cmd.none )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    updatedComponent loader =
      loader
  in
    ( { model | loader = updatedComponent model.loader }, cmd )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

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
