module Reference.NotificationCenter exposing (..)

import Components.Reference

import Html.Events.Extra exposing (onEnter)

import Ui.NotificationCenter as Notifications
import Ui.Button
import Ui.Input

import Html.Attributes exposing (class)
import Html exposing (div, text)


type alias Model =
  { notifications : Notifications.Model Msg
  , input : Ui.Input.Model
  }


type Msg
  = Notifications Notifications.Msg
  | Input Ui.Input.Msg
  | Notify


init : Model
init =
  { input =
      Ui.Input.init ()
        |> Ui.Input.placeholder "Message..."
  , notifications = Notifications.init 5000 400
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Input subMsg ->
      let
        ( input, cmd ) =
          Ui.Input.update subMsg model.input
      in
        ( { model | input = input }, Cmd.map Input cmd )

    Notifications subMsg ->
      let
        ( notifications, cmd ) =
          Notifications.update subMsg model.notifications
      in
        ( { model | notifications = notifications }, Cmd.map Notifications cmd )

    Notify ->
      let
        ( notifications, cmd ) =
          Notifications.notify (text model.input.value) model.notifications

        ( input, inputCmd ) =
          Ui.Input.setValue "" model.input
      in
        ( { model
            | notifications = notifications
            , input = input
          }
        , Cmd.batch
          [ Cmd.map Notifications cmd
          , Cmd.map Input inputCmd
          ]
        )


view : Model -> Html.Html Msg
view model =
  let
    demo =
      div [ class "notification-center-demo"
          , onEnter False Notify
          ]
        [ Html.map Input (Ui.Input.view model.input)
        , Ui.Button.primary "Send" Notify
        , Notifications.view Notifications model.notifications
        ]
  in
    Components.Reference.view demo (text "")
