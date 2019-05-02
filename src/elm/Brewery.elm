module Brewery exposing (Data, Type, decoder, queryEncoder)

import Json.Decode as Decode exposing (Decoder, int, list, nullable, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (object)


type alias Data =
    { id : Int
    , name : String
    , breweryType : String -- Refactor to Custom Type
    , street : String
    , city : String
    , state : String
    , postalCode : String
    , country : String
    , longitude : Maybe String
    , latitude : Maybe String
    , phone : String
    , websiteUrl : String
    , updated_at : String
    , tags : List String
    }


type Type
    = Micro
    | Regional
    | Brewpub
    | Large
    | Planning
    | Bar
    | Contract
    | Proprietor


decoder : Decoder (List Data)
decoder =
    list breweryDecoder


breweryDecoder : Decoder Data
breweryDecoder =
    Decode.succeed Data
        |> required "id" int
        |> required "name" string
        |> required "brewery_type" string
        |> required "street" string
        |> required "city" string
        |> required "state" string
        |> required "postal_code" string
        |> required "country" string
        |> required "longitude" (nullable string)
        |> required "latitude" (nullable string)
        |> required "phone" string
        |> required "website_url" string
        |> required "updated_at" string
        |> required "tag_list" (list string)


queryEncoder state city =
    object
        [ ( "by_state", Encode.string state )
        , ( "by_city", Encode.string city )
        ]
