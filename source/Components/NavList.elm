module Components.NavList exposing (..)

import Html.Attributes exposing (classList, href)
import Html.Events exposing (onClick)
import Html exposing (node, text)
import Html.App
import Ui.Helpers.Emitter as Emitter
import Ui.SearchInput
import Fuzzy


type alias Item =
  { label : String
  , href : String
  }


type alias Model =
  { items : List Item
  , input : Ui.SearchInput.Model
  , prefix : String
  }


type Msg
  = Navigate String
  | Input Ui.SearchInput.Msg


init : String -> String -> List Item -> Model
init prefix placeholder items =
  { items = items
  , prefix = prefix
  , input = Ui.SearchInput.init 0 placeholder
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
      Fuzzy.match [ Fuzzy.movePenalty 1000 ] [] model.input.value item.label
  in
    result.score < 2000


view : String -> Model -> Html.Html Msg
view active model =
  node "ui-nav-list"
    []
    [ Html.App.map Input (Ui.SearchInput.view model.input)
    , node "ui-nav-list-items" [] (renderItems active model)
    ]


renderItems : String -> Model -> List (Html.Html Msg)
renderItems active model =
  List.filter (match model) model.items
    |> List.sortBy .label
    |> List.map (renderItem active model)


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
