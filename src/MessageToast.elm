module MessageToast exposing
    ( MessageToast(..)
    , init, initWithConfig
    , danger, info, success, warning
    , view
    , subscriptions
    , getOldestToast
    , overwriteContainerAttributes, overwriteIconAttributes, overwriteMessageAttributes, overwriteToastAttributes, popOldestToast
    )

{-| MessageToast displays a list of feedback messages, each with a specified
message-type.


# Definition

@docs MessageToast


# Init

@docs init, initWithConfig


# Create

@docs danger, info, success, warning


# View

@docs view


# Subscriptions

@docs subscriptions


# Query

@docs getOldestToast


# Manipulate

@docs overwriteContainerAttributes, overwriteIconAttributes, overwriteMessageAttributes, overwriteToastAttributes, popOldestToast

-}

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick)
import Icons
import Time



-- MODEL


{-| MessageToast holds the collection of messages.
-}
type MessageToast msg
    = MessageToast (ToastConfig msg) (List ToastMessage)


{-| Different message toast types.
-}
type ToastType
    = Danger
    | Info
    | Success
    | Warning


{-| Holds the configuration of the message toast.
-}
type alias ToastConfig msg =
    { customContainerAttributes : List (Html.Attribute msg)
    , customIconAttributes : List (Html.Attribute msg)
    , customMessageAttributes : List (Html.Attribute msg)
    , customToastAttributes : List (Html.Attribute msg)
    , delayInMs : Float
    , toastsToShow : Int
    , updateMsg : MessageToast msg -> msg
    }


{-| ToastMessage holds the message, the specified type and the unique id.
-}
type alias ToastMessage =
    { message : String
    , toastType : ToastType
    , id : Int
    }



-- INIT


{-| Initializes the messageToast handler with the default settings.

    - Delay: 8 seconds
    - Showing messages: 4
    - Styling: default

-}
init : (MessageToast msg -> msg) -> MessageToast msg
init updateMsg =
    let
        config =
            { customContainerAttributes = []
            , customIconAttributes = []
            , customMessageAttributes = []
            , customToastAttributes = []
            , delayInMs = 8000
            , toastsToShow = 4
            , updateMsg = updateMsg
            }
    in
    MessageToast config []


{-| Initializes a custom messageToast handler with the provided options.
-}
initWithConfig : (MessageToast msg -> msg) -> { delayInMs : Float, toastsToShow : Int } -> MessageToast msg
initWithConfig updateMsg customConfig =
    let
        config =
            { customContainerAttributes = []
            , customIconAttributes = []
            , customMessageAttributes = []
            , customToastAttributes = []
            , delayInMs = customConfig.delayInMs
            , toastsToShow = customConfig.toastsToShow
            , updateMsg = updateMsg
            }
    in
    MessageToast config []



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


