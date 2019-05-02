module Main exposing (init, initialModel, main, subscriptions, update, view)

import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Select as Select
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Text as Text
import Brewery
import Browser
import Debounce exposing (Debounce)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import States
import String.Extra as String
import Task exposing (..)



-- MODEL


initialModel : Model
initialModel =
    { breweries = []
    , selectedState = Nothing
    , cityQuery = ""
    , debounce = Debounce.init
    }


type alias Model =
    { breweries : List Brewery.Data
    , selectedState : Maybe String
    , cityQuery : String
    , debounce : Debounce String
    }



-- VIEW


view : Model -> Html Msg
view model =
    Grid.container []
        [ Grid.row []
            [ Grid.col []
                [ text "\u{00A0}" ]
            ]
        , Grid.row
            []
            [ Grid.col [ Col.attrs [ class "text-center" ] ]
                [ img [ src "/images/beer_mugs.png", height 100 ] [], h1 [] [ text "Elm Brewfinder" ] ]
            ]
        , Grid.row []
            [ Grid.col []
                [ text "\u{00A0}" ]
            ]
        , Grid.row []
            [ Grid.col [ Col.textAlign Text.alignXsCenter ]
                [ Form.formInline [ justifyContentCenter ]
                    [ Form.label [] [ text "State" ]
                    , Select.select [ Select.large, Select.onChange StateSelectionChanged ] (viewStateList model)
                    , Form.label [] [ text "City" ]
                    , Input.text
                        [ Input.large
                        , Input.attrs [ placeholder "e.g. Detroit" ]
                        , Input.onInput CityQueryUpdated
                        ]
                    ]
                ]
            ]
        , Grid.row []
            (List.map viewBrewery model.breweries)
        ]


viewStateList { selectedState } =
    States.list
        |> (::) ""
        |> List.map String.toTitleCase
        |> List.map (\state -> Select.item [] [ text <| state ])


viewStateItem state selectedState =
    Select.item [] [ text <| state ]


viewBrewery brewery =
    Grid.col [ Col.xs12 ]
        [ Card.config [ Card.attrs [ class "mt-3" ] ]
            |> Card.block []
                [ Block.titleH4 [] [ text brewery.name ]
                , Block.text [] [ text brewery.street, br [] [], text <| viewBreweryAddress brewery ]
                , Block.link [ href <| mapsUrl brewery, target "_blank" ] [ text "View in Google Maps" ]
                ]
            |> Card.view
        ]


viewBreweryAddress { city, state, postalCode } =
    city ++ ", " ++ state ++ ", " ++ postalCode



-- UPDATE


type Msg
    = OpenBrewApiResponsed (Result Http.Error (List Brewery.Data))
    | CityQuerySaved String
    | StateSelectionChanged String
    | DebounceTriggered Debounce.Msg
    | CityQueryUpdated String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StateSelectionChanged state ->
            let
                updatedModel =
                    { model | selectedState = Just state }
            in
            ( updatedModel
            , postBreweries updatedModel
            )

        CityQueryUpdated s ->
            let
                ( debounce, cmd ) =
                    Debounce.push debounceConfig s model.debounce
            in
            ( { model
                | cityQuery = s
                , debounce = debounce
              }
            , cmd
            )

        CityQuerySaved city ->
            let
                updatedModel =
                    { model | cityQuery = city }
            in
            ( updatedModel
            , postBreweries updatedModel
            )

        OpenBrewApiResponsed response ->
            case response of
                Ok breweries ->
                    let
                        updatedModel =
                            { model | breweries = List.sortBy .name breweries }
                    in
                    ( updatedModel, Cmd.none )

                Err error ->
                    let
                        x =
                            Debug.log "error" error
                    in
                    ( model, Cmd.none )

        DebounceTriggered msg_ ->
            let
                ( debounce, cmd ) =
                    Debounce.update
                        debounceConfig
                        (Debounce.takeLast save)
                        msg_
                        model.debounce
            in
            ( { model | debounce = debounce }
            , cmd
            )


save : String -> Cmd Msg
save s =
    Task.perform CityQuerySaved (Task.succeed s)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


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



-- CONFIG


debounceConfig =
    { strategy = Debounce.later 1000
    , transform = DebounceTriggered
    }



-- HELPERS


postBreweries : Model -> Cmd Msg
postBreweries { selectedState, cityQuery } =
    let
        state =
            Maybe.withDefault "" selectedState
    in
    Http.post
        { url = brewApiEndpoint
        , body = Http.jsonBody (Brewery.queryEncoder state cityQuery)
        , expect =
            Http.expectJson
                OpenBrewApiResponsed
                Brewery.decoder
        }


mapsUrl { name, street, city, state, postalCode } =
    let
        query =
            String.join "," [ name, street, city, state, postalCode ]
    in
    "https://www.google.com/maps/search/?api=1&query=" ++ query



-- Detroit%20Beer%20Co%2C%201529%20Broadway%20St%20Ste%20100%2C%20Detroit%2C%20Michigan


brewApiEndpoint =
    "/.netlify/functions/process"


justifyContentCenter =
    class "justify-content-center"
