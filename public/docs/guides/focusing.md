# Focusing
Focusing **components** or **HTML elements** is an integral part of any
application. The main reason for focusing a component is to guide the user
to a specific part of the application that requires user input.

## HTML Elements
Focusing HTML elemenst is done via the official [Dom package](http://package.elm-lang.org/packages/elm-lang/dom).
You can focus any HTML element with and **id attribute** using the
[Dom.focus](http://package.elm-lang.org/packages/elm-lang/dom/1.1.0/Dom#focus)
function which returns a task, when run it will focus the element and if it's
not present in the DOM it returns an error.

```elm
  task = Dom.focus "my-thing"
```

## Ui.* Components
Most `Ui.*` components implement a `uid` field, the value of this field is
set for the **id** attribute of the for focusable HTML element. This means if
you need to focus a component you can just call:

```elm
  task = Dom.focus model.textarea.uid
```
