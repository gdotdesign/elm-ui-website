module Reference.Tagger exposing (..)

import Components.Form as Form
import Components.Reference

import Ui.Native.Uid as Uid
import Ui.Tagger

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
  { tagger =
      Ui.Tagger.init ()
        |> Ui.Tagger.placeholder "Add a tag.."
  , tags =
      [ { label = "Vader", id = "vader" }
      , { label = "Luke",  id = "luke"  }
      ]
  , form =
      Form.init
        { checkboxes =
            [ ( "disabled",   1, False )
            , ( "readonly",   2, False )
            , ( "removeable", 3, True  )
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
  Sub.batch
    [ Ui.Tagger.onCreate AddTag model.tagger
    , Ui.Tagger.onRemove RemoveTag model.tagger
    ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Tagger msg ->
      let
        ( tagger, cmd ) =
          Ui.Tagger.update msg model.tagger
      in
        ( { model | tagger = tagger }, Cmd.map Tagger cmd )

    Form msg ->
      let
        ( form, cmd ) =
          Form.update msg model.form
      in
        ( { model | form = form }, Cmd.map Form cmd )
          |> updateState

    AddTag value ->
      let
        ( tagger, cmd ) =
          Ui.Tagger.setValue "" model.tagger

        tag =
          { label = value
          , id = Uid.uid ()
          }
      in
        ( { model
            | tags = tag :: model.tags
            , tagger = tagger
          }
        , Cmd.map Tagger cmd
        )

    RemoveTag id ->
      ( { model | tags = List.filter (\tag -> tag.id /= id) model.tags }
      , Cmd.none
      )


updateState : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateState ( model, cmd ) =
  let
    updatedComponent tagger =
      { tagger
        | removeable = Form.valueOfCheckbox "removeable" False model.form
        , disabled = Form.valueOfCheckbox "disabled" False model.form
        , readonly = Form.valueOfCheckbox "readonly" False model.form
      }
  in
    ( { model | tagger = updatedComponent model.tagger }, cmd )


view : Model -> Html.Html Msg
view model =
  let
    form =
      Form.view Form model.form

    demo =
      Html.map Tagger (Ui.Tagger.view model.tags model.tagger)
  in
    Components.Reference.view demo form
