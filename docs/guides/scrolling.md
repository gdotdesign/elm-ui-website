# Scrolling
Sometimes an application needs to scroll some content in the page, the most
common use case is to scroll to the top of the page.

The official [dom package](http://package.elm-lang.org/packages/elm-lang/dom/latest)
provides functions for getting and setting an elements scroll position, these
functions requires the elements to have an **id** attribute.

## Scrolling to the top
To scroll to the top of the page we need to add an **id** to the body, it can be
done in the **public/index.html** of any Elm-UI app:

```html
<html>
  <head>
    <link rel="stylesheet" type="text/css" href="main.css">
    <title>Scroll example</title>
  </head>
  <body id="body">
    <script src='Main.js' type='application/javascript'></script>
    <script type="text/javascript">
      var app = Elm.Main.fullscreen();
    </script>
  </body>
</html>
```

In the source you need to import the `Dom.Scroll` module:

```
import Dom.Scroll

type alias Model =
  {}

init : Model
init =
  {}
```

You will need an event to perform the `Task` that the `toTop `function returns,
for this we will add a `Ui.Button`:

```
type Msg
  = ToTop
  | Scrolled ()

view : Model -> Html.Html Msg
view model =
  div
    [ style [ ( "padding-top", "1000px" ) ] ]
    [ Ui.Button.primary "To Top!" ToTop
    ]
```

In the update we perform the task:

```
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ToTop ->
      let
        task = Dom.Scroll.toTop
      in
        ( model, Task.perform NotFound Scrolled task )

    Scrolled () ->
      ( model, Cmd.none )
```

You can see the full code for the example [here]()
