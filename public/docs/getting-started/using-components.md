# Using Components
Components follow traditional **The Elm Architecture**, so they have
`init`, `update`, `subscriptions` and `view` functions, they can be included
as any other module.

Don't worry about the styles they are added automagically ;)

```elm
-- Import the component
import Ui.Ratings

-- Add it to your model
type alias Model =
  { ratings = Ui.Ratings.Model
  }

-- Add it's messages to your messages
type Msg
  = Ratings Ui.Ratings.Msg

-- Add it to your init function
init : Model
init =
  { ratings =
      Ui.Ratings.init ()
        |> Ui.Ratings.size 10 -- set things on your component
  }

-- Update as usual
update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Ratings msg ->
      let
        ( ratings, cmd ) =
          Ui.Ratings.update msg model.ratings
      in
        ( { model | ratings = ratings }, Cmd.map Ratings cmd )

-- Render it in your view
view : Model -> Html.Html Msg
view model =
  Html.map Ratings (Ui.Ratings.view model.ratings)
```
