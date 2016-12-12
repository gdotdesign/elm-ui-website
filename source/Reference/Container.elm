module Reference.Container exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Container
import Ui.Chooser

import Html.Attributes exposing (id)
import Html exposing (node)


type Msg
  = Form Form.Msg
  | Nothing


type alias Model =
  { container : Ui.Container.Model
  , form : Form.Model Msg
  }


directionData : List Ui.Chooser.Item
directionData =
  [ { label = "row", value = "row" }
  , { label = "column", value = "column" }
  ]


alignData : List Ui.Chooser.Item
alignData =
  [ { label = "start", value = "start" }
  , { label = "center", value = "center" }
  , { label = "space-between", value = "space-between" }
  , { label = "space-around", value = "space-around" }
  , { label = "end", value = "end" }
  ]


init : Model
init =
  { container =
      { direction = "row"
      , align = "start"
      , compact = False
      }
  , form =
      Form.init
        { checkboxes =
            [ ( "compact", 2, False )
            ]
        , choosers =
            [ ( "direction", 0, directionData, "", "row" )
            , ( "align", 1, alignData, "", "start" )
            ]
        , numberRanges = []
        , textareas = []
        , colors = []
        , inputs = []
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
    updatedComponent container =
      { container
        | direction = Form.valueOfChooser "direction" "row" model.form
        , compact = Form.valueOfCheckbox "compact" False model.form
        , align = Form.valueOfChooser "align" "stretch" model.form
      }
  in
    ( { model | container = updatedComponent model.container }, effect )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Ui.Container.view model.container
        [ id "test-container" ]
        [ node "test-box" [] []
        , node "test-box" [] []
        , node "test-box" [] []
        ]
  in
    Components.Reference.view demo form
