module MessageToast exposing
    ( MessageToast(..)
    , init
    , danger, info, success, warning
    , view
    , subscriptions
    , getOldestToast
    , popOldestToast
    )

{-| MessageToast displays a list of feedback messages, each with a specified
message-type.


# Definition

@docs MessageToast


# Init

@docs init


# Create

@docs danger, info, success, warning


# View

@docs view


# Subscriptions

@docs subscriptions


# Query

@docs getOldestToast


# Manipulate

@docs popOldestToast

-}

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick)
import Icons
import Time



-- MODEL


{-| Different message toast types.
-}
type ToastType
    = Danger
    | Info
    | Success
    | Warning


{-| ToastMessage holds the message, the specified type and the unique id.
-}
type alias ToastMessage =
    { message : String
    , toastType : ToastType
    , id : Int
    }


{-| MessageToast holds the collection of messages.
-}
type MessageToast msg
    = MessageToast
        { updateMsg : MessageToast msg -> msg
        , delayInMs : Float
        , toastsToShow : Int
        }
        (List ToastMessage)



-- INIT


{-| Initializes the messageToast handler.
-}
init : (MessageToast msg -> msg) -> MessageToast msg
init updateMsg =
    MessageToast
        { updateMsg = updateMsg
        , delayInMs = 8000
        , toastsToShow = 4
        }
        []



-- CREATE


{-| Displays a dangerous message.
-}
danger : MessageToast msg -> String -> MessageToast msg
danger toast message =
    appendToList { message = message, toastType = Danger, id = 0 } toast


{-| Displays an informative message.
-}
info : MessageToast msg -> String -> MessageToast msg
info toast message =
    appendToList { message = message, toastType = Info, id = 0 } toast


{-| Displays a success message.
-}
success : MessageToast msg -> String -> MessageToast msg
success toast message =
    appendToList { message = message, toastType = Success, id = 0 } toast


{-| Displays a warning message.
-}
warning : MessageToast msg -> String -> MessageToast msg
warning toast message =
    appendToList { message = message, toastType = Warning, id = 0 } toast



-- VIEW


{-| Displays the message toasts.
-}
view : MessageToast msg -> Html msg
view (MessageToast config toasts) =
    let
        dismissEvent =
            \toastMessage ->
                toasts
                    |> List.filter (\toast -> toast.id /= toastMessage.id)
                    |> MessageToast config
                    |> config.updateMsg
    in
    case List.reverse toasts of
        [] ->
            text ""

        toastList ->
            div
                [ id "elm-message-toast"
                , style "width" "350px"
                , style "max-width" "90%"
                , style "position" "fixed"
                , style "bottom" "20px"
                , style "right" "20px"
                , style "z-index" "50"
                , style "display" "flex"
                , style "flex-direction" "flex-col"
                , style "flex-flow" "wrap"
                , style "overflow" "hidden"
                ]
                (viewToasts dismissEvent toastList)


viewToasts : (ToastMessage -> msg) -> List ToastMessage -> List (Html msg)
viewToasts dismissEvent toasts =
    case toasts of
        topToast :: remainingToasts ->
            List.append [ viewToast dismissEvent topToast ] (viewToasts dismissEvent remainingToasts)

        [] ->
            [ text "" ]


viewToast : (ToastMessage -> msg) -> ToastMessage -> Html msg
viewToast dismissEvent toast =
    let
        messageToastAttributes =
            [ class ("message-toast" ++ " " ++ toastTypeClass toast.toastType)
            , onClick <| dismissEvent toast
            , style "width" "100%"
            , style "z-index" "50"
            , style "cursor" "pointer"
            , style "font-size" "0.75rem"
            , style "background-color" "#fff"
            , style "display" "flex"
            , style "flex-direction" "row"
            , style "align-items" "center"
            , style "border-radius" "0.25rem"
            , style "margin" "0.125rem 0"
            , style "box-shadow" "0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)"
            ]
    in
    div messageToastAttributes
        [ viewToastIcon toast
        , viewToastMessage toast
        ]


viewToastIcon : ToastMessage -> Html msg
viewToastIcon toast =
    let
        ( bgColor, icon ) =
            case toast.toastType of
                Danger ->
                    ( "#cc0000", Icons.xCircle )

                Info ->
                    ( "#8b8d8f", Icons.info )

                Success ->
                    ( "#3f9c35", Icons.checkCircle )

                Warning ->
                    ( "#ec7a08", Icons.alertTriangle )
    in
    span
        [ style "background-color" bgColor
        , style "color" "rgba(255,255,255,.74)"
        , style "text-align" "center"
        , style "width" "3rem"
        , style "padding" "0.5rem 0"
        , style "height" "100%"
        , style "border-top-left-radius" "0.25rem"
        , style "border-bottom-left-radius" "0.25rem"
        , style "flex-shrink" "0"
        , style "flex-grow" "0"
        ]
        [ icon ]


viewToastMessage : ToastMessage -> Html msg
viewToastMessage toast =
    span
        [ style "padding" "0.5rem"
        , style "flex-grow" "1"
        ]
        [ text toast.message ]



-- SUBSCRIPTIONS


{-| Subscription to automatically remove the oldest toast that is still displayed.
-}
subscriptions : MessageToast msg -> Sub msg
subscriptions ((MessageToast config _) as messageToast) =
    case getOldestToast messageToast of
        Just toastMessage ->
            Time.every config.delayInMs (\_ -> config.updateMsg <| popOldestToast messageToast)

        Nothing ->
            Sub.none



-- QUERY


{-| Provides the time-wise oldest message toast that is still shown.
-}
getOldestToast : MessageToast msg -> Maybe ToastMessage
getOldestToast (MessageToast _ toasts) =
    List.head toasts



-- MANIPULATION


{-| Removes the time-wise oldest toast from the existing collection.
-}
popOldestToast : MessageToast msg -> MessageToast msg
popOldestToast (MessageToast config toasts) =
    MessageToast config <| List.drop 1 toasts



-- HELPER


appendToList : ToastMessage -> MessageToast msg -> MessageToast msg
appendToList toastMessage (MessageToast config toasts) =
    let
        lastUsedId =
            toasts
                |> List.head
                |> Maybe.map .id
                |> Maybe.withDefault 0
    in
    toasts
        |> List.append [ { toastMessage | id = lastUsedId + 1 } ]
        |> List.take config.toastsToShow
        |> MessageToast config


{-| Provides a specific class name to better distinguish the different toasts outside.
-}
toastTypeClass : ToastType -> String
toastTypeClass toastType =
    case toastType of
        Danger ->
            "danger"

        Info ->
            "info"

        Success ->
            "success"

        Warning ->
            "warning"
