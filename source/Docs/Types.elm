module Docs.Types exposing (..)

import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Json.Decode exposing (string, list, Decoder)


type alias Documentation =
  { modules : List Module }


type alias Module =
  { name : String
  , comment : String
  , aliases : List Alias
  , types : List Type
  , functions : List Function
  }


type alias Alias =
  { name : String
  , comment : String
  , args : List String
  , definition : String
  }


type alias Type =
  { name : String
  , comment : String
  , args : List String
  }


type alias Function =
  { name : String
  , comment : String
  , definition : String
  }


decodeDocumentation : Decoder Documentation
decodeDocumentation =
  Json.Decode.object1 Documentation (list decodeModule)


decodeModule : Decoder Module
decodeModule =
  decode Module
    |> required "name" string
    |> required "comment" string
    |> required "aliases" (list decodeAlias)
    |> required "types" (list decodeType)
    |> required "values" (list decodeFunction)


decodeType : Decoder Type
decodeType =
  decode Type
    |> required "name" string
    |> required "comment" string
    |> required "args" (list string)


decodeFunction : Decoder Function
decodeFunction =
  decode Function
    |> required "name" string
    |> required "comment" string
    |> required "type" string


decodeAlias : Decoder Alias
decodeAlias =
  decode Alias
    |> required "name" string
    |> required "comment" string
    |> required "args" (list string)
    |> required "type" string
