module Reference.Button exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Chooser
import Ui.Button

import Html

type Msg
  = Form Form.Msg
  | Nothing


type alias Model =
  { button : Ui.Button.Model
  , form : Form.Model Msg
  }


sizeData : List Ui.Chooser.Item
sizeData =
  [ { id = "medium", label = "Medium", value = "medium" }
  , { id = "small",  label = "Small",  value = "small"  }
  , { id = "big",    label = "Big",    value = "big"    }
  ]


kindData : List Ui.Chooser.Item
kindData =
  [ { id = "secondary", label = "Secondary", value = "secondary" }
  , { id = "primary",   label = "Primary",   value = "primary"   }
  , { id = "sucess",    label = "Success",   value = "success"   }
  , { id = "warning",   label = "Warning",   value = "warning"   }
  , { id = "danger",    label = "Danger",    value = "danger"    }
  ]


init : Model
init =
  { button =
      { text = "Use The Force"
      , disabled = False
      , readonly = False
      , kind = "primary"
      , size = "medium"
      }
  , form =
      Form.init
        { numberRanges = []
        , textareas = []
        , colors = []
        , dates = []
        , inputs =
            [ ( "text", 2, "Text...", "Use The Force" )
            ]
        , checkboxes =
            [ ( "disabled", 3, False )
            , ( "readonly", 4, False )
            ]
        , choosers =
            [ ( "kind", 0, kindData, "", "primary" )
            , ( "size", 1, sizeData, "", "medium"  )
            ]
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

    _ ->
      ( model, Cmd.none )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    updatedComponent button =
      { button
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , kind = Form.valueOfChooser "kind" "primary" model.form
        , size = Form.valueOfChooser "size" "medium" model.form
        , text = Form.valueOfInput "text" "Test" model.form
      }
  in
    ( { model | button = updatedComponent model.button }, cmd )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map Form (Form.subscriptions model.form)


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Ui.Button.view Nothing model.button
  in
    Components.Reference.view demo form
