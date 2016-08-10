module Reference.IconButton exposing (..)

import Reference.Button exposing (sizeData, kindData)

import Components.Form as Form
import Components.Reference

import Ui.IconButton
import Ui.Chooser

import Html.App
import Html


type Msg
  = Form Form.Msg
  | Nothing


type alias Model =
  { iconButton : Ui.IconButton.Model
  , form : Form.Model Msg
  }

glyphData : List Ui.Chooser.Item
glyphData =
  [ { label = "Plus", value = "plus" }
  , { label = "Checkmark", value = "checkmark" }
  , { label = "Close Circled", value = "close-circled" }
  , { label = "Heart", value = "heart" }
  ]

sideData : List Ui.Chooser.Item
sideData =
  [ { label = "Left", value = "left" }
  , { label = "Right", value = "right" }
  ]

init : Model
init =
  { iconButton =
      { text = "Add Document"
      , disabled = False
      , readonly = False
      , kind = "primary"
      , size = "medium"
      , glyph = "plus"
      , side = "left"
      }
  , form =
      Form.init
        { inputs =
            [ ( "text", 2, "Text...", "Add Document" )
            ]
        , checkboxes =
            [ ( "disabled", 3, False )
            , ( "readonly", 4, False )
            ]
        , choosers =
            [ ( "kind", 0, kindData, "", "primary" )
            , ( "size", 1, sizeData, "", "medium" )
            , ( "glyph", 2, glyphData, "", "plus")
            , ( "side", 2, sideData, "", "left")
            ]
        , numberRanges = []
        , textareas = []
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

    _ ->
      ( model, Cmd.none )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedComponent iconButton =
      { iconButton
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , kind = Form.valueOfChooser "kind" "primary" model.form
        , size = Form.valueOfChooser "size" "medium" model.form
        , glyph = Form.valueOfChooser "glyph" "plus" model.form
        , side = Form.valueOfChooser "side" "left" model.form
        , text = Form.valueOfInput "text" "Test" model.form
      }
  in
    ( { model | iconButton = updatedComponent model.iconButton }, effect )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Ui.IconButton.view Nothing model.iconButton
  in
    Components.Reference.view demo form
