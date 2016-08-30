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
  { dropdownPosition : String
  , open : Bool
  }


init : Model
init =
  { dropdownPosition = "bottom-right"
  , open = False
  }
```

## Opening / Closing
To open a drop-down you will need the dimensions of the element where you want
to position around the drop-down and the dimensions of the drop-down. There are
decoders for this.

We will use the **focus** event to open the dropdown and the **blur event** to
close it.

To use them we need have tags that handle them:

```
type Msg
  = Open Ui.Helpers.Dropdown.Dimensions
  | Close
  | NoOp -- this is needed to stop the click event inside the dropdown
```

Also we need to change our view:

```
view : Model -> Html.Html Msg
view model =
  let
    classes =
      classList
        [ ( "my-dropdown", True )
        -- this class is required to show the dropdown
        , ( "dropdown-open", model.open )
        ]
  in
    div [ classes ]
      [ span
          [ tabindex 0 -- make sure it's focusable
          , Ui.Helpers.Dropdown.onWithDimensions "focus" Open
          , on "blur" (Json.succeed Close)
          ]
          [ text "Open" ]
      , Ui.Helpers.Dropdown.view NoOp
          model.dropdownPosition
          [ text "Dropdown Contents" ]
      ]
```

Then to actually open the drop-down we need to call the
`Ui.Helpers.Dropdown.openWithDimensions` function in the update.

```
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Open dimensions ->
      ( Ui.Helpers.Dropdown.openWithDimensions dimensions model
      , Cmd.none )

    Close ->
      ( Ui.Helpers.Dropdown.close model, Cmd.none )

    NoOp ->
      ( model, Cmd.none )
```

The last thing is to make sure that the our component has **relative** or
**absolute** positioning.

We can add that to the **stylesheets/main.scss**

```scss
@import 'ui';

.my-dropdown {
  position: relative
}
```

You can see the full code for the example [here](https://github.com/gdotdesign/elm-ui-examples/tree/master/drop-down).
