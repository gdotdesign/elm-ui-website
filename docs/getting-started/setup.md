## Prerequisites
You should have a basic knowledge of **Elm** and of **The Elm Architecture**. Here are
some resources to get you up to speed:
* [Elm](http://elm-lang.org) - The official website of Elm
* [Elm Guide](http://guide.elm-lang.org) - The official Elm guide
* [The Elm Architecture](http://guide.elm-lang.org/architecture/) - The Elm Architecture guide
* [Elm Tutorial](http://www.elm-tutorial.org/en/) - A tutorial on how to write
  web apps in elm

## Dependencies
Currently the following external dependencies are needed for Elm-UI:
* [Node.js](https://nodejs.org/en/)
* [Git](https://git-scm.com)

## Features
Elm-UI offers the following features:
* A complete development environment for writing UIs for web apps:
  * Live reload server for development
  * Building and minifying production files
  * Support for multiple environments
* 25+ fully featured UI components
* Theming

## Technologies
Elm-UI uses the following technologies:
* Node.js - The platform
* Elm - The frontend language via [elm](https://www.npmjs.com/package/elm)
* Sass - The CSS preprocessor using [node-sass](https://www.npmjs.com/package/node-sass)
* Autoprefixer - Automatically add browser prefixes when needed via [autoprefixer](https://www.npmjs.com/package/autoprefixer)
* Browsersync - Live reload functionality via [browser-sync](https://www.npmjs.com/package/browser-sync)

## Command line tool
Similarly to many frameworks, Elm-UI comes with a
command line tool `elm-ui` that lets you:
* Scaffold applications
* Install Elm packages
* Serve your application for development
* Building your application for production
* Generate documentation for your application

This tool lives on [NPM](https://www.npmjs.com/package/elm-ui) and can be
installed via command line:

```bash
npm install elm-ui -g
```

Here are the list of options:
```bash
Usage: elm-ui [options] [command]

Commands:
  install                  Installs Elm dependencies
  docs                     Generates Elm documentation
  help                     Output usage information
  new|init <dir>           Scaffolds a new Elm-UI project
  server|start [options]   Starts development server
  build [options]          Builds final files

Options:
  -h, --help       output usage information
  -V, --version    output the version number
  -e, --env [env]  environment
```

