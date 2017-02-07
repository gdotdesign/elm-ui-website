module Reference.Pager exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Pager

import Html.Attributes exposing (class)
import Html exposing (div, text)

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
  { pager = Ui.Pager.init ()
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
      |> Form.button "Next Page"     "primary" Next
      |> Form.button "Previous Page" "primary" Previous
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Pager msg ->
      ( { model | pager = Ui.Pager.update msg model.pager }, Cmd.none )

    Form msg ->
      let
        ( form, cmd ) = Form.update msg model.form
      in
        ( { model | form = form }, Cmd.map Form cmd )
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
updateState ( model, cmd ) =
  let
    updatedComponent pager =
      pager
  in
    ( { model | pager = updatedComponent model.pager }, cmd )


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
        { address = Pager
        , pages =
          [ div [ class "demo-page-1" ] [ text "Page 1" ]
          , div [ class "demo-page-2" ] [ text "Page 2" ]
          , div [ class "demo-page-3" ] [ text "Page 3" ]
          , div [ class "demo-page-4" ] [ text "Page 4" ]
          ]
        }
        model.pager
  in
    Components.Reference.view demo form