{-| Displays the configured message toasts.
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
            let
                defaultContainerAttributes =
                    [ id "elm-message-toast"
                    , style "width" "350px"
                    , style "max-width" "90%"
                    , style "max-height" "90%"
                    , style "overflow" "auto"
                    , style "position" "fixed"
                    , style "bottom" "20px"
                    , style "right" "20px"
                    , style "z-index" "50"
                    , style "display" "flex"
                    , style "flex-direction" "flex-col"
                    , style "flex-flow" "wrap"
                    ]

                updatedContainerAttributes =
                    List.append defaultContainerAttributes config.customContainerAttributes
            in
            div updatedContainerAttributes (viewToasts dismissEvent config toastList)


viewToasts : (ToastMessage -> msg) -> ToastConfig msg -> List ToastMessage -> List (Html msg)
viewToasts dismissEvent config toasts =
    case toasts of
        topToast :: remainingToasts ->
            List.append [ viewToast dismissEvent config topToast ] (viewToasts dismissEvent config remainingToasts)

        [] ->
            [ text "" ]


viewToast : (ToastMessage -> msg) -> ToastConfig msg -> ToastMessage -> Html msg
viewToast dismissEvent config toast =
    let
        defaultToastAttributes =
            [ class ("message-toast" ++ " " ++ toastTypeClass toast.toastType)
            , style "width" "100%"
            , style "position" "relative"
            , style "z-index" "50"
            , style "font-size" "0.75rem"
            , style "background-color" "#fff"
            , style "display" "flex"
            , style "flex-direction" "row"
            , style "align-items" "center"
            , style "border" "1px solid #bbb"
            , style "border-radius" "0.25rem"
            , style "margin" "0.125rem 0"
            , style "box-shadow" "0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)"
            ]

        updatedToastAttributes =
            List.append defaultToastAttributes config.customToastAttributes
    in
    div updatedToastAttributes
        [ viewToastIcon config.customIconAttributes toast
        , viewToastMessage config.customMessageAttributes toast
        , viewCloseIcon (dismissEvent toast)
        ]


viewToastIcon : List (Html.Attribute msg) -> ToastMessage -> Html msg
viewToastIcon customIconAttributes toast =
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

        defaultToastIconStyles =
            [ style "background-color" bgColor
            , style "color" "rgba(255,255,255,.74)"
            , style "text-align" "center"
            , style "width" "3rem"
            , style "padding" "0.5rem 0"
            , style "height" "100%"
            , style "border-top-left-radius" "0.125rem"
            , style "border-bottom-left-radius" "0.125rem"
            , style "flex-shrink" "0"
            , style "box-sizing" "border-box"
            , style "flex-grow" "0"
            ]

        updatedToastIconStyles =
            List.append defaultToastIconStyles customIconAttributes
    in
    span updatedToastIconStyles [ icon ]


viewToastMessage : List (Html.Attribute msg) -> ToastMessage -> Html msg
viewToastMessage customMessageAttributes toast =
    let
        defaultToastMessageAttributes =
            [ style "padding" "0.75rem"
            , style "flex-grow" "1"
            ]

        updatedToastMessageAttributes =
            List.append defaultToastMessageAttributes customMessageAttributes
    in
    span updatedToastMessageAttributes [ text toast.message ]


viewCloseIcon : msg -> Html msg
viewCloseIcon dismissEvent =
    span
        [ style "position" "absolute"
        , style "top" "2px"
        , style "right" "2px"
        , style "color" "#ccc"
        , style "cursor" "pointer"
        , onClick dismissEvent
        ]
        [ Icons.x ]



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


{-| Overwrite existing styles for the message toast container that contains all the several toasts displayed.

For example, this can be used to override the position or width of the toasts.

-}
overwriteContainerAttributes : List (Html.Attribute msg) -> MessageToast msg -> MessageToast msg
overwriteContainerAttributes attributes (MessageToast config toasts) =
    MessageToast { config | customContainerAttributes = attributes } toasts


{-| Overwrite existing styles for the message toast icon that's placed inside the toast container besides the message block.

For example, this can be used to override colors, spacings or sizes of the icon.

-}
overwriteIconAttributes : List (Html.Attribute msg) -> MessageToast msg -> MessageToast msg
overwriteIconAttributes attributes (MessageToast config toasts) =
    MessageToast { config | customIconAttributes = attributes } toasts


{-| Overwrite existing styles for the message toast message block that's placed inside the toast container besides the icon.

For example, this can be used to override colors, spacings, font attributes or alignments of the toast message.

-}
overwriteMessageAttributes : List (Html.Attribute msg) -> MessageToast msg -> MessageToast msg
overwriteMessageAttributes attributes (MessageToast config toasts) =
    MessageToast { config | customMessageAttributes = attributes } toasts


{-| Override existing styles for the message toast that wraps the icon and message block.

For example, can be used to ovveride border stylings, shadows or spacings between the toasts.

-}
overwriteToastAttributes : List (Html.Attribute msg) -> MessageToast msg -> MessageToast msg
overwriteToastAttributes attributes (MessageToast config toasts) =
    MessageToast { config | customToastAttributes = attributes } toasts


{-| Removes the time-wise oldest toast from the existing collection.
-}
popOldestToast : MessageToast msg -> MessageToast msg
popOldestToast (MessageToast config toasts) =
    let
        newToasts =
            List.take (List.length toasts - 1) toasts
    in
    MessageToast config newToasts



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


{-| Provides a specific HTML-class name to better distinguish the different toast types in the DOM.
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
