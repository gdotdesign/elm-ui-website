module Reference.Tagger exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Native.Uid as Uid
import Ui.Tagger

import Html.App
import Html


type Msg
  = Tagger Ui.Tagger.Msg
  | RemoveTag String
  | AddTag String
  | Form Form.Msg


type alias Model =
  { tagger : Ui.Tagger.Model
  , tags : List Ui.Tagger.Tag
  , form : Form.Model Msg
  }


init : Model
init =
  { tagger = Ui.Tagger.init "Add a tag.."
  , tags =
      [ { label = "Vader", id = "vader" }
      , { label = "Luke", id = "luke" }
      ]
  , form =
      Form.init
        { checkboxes =
            [ ( "disabled", 1, False )
            , ( "readonly", 2, False )
            , ( "removeable", 3, True )
            ]
        , numberRanges = []
        , textareas = []
        , choosers = []
        , inputs = []
        , colors = []
        , dates = []
        }
  }


subscriptions : Model -> Sub Msg
subscriptions model =
  Ui.Tagger.subscribe AddTag RemoveTag model.tagger


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Tagger act ->
      let
        ( tagger, effect ) =
          Ui.Tagger.update act model.tagger
      in
        ( { model | tagger = tagger }, Cmd.map Tagger effect )

    Form act ->
      let
        ( form, effect ) =
          Form.update act model.form
      in
        ( { model | form = form }, Cmd.map Form effect )
          |> updateState

    AddTag value ->
      let
        tag =
          { label = value
          , id = Uid.uid ()
          }
      in
        ( { model
            | tags = tag :: model.tags
            , tagger = Ui.Tagger.setValue "" model.tagger
          }
        , Cmd.none
        )

    RemoveTag id ->
      ( { model | tags = List.filter (\tag -> tag.id /= id) model.tags }
      , Cmd.none
      )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, effect ) =
  let
    updatedComponent tagger =
      { tagger
        | disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
        , removeable = Form.valueOfCheckbox "removeable" False model.form
      }
  in
    ( { model | tagger = updatedComponent model.tagger }, effect )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Html.App.map Tagger (Ui.Tagger.view model.tags model.tagger)
  in
    Components.Reference.view demo form
