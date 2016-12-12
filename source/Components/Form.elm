module Components.Form exposing (..)

import Html exposing (node, text)
import Html.Keyed
import Html.Lazy

import Ext.Color exposing (Hsv)
import Dict exposing (Dict)
import Color
import Date

import Ui.Native.Uid as Uid
import Ui.ColorPicker
import Ui.NumberRange
import Ui.DatePicker
import Ui.Textarea
import Ui.Checkbox
import Ui.Chooser
import Ui.Button
import Ui.Input


type Msg
  = NumberRanges String Ui.NumberRange.Msg
  | DatePickers String Ui.DatePicker.Msg
  | Checkboxes String Ui.Checkbox.Msg
  | Colors String Ui.ColorPicker.Msg
  | Textareas String Ui.Textarea.Msg
  | Choosers String Ui.Chooser.Msg
  | Inputs String Ui.Input.Msg


type alias Model msg =
  { numberRanges : Dict String ( Int, Ui.NumberRange.Model )
  , checkboxes : Dict String ( Int, Ui.Checkbox.Model )
  , colors : Dict String ( Int, Ui.ColorPicker.Model )
  , textareas : Dict String (Int, Ui.Textarea.Model )
  , choosers : Dict String ( Int, Ui.Chooser.Model )
  , dates : Dict String ( Int, Ui.DatePicker.Model )
  , inputs : Dict String ( Int, Ui.Input.Model )
  , buttons : List ( Int, msg, Ui.Button.Model )
  , uid : String
  }


type alias TempModel =
  { numberRanges : List ( String, Int, Float, String, Float, Float, Int, Float )
  , choosers : List ( String, Int, List Ui.Chooser.Item, String, String )
  , textareas : List ( String, Int, String, String )
  , inputs : List ( String, Int, String, String )
  , colors : List ( String, Int, Color.Color )
  , checkboxes : List ( String, Int, Bool )
  , dates : List ( String, Int, Date.Date )
  }


init : TempModel -> Model msg
init data =
  let
    initDatePickers ( name, index, value ) =
      let
        datePicker =
          Ui.DatePicker.init ()
            |> Ui.DatePicker.setValue value
      in
        ( name, ( index, datePicker ) )

    initCheckbox ( name, index, value ) =
      let
        checkbox =
          Ui.Checkbox.init ()
            |> Ui.Checkbox.setValue value
      in
        ( name, ( index, checkbox ) )

    initChooser ( name, index, data, placeholder, value ) =
      let
        chooser =
          Ui.Chooser.init ()
            |> Ui.Chooser.items data
            |> Ui.Chooser.placeholder placeholder
            |> Ui.Chooser.setValue value
      in
        ( name, ( index, chooser ) )

    initInput ( name, index, placeholder, value ) =
      let
        ( input, inputCmd ) =
          Ui.Input.init ()
            |> Ui.Input.placeholder placeholder
            |> Ui.Input.setValue value
      in
        ( name, ( index, input ) )

    initColors ( name, index, value ) =
      let
        ( colorPicker, colorPickerCmd ) =
          Ui.ColorPicker.init ()
            |> Ui.ColorPicker.setValue value
      in
        ( name, ( index, colorPicker ) )

    initTextarea ( name, index, placeholder, value ) =
      let
        ( textarea, textareaCmd ) =
          Ui.Textarea.init ()
            |> Ui.Textarea.placeholder placeholder
            |> Ui.Textarea.setValue value
      in
        ( name, ( index, textarea ) )

    initNumberRange ( name, index, value, affix, min, max, round, step) =
      let
        ( numberRange, numberRangeCmd ) =
          Ui.NumberRange.init ()
           |> Ui.NumberRange.affix affix
           |> Ui.NumberRange.round round
           |> Ui.NumberRange.dragStep step
           |> Ui.NumberRange.min min
           |> Ui.NumberRange.max max
           |> Ui.NumberRange.setValue value
      in
        ( name, ( index, numberRange ) )
  in
    { numberRanges = Dict.fromList (List.map initNumberRange data.numberRanges)
    , checkboxes = Dict.fromList (List.map initCheckbox data.checkboxes)
    , textareas = Dict.fromList (List.map initTextarea data.textareas)
    , choosers = Dict.fromList (List.map initChooser data.choosers)
    , dates = Dict.fromList (List.map initDatePickers data.dates)
    , colors = Dict.fromList (List.map initColors data.colors)
    , inputs = Dict.fromList (List.map initInput data.inputs)
    , buttons = []
    , uid = Uid.uid ()
    }

