module Documentation exposing (..)

import Html.Events exposing (onClick)
import Html exposing (node, text)
import Http
import Task

import Components.Markdown as Markdown
import Components.NavList as NavList

type alias Model =
  { contents : String
  , list : NavList.Model
  }

type Msg
  = Load String
  | Loaded (Result Http.Error String)
  | List NavList.Msg

pages : List (String, String)
pages =
  [ ("getting-started/setup",               "1.1 Setup"               )
  , ("getting-started/adding-components",   "1.2 Adding Components"   )
  , ("getting-started/reacting-to-changes", "1.4 Reacting to Changes" )
  ]

guidePages : List (String, String)
guidePages =
  [ ("guides/introduction", "2.1 Introduction")
  , ("guides/focusing", "2.2 Focusing")
  , ("guides/handling-files", "2.3 Handling Files")
  , ("guides/environment-variables", "2.4 Environment Variables")
  , ("guides/scrolling", "2.5 Scrolling")
  , ("guides/drag-and-drop", "2.6 Drag and Drop")
  , ("guides/drop-downs", "2.6 Drop Downs")
  ]

navItems =
  let
    convert items =
      List.map (\(url, label) -> { href = url, label = label }) items
  in
    [ ("1. Getting Started", convert pages)
    , ("2. Guides", convert guidePages)
    ]

init : Model
init =
  { contents = ""
  , list = NavList.init "documentation" "Search the docs..." navItems
  }

setContents : String -> Model -> Model
setContents contents model =
  { model | contents = contents }

load : String -> Cmd Msg
load page =
  Task.perform (\_-> Load page) (Task.succeed "")

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Load page ->
      let
        cmd =
          Http.getString ("/docs/" ++ page ++ ".md")
            |> Http.send Loaded
      in
        (model, cmd)

    Loaded result ->
      case result of
        Ok contents ->
          (setContents contents model, Cmd.none)
        Err _ ->
          (model, Cmd.none)

    List act ->
      let
        (list, effect) = NavList.update act model.list
      in
        ({ model | list = list }, Cmd.map List effect)

view : String -> Model -> Html.Html Msg
view active model =
  node "ui-documentation" []
    [ Html.map List (NavList.view active model.list)
    , Markdown.view model.contents
    ]
