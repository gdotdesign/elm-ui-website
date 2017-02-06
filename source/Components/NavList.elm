module Components.NavList exposing (..)

{-| This is a component for rendering a serachable navigation list with
categories.
-}
import Html.Attributes exposing (classList, href)
import Html exposing (node, text)
import Html.Lazy

import Ui.Helpers.Emitter as Emitter
import Ui.SearchInput
import Ui.Link

import String
import Fuzzy

{-| Represenation of a category.
-}
type alias Category =
  (String, (List Item))


{-| Representation of an item.
-}
type alias Item =
  { label : String
  , href : String
  }


{-| Representation of a navigation list.
-}
type alias Model =
  { input : Ui.SearchInput.Model
  , items : List Category
  , prefix : String
  }


{-| Messages that a navigation list can receive.
-}
type Msg
  = Input Ui.SearchInput.Msg
  | Navigate String


{-| Initializes a navigation list with the given prefix and placeholder.
-}
init : String -> String -> List Category -> Model
init prefix placeholder items =
  { prefix = prefix
  , items = items
  , input =
      Ui.SearchInput.init ()
        |> Ui.SearchInput.timeout 0
        |> Ui.SearchInput.placeholder placeholder
  }


{-| Updates a navigation list.
-}
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


{-| Matches an item based on the search input.
-}
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


{-| Renders a navigation list lazily.
-}
view : String -> Model -> Html.Html Msg
view active model =
  Html.Lazy.lazy2 render active model


{-| Renders a navigation list.
-}
render : String -> Model -> Html.Html Msg
render active model =
  let
    items =
      List.map (renderCategory active model) model.items
      |> List.foldr (++) []
  in
    node "ui-nav-list"
      []
      [ Html.map Input (Ui.SearchInput.view model.input)
      , node "ui-nav-list-items" [] items
      ]


{-| Renders a category.
-}
renderCategory : String -> Model -> (String, List Item)
               -> List (Html.Html Msg)
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


{-| Renders a navigation item.
-}
renderItem : String -> Model -> Item -> Html.Html Msg
renderItem active model item =
  let
    url =
      "/" ++ model.prefix ++ "/" ++ item.href
  in
    node "ui-nav-list-item"
      [ classList [ ( "active", active == item.href ) ]
      ]
      [ Ui.Link.view
        { contents = [ text item.label ]
        , msg = Just (Navigate url)
        , target = Nothing
        , url = Just url
        }
      ]
