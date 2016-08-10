module Reference.Pager exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Pager

import Html.Attributes exposing (class)
import Html exposing (div, text)
import Html.App


type Msg
  = Pager Ui.Pager.Msg
  | Form Form.Msg
  | Previous
  | Next


type alias Model =
  { pager : Ui.Pager.Model
  , form : Form.Model Msg
  }


init : Model
init =
  let
    pager = Ui.Pager.init 0
  in
    { pager = {
        pager
        | width = "460px"
        , height = "200px"
      }
    , form =
        Form.init
          { numberRanges = []
          , checkboxes = []
          , textareas = []
          , choosers = []
          , colors = []
          , inputs = []
          , dates = []
          }
        |> Form.button "Next Page" "primary" 0 Next
        |> Form.button "Previous Page" "primary" 0 Previous
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Pager act ->
      ( { model | pager = Ui.Pager.update act model.pager }, Cmd.none )

    Form act ->
      let
        ( form, effect ) = Form.update act model.form
      in
        ( { model | form = form }, Cmd.map Form effect )
          |> updateState

    Next ->
      let
        page = clamp 0 3 (model.pager.active + 1)
      in
        ( { model | pager = Ui.Pager.select page model.pager }, Cmd.none )

    Previous ->
      let
        page = clamp 0 3 (model.pager.active - 1)
      in
        ( { model | pager = Ui.Pager.select page model.pager }, Cmd.none )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedComponent pager =
      pager
  in
    ( { model | pager = updatedComponent model.pager }, effect )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map Form (Form.subscriptions model.form)


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Ui.Pager.view
        Pager
        [ div [ class "demo-page-1" ] [ text "Page 1" ]
        , div [ class "demo-page-2" ] [ text "Page 2" ]
        , div [ class "demo-page-3" ] [ text "Page 3" ]
        , div [ class "demo-page-4" ] [ text "Page 4" ]
        ]
        model.pager
  in
    Components.Reference.view demo form
