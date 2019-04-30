port module Main exposing (init, initialModel, main, subscriptions, update, view)

import Browser
import Html exposing (Html, text)


initialModel : Model
initialModel =
    { breweries = [] }


type alias Model =
    { breweries : List Brewery }


type alias Brewery =
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


type BreweryType
    = Micro
    | Regional
    | Brewpub
    | Large
    | Planning
    | Bar
    | Contract
    | Proprietor


view : Model -> Html Msg
view model =
    text "Hello, World!!!!!"


type Msg
    = None


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none )


subscriptions _ =
    Sub.none


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel
    , Cmd.none
    )
