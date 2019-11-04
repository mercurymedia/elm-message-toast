module Main exposing (main)

import Browser
import Html exposing (Html, button, div, table, td, text, th, tr)
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
    { -- MessageToast can be initialized with custom settings
      customMessageToast = MessageToast.initWithConfig UpdatedCustomMessageToast { delayInMs = 2000, toastsToShow = 10 }

    -- MessageToast provides default settings and is therefore easy to use
    , simpleMessageToast = MessageToast.init UpdatedSimpleMessageToast
    }



-- MODEL


type alias Model =
    { customMessageToast : MessageToast Msg
    , simpleMessageToast : MessageToast Msg
    }


type Msg
    = ShowDangerCustom
    | ShowDangerSimple
    | ShowInfoCustom
    | ShowInfoSimple
    | ShowSuccessCustom
    | ShowSuccessSimple
    | ShowWarningCustom
    | ShowWarningSimple
    | ShowSuperLongCustom
    | ShowSuperLongSimple
    | UpdatedCustomMessageToast (MessageToast Msg)
    | UpdatedSimpleMessageToast (MessageToast Msg)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowDangerCustom ->
            ( { model | customMessageToast = MessageToast.danger model.customMessageToast "Something critical happend." }, Cmd.none )

        ShowDangerSimple ->
            ( { model | simpleMessageToast = MessageToast.danger model.simpleMessageToast "Something critical happend." }, Cmd.none )

        ShowInfoCustom ->
            ( { model | customMessageToast = MessageToast.info model.customMessageToast "Process aborted." }, Cmd.none )

        ShowInfoSimple ->
            ( { model | simpleMessageToast = MessageToast.info model.simpleMessageToast "Process aborted." }, Cmd.none )

        ShowSuccessCustom ->
            ( { model | customMessageToast = MessageToast.success model.customMessageToast "Entity created." }, Cmd.none )

        ShowSuccessSimple ->
            ( { model | simpleMessageToast = MessageToast.success model.simpleMessageToast "Entity created." }, Cmd.none )

        ShowWarningCustom ->
            ( { model | customMessageToast = MessageToast.warning model.customMessageToast "Could not create it." }, Cmd.none )

        ShowWarningSimple ->
            ( { model | simpleMessageToast = MessageToast.warning model.simpleMessageToast "Could not create it." }, Cmd.none )

        ShowSuperLongCustom ->
            let
                loremIpsum =
                    "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut "
                        ++ "labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores "
                        ++ "et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. "
                        ++ "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut "
                        ++ "labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores "
                        ++ "et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
            in
            ( { model | customMessageToast = MessageToast.info model.customMessageToast loremIpsum }, Cmd.none )

        ShowSuperLongSimple ->
            let
                loremIpsum =
                    "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut "
                        ++ "labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores "
                        ++ "et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. "
                        ++ "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut "
                        ++ "labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores "
                        ++ "et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
            in
            ( { model | simpleMessageToast = MessageToast.info model.simpleMessageToast loremIpsum }, Cmd.none )

        UpdatedCustomMessageToast updatedMessageToast ->
            -- Only needed to re-assign the updated MessageToast to the model.
            ( { model | customMessageToast = updatedMessageToast }, Cmd.none )

        UpdatedSimpleMessageToast updatedMessageToast ->
            -- Only needed to re-assign the updated MessageToast to the model.
            ( { model | simpleMessageToast = updatedMessageToast }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ style "width" "100vw", style "height" "100vh" ]
        [ -- Stylings (or in general Html.Attribute's) of the MessageToast view can be overriden
          -- NOTE: Does not need to be initialized with `initCustom`
          model.customMessageToast
            |> MessageToast.overwriteContainerAttributes [ style "top" "20px", style "bottom" "auto" ]
            |> MessageToast.overwriteToastAttributes [ style "font-size" "1rem" ]
            |> MessageToast.view

        -- MessageToast view provides default styling and is therefore easy to use
        , MessageToast.view model.simpleMessageToast
        , table []
            [ tr []
                [ th [] []
                , th [ class "danger" ] [ text "DANGER" ]
                , th [ class "info" ] [ text "INFO" ]
                , th [ class "success" ] [ text "SUCCESS" ]
                , th [ class "warning" ] [ text "WARNING" ]
                , th [ class "info" ] [ text "SUPERLONG" ]
                ]
            , tr []
                [ th [] [ text "Simple Toasts" ]
                , td [] [ button [ onClick <| ShowDangerSimple ] [ text "Show" ] ]
                , td [] [ button [ onClick <| ShowInfoSimple ] [ text "Show" ] ]
                , td [] [ button [ onClick <| ShowSuccessSimple ] [ text "Show" ] ]
                , td [] [ button [ onClick <| ShowWarningSimple ] [ text "Show" ] ]
                , td [] [ button [ onClick <| ShowSuperLongSimple ] [ text "Show" ] ]
                ]
            , tr []
                [ th [] [ text "Customized Toasts" ]
                , td [] [ button [ onClick <| ShowDangerCustom ] [ text "Show" ] ]
                , td [] [ button [ onClick <| ShowInfoCustom ] [ text "Show" ] ]
                , td [] [ button [ onClick <| ShowSuccessCustom ] [ text "Show" ] ]
                , td [] [ button [ onClick <| ShowWarningCustom ] [ text "Show" ] ]
                , td [] [ button [ onClick <| ShowSuperLongCustom ] [ text "Show" ] ]
                ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ -- MessageToast provides a subscription to close automatically which is easy to use.
          MessageToast.subscriptions model.simpleMessageToast
        , MessageToast.subscriptions model.customMessageToast
        ]
