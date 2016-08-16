module Utils.ScrollToTop exposing (Model, Msg, init, subscriptions, update, start)

import AnimationFrame
import Animation exposing (Animation)
import Time exposing (Time)
import Task
import Dom.Scroll
import Dom


type alias Model =
  { animation : Maybe Animation
  , setup : Animation -> Animation
  }


type Msg
  = StartAnimation ( Time, Float )
  | NotFound Dom.Error
  | Animate Time
  | NoOp ()


init : (Animation -> Animation) -> Model
init setup =
  { setup = setup
  , animation = Nothing
  }


start : Cmd Msg
start =
  let
    task =
      Task.map2 (,) (Time.now) (Dom.Scroll.y "body")
  in
    Task.perform NotFound StartAnimation task


subscriptions : Model -> Sub Msg
subscriptions model =
  case model.animation of
    Just _ ->
      AnimationFrame.times Animate

    _ ->
      Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Animate time ->
      let
        position =
          Maybe.map (Animation.animate time) model.animation
            |> Maybe.withDefault 0

        scrollTask =
          Task.perform NotFound NoOp (Dom.Scroll.toY "body" position)
      in
        if position == 0 then
          ( { model | animation = Nothing }, Cmd.none )
        else
          ( model, scrollTask )

    StartAnimation ( time, position ) ->
      let
        animation =
          Animation.animation time
            |> Animation.from position
            |> Animation.to 0
            |> model.setup
      in
        ( { model | animation = Just animation }, Cmd.none )

    _ ->
      ( model, Cmd.none )
