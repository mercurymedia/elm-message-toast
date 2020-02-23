# elm-message-toast

**Install:** `elm install mercurymedia/elm-message-toast`

Display a list of small popups with a feedback message to the user (_default 4 at a time_). The popup disappears automatically after a few seconds (_default 8 seconds_) or if the user taps on it.

There are **4 different types** for the message to choose from: **Danger**, **Info**, **Success** and **Warning**

![MessageToast in Elm](https://user-images.githubusercontent.com/49154679/69343512-0fd87000-0c6e-11ea-9325-80f24988ded3.png)

## Usage

The package offers a way to use the `MessageToast` fully pre-configured, which makes it easy to use. There's also ways to customize the `MessageToast` to some individual needs _(e.g. number of messages shown at the same time, delay until a message disappears or customized attributes)_.

#### Connect to the model

Usually there will be only one MessageToast declaration on the model, since the message popups will be in one group and share the same settings. Multiple attributes are only necessary if separate configurations are used.

The pre-configured `MessageToast` is initialized with `init`.

```elm
import MessageToast exposing (MessageToast)

type alias Model =
    { messageToast : MessageToast Msg }

initialModel : Model
initialModel =
    { -- MessageToast requires by default only the message to update itself to the model
      messageToast = MessageToast.init UpdatedSimpleMessageToast
    }
```

To provide custom settings use `initWithConfig`.

```elm
    { -- MessageToast can also be initialized with custom settings
      messageToast = MessageToast.initWithConfig UpdatedCustomMessageToast { delayInMs = 2000, toastsToShow = 10 }
    }
```

#### Establish updates off the `MessageToast`

The `MessageToast` can update itself, so that it's only required that the updated `MessageToast` will be set on the model.

```elm
UpdatedSimpleMessageToast updatedMessageToast ->
    -- Only needed to re-assign the updated MessageToast to the model.
    ( { model | messageToast = updatedMessageToast }, Cmd.none )
```

#### Display `MessageToast` in the view

The default view of the `MessageToast` can be shown by simply passing the `MessageToast` into the `view` function.

```elm
view : Model -> Html Msg
view model =
    div [ style "width" "100vw", style "height" "100vh" ]
        [ -- Only need to pass the proper MessageToast
          MessageToast.view model.messageToast
        ...
        ]
```

However, the `MessageToast` can be customized in a certain extent by overriding attributes (and therefore also stylings) using provided functions (`overwriteContainerAttributes`, `overwriteToastAttributes`, `overwriteMessageAttributes`, `overwriteIconAttributes`). [For further informations see docs.](http://package.elm-lang.org/packages/mercurymedia/elm-message-toast/latest/MessageToast)

```elm
view : Model -> Html Msg
view model =
    div [ style "width" "100vw", style "height" "100vh" ]
        [ -- Stylings (or in general Html.Attribute's) of the MessageToast view can be overridden
          model.messageToast
            |> MessageToast.overwriteContainerAttributes [ style "top" "20px", style "bottom" "auto" ]
            |> MessageToast.overwriteToastAttributes [ style "font-size" "1rem" ]
            |> MessageToast.view
        ...
        ]
```

#### Setup subscription

So that the `MessageToast` can automatically pop off the time-wise oldest message, simply connect the subscription of the `MessageToast` to the application.

```elm
subscriptions : Model -> Sub Msg
subscriptions model =
    -- MessageToast provides a subscription to close automatically which is easy to use.
    MessageToast.subscriptions model.messageToast
```

**However, if this functionality of automatically disappearing messages is not wanted, this part can be skipped.**

#### Use it

To show a message popup simply generate a toast with one of the 4 type functions (`danger`, `info`, `success`, `warning`) and call a function onto it to display it with your individual needs.
The simplest way is done by piping the generated toast into `MessageToast.withMessage`.

**Example:**

```elm
-- Message that assigns a new "Danger" message toast to the MessageToast handler with default HTML layout.

ShowDanger ->
    let
        messageToast =
            model.messageToast
                |> MessageToast.warning
                |> MessageToast.withMessage "My warning message"
    in
    ( { model | messageToast = messageToast }, Cmd.none)
```

This will display the message with the default HTML layout of the MessageToast.
If you want to customize the layout, you can instead pipe the generated toast into `MessageToast.withHtml` and provide a individual structured HTML layout for the content of the MessageToast.

**Example:**

```elm
-- Message that assigns a new "Danger" message toast to the MessageToast handler with user defined HTML layout.

ShowDanger ->
    let
        messageToast =
            model.messageToast
                |> MessageToast.warning
                |> MessageToast.withHtml (div [] [ text "My title", text "My warning message body" ])
    in
    ( { model | messageToast = messageToast }, Cmd.none)
```

## Example

Examples can be found in the `examples/` folder. To build the examples and view it in the browser you can simply run `elm make examples/Default.elm` or `elm make examples/Configured.elm`.

---

[![Mercury Media logo](https://user-images.githubusercontent.com/49154679/69350588-21277980-0c7a-11ea-8501-7860daf6f980.png)](https://getmercury.io/)
