# Handling Files
Handling files are very common for web and mobile applications for a lot of
tasks including:
- Selecting and uploading files to a server
- Selecting and showing images for the users local machine
- Downloading / saving files to the users local machine

Elm-UI have the `Ui.Native.FileManager` module which exposes functions for
selecting, downloading and reading files.

_Currently there are no official way for doing these things in Elm. The
following patterns and solutions are Elm-UI only and uses native code._

## The File Type
If the user selects file(s) then the end result will be a single or a
list of `File`:

```elm
type alias File =
  { name : String
  , mimeType : String
  , size : Float
  , data : Data
  }
```

These `File` records can only be created by the exposed API.

## Selecting Files
Selecting files are implemented with an `input[type=file]` natively and exposed
via the `openSingleDecoder` and `openMultipleDecoder` APIs.

An example of opening a file browser for selecting a single image:
```elm
{- We need two tags one for opening a file browser
and one for getting the selected file.
-}
| Opened (Task Never File)
| GetFile File

{- In the  update, we handle the two tags.
-}
Opened task ->
  (model, Task.peform (\_ -> Debug.crash "") GetFile task

GetFile file ->
  ({ model | file = file }, Cmd.none)

{- In the view we use the decoder to get the task for
getting the selected file.
-}
div
  [ on "click" (Ui.Native.FileManager.openSingleDecoder "image/*" Opened) ]
  [ text "Open File" ]
```

## Reading Files
After selecting a file you might want to read that as a string or as a
[Data URI](https://en.wikipedia.org/wiki/Data_URI_scheme). There are conviniece
functions for these: `readAsString` and `readAsDataURL` that will return a task.

Examples of reading a file:
```elm
-- Ui.FileManager.readAsDataURL : File -> Task Never String
task = Ui.FileManager.readAsDataURL file

-- Ui.FileManager.readAsString : File -> Task Never String
task = Ui.FileManager.readAsString file
```

## Uploading Files
Currently the [Http package](http://package.elm-lang.org/packages/evancz/elm-http/3.0.1)
only allows sending **string or multipart data** and not binary or file data.

The implementation however is using [FormData](https://developer.mozilla.org/en/docs/Web/API/FormData)
which allows appending files. The trick is to create a `Http.StringData` that
has a `File` object associated with it and passing that masqueraded as a string
to the FormData object. By doing this we can send multipart forms with files.

To convert a `File` to FormData you can use the following code:
```elm
-- Ui.Native.FileManager.toFormData : String -> File -> Http.Data
data = Ui.Native.FileManager.toFormData "key" file
```

A full example of a file upload can be viewed [here](https://github.com/gdotdesign/elm-ui-examples/tree/master/file-upload).

## Downloading Files
Sometimes you have string data that you want to download to the users local
machine for example a JSON or text file.

You can initiate a download with `download` function:
```elm
-- Ui.Native.FileManager.download : String -> String -> String -> Task Never String
task = Ui.Native.FileManager.download "my.json" "application/json" stringData
```

Caveats:
- This function uses the [chrome.fileSystem](https://developer.chrome.com/apps/fileSystem)
	to show the save as dialog for Chrome apps.
- This function wraps the [download.js](http://danml.com/download.html) library
