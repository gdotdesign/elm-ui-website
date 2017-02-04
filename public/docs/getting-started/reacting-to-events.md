# Reacting to events
In Elm-UI some components broadcast events (change, item added, item removed,
etc..) which you can subscribe to.

For example if you have a `Ui.Ratings` component in your application you can
subscribe to it's changes with the `Ui.Ratings.onChange` function:

```elm
-- Add the message that recives the change event to your types
type Msg
  = Ratings Ui.Ratings.Msg
  | Changed Float

-- Create a subscription for the event
subscription : Model -> Sub Msg
subscription model =
  Ui.Ratings.onChange Changed model.ratings

-- Add the messages to your update function
update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Changed value ->
      -- Do things here with the value

    Ratings msg ->
      let
        ( ratings, cmd ) =
          Ui.Ratings.update msg model.ratings
      in
        ( { model | ratings = ratings }, Cmd.map Ratings cmd )
```
