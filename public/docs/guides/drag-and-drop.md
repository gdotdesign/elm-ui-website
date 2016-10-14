# Drag and Drop
Drag and drop interactions for UI elements are very common and it's used for
many things from sliders to image cropping, handling these can be difficult so
this guide tries to help you tackle them.

Most drag and drop functionality in Elm-UI is using the `Ui.Helpers.Drag`
module, which is this guide is about.

## Setup
The module offers a model for a **drag** which keeps track of the mouse start
position and the **dimensions** of the dragged element:

```
{ mouseStartPosition : Html.Events.Geometry.MousePosition
, dimensions : Html.Events.Geometry.ElementDimensions
, dragging : Bool
}
```

Let's say we want to drag and drop a div around the page, then we need a model
for it:
```
{- Import the modules. -}
import Html.Events.Geometry exposing (Dimensions, onWithDimensions)
import Ui.Helpers.Drag as Drag

init : Model
init =
  { position = (0, 0) -- start position
  , startPosition = (0,0) -- start position of the div
  , drag = Drag.init -- initialize a drag record
  }
```

## Lift - The start of a drag
To start a **drag** you will need to call the `lift` function which takes the
start mouse position, the dimensions of the element and the model.

There is a decoder to get these from an event `onWithDimensions` from the
`Html.Events.Geometry` module:
```
{- We need a tag to handle the event. -}
type Msg
  = MouseDown Dimensions

{- In the update we start the drag -}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MouseDown (mousePosition, dimensions, windowSize) ->
      ({ model
       | drag = Drag.lift dimensions mousePosition model.drag
       , startPosition = model.position
       }, Cmd.none)

{- In the view we use the decoder. -}
view : Model -> Html.Html Msg
view model =
  div
    [ style
      [ ("top", (toString (fst model.position)) ++ "px")
      , ("left", (toString (snd model.position)) ++ "px")
      ]
    , onWithDimensions "mousedown" False MouseDown
    ]
    [ text "Drag ME!!" ]
```

## Subscriptions - Updating the model
The module offers a way to simplify getting the mouse position and the click
events from the official [Mouse](http://package.elm-lang.org/packages/elm-lang/mouse/latest) package.

To use it you need to provide two tags, one for the mouse position and one
for the clicks and an additional parameter which is the state of the drag
(to only subscribe if dragging to avoid none usefull updates):
```
{- These are the tags for the subscription. -}
...
| MouseMove (Float, Float)
| Click Bool

{- Provide subscriptions for this particular component. -}
subscriptions : Model -> Sub Msg
subscriptions model =
  Drag.subscriptions MouseMove Click model.drag.dragging
```

Then we need to handle them in the update function:
```
...
{- Here we can calulate diffs and update the position. -}
MouseMove (left, top) ->
  let
    diff =
      Drag.diff left top model.drag

    position =
      ( (fst model.startPosition) + diff.top
      , (snd model.startPosition) + diff.left)
  in
    ({ model | position = position }, Cmd.none)

{- Here we handle th click, stopping the drag if pressed is false -}
Click pressed ->
  ({ model | drag = Drag.handleClick pressed model.drag }, Cmd.none)
```

That's it our example is complete the div is now draggable on the page.

You can see the full code for the example [here](https://github.com/gdotdesign/elm-ui-examples/tree/master/drag-and-drop).
