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
import RemoteData exposing (..)
import States
import String.Extra as String
import Task exposing (..)



-- MODEL


initialModel : Model
initialModel =
    { breweries = NotAsked
    , selectedState = Nothing
    , cityQuery = ""
    , debounce = Debounce.init
    }


type alias Model =
    { breweries : WebData (List Brewery.Data)
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
        , Grid.row [] (viewBreweries model)
        ]


viewStateList { selectedState } =
    States.list
        |> (::) ""
        |> List.map String.toTitleCase
        |> List.map (\state -> Select.item [] [ text <| state ])


viewStateItem state selectedState =
    Select.item [] [ text <| state ]


viewBreweries { breweries } =
    let
        viewCol content =
            [ Grid.col (offset2Col8 ++ [ Col.attrs [ class "text-center" ] ]) content ]

        viewBreweryList =
            case breweries of
                NotAsked ->
                    viewCol viewNoSearch

                Loading ->
                    viewCol viewLoader

                Failure err ->
                    let
                        x =
                            Debug.log "err" err
                    in
                    viewCol viewError

                Success breweryList ->
                    if List.isEmpty breweryList then
                        viewCol viewNoBrewFound

                    else
                        List.map viewBrewery breweryList
    in
    viewBreweryList


viewBrewery brewery =
    Grid.col offset2Col8
        [ Card.config []
            |> Card.block []
                [ Block.titleH4 [] [ text brewery.name ]
                , Block.text [] [ text brewery.street, br [] [], text <| viewBreweryAddress brewery ]
                , Block.link [ href <| mapsUrl brewery, target "_blank" ] [ text "View in Google Maps" ]
                ]
            |> Card.view
        ]


viewNoBrewFound =
    [ Card.config []
        |> Card.block []
            [ Block.text []
                [ i [ class "fa-3x fas fa-sad-tear color text-warning mb-1" ] []
                , br [] []
                , span [ style "vertical-align" "middle" ] [ text "No breweries found in this city/state " ]
                ]
            ]
        |> Card.view
    ]


viewBreweryAddress { city, state, postalCode } =
    city ++ ", " ++ state ++ ", " ++ postalCode


viewLoader =
    [ br [] []
    , br [] []
    , i [ class "fa-3x fas fa-spinner fa-pulse text-warning" ] []
    ]


viewNoSearch =
    [ Card.config []
        |> Card.block []
            [ Block.text [] [ text "Use the search fields above to search for breweries" ] ]
        |> Card.view
    ]


viewError =
    [ text "Error occurred fetching brews..." ]



-- UPDATE


type Msg
    = OpenBrewApiResponsed (WebData (List Brewery.Data))
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
                    { model
                        | selectedState = Just state
                        , breweries = Loading
                    }
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
                    { model
                        | cityQuery = city
                        , breweries = Loading
                    }
            in
            ( updatedModel
            , postBreweries updatedModel
            )

        OpenBrewApiResponsed response ->
            let
                updatedModel =
                    { model | breweries = sortBreweries response }
            in
            ( updatedModel, Cmd.none )

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


sortBreweries breweries =
    let
        sortedBreweries =
            RemoteData.map (\b -> List.sortBy .name b) breweries
    in
    sortedBreweries


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
            Http.expectJson (RemoteData.fromResult >> OpenBrewApiResponsed) Brewery.decoder
        }


mapsUrl { name, street, city, state, postalCode } =
    let
        query =
            String.join "," [ name, street, city, state, postalCode ]
    in
    "https://www.google.com/maps/search/?api=1&query=" ++ query


brewApiEndpoint =
    "/.netlify/functions/process"


justifyContentCenter =
    class "justify-content-center"


offset2Col8 =
    [ Col.attrs [ class "mt-3" ], Col.xs12, Col.md8, Col.offsetMd2 ]
