module Reference.Form exposing (..)

import Html exposing (node, div, text)
import Html.App

import Dict exposing (Dict)

import Ui.Checkbox
import Ui.Chooser
import Ui.Input

type Msg
  = Checkboxes String Ui.Checkbox.Msg
  | Choosers String Ui.Chooser.Msg
  | Inputs String Ui.Input.Msg

type alias Model =
  { checkboxes : Dict String (Int, Ui.Checkbox.Model)
  , choosers : Dict String (Int, Ui.Chooser.Model)
  , inputs : Dict String (Int, Ui.Input.Model)
  }

type alias TempModel =
  { checkboxes : List (String, Int, Bool)
  , choosers : List (String, Int, List Ui.Chooser.Item, String, String)
  , inputs : List (String, Int, String, String)
  }

{-- Initializers --}
init : TempModel -> Model
init data =
  let
    initCheckbox (name, index, value) =
      (name, (index, Ui.Checkbox.init value))

    initChooser (name, index, data, placeholder, value) =
      (name, (index, Ui.Chooser.init data placeholder value))

    initInput (name, index, placeholder, value) =
      (name, (index, Ui.Input.init value placeholder))
  in
    { checkboxes = Dict.fromList (List.map initCheckbox data.checkboxes)
    , choosers = Dict.fromList (List.map initChooser data.choosers)
    , inputs = Dict.fromList (List.map initInput data.inputs)
    }

{-- Values --}
valueOfSimple : String -> a -> (b -> a) -> Dict String (Int, b) -> a
valueOfSimple name default accessor dict =
  case Dict.get name dict of
    Just (index, checkbox) -> accessor checkbox
    _ -> default

valueOfCheckbox : String -> Bool -> Model -> Bool
valueOfCheckbox name default model =
  valueOfSimple name default .value model.checkboxes

valueOfInput : String -> String -> Model -> String
valueOfInput name default model =
  valueOfSimple name default .value model.inputs

valueOfChooser : String -> String -> Model -> String
valueOfChooser name default model =
  case Dict.get name model.choosers of
    Just (index, chooser) ->
      Maybe.withDefault default (Ui.Chooser.getFirstSelected chooser)
    _ -> default

updateCheckbox : String -> Bool -> Model -> Model
updateCheckbox name value model =
  let
    updatedCheckbox item =
      case item of
        Just (index, checkbox) -> Just (index, Ui.Checkbox.setValue value checkbox)
        _ -> item
  in
    { model | checkboxes = Dict.update name updatedCheckbox model.checkboxes }

updateDict name act fn dict =
  case Dict.get name dict of
    Just (index, value) ->
      let
        (updateValue, effect) = fn act value
      in
        (effect, Dict.insert name (index, updateValue) dict)
    Nothing ->
      (Cmd.none, dict)

{-- Update --}
update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    Checkboxes name act ->
      let
        (effect, updatedCheckboxes) =
          updateDict name act Ui.Checkbox.update model.checkboxes
      in
        ( { model | checkboxes = updatedCheckboxes }
        , Cmd.map (Checkboxes name) effect)
    Choosers name act ->
      let
        (effect, updatedChoosers) =
          updateDict name act Ui.Chooser.update model.choosers
      in
        ( { model | choosers = updatedChoosers }
        , Cmd.map (Choosers name) effect)
    Inputs name act ->
      let
        (effect, updatedInputs) =
          updateDict name act Ui.Input.update model.inputs
      in
        ( { model | inputs = updatedInputs }
        , Cmd.map (Inputs name) effect)

{-- View --}
view : Model -> Html.Html Msg
view fields =
  let
    renderCheckbox name data =
      inlineField
        name
        (Html.App.map (Checkboxes name) (Ui.Checkbox.view data))

    renderChooser name data =
      blockField
        name
        (Html.App.map (Choosers name) (Ui.Chooser.view data))

    renderInput name data =
      blockField
        name
        (Html.App.map (Inputs name) (Ui.Input.view data))

    blockField name child =
      node "ui-form-block" []
        [ node "ui-form-label" [] [text name]
        , child
        ]

    inlineField name child =
      node "ui-form-inline" []
        [ child
        , node "ui-form-label" [] [text name]
        ]

    renderList fn (name, (index, data)) =
      (index, fn name data)

    renderMap fn list =
      List.map (\item -> renderList fn item) (Dict.toList list)

    items =
      ((renderMap renderCheckbox fields.checkboxes)
      ++ (renderMap renderChooser fields.choosers)
      ++ (renderMap renderInput fields.inputs))

    sortedItems =
      List.sortWith (\(a, _) (b, _) -> compare a b) items
        |> List.map snd
  in
    node "ui-form" [] sortedItems
