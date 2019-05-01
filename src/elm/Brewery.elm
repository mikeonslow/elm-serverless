module Brewery exposing (Data, Type)


type alias Data =
    { id : Int
    , name : String
    , breweryType : String -- Refactor to Custom Type
    , street : String
    , city : String
    , state : String
    , postalCode : String
    , country : String
    , longitude : String
    , latitude : String
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
