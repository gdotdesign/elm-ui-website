# Setup
Elm-UI lives on [NPM](https://www.npmjs.com/package/elm-ui) and can be installed
via command line:

```bash
npm install elm-ui@alpha -g
```

## Command line tool
Similarly to [Ruby on Rails](http://rubyonrails.org), Elm-UI comes with a
command line tool `elm-ui` that lets you:
* Scaffold applications
* Install Elm packages
* Serve your application for development
* Building your application for production
* Generate documentation for your application

Here is the list of options:
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

## Our first application
First we need to scaffold a new application by giving the following command in
the terminal:

```bash
elm-ui init my-awesome-app
```

This will create a directory structure like this one:

```bash
my-awesome-app
├── config
│   └── development.json
├── public
│   └── index.html
├── source
│   └── Main.elm
├── stylesheets
│   └── main.scss
└── elm-package.json
```

* **config** - This directory contains the files for the [environment variables](https://en.wikipedia.org/wiki/Environment_variable).
<br> The application have access to them and they are generally have different values for development and production.
* **source** - This directory contains the source (.elm) files for the application.
<br>The **Main.elm** is the file that runs and imports all other modules.
* **stylesheets** - This directory contains the styles for the application.
<br>The **main.scss** file is compiled to **CSS** and loaded in the app.
* **public** - This directory contains all of other files (images, pdfs, etc..) that are needed for your application.
<br>These files are serves as is without any processing.
<br>The **index.html** in this directory is your main file that is displayed.
<br>The **elm-package.json** is your standard Elm package configuration file.

## Installing dependecies
Any Elm-UI application will have dependencies such as **gdotdesign/elm-ui**,
**elm-lang/core** and **other packages**. To install these you need to
run this command:

```bash
elm-ui install
```

After it finishes you are ready for development!

## Running the application
To run the application you need to run the following command in the terminal:

```bash
elm-ui server
```

This will start three servers:
* http://localhost:8001 - The application server
* http://localhost:8002 - Proxied application server that has live reloading
* http://localhost:8003 - Settings for the live reload server

You can load either http://localhost:8001 or http://localhost:8002 to see the
running application.
