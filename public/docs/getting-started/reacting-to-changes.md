# Reacting to Changes
Continuing the previous example we will make it so that changing the number range component will change the counter and vice versa.

## Updating the counter
Most cases we want to **react** (get a message) to the changes in a component, the _official_ way would be to modify the update function to something like this:
```elm
NumberRange subMsg ->
  let
    (numberRange, cmd) =
      Ui.NumberRange.update subMsg model.numberRange

    updatedCommand =
      Cmd.map NumberRange cmd

    updatedModel =
      { model | numberRange = numberRange }
  in
    if numberRange.value /= model.numberRange.value then
      ({ updatedModel | counter = round numberRange.value }, updatedCommand)
    else
      (updatedModel, updatedCommand)
```
After a while this pattern becomes hard to maintain and to generally hard to manage.

In Elm-UI however the components **emit changes in the value** and we can **subscribe** to those changes.

In order to receive these messages we need a tag:
```elm
type Msg
  ...
  | SetCounter Int
  ...
```

The next thing is to **subscribe** to the changes:
```elm
...
, subscriptions = \model ->
  Sub.batch [ Sub.map NumberRange (Ui.NumberRange.subscriptions model.numberRange)
            , Ui.NumberRange.subscribe (SetCounter << round) model.numberRange
            ]
...
```

And the last thing is to handle the new tag in the `update`:
```elm
SetCounter value ->
  ({ model | counter = value }, Cmd.none)
```

This way is nicer for many reasons:
  - The update part of the component doesn't change
  - The tag to update the counter is generic and can be reused
  - Subscriptions can be removed when not needed

## Updating the component
Right now the `Increment` and `Decrement` tags are updating the counter and not our number range component, so we need to extract and modify the logic into a standalone function:
```elm
updateCounter : Int -> Model -> Model
updateCounter value model =
  { model
  | counter = value
  , numberRange = Ui.NumberRange.setValue (toFloat value) model.numberRange
  }
```
This function updates the counter and the number range with the same value.

We need to use this in our update function:
```elm
...
Increment ->
  (updateCounter (model.counter + 1) model, Cmd.none )

Decrement ->
  (updateCounter (model.counter + 1) model, Cmd.none )
...
```

So now whatever we do the counter and the number range component are in sync.
