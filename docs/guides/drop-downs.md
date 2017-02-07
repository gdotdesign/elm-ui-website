# Creating Drop-downs

There are many problems where using drop-down menus are the best solution, for
example date or color pickers. Creating drop-down menus can be difficult, this
guide will show you how to easily create them using the `Ui.Helpers.Dropdown`
module.

The features / requirements for a drop-down menu are:
* Open to the side of the screen where are more space
* Close it when clicking outside of the drop-down
* Don't close when clicking inside the drop-down

## Model
There is two fields that are required for creating a drop-down, so our components
module will look something like this:

```
type alias Model =
  { dropdown : Dropdown.Dropdown
  , uid : String
  }


init : Model
init =
  { dropdown = Dropdown.init
  , uid = "my-dropdown" -- a unique identifier for your dropdown
  }
```

## Wiring & Opening
The `Ui.Helpers.Dropdown` handles the positioning of the dropdown so you don't
need to worry about it, it does this with it's own update function so we need
a tag for it. Also we need a tag for opening a dropdown:
```
type Msg
  = Dropdown Dropdown.Msg
  | Open
```

Then we need to handle these two tags:
```
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Open ->
      ( Dropdown.open model, Cmd.none )

    Dropdown msg ->
      ( Dropdown.update msg model, Cmd.none )
```

Our view will look like this:
```
view : Model -> Html.Html Msg
view model =
  Dropdown.view
      -- the elements that are displayed and can be used to open the dropdown
    { children = [ button [ onClick Open ] [ text "Open" ] ]
      -- the contents of the dropdown
    , contents = [ text "Contents..." ]
      -- the address for it's update function
    , address = Dropdown
      -- additional attributes to add the wrapper element
    , attributes = []
      -- the tag of the wrapper element (the children goes into this)
    , tag = "span"
    }
    model
```

## Subscriptions
A subscription is needed to handle closing of the dropdown when the user
clicks outside of the it:

```
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map Dropdown (Dropdown.subscriptions model)
```

You can see the full code for the example [here](https://github.com/gdotdesign/elm-ui-examples/tree/master/drop-down).

Also you can see how it is used in Elm-UI components:
* [Ui.Chooser](https://github.com/gdotdesign/elm-ui/blob/development/source/Ui/Chooser.elm)
* [Ui.ColorPicker](https://github.com/gdotdesign/elm-ui/blob/development/source/Ui/ColorPicker.elm)
* [Ui.DatePicker](https://github.com/gdotdesign/elm-ui/blob/development/source/Ui/DatePicker.elm)
* [Ui.DropdownMenu](https://github.com/gdotdesign/elm-ui/blob/development/source/Ui/DropdownMenu.elm)
