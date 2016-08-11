module Reference.NotificationCenter exposing (..)

import Components.Reference

import Html.Events.Extra exposing (onEnter)

import Ui.NotificationCenter as Notifications
import Ui.Button
import Ui.Input

import Html.Attributes exposing (class)
import Html exposing (div, text)
import Html.App


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
  { input = Ui.Input.init "" "Message..."
  , notifications = Notifications.init 5000 500
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
      in
        ( { model
            | input = Ui.Input.setValue "" model.input
            , notifications = notifications
          }
        , Cmd.map Notifications cmd
        )


view : Model -> Html.Html Msg
view model =
  let
    demo =
      div [ class "notification-center-demo"
          , onEnter False Notify
          ]
        [ Html.App.map Input (Ui.Input.view model.input)
        , Ui.Button.primary "Send" Notify
        , Notifications.view Notifications model.notifications
        ]
  in
    Components.Reference.view demo (text "")
