module Reference.ButtonGroup exposing (..)

import Reference.Button exposing (sizeData, kindData)

import Components.Form as Form
import Components.Reference

import Ui.ButtonGroup

import Html

type Msg
  = Form Form.Msg
  | Nothing


type alias Model =
  { buttonGroup : Ui.ButtonGroup.Model Msg
  , form : Form.Model Msg
  }


init : Model
init =
  { buttonGroup =
      { items =
          [ ( "Yoda",        Nothing )
          , ( "Obi-Wan",     Nothing )
          , ( "Darth Vader", Nothing )
          ]
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
            [ ( "first",  2, "Text...", "Yoda"        )
            , ( "second", 3, "Text...", "Obi-Wan"     )
            , ( "third",  4, "Text...", "Darth Vader" )
            ]
        , checkboxes =
            [ ( "disabled", 5, False )
            , ( "readonly", 6, False )
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
    updatedComponent buttonGroup =
      { buttonGroup
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , kind = Form.valueOfChooser "kind" "primary" model.form
        , size = Form.valueOfChooser "size" "medium" model.form
        , items =
            [ ( Form.valueOfInput "first"  "" model.form, Nothing )
            , ( Form.valueOfInput "second" "" model.form, Nothing )
            , ( Form.valueOfInput "third"  "" model.form, Nothing )
            ]
      }
  in
    ( { model | buttonGroup = updatedComponent model.buttonGroup }, cmd )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map Form (Form.subscriptions model.form)


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Ui.ButtonGroup.view model.buttonGroup
  in
    Components.Reference.view demo form
