# Environment Variables
Environment Variables are must have for applications that supports [multiple environments](https://en.wikipedia.org/wiki/Deployment_environment).

## Specifying the data
The variables for different environments live in the **config** folder of an
Elm-UI application.

Each environment can have **JSON** file, for example this app uses three
environments (development, staging, production):

```bash
my-app
├── config
│   ├── development.json
│   ├── staging.json
│   └── production.json
...
```

## Specifying the environment
Every command can have the `-e, --env [env]` flag that specifies the current
environment. If no environment is specified **development** is assumed and used.

Running the development server in staging environment:

```bash
elm-ui start -e staging
```

The contents of the current environment is injected into the compiled code and
is accessible as `window.ENV`.

## Accessing the variables
Reading the variables can be done with the `Ui.Helpers.Env` module specifically
the `get` function.

For example we have the following data:
```json
{
  "endpoint": "https://httpbin.org/post"
}
```

We can read the `endpoint` with the following code:
```elm
-- Ui.Helpers.Env.get : String -> Json.Decoder a -> Result String a
result = Ui.Helpers.Env.get "endpoint" Json.Decode.string
```
