module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import MessageToast exposing (MessageToast)
import Time exposing (Month(..), Posix)



-- INIT


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { messageToast = MessageToast.initWithConfig UpdatedMessageToast { delayInMs = 2000, toastsToShow = 10 }
    }



-- MODEL


type alias Model =
    { messageToast : MessageToast Msg
    }


type Msg
    = ShowMessageToastDanger
    | ShowMessageToastInfo
    | ShowMessageToastSuccess
    | ShowMessageToastWarning
    | ShowSuperLongTextMessageToast
    | UpdatedMessageToast (MessageToast Msg)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowMessageToastDanger ->
            ( { model | messageToast = MessageToast.danger model.messageToast "Something critical happend." }, Cmd.none )

        ShowMessageToastInfo ->
            ( { model | messageToast = MessageToast.info model.messageToast "Process aborted." }, Cmd.none )

        ShowMessageToastSuccess ->
            ( { model | messageToast = MessageToast.success model.messageToast "Entity created." }, Cmd.none )

        ShowMessageToastWarning ->
            ( { model | messageToast = MessageToast.warning model.messageToast "Could not create it." }, Cmd.none )

        ShowSuperLongTextMessageToast ->
            let
                loremIpsum =
                    "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut "
                        ++ "labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores "
                        ++ "et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. "
                        ++ "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut "
                        ++ "labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores "
                        ++ "et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
            in
            ( { model | messageToast = MessageToast.info model.messageToast loremIpsum }, Cmd.none )

        UpdatedMessageToast updatedMessageToast ->
            ( { model | messageToast = updatedMessageToast }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ style "width" "100vw", style "height" "100vh" ]
        [ model.messageToast
            |> MessageToast.overwriteContainerAttributes [ style "font-size" "1rem" ]
            |> MessageToast.view
        , div [ style "background-color" "#202B5C", style "font-size" "0.75rem", style "display" "flex", style "flex-direction" "row" ]
            [ div [ style "margin" "1rem" ] [ button [ onClick <| ShowMessageToastDanger ] [ text "Show DANGER messageToast" ] ]
            , div [ style "margin" "1rem" ] [ button [ onClick <| ShowMessageToastInfo ] [ text "Show INFO messageToast" ] ]
            , div [ style "margin" "1rem" ] [ button [ onClick <| ShowMessageToastSuccess ] [ text "Show SUCCESS messageToast" ] ]
            , div [ style "margin" "1rem" ] [ button [ onClick <| ShowMessageToastWarning ] [ text "Show WARNING messageToast" ] ]
            , div [ style "margin" "1rem" ] [ button [ onClick <| ShowSuperLongTextMessageToast ] [ text "Show SUPERLONG messageToast" ] ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    MessageToast.subscriptions model.messageToast