nextPosition : Model msg -> Int
nextPosition model =
  (Dict.size model.numberRanges) +
  (Dict.size model.checkboxes) +
  (Dict.size model.textareas) +
  (Dict.size model.choosers) +
  (Dict.size model.dates) +
  (Dict.size model.colors) +
  (Dict.size model.inputs) +
  (List.length model.buttons)


button : String -> String -> msg -> Model msg -> Model msg
button text kind msg model =
  let
    button =
      { disabled = False
      , readonly = False
      , size = "medium"
      , kind = kind
      , text = text
      }
  in
    { model | buttons = (nextPosition model, msg, button) :: model.buttons }


subscriptions : Model msg -> Sub Msg
subscriptions model =
  let
    colorSub name colorPicker =
      Sub.map (Colors name) (Ui.ColorPicker.subscriptions colorPicker)

    colorSubs =
      Dict.toList model.colors
      |> List.map (\(key, (pos, colorPicker)) -> colorSub key colorPicker)

    numberRangeSub name numberRange =
      Sub.map (NumberRanges name) (Ui.NumberRange.subscriptions numberRange)

    numberRangeSubs =
      Dict.toList model.numberRanges
      |> List.map (\(key, (pos, numberRange)) -> numberRangeSub key numberRange)

  in
    Sub.batch (colorSubs ++ numberRangeSubs)

valueOfSimple :
  String
  -> value
  -> (model -> value)
  -> Dict String ( Int, model )
  -> value
valueOfSimple name default accessor dict =
  Dict.get name dict
    |> Maybe.map Tuple.second
    |> Maybe.map accessor
    |> Maybe.withDefault default


valueOfCheckbox : String -> Bool -> Model msg -> Bool
valueOfCheckbox name default model =
  valueOfSimple name default .value model.checkboxes


valueOfInput : String -> String -> Model msg -> String
valueOfInput name default model =
  valueOfSimple name default .value model.inputs


valueOfNumberRange : String -> Float -> Model msg -> Float
valueOfNumberRange name default model =
  valueOfSimple name default .value model.numberRanges


valueOfTextarea : String -> String -> Model msg -> String
valueOfTextarea name default model =
  valueOfSimple name default .value model.textareas


valueOfColor : String -> Hsv -> Model msg -> Hsv
valueOfColor name default model =
  valueOfSimple name default (\item -> item.colorPanel.value) model.colors


valueOfDate : String -> Date.Date -> Model msg -> Date.Date
valueOfDate name default model =
  valueOfSimple name default (\item -> item.calendar.value) model.dates


valueOfChooser : String -> String -> Model msg -> String
valueOfChooser name default model =
  case Dict.get name model.choosers of
    Just ( index, chooser ) ->
      Maybe.withDefault default (Ui.Chooser.getFirstSelected chooser)

    _ ->
      default

updateColor : String -> Color.Color -> Model msg -> Model msg
updateColor name value model =
  let
    updatedColor item =
      case item of
        Just ( index, colorPicker ) ->
          let
            ( updatedColorPicker, colorPickerCmd ) =
              Ui.ColorPicker.setValue value colorPicker
          in
            Just ( index, updatedColorPicker )

        _ ->
          item
  in
    { model | colors = Dict.update name updatedColor model.colors }


updateDate : String -> Date.Date -> Model msg -> Model msg
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


