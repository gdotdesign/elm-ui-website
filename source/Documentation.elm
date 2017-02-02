module Documentation exposing (..)

{-| This module is repsonsible for rendering the documentation pages.
-}
import Html exposing (node)
import Html.Lazy

import Http
import Task

import Components.NavList as NavList exposing (Category)
import Components.Markdown as Markdown

{-| Representation of a documentation component.
-}
type alias Model =
  { contents : String
  , list : NavList.Model
  }


{-| Messages a documentation component can receive.
-}
type Msg
  = Load String
  | Loaded (Result Http.Error String)
  | List NavList.Msg


{-| Pages of documentation.
-}
pages : List (String, String)
pages =
  [ ( "getting-started/setup",               "1.1 Setup"               )
  , ( "getting-started/adding-components",   "1.2 Adding Components"   )
  , ( "getting-started/reacting-to-changes", "1.4 Reacting to Changes" )
  ]


{-| Pages of guide documentation.
-}
guidePages : List (String, String)
guidePages =
  [ ( "guides/introduction",          "2.1 Introduction"          )
  , ( "guides/focusing",              "2.2 Focusing"              )
  , ( "guides/handling-files",        "2.3 Handling Files"        )
  , ( "guides/environment-variables", "2.4 Environment Variables" )
  , ( "guides/scrolling",             "2.5 Scrolling"             )
  , ( "guides/drag-and-drop",         "2.6 Drag and Drop"         )
  , ( "guides/drop-downs",            "2.7 Drop Downs"            )
  ]


{-| Categories for the navigation list.
-}
navItems : List Category
navItems =
  let
    convert items =
      List.map (\(url, label) -> { href = url, label = label }) items
  in
    [ ( "1. Getting Started", convert pages      )
    , ( "2. Guides",          convert guidePages )
    ]


{-| Initializes a documentation component.
-}
init : Model
init =
  { contents = ""
  , list = NavList.init "documentation" "Search the docs..." navItems
  }


{-| Sets the contents of the main area.
-}
setContents : String -> Model -> Model
setContents contents model =
  { model | contents = contents }


{-| Loads the page with the given url.
-}
load : String -> Cmd Msg
load page =
  Task.perform (\_-> Load page) (Task.succeed "")

{-| Updates a documentation component.
-}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Load page ->
      let
        cmd =
          Http.getString ("/docs/" ++ page ++ ".md")
            |> Http.send Loaded
      in
        ( model, cmd )

    Loaded result ->
      case result of
        Ok contents ->
          ( setContents contents model, Cmd.none )
        Err _ ->
          ( model, Cmd.none )

    List act ->
      let
        ( list, cmd ) = NavList.update act model.list
      in
        ( { model | list = list }, Cmd.map List cmd )


{-| Renders a documentation component laziy.
-}
view : String -> Model -> Html.Html Msg
view active model =
  Html.Lazy.lazy2 render active model


{-| Renders a documentation component.
-}
render : String -> Model -> Html.Html Msg
render active model =
  node "ui-documentation" []
    [ Html.map List (NavList.view active model.list)
    , Markdown.view model.contents
    ]
