module Reference.Layout exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Chooser
import Ui.Layout

import Html exposing (text)
import Html.App


type Msg
  = Form Form.Msg


type alias Model =
  { form : Form.Model
  }


viewData : List Ui.Chooser.Item
viewData =
  [ { label = "Center Default", value = "centerDefault" }
  , { label = "Default", value = "default" }
  , { label = "Sidebar", value = "sidebar" }
  ]


init : Model
init =
  { form =
      Form.init
        { numberRanges = []
        , checkboxes = []
        , textareas = []
        , inputs = []
        , colors = []
        , dates = []
        , choosers =
            [ ( "view", 0, viewData, "", "default" )
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


view : Model -> Html.Html Msg
view model =
  let
    form =
      Html.App.map Form (Form.view model.form)

    demo =
      case Form.valueOfChooser "view" "default" model.form of
        "sidebar" ->
          Ui.Layout.sidebar [ text "SIDEBAR" ]
            [ text "CONTENT" ]

        "centerDefault" ->
          Ui.Layout.centerDefault [ text "HEADER" ]
            [ text "CONTENT" ]
            [ text "FOOTER" ]

        _ ->
          Ui.Layout.default [ text "HEADER" ]
            [ text "CONTENT" ]
            [ text "FOOTER" ]
  in
    Components.Reference.view demo form