updateTextarea : String -> String -> Model msg -> Model msg
updateTextarea name value model =
  let
    updatedTextarea item =
      case item of
        Just ( index, input ) ->
          let
            ( updatedInput, textareaCmd ) =
              Ui.Textarea.setValue value input
          in
            Just ( index, updatedInput )

        _ ->
          item
  in
    { model | textareas = Dict.update name updatedTextarea model.textareas }


updateInput : String -> String -> Model msg -> Model msg
updateInput name value model =
  let
    updatedInput item =
      case item of
        Just ( index, input ) ->
          let
            ( updatedInput, textareaCmd ) =
              Ui.Input.setValue value input
          in
            Just ( index, updatedInput )

        _ ->
          item
  in
    { model | inputs = Dict.update name updatedInput model.inputs }


updateNumberRange : String -> Float -> Model msg -> Model msg
updateNumberRange name value model =
  let
    updatedNumberRange item =
      case item of
        Just ( index, numberRange ) ->
          let
            ( updatedInput, textareaCmd ) =
              Ui.NumberRange.setValue value numberRange
          in
            Just ( index, updatedInput )

        _ ->
          item
  in
    { model | numberRanges = Dict.update name updatedNumberRange model.numberRanges }


updateCheckbox : String -> Bool -> Model msg -> Model msg
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


update : Msg -> Model msg -> ( Model msg, Cmd Msg )
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

    Colors name act ->
      let
        ( effect, updatedColors ) =
          updateDict name act Ui.ColorPicker.update model.colors
      in
        ( { model | colors = updatedColors }
        , Cmd.map (Colors name) effect
        )

    Textareas name act ->
      let
        ( effect, updatedTextareas ) =
          updateDict name act Ui.Textarea.update model.textareas
      in
        ( { model | textareas = updatedTextareas }
        , Cmd.map (Textareas name) effect
        )

    NumberRanges name act ->
      let
        ( effect, updatedNumberRanges ) =
          updateDict name act Ui.NumberRange.update model.numberRanges
      in
        ( { model | numberRanges = updatedNumberRanges }
        , Cmd.map (NumberRanges name) effect
        )


view : (Msg -> msg) -> Model msg -> Html.Html msg
view address fields =
  let
    renderDatePicker name data =
      blockField name
        (Html.map (address << (DatePickers name)) (Ui.DatePicker.view "en_us" data))

    renderCheckbox name data =
      inlineField name
        (Html.map (address << (Checkboxes name)) (Ui.Checkbox.view data))

    renderChooser name data =
      blockField name
        (Html.map (address << (Choosers name)) (Ui.Chooser.view data))

    renderInput name data =
      blockField name
        (Html.map (address << (Inputs name)) (Ui.Input.view data))

    renderColorPicker name data =
      blockField name
        (Html.map (address << (Colors name)) (Ui.ColorPicker.view data))

    renderTextarea name data =
      blockField name
        (Html.map (address << (Textareas name)) (Ui.Textarea.view data))

    renderNumberRange name data =
      blockField name
        (Html.map (address << (NumberRanges name)) (Ui.NumberRange.view data))

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

    renderButton (index, msg, button) =
      let
        html =
          node "ui-form-block"
          []
          [ Ui.Button.view msg button
          ]
      in
        ( index, html)

    renderButtons list =
      List.map renderButton list

    renderMap fn list =
      List.map (\item -> renderList fn item) (Dict.toList list)

    items =
      ((renderMap renderCheckbox fields.checkboxes)
        ++ (renderMap (Html.Lazy.lazy2 renderColorPicker) fields.colors)
        ++ (renderMap (Html.Lazy.lazy2 renderChooser) fields.choosers)
        ++ (renderMap (Html.Lazy.lazy2 renderDatePicker) fields.dates)
        ++ (renderMap (Html.Lazy.lazy2 renderInput) fields.inputs)
        ++ (renderMap (Html.Lazy.lazy2 renderTextarea) fields.textareas)
        ++ (renderMap (Html.Lazy.lazy2 renderNumberRange) fields.numberRanges)
        ++ (renderButtons fields.buttons)
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
