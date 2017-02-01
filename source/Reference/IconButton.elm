module Reference.IconButton exposing (..)

import Reference.Button exposing (sizeData, kindData)

import Components.Form as Form
import Components.Reference

import Ui.IconButton
import Ui.Chooser
import Ui.Icons

import Html


type Msg
  = Form Form.Msg
  | Nothing


type alias Model =
  { iconButton : Ui.IconButton.Model Msg
  , form : Form.Model Msg
  }

glyphData : List Ui.Chooser.Item
glyphData =
  [ { id = "plus", label = "Plus", value = "plus" }
  , { id = "checkmark", label = "Checkmark", value = "checkmark" }
  , { id = "close", label = "Close", value = "close" }
  , { id = "star", label = "Star", value = "star" }
  ]

sideData : List Ui.Chooser.Item
sideData =
  [ { id = "left", label = "Left", value = "left" }
  , { id = "right", label = "Right", value = "right" }
  ]

init : Model
init =
  { iconButton =
      { text = "Add Document"
      , disabled = False
      , readonly = False
      , kind = "primary"
      , size = "medium"
      , glyph = Ui.Icons.plus []
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
    glyph =
      case Form.valueOfChooser "glyph" "plus" model.form of
        "checkmark" -> Ui.Icons.checkmark []
        "star" -> Ui.Icons.starFull []
        "close" -> Ui.Icons.close []
        _ -> Ui.Icons.plus []

    updatedComponent iconButton =
      { iconButton
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , kind = Form.valueOfChooser "kind" "primary" model.form
        , size = Form.valueOfChooser "size" "medium" model.form
        , side = Form.valueOfChooser "side" "left" model.form
        , text = Form.valueOfInput "text" "Test" model.form
        , glyph = glyph
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
