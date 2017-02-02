module Docs.Types exposing (..)

{-| Types for rendering elm documentation.
-}
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Json.Decode exposing (string, list, Decoder)

{-| Representation of a documentation.
-}
type alias Documentation =
  { modules : List Module }


{-| Representation a module.
-}
type alias Module =
  { functions : List Function
  , aliases : List Alias
  , types : List Type
  , comment : String
  , name : String
  }


{-| Representation of a type alias.
-}
type alias Alias =
  { definition : String
  , args : List String
  , comment : String
  , name : String
  }


{-| Representation of a type.
-}
type alias Type =
  { args : List String
  , comment : String
  , name : String
  }

{-| Representation of a function.
-}
type alias Function =
  { definition : String
  , comment : String
  , name : String
  }


{-| Decodes a documentation.
-}
decodeDocumentation : Decoder Documentation
decodeDocumentation =
  Json.Decode.map Documentation (list decodeModule)


{-| Decodes a module.
-}
decodeModule : Decoder Module
decodeModule =
  decode Module
    |> required "values" (list decodeFunction)
    |> required "aliases" (list decodeAlias)
    |> required "types" (list decodeType)
    |> required "comment" string
    |> required "name" string


{-| Decodes a type.
-}
decodeType : Decoder Type
decodeType =
  decode Type
    |> required "args" (list string)
    |> required "comment" string
    |> required "name" string


{-| Decodes a function.
-}
decodeFunction : Decoder Function
decodeFunction =
  decode Function
    |> required "type" string
    |> required "comment" string
    |> required "name" string


{-| Decodes a type alias.
-}
decodeAlias : Decoder Alias
decodeAlias =
  decode Alias
    |> required "type" string
    |> required "args" (list string)
    |> required "comment" string
    |> required "name" string
