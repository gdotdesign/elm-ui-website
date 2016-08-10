module Reference.Ratings exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Ratings

import Html exposing (text)
import Html.App


type Msg
  = Ratings Ui.Ratings.Msg
  | Form Form.Msg


type alias Model =
  { ratings : Ui.Ratings.Model
  , form : Form.Model Msg
  }


init : Model
init =
  { ratings = Ui.Ratings.init 5 0.5
  , form =
      Form.init
        { numberRanges =
            [ ( "value", 1, 0.5, "", 0, 1, 2, 0.05 )
            , ( "size", 2, 5, "", 0, 10, 0, 0.05 )
            ]
        , textareas = []
        , colors = []
        , dates = []
        , inputs = []
        , checkboxes =
            [ ( "disabled", 7, False )
            , ( "readonly", 8, False )
            , ( "clearable", 9, False )
            ]
        , choosers =
            []
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

    Ratings act ->
      let
        ( ratings, effect ) =
          Ui.Ratings.update act model.ratings
      in
        ( { model | ratings = ratings }, Cmd.map Ratings effect )
          |> updateForm


updateForm : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm ( model, effect ) =
  let
    updatedForm =
      Form.updateNumberRange "value" model.ratings.value model.form
  in
    ( { model | form = updatedForm }, effect )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    value =
      Form.valueOfNumberRange "value" 0 model.form

    updatedComponent ratings =
      { ratings
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , clearable = Form.valueOfCheckbox "clearable" False model.form
        , size = round (Form.valueOfNumberRange "size" 0 model.form)
      }
      |> Ui.Ratings.setValue value
  in
    ( { model | ratings = updatedComponent model.ratings }, effect )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map Form (Form.subscriptions model.form)
    ]


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Html.App.map Ratings (Ui.Ratings.view model.ratings)
  in
    Components.Reference.view demo form
