## Prerequisites
You should have a basic knowledge of **Elm** and of **The Elm Architecture**.

Here are some resources to get you up to speed:
* [Elm](http://elm-lang.org) - The official website of Elm
* [Elm Guide](http://guide.elm-lang.org) - The official Elm guide
* [The Elm Architecture](http://guide.elm-lang.org/architecture/) - The Elm Architecture guide
* [Elm Tutorial](http://www.elm-tutorial.org/en/) - A tutorial on how to write web apps in elm

## Installing
Add the Elm-UI as a dependency as you would any other pacakge to your
`elm-package.json` file:

```json
{
  "dependencies": {
    "gdotdesign/elm-ui": "1.0.0 <= v < 2.0.0"
  }
}
```

Since Elm-UI uses stuff that are [not allowed](https://github.com/gdotdesign/elm-ui/issues/24#issuecomment-209217352) in the official repository
you cannot installed it via the default method, however you can install it and
other packages like it with [elm-github-install](https://github.com/gdotdesign/elm-github-install)
which gives you the `elm-install` command, which installs all your packages from
github.
