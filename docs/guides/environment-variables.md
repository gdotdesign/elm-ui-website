# Environment Variables
Environment Variables are must have for applications that supports
[multiple environments](https://en.wikipedia.org/wiki/Deployment_environment).

Elm-UI provides a way to read data from the `window.ENV` object with the
`Ui.Helpers.Env` module.

## Retrieving values
You can get a value from that object with the `Ui.Helpers.Env.get` function
which takes a string (the key to read) and a **json decoder** for it's value and
returns a result.

For example you have the following env object:
```js
window.ENV = {
  endpoint: "https://httpbin.org/post"
}
```

To get the endpoint you can do the following:
```
case Ui.Helpers.Env.get "endpoint" Json.Decode.string of
  Ok value ->
    -- do something with the value
  Err error ->
    -- the decoding failed handle the error
```
