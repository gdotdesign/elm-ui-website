# Scaffolding
Scaffolding a new application is done with the `init` command:

```bash
elm-ui init my-awesome-app
cd my-awesome-app
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

* **config** - This directory contains the files for the [environment variables](https://en.wikipedia.org/wiki/Deployment_environment).
<br> The application have access to them and they are generally have different values for development, production, etc...
* **source** - This directory contains the source (.elm) files for the application.
<br>The **Main.elm** is the file that runs and imports all other modules.
* **stylesheets** - This directory contains the styles for the application.
<br>The **main.scss** file is compiled to **CSS** and loaded in the app.
* **public** - This directory contains all of other files (images, pdfs, etc..) that are needed for the application.
<br>These files are served as is without any processing.
<br>The **index.html** in this directory is your main file that is displayed.
* **elm-package.json** - It is your standard Elm package configuration file

## Installing dependecies
Any Elm-UI application will have dependencies such as **gdotdesign/elm-ui**,
**elm-lang/core** and **other packages**.

To install these you need to run the **install** command:

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
