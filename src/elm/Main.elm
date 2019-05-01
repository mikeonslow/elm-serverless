module Main exposing (init, initialModel, main, subscriptions, update, view)

import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Select as Select
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Brewery
import Browser
import Html exposing (Html, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import States
import String.Extra as String
import Bootstrap.Text as Text


-- MODEL


initialModel : Model
initialModel =
    { breweries = []
    , selectedState = Nothing
    , cityQuery = ""
    }


type alias Model =
    { breweries : List Brewery.Data
    , selectedState : Maybe String
    , cityQuery : String
    }



-- VIEW


view : Model -> Html Msg
view model =
    Grid.container []
        [ Grid.row []
            [ Grid.col []
                [ text " " ]
            ]
        , Grid.row []
            [ Grid.col [ Col.textAlign Text.alignXsCenter]
                [ Form.formInline []
                    [ Form.label [] [ text "State" ]
                    , Select.select [ Select.large, Select.onChange StateSelectionChanged ] (viewStateList model)
                    , Form.label [] [ text "City" ]
                    , Input.text [ Input.large, Input.attrs [ placeholder "e.g. Southfield" ] ]
                    ]
                ]
            ]
        ]


viewStateList { selectedState } =
    States.list
        |> List.map String.toTitleCase
        |> List.map (\state -> Select.item [] [ text <| state ])


viewStateItem state selectedState =
    Select.item [] [ text <| state ]



-- UPDATE


type Msg
    = OpenBrewApiResponsed
    | StateSelectionChanged String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StateSelectionChanged state ->
            ( { model | selectedState = Just state }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )



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



-- HELPERS


brewApiEndpoint =
    "/.netlify/functions/process"
