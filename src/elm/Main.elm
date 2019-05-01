module Main exposing (init, initialModel, main, subscriptions, update, view)

import Bootstrap.Button as Button
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
            [ Grid.col [ Col.attrs [ class "text-center" ] ]
                [ h1 [] [ text "Elm Brewfinder" ] ]
            ]
        , Grid.row []
            [ Grid.col []
                [ text " " ]
            ]
        , Grid.row []
            [ Grid.col [ Col.textAlign Text.alignXsCenter ]
                [ Form.formInline [ justifyContentCenter ]
                    [ Form.label [] [ text "State" ]
                    , Select.select [ Select.large, Select.onChange StateSelectionChanged ] (viewStateList model)
                    , Form.label [] [ text "City" ]
                    , Input.text
                        [ Input.large
                        , Input.attrs [ placeholder "e.g. Southfield" ]
                        , Input.onInput CityQueryUpdated
                        ]
                    ]
                ]
            ]
        ]


viewStateList { selectedState } =
    States.list
        |> (::) ""
        |> List.map String.toTitleCase
        |> List.map (\state -> Select.item [] [ text <| state ])


viewStateItem state selectedState =
    Select.item [] [ text <| state ]



-- UPDATE


type Msg
    = OpenBrewApiResponsed
    | CityQuerySaved String
    | StateSelectionChanged String
    | DebounceTriggered Debounce.Msg
    | CityQueryUpdated String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StateSelectionChanged state ->
            ( { model | selectedState = Just state }
            , Cmd.none
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

        _ ->
            ( model, Cmd.none )

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


brewApiEndpoint =
    "/.netlify/functions/process"


justifyContentCenter =
    class "justify-content-center"
