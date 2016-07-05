module Reference.Button exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Chooser
import Ui.Button

import Html.App
import Html


type Msg
  = Form Form.Msg
  | Nothing


type alias Model =
  { button : Ui.Button.Model
  , form : Form.Model
  }


sizeData : List Ui.Chooser.Item
sizeData =
  [ { label = "Medium", value = "medium" }
  , { label = "Small", value = "small" }
  , { label = "Big", value = "big" }
  ]


kindData : List Ui.Chooser.Item
kindData =
  [ { label = "Secondary", value = "secondary" }
  , { label = "Primary", value = "primary" }
  , { label = "Success", value = "success" }
  , { label = "Warning", value = "warning" }
  , { label = "Danger", value = "danger" }
  ]


init : Model
init =
  { button =
      { text = "Sign Up Free"
      , disabled = False
      , readonly = False
      , kind = "primary"
      , size = "medium"
      }
  , form =
      Form.init
        { dates = []
        , inputs =
            [ ( "text", 2, "Text...", "Sign Up Free" )
            ]
        , checkboxes =
            [ ( "disabled", 3, False )
            , ( "readonly", 4, False )
            ]
        , choosers =
            [ ( "kind", 0, kindData, "", "primary" )
            , ( "size", 1, sizeData, "", "medium" )
            ]
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
    updatedButton button =
      { button
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , kind = Form.valueOfChooser "kind" "primary" model.form
        , size = Form.valueOfChooser "size" "medium" model.form
        , text = Form.valueOfInput "text" "Test" model.form
      }
  in
    ( { model | button = updatedButton model.button }, effect )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Html.App.map Form (Form.view model.form)

    demo =
      Ui.Button.view Nothing model.button
  in
    Components.Reference.view demo form
