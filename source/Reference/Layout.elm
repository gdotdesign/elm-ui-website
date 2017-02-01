module Reference.Layout exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Chooser
import Ui.Layout

import Html exposing (text)


type Msg
  = Form Form.Msg


type alias Model =
  { form : Form.Model Msg
  }


viewData : List Ui.Chooser.Item
viewData =
  [ { id = "app", label = "App", value = "app" }
  , { id = "website", label = "Website", value = "website" }
  , { id = "sidebar", label = "Sidebar", value = "sidebar" }
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
            [ ( "view", 0, viewData, "", "app" )
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
      Form.view Form model.form

    demo =
      case Form.valueOfChooser "view" "default" model.form of
        "sidebar" ->
          Ui.Layout.sidebar
            [ text "SIDEBAR" ]
            [ text "CONTENT" ]

        "website" ->
          Ui.Layout.website
            [ text "HEADER" ]
            [ text "CONTENT" ]
            [ text "FOOTER" ]

        _ ->
          Ui.Layout.app
            [ text "SIDEBAR" ]
            [ text "TOOLBAR" ]
            [ text "CONTENT" ]
  in
    Components.Reference.view demo form
