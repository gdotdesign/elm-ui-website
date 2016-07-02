module Documentation exposing (..)

import Html.Events exposing (onClick)
import Html exposing (node, text)
import Markdown
import Http
import Task

type alias Model =
  { contents : String }

type Msg
  = Load String
  | Loaded String
  | Error Http.Error

pages : List String
pages =
  [ "getting-started/setup"
  , "getting-started/adding-components"
  ]

init : Model
init =
  { contents = "" }

setContents : String -> Model -> Model
setContents contents model =
  { model | contents = contents }

load : String -> Cmd Msg
load page =
  Task.perform (\_ -> Debug.crash "") (\_-> Load page) (Task.succeed "")

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Load page ->
      let
        cmd =
          Task.perform
            Error
            Loaded
            (Http.getString ("/docs/" ++ page ++ ".md"))
      in
        (model, cmd)

    Loaded contents ->
      (setContents contents model, Cmd.none)

    Error _ ->
      (model, Cmd.none)

view : Model -> Html.Html Msg
view model =
  let
    renderItem page =
      node "li" [onClick (Load page)] [text page]
    items =
      List.map renderItem pages
  in
    node "ui-documentation" []
      [ node "ul" [] items
      , Markdown.toHtml [] model.contents
      ]
