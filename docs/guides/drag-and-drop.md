# Drag and Drop
Drag and drop interactions for UI elements are very common and it's used for
many things from sliders to image cropping, handling these can be difficult so
this guide tries to help you tackle them.

Most drag and drop functionality in Elm-UI is using the `Ui.Helpers.Drag`
module, which is this guide is about.

_Also Elm-UI uses [elm-dom](https://github.com/gdotdesign/elm-dom) internally,
so if you need add that to your **elm-package.json** as a dependency._

## Setup
The module offers a model for a **drag** which keeps track of the mouse start
position and the **dimensions** of the dragged element:

```
-- From Ui.Helpers.Drag
type alias Drag =
  { startPosition : Position
  , dimensions : Dimensions
  , dragging : Bool
  }
```

Let's say we want to drag and drop a div around the page, then we need a model
for it:
```
-- Import the modules.
import Ui.Helpers.Drag as Drag
import DOM exposing (Position)

init : Model
init =
  { startPosition : Position
  , position : Position
  , drag : Drag.Drag
  , uid : String
  }
```

## Lift - The start of a drag
To start a **drag** you will need to call the `lift` function which takes the
start mouse position, the dimensions of the element and the model.

There is an event handler for this event `Drag.liftHandler`:
```
-- These are the message we need to handle
type Msg
  = Lift Position

-- In the update we start the drag
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Lift position ->
      let
        -- Set the start position and start the drag with Drag.lift
        updatedModel =
          { model | startPosition = model.position}
            |> Drag.lift position
      in
       ( updatedModel, Cmd.none )

-- In the view we use the decoder.
view : Model -> Html.Html Msg
view model =
  div
    [ style
      [ ("left", (toString model.position.left) ++ "px")
      , ("top", (toString model.position.top) ++ "px")

      , ("border", "1px solid #DDD")
      , ("background", "#f5f5f5")
      , ("position", "absolute")
      , ("font-family", "sans")
      , ("padding", "40px")
      , ("cursor", "move")

      , ("-webkit-user-select", "none")
      , ("-moz-user-select", "none")
      , ("-ms-user-select", "none")
      , ("user-select", "none")
      ]
    , Drag.liftHandler Lift
    ]
    [ text "Drag ME!!" ]
```

## Subscriptions - Updating the model
The module offers a way to simplify getting the mouse position and the click
events from the official [Mouse](http://package.elm-lang.org/packages/elm-lang/mouse/latest) package.

To use it you need to provide two tags, one for the move events and one for
the end of the drag.
```
-- These are the tags for the subscription.
...
  | Move Position
  | End

-- Provide subscriptions for this particular component.
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Drag.onMove Move model
    , Drag.onEnd End model
    ]
```

Then we need to handle them in the update function:
```
...
  -- Here we can calulate diffs and update the position.
  Move position ->
    let
      -- Get the diff between the start position and the current position
      diff =
        Drag.diff position model

      -- Calculate new positions
      newPosition =
        { left = model.startPosition.left + diff.left
        , top = model.startPosition.top + diff.top
        }
    in
      ( { model | position = newPosition }, Cmd.none )

  End ->
    -- End the drag
    ( Drag.end model, Cmd.none)
```

That's it our example is complete the div is now draggable on the page.

You can see the full code for the example
[here](https://github.com/gdotdesign/elm-ui-examples/tree/master/drag-and-drop).
