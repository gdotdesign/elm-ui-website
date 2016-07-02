## Installing
Elm-UI lives on [NPM](https://www.npmjs.com/package/elm-ui) and can be installed via command line:

`npm install elm-ui@alpha -g`

## Command line tool
Similarly to [Ruby on Rails](http://rubyonrails.org), Elm-UI comes with a command line tool `elm-ui` that lets you:
* Scaffold applications
* Install Elm packages
* Serve your application for development
* Building your application for production
* Generate documentation for your application

Here is the list of options:
```
Usage: elm-ui [options] [command]

Commands:
  install                  Installs Elm dependencies
  docs                     Generates Elm documentation
  help                     Output usage information
  new|init <dir>           Scaffolds a new Elm-UI project
  server|start [options]   Starts development server
  build                    Builds final files

Options:
  -h, --help       output usage information
  -V, --version    output the version number
  -e, --env [env]  environment
```

## Our first application
First we need to scaffold a new application by giving the following command in the terminal:

```
elm-ui init my-awesome-app
```

This will create a directory structure like this one:

```
my-awesome-app
├── config
|   └── development.json
├── public
|   └── index.html
├── source
│   └── Main.elm
├── stylesheets
│   └── main.scss
└── elm-ui.json
```

#### config
This directory contains the files for the [environment variables](https://en.wikipedia.org/wiki/Environment_variable). The application have access to them and they are generally have different values for development and production.

#### source
This directory contains the source (.elm) files for the application. The **Main.elm** is the file that runs and imports all other modules.

#### stylesheets
This directory contains the styles for the application. The **main.scss** file is compiled to **CSS** and loaded in the app.

#### public
This directory contains all of other files (images, pdfs, etc..) that are needed for your application. These files are serves as is without any processing.

The **index.html** in this directory is your main file that is displayed.

#### elm-ui.json
Elm-UI manages the **elm-package.json** for you in order for the app to access the Elm-UI modules. Because of this the third-party packages are need to be set in **elm-ui.json** which has the same fields and syntax as the **elm-package.json**

## Installing dependecies
Any Elm-UI application will have dependencies such as **elm-lang/html** or **other package**. To install these you need to
run this command:
```
elm-ui install
```
After it finishes you are ready for development!

## Running the application
To run the application you need to run the following command in the terminal:
```
elm-ui server
```
This will start three servers:
* http://localhost:8001 - The application server
* http://localhost:8002 - Proxied application server that has live reloading
* http://localhost:8003 - Settings for the live reload server

You can load either http://localhost:8001 or http://localhost:8002 to see the running application.
