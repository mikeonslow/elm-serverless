port module Main exposing (init, initialModel, main, subscriptions, update, view)

import Browser
import Html exposing (Html, text)


initialModel : Model
initialModel =
    {}


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
