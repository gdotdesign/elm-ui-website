# Focusing
Focusing **components** or **HTML elements** is an integral part of any application. The main reason for focusing a component is to guide the user to a specific part of the application that requires user input.

## HTML Elements
You can focus any HTML elements in Elm-UI with the [`Ui.Native.Dom.focusSelector`](/reference/native/dom) function, which takes a **noop** message and an arbitrary **CSS selector** and returns a **command**.

```elm
focus : Cmd Msg
focus =
  Ui.Native.Dom.focusSelector NoOp "input#first-name"
```
The command when executed will try to find the element and will call `focus()` on it.

## Components
You can focus any rendered `Ui.*` component with the [`Ui.Native.Dom.focusComponent`](/reference/native/dom) function, which takes a **noop** message and an arbitrary component `{ component | uid : String }` and returns a **command**.

```elm
focus : Model -> Cmd Msg
focus model =
  Ui.Native.Dom.focusComponent NoOp model.textarea
```
The command when executed will try to find the component with the attribute `uid` and will call `focus()` on it.

## Delay
There is a **30 milliseconds ~ 2 frames** delay to make sure the element / component is available in the DOM after an Elm update.
