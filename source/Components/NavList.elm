module Components.NavList exposing (..)

import Html.Attributes exposing (classList, href)
import Html.Events exposing (onClick)
import Html exposing (node, text)
import Html.Lazy
import Html.App

import Ui.Helpers.Emitter as Emitter
import Ui.SearchInput

import String
import Fuzzy

type alias Category =
  (String, (List Item))

type alias Item =
  { label : String
  , href : String
  }


type alias Model =
  { items : List Category
  , input : Ui.SearchInput.Model
  , prefix : String
  }


type Msg
  = Input Ui.SearchInput.Msg
  | Navigate String


init : String -> String -> List Category -> Model
init prefix placeholder items =
  { input = Ui.SearchInput.init 0 placeholder
  , prefix = prefix
  , items = items
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Navigate url ->
      ( model, Emitter.sendString "navigation" url )

    Input act ->
      let
        ( input, effect ) =
          Ui.SearchInput.update act model.input
      in
        ( { model | input = input }, Cmd.map Input effect )


match : Model -> Item -> Bool
match model item =
  let
    result =
      Fuzzy.match
        [ Fuzzy.movePenalty 500 ]
        []
        (String.toLower model.input.value)
        (String.toLower item.label)
  in
    result.score < 2000

view : String -> Model -> Html.Html Msg
view active model =
  Html.Lazy.lazy2 render active model

render : String -> Model -> Html.Html Msg
render active model =
  let
    items =
      List.map (renderCategory active model) model.items
      |> List.foldr (++) []
  in
    node "ui-nav-list"
      []
      [ Html.App.map Input (Ui.SearchInput.view model.input)
      , node "ui-nav-list-items" [] items
      ]


renderCategory : String -> Model -> (String, List Item) -> List (Html.Html Msg)
renderCategory active model (title, categoryItems) =
  let
    items =
      List.filter (match model) categoryItems
        |> List.sortBy .label
        |> List.map (renderItem active model)
  in
    if (List.isEmpty items) then
      []
    else
      [ node "ui-nav-list-category" [] [ text title ] ] ++ items


renderItem : String -> Model -> Item -> Html.Html Msg
renderItem active model item =
  let
    url =
      "/" ++ model.prefix ++ "/" ++ item.href
  in
    node "ui-nav-list-item"
      [ classList [ ( "active", active == item.href ) ]
      , onClick (Navigate url)
      ]
      [ text item.label
      ]
