# Adding Components
Components are added with the traditional The Elm Architecture way with some modifications:
  - Add a field to the model for the components `Model`
  - Initialize the component with the `init` function
  - Create a tag for its messages (`Msg`)
  - Wire in the component in the `update` function
  - Wire in subscriptions if necessary by using the `subscriptions` function
  - Add the component to the view using the `view` or `render` functions

## Example
We will be expanding the created application to set the counters value with a `Ui.NumberRange` component.

We start by importing the component we want to use:
```elm
import Ui.NumberRange
```

Then we add a `numberRange` field to the model and the record to the `init` function:
```elm
type alias Model =
  { app : Ui.App.Model
  , numberRange : Ui.NumberRange.Model
  , counter : Int
  }

init : Model
init =
  { app = Ui.App.init "Elm-UI Project"
  , numberRange = Ui.NumberRange.init 0
  , counter = 0
  }
```

Then we add a new tag for the messages:
```elm
type Msg
  = App Ui.App.Msg
  | NumberRange Ui.NumberRange.Msg
  | Increment
  | Decrement
```

Then we need to make sure that the component is updated
```elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  ...
  NumberRange subMsg ->
    let
      (numberRange, cmd) = Ui.NumberRange.update subMsg model.numberRange
    in
      ({ model | numberRange = numberRange }, Cmd.map NumberRange cmd)
```

Now we can add its view below the buttons:
```elm
view : Model -> Html.Html Msg
view model =
  ...
  , Ui.Button.primary "Increment" Increment
      ]
  , Html.App.map NumberRange (Ui.NumberRange.view model.numberRange)
  ]
  ...
```

Right now we are be seeing something like this:

![Adding Components](/images/adding-components.jpg)

But the number range component doesn't seem work right, it's value cannot be changed by dragging.That is because some components like this one need subscriptions (for mouse and such) and it needs to be wired in to our application.

To do that we need to add the following line:
```elm
main =
  Html.App.program
    { init = ( init, Cmd.none )
    , view = view
    , update = update
    , subscriptions = \model ->
        Sub.map NumberRange (Ui.NumberRange.subscriptions model.numberRange)
    }
```
And now our new component works as expected.

-------------------------------------------------------------------------------------

In the next part we will see how can we **react** to the changes of this component.
