module Configured exposing (main)

import Browser
import Html exposing (Html, button, div, span, table, td, text, th, tr)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import MessageToast exposing (MessageToast)



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
    { -- MessageToast can be initialized with custom settings using `initCustom`
      messageToast = MessageToast.initWithConfig UpdatedMessageToast { delayInMs = 2000, toastsToShow = 10 }
    }



-- MODEL


type alias Model =
    { messageToast : MessageToast Msg }


type Msg
    = ShowDanger
    | ShowInfo
    | ShowSuccess
    | ShowWarning
    | ShowSuperLong
    | ShowCustomView
    | UpdatedMessageToast (MessageToast Msg)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowDanger ->
            let
                toast =
                    model.messageToast
                        |> MessageToast.danger
                        |> MessageToast.withMessage "Something critical happened."
            in
            ( { model | messageToast = toast }, Cmd.none )

        ShowInfo ->
            let
                toast =
                    model.messageToast
                        |> MessageToast.info
                        |> MessageToast.withMessage "Process aborted."
            in
            ( { model | messageToast = toast }, Cmd.none )

        ShowSuccess ->
            let
                toast =
                    model.messageToast
                        |> MessageToast.success
                        |> MessageToast.withMessage "Entity created."
            in
            ( { model | messageToast = toast }, Cmd.none )

        ShowWarning ->
            let
                toast =
                    model.messageToast
                        |> MessageToast.warning
                        |> MessageToast.withMessage "Could not create entity."
            in
            ( { model | messageToast = toast }, Cmd.none )

        ShowSuperLong ->
            let
                loremIpsum =
                    "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut "
                        ++ "labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores "
                        ++ "et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. "
                        ++ "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut "
                        ++ "labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores "
                        ++ "et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."

                toast =
                    model.messageToast
                        |> MessageToast.info
                        |> MessageToast.withMessage loremIpsum
            in
            ( { model | messageToast = toast }, Cmd.none )

        ShowCustomView ->
            let
                toast =
                    model.messageToast
                        |> MessageToast.warning
                        |> MessageToast.withHtml (viewMessageToast "My message title" "My custom messageToast body.")
            in
            ( { model | messageToast = toast }, Cmd.none )

        UpdatedMessageToast updatedMessageToast ->
            -- Only needed to re-assign the updated MessageToast to the model.
            ( { model | messageToast = updatedMessageToast }, Cmd.none )



-- VIEW


viewMessageToast : String -> String -> Html Msg
viewMessageToast title body =
    div [ style "display" "flex", style "flex-direction" "column" ]
        [ span [ style "font-weight" "900" ] [ text title ]
        , text body
        ]


view : Model -> Html Msg
view model =
    let
        thStyle =
            [ style "background-color" "lightgray", style "padding" "0.75rem", style "min-width" "150px", style "text-align" "center" ]
    in
    div [ style "width" "100vw", style "height" "100vh" ]
        [ -- Stylings (or in general Html.Attribute's) of the MessageToast view can be overridden
          -- NOTE: Does not need to be initialized with `initCustom`
          model.messageToast
            |> MessageToast.overwriteContainerAttributes [ style "top" "20px", style "bottom" "auto" ]
            |> MessageToast.overwriteToastAttributes [ style "font-size" "1rem" ]
            |> MessageToast.view
        , table []
            [ tr []
                [ th thStyle []
                , th (thStyle ++ [ style "background-color" "red" ]) [ text "DANGER" ]
                , th (thStyle ++ [ style "background-color" "gray" ]) [ text "INFO" ]
                , th (thStyle ++ [ style "background-color" "lime" ]) [ text "SUCCESS" ]
                , th (thStyle ++ [ style "background-color" "orange" ]) [ text "WARNING" ]
                , th (thStyle ++ [ style "background-color" "gray" ]) [ text "SUPERLONG" ]
                , th (thStyle ++ [ style "background-color" "orange" ]) [ text "CUSTOM VIEW" ]
                ]
            , tr []
                [ th thStyle [ text "Show Message" ]
                , td [ style "background-color" "#ddd", style "text-align" "center" ] [ button [ onClick <| ShowDanger ] [ text "Show" ] ]
                , td [ style "background-color" "#ddd", style "text-align" "center" ] [ button [ onClick <| ShowInfo ] [ text "Show" ] ]
                , td [ style "background-color" "#ddd", style "text-align" "center" ] [ button [ onClick <| ShowSuccess ] [ text "Show" ] ]
                , td [ style "background-color" "#ddd", style "text-align" "center" ] [ button [ onClick <| ShowWarning ] [ text "Show" ] ]
                , td [ style "background-color" "#ddd", style "text-align" "center" ] [ button [ onClick <| ShowSuperLong ] [ text "Show" ] ]
                , td [ style "background-color" "#ddd", style "text-align" "center" ] [ button [ onClick <| ShowCustomView ] [ text "Show" ] ]
                ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ -- MessageToast provides a subscription to close automatically.
          MessageToast.subscriptions model.messageToast
        ]
