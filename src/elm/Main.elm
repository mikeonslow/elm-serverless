port module Main exposing (init, initialModel, main, subscriptions, update, view)

import Browser
import Html exposing (Html, text)


initialModel : Model
initialModel =
    { breweries: List Brewery }

type alias Brewery = {
    id: Int,
    
    name: String
}

{--

{
	"id": 3405,
	"name": "Axle Brewing Company",
	"brewery_type": "micro",
	"street": "567 Livernois St",
	"city": "Ferndale",
	"state": "Michigan",
	"postal_code": "48220-2303",
	"country": "United States",
	"longitude": "-83.1428144",
	"latitude": "42.4508021",
	"phone": "2486137002",
	"website_url": "http://www.axlebrewing.com",
	"updated_at": "2018-08-24T00:42:08.765Z",
	"tag_list": []
}

--}


type alias Model =
    {}


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
