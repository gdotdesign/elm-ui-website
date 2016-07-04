module Components.Form exposing (..)

import Html exposing (node, text)
import Html.Keyed
import Html.App

import Dict exposing (Dict)
import Date

import Ui.DatePicker
import Ui.Checkbox
import Ui.Chooser
import Ui.Input


type Msg
  = DatePickers String Ui.DatePicker.Msg
  | Checkboxes String Ui.Checkbox.Msg
  | Choosers String Ui.Chooser.Msg
  | Inputs String Ui.Input.Msg


type alias Model =
  { checkboxes : Dict String ( Int, Ui.Checkbox.Model )
  , choosers : Dict String ( Int, Ui.Chooser.Model )
  , dates : Dict String ( Int, Ui.DatePicker.Model )
  , inputs : Dict String ( Int, Ui.Input.Model )
  , uid : String
  }


type alias TempModel =
  { choosers : List ( String, Int, List Ui.Chooser.Item, String, String )
  , inputs : List ( String, Int, String, String )
  , checkboxes : List ( String, Int, Bool )
  , dates : List ( String, Int, Date.Date )
  }


init : TempModel -> Model
init data =
  let
    initDatePickers ( name, index, date ) =
      ( name, ( index, Ui.DatePicker.init date ) )

    initCheckbox ( name, index, value ) =
      ( name, ( index, Ui.Checkbox.init value ) )

    initChooser ( name, index, data, placeholder, value ) =
      ( name, ( index, Ui.Chooser.init data placeholder value ) )

    initInput ( name, index, placeholder, value ) =
      ( name, ( index, Ui.Input.init value placeholder ) )
  in
    { checkboxes = Dict.fromList (List.map initCheckbox data.checkboxes)
    , choosers = Dict.fromList (List.map initChooser data.choosers)
    , dates = Dict.fromList (List.map initDatePickers data.dates)
    , inputs = Dict.fromList (List.map initInput data.inputs)
    , uid = Native.Uid.uid ()
    }


valueOfSimple :
  String
  -> value
  -> (model -> value)
  -> Dict String ( Int, model )
  -> value
valueOfSimple name default accessor dict =
  Dict.get name dict
    |> Maybe.map snd
    |> Maybe.map accessor
    |> Maybe.withDefault default


valueOfCheckbox : String -> Bool -> Model -> Bool
valueOfCheckbox name default model =
  valueOfSimple name default .value model.checkboxes


valueOfInput : String -> String -> Model -> String
valueOfInput name default model =
  valueOfSimple name default .value model.inputs


valueOfDate : String -> Date.Date -> Model -> Date.Date
valueOfDate name default model =
  valueOfSimple name default (\item -> item.calendar.value) model.dates


valueOfChooser : String -> String -> Model -> String
valueOfChooser name default model =
  case Dict.get name model.choosers of
    Just ( index, chooser ) ->
      Maybe.withDefault default (Ui.Chooser.getFirstSelected chooser)

    _ ->
      default


updateDate : String -> Date.Date -> Model -> Model
updateDate name value model =
  let
    updatedDate item =
      case item of
        Just ( index, datepicker ) ->
          Just ( index, Ui.DatePicker.setValue value datepicker )

        _ ->
          item
  in
    { model | dates = Dict.update name updatedDate model.dates }


updateCheckbox : String -> Bool -> Model -> Model
updateCheckbox name value model =
  let
    updatedCheckbox item =
      case item of
        Just ( index, checkbox ) ->
          Just ( index, Ui.Checkbox.setValue value checkbox )

        _ ->
          item
  in
    { model | checkboxes = Dict.update name updatedCheckbox model.checkboxes }


updateDict :
  String
  -> msg
  -> (msg -> model -> ( model, Cmd msg ))
  -> Dict String ( Int, model )
  -> ( Cmd msg, Dict String ( Int, model ) )
updateDict name act fn dict =
  case Dict.get name dict of
    Just ( index, value ) ->
      let
        ( updateValue, effect ) =
          fn act value
      in
        ( effect, Dict.insert name ( index, updateValue ) dict )

    Nothing ->
      ( Cmd.none, dict )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    DatePickers name act ->
      let
        ( effect, updatedDatePickers ) =
          updateDict name act Ui.DatePicker.update model.dates
      in
        ( { model | dates = updatedDatePickers }
        , Cmd.map (DatePickers name) effect
        )

    Checkboxes name act ->
      let
        ( effect, updatedCheckboxes ) =
          updateDict name act Ui.Checkbox.update model.checkboxes
      in
        ( { model | checkboxes = updatedCheckboxes }
        , Cmd.map (Checkboxes name) effect
        )

    Choosers name act ->
      let
        ( effect, updatedChoosers ) =
          updateDict name act Ui.Chooser.update model.choosers
      in
        ( { model | choosers = updatedChoosers }
        , Cmd.map (Choosers name) effect
        )

    Inputs name act ->
      let
        ( effect, updatedInputs ) =
          updateDict name act Ui.Input.update model.inputs
      in
        ( { model | inputs = updatedInputs }
        , Cmd.map (Inputs name) effect
        )


view : Model -> Html.Html Msg
view fields =
  let
    renderDatePicker name data =
      blockField name
        (Html.App.map (DatePickers name) (Ui.DatePicker.view "en_us" data))

    renderCheckbox name data =
      inlineField name
        (Html.App.map (Checkboxes name) (Ui.Checkbox.view data))

    renderChooser name data =
      blockField name
        (Html.App.map (Choosers name) (Ui.Chooser.view data))

    renderInput name data =
      blockField name
        (Html.App.map (Inputs name) (Ui.Input.view data))

    blockField name child =
      node "ui-form-block"
        []
        [ node "ui-form-label" [] [ text name ]
        , child
        ]

    inlineField name child =
      node "ui-form-inline"
        []
        [ child
        , node "ui-form-label" [] [ text name ]
        ]

    renderList fn ( name, ( index, data ) ) =
      ( index, fn name data )

    renderMap fn list =
      List.map (\item -> renderList fn item) (Dict.toList list)

    items =
      ((renderMap renderCheckbox fields.checkboxes)
        ++ (renderMap renderChooser fields.choosers)
        ++ (renderMap renderDatePicker fields.dates)
        ++ (renderMap renderInput fields.inputs)
      )

    sortedItems =
      List.sortWith (\( a, _ ) ( b, _ ) -> compare a b) items
        |> List.map (\( key, value ) -> ( fields.uid ++ (toString key), value ))
  in
    node "ui-form"
      []
      [ node "ui-form-title" [] [ text "Fields" ]
      , Html.Keyed.node "ui-form-fields" [] sortedItems
      ]
