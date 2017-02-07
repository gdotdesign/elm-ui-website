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
  [ { id = "row",    label = "row",    value = "row"    }
  , { id = "column", label = "column", value = "column" }
  ]


alignData : List Ui.Chooser.Item
alignData =
  [ { id = "start",   label = "start",         value = "start"         }
  , { id = "center",  label = "center",        value = "center"        }
  , { id = "between", label = "space-between", value = "space-between" }
  , { id = "around",  label = "space-around",  value = "space-around"  }
  , { id = "end",     label = "end",           value = "end"           }
  ]


init : Model
init =
  { container =
      { direction = "row"
      , compact = False
      , align = "start"
      }
  , form =
      Form.init
        { checkboxes =
            [ ( "compact", 2, False )
            ]
        , choosers =
            [ ( "direction", 0, directionData, "", "row"   )
            , ( "align",     1, alignData,     "", "start" )
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


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map Form (Form.subscriptions model.form)


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
