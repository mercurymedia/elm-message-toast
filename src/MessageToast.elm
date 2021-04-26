module MessageToast exposing
    ( MessageToast(..)
    , init, initWithConfig
    , danger, info, success, warning
    , persistToast
    , withHtml, withMessage
    , view
    , subscriptions
    , overwriteContainerAttributes, overwriteIconAttributes, overwriteMessageAttributes, overwriteToastAttributes
    )

{-| MessageToast displays a list of feedback messages, each with a specified
message-type.


# Definition

@docs MessageToast


# Init

@docs init, initWithConfig


# Initial

@docs danger, info, success, warning


# Intermediate

@docs persistToast


# Final

@docs withHtml, withMessage


# View

@docs view


# Subscriptions

@docs subscriptions


# Manipulate

@docs overwriteContainerAttributes, overwriteIconAttributes, overwriteMessageAttributes, overwriteToastAttributes

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
    = MessageToast (ToastConfig msg) (List (ToastMessage msg))


{-| Defines the content type of a toast.

    Undefined -> No display type defined, nothing will be displayed
    Message m -> User defined message, that will be displayed
    View v -> User defined view that will take in the toast

-}
type ToastContent msg
    = Undefined
    | Message String
    | View (Html msg)


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
type alias ToastMessage msg =
    { content : ToastContent msg
    , id : Int
    , persisted : Bool
    , toastType : ToastType
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



-- INITIAL TOAST METHODS


{-| Generates a dangerous message toast.
-}
danger : MessageToast msg -> ( ToastMessage msg, MessageToast msg )
danger messageToast =
    Tuple.pair { defaultToastMessage | toastType = Danger } messageToast


{-| Generates an informative message toast.
-}
info : MessageToast msg -> ( ToastMessage msg, MessageToast msg )
info messageToast =
    Tuple.pair { defaultToastMessage | toastType = Info } messageToast


{-| Generates a success message toast.
-}
success : MessageToast msg -> ( ToastMessage msg, MessageToast msg )
success messageToast =
    Tuple.pair { defaultToastMessage | toastType = Success } messageToast


{-| Generates a warning message toast.
-}
warning : MessageToast msg -> ( ToastMessage msg, MessageToast msg )
warning messageToast =
    Tuple.pair { defaultToastMessage | toastType = Warning } messageToast



-- INTERMEDIATE TOAST METHODS


{-| Keeps the toast persisted in the MessageToast container by making it unaffected to
the defined toast-timeout. The toast can still be removed by user clicks.
-}
persistToast : ( ToastMessage msg, MessageToast msg ) -> ( ToastMessage msg, MessageToast msg )
persistToast ( toastMessage, messageToast ) =
    ( { toastMessage | persisted = True }, messageToast )



-- FINAL TOAST METHODS


{-| Displays a generated MessageToast content with a given message in the default layout.
-}
withMessage : String -> ( ToastMessage msg, MessageToast msg ) -> MessageToast msg
withMessage message ( content, toast ) =
    appendToList { content | content = Message message } toast


{-| Displays a generated MessageToast content with a given user-defined layout.
-}
withHtml : Html msg -> ( ToastMessage msg, MessageToast msg ) -> MessageToast msg
withHtml userDefinedView ( content, toast ) =
    appendToList { content | content = View userDefinedView } toast



-- VIEW


{-| Displays the configured message toasts.
-}
view : MessageToast msg -> Html msg
view (MessageToast config toasts) =
    let
        dismissEvent =
            \toastToDrop ->
                toasts
                    |> dropToastById toastToDrop.id
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


viewToasts : (ToastMessage msg -> msg) -> ToastConfig msg -> List (ToastMessage msg) -> List (Html msg)
viewToasts dismissEvent config toasts =
    case toasts of
        topToast :: remainingToasts ->
            List.append [ viewToast dismissEvent config topToast ] (viewToasts dismissEvent config remainingToasts)

        [] ->
            [ text "" ]


viewToast : (ToastMessage msg -> msg) -> ToastConfig msg -> ToastMessage msg -> Html msg
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


viewToastIcon : List (Html.Attribute msg) -> ToastMessage msg -> Html msg
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
            [ class "toast-icon"
            , style "background-color" bgColor
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
            , style "display" "flex"
            , style "justify-content" "center"
            ]

        updatedToastIconStyles =
            List.append defaultToastIconStyles customIconAttributes
    in
    span updatedToastIconStyles [ icon ]


viewToastMessage : List (Html.Attribute msg) -> ToastMessage msg -> Html msg
viewToastMessage customMessageAttributes toast =
    let
        defaultToastMessageAttributes =
            [ class "toast-message"
            , style "padding" "0.75rem"
            , style "flex-grow" "1"
            ]

        updatedToastMessageAttributes =
            List.append defaultToastMessageAttributes customMessageAttributes
    in
    span updatedToastMessageAttributes
        [ case toast.content of
            Undefined ->
                text ""

            Message message ->
                text message

            View userDefinedView ->
                userDefinedView
        ]


viewCloseIcon : msg -> Html msg
viewCloseIcon dismissEvent =
    span
        [ class "close-toast"
        , style "position" "absolute"
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
subscriptions (MessageToast config toasts) =
    case findToastToDrop toasts of
        Just toastToDrop ->
            Time.every config.delayInMs (\_ -> config.updateMsg <| MessageToast config <| dropToastById toastToDrop.id toasts)

        Nothing ->
            Sub.none



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

For example, can be used to override border stylings, shadows or spacings between the toasts.

-}
overwriteToastAttributes : List (Html.Attribute msg) -> MessageToast msg -> MessageToast msg
overwriteToastAttributes attributes (MessageToast config toasts) =
    MessageToast { config | customToastAttributes = attributes } toasts



-- HELPER


appendToList : ToastMessage msg -> MessageToast msg -> MessageToast msg
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


{-| Default configuration for ToastMessages.
-}
defaultToastMessage : ToastMessage msg
defaultToastMessage =
    { content = Undefined
    , id = 0
    , persisted = False
    , toastType = Danger
    }


{-| Drops Toast by Id from the list and returns the updated list.
-}
dropToastById : Int -> List (ToastMessage msg) -> List (ToastMessage msg)
dropToastById toastIdToRemove toasts =
    List.filter (.id >> (/=) toastIdToRemove) toasts


{-| Find toasts to be dropped next from the given list and return Just that element. If none match, return Nothing.
-}
findToastToDrop : List (ToastMessage msg) -> Maybe (ToastMessage msg)
findToastToDrop toasts =
    -- Searching for the oldest, not persisted toast
    toasts
        |> List.reverse
        |> getFirstMatch (.persisted >> not)


{-| Get the first element that satisfies a predicate and return Just that element. If none match, return Nothing.
-}
getFirstMatch : (a -> Bool) -> List a -> Maybe a
getFirstMatch predicate list =
    case list of
        [] ->
            Nothing

        head :: tail ->
            if predicate head then
                Just head

            else
                getFirstMatch predicate tail


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
