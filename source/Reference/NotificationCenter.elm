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
  , notifications =
      Notifications.init ()
        |> Notifications.timeout 5000
        |> Notifications.duration 500
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Input msg ->
      let
        ( input, cmd ) =
          Ui.Input.update msg model.input
      in
        ( { model | input = input }, Cmd.map Input cmd )

    Notifications msg ->
      let
        ( notifications, cmd ) =
          Notifications.update msg model.notifications
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
        , Ui.Button.view
          Notify
          { kind = "primary"
          , text = "Send"
          , size = "medium"
          , disabled = False
          , readonly = False
          }
        , Notifications.view Notifications model.notifications
        ]
  in
    Components.Reference.view demo (text "")
