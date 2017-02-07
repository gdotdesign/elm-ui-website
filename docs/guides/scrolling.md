# Scrolling
Sometimes an application needs to scroll some content in the page, the most
common use case is to scroll to the top of the page.

The official [dom package](http://package.elm-lang.org/packages/elm-lang/dom/latest)
provides functions for getting and setting an elements scroll position, these
functions requires the elements to have an **id** attribute.

## Scrolling to the top
To scroll to the top of the page you need to add an **id** to the body, it can
be done in the HTML file of your app:

```html
<html>
  <head>
    ...
  </head>
  <body id="body">
    ...
  </body>
</html>
```

In the source you need to import the `Dom.Scroll` module:

```
import Dom.Scroll
import Task
import Dom

type alias Model =
  {}

init : Model
init =
  {}
```

You will need an event to perform the `Task` that the `toTop `function returns,
for this we will add a `Ui.Button` from Elm-UI:

```
import Ui.Button

type Msg
  = NotFound Dom.Error
  | Scrolled ()
  | ToTop

view : {} -> Html.Html Msg
view model =
  div
  [ style
    [ ( "font-family", "sans" )
    , ( "margin", "40px" )
    ]
  ]
  [ span [ ] [ text "Scroll down and push the button!" ]
  , div
    [ style [ ( "padding-top", "1000px" ) ] ]
    [ Ui.Button.view ToTop
      { disabled = False
      , readonly = False
      , text = "To Top!"
      , kind = "primary"
      , size = "medium"
      }
    ]
  ]
```

In the update we perform the task:

```
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ToTop ->
      let
        task =
          Dom.Scroll.toTop "body"
      in
        ( model, Task.attempt NotFound Scrolled task )

    Scrolled () ->
      ( model, Cmd.none )

    NotFound _ ->
      ( model, Cmd.none )
```

You can see the full code for the example [here](https://github.com/gdotdesign/elm-ui-examples/tree/master/scroll-to-top).
