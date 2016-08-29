# Creating Drop-downs

There are many problems where using drop-down menus are the best solution, for
example date or color pickers. Creating drop-down menus can be difficult, this
guide will show you how to easily create them using the `Ui.Helpers.Dropdown`
module.

The features / requirements for a drop-down menu are:
* Open to the side of the screen where are more space
* Close it when clicking outside of the drop-down

## Model
There is two fields that are required for creating a drop-down, so our components
module will look something like this:

```
type alias Model =
  { dropdownPosition : String -- the position of the drop-down ("top-left")
  , open : Bool -- whether the drop-down is open or not
  }

init : Model
init =
  { dropdownPosition = "top-left"
  , open = false
  }
```

## View
The module offers a view for your drop-down:

```
view : Model -> Html.Html Msg
view model =
  div
    [ class "my-dropdown" ]
    [ span [] [ text "open" ]
    , Ui.Helpers.Dropdown.view
        NoOp
        model.dropdownPosition
        [ text "Dropdown Contents" ]
    ]
```

## Opening
To open a drop-down you will need the dimensions of the element where you want
to position around the drop-down and the dimensions of the drop-down. There are
decoders for this.

To use them we need have tags that handle them:

```
type Msg
  = Open Ui.Helpers.Dropdown.Dimensions
```

Also we need to change our view:

```
view : Model -> Html.Html Msg
view model =
  div
    [ class "my-dropdown" ]
    [ span
      [ tabindex 0
      , Ui.Helpers.Dropdown.onWithDimensions "focus" Open
      ]
      [ text "Open" ]
    , Ui.Helpers.Dropdown.view
        NoOp -- This is needed for stopping click events
        model.dropdownPosition
        [ text "Dropdown Contents" ]
    ]
```

Then to actually open the drop-down we need to call the
`Ui.Helpers.Dropdown.openWithDimensions` function in the update.

```
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Open dimensions ->
      (Ui.Helpers.Dropdown.openWithDimensions model, Cmd.none)
```

## Closing
To close the drop-down when clicking outside of it we will use the blur event:

```
...
  | Close


...
      [ tabindex 0
      , Ui.Helpers.Dropdown.onWithDimensions "focus" Open
      , on "blur" (Json.succeed Close)
      ]
...
```
