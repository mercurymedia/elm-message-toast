# elm-message-toast

**Install:** `elm install mercurymedia/elm-message-toast`

Display a list of small popups with a feedback message to the user (_default 4 at a time_). The popup disappears automatically after a few seconds (_default 8 seconds_) or if the user taps on it.

There are **4 different types** for the message to choose from: **Danger**, **Info**, **Success** and **Warning**

<img src="https://user-images.githubusercontent.com/49154679/68119166-48ecb280-ff02-11e9-86d4-9ff5c8e3a241.png" width="350">

## Usage

The package offers a way to use the `MessageToast` fully pre-configured, which makes it easy to use. There's also ways to customize the `MessageToast` to some individual needs _(e.g. number of messages shown at the same time, delay until a message disappears or customized attributes)_.

#### Connect to the model

Usually there will be only one MessageToast declaration on the model, since the message popups will be in one group and share the same settings. Multiple attributes are only necessary if separate configurations are used.

The pre-configured `MessageToast` is initialized with `init`. To provide custom settings use `initCustom`.

```elm
import MessageToast exposing (MessageToast)

type alias Model =
    { simpleMessageToast : MessageToast Msg
    , customMessageToast : MessageToast Msg
    }

initialModel : Model
initialModel =
    { -- MessageToast requires by default only the message to update itself to the model
      simpleMessageToast = MessageToast.init UpdatedSimpleMessageToast

    -- MessageToast can also be initialized with custom settings
    , customMessageToast = MessageToast.initCustom UpdatedCustomMessageToast { delayInMs = 2000, toastsToShow = 10 }
    }
```

#### Establish updates off the `MessageToast`

The `MessageToast` can update itself, so that it's only required that the updated `MessageToast` will be set on the model.

```elm
UpdatedSimpleMessageToast updatedMessageToast ->
    -- Only needed to re-assign the updated MessageToast to the model.
    ( { model | simpleMessageToast = updatedMessageToast }, Cmd.none )
```

#### Display `MessageToast` in the view

The default view of the `MessageToast` can be shown by simply passing the `MessageToast` into the `view` function.

```elm
view : Model -> Html Msg
view model =
    div [ style "width" "100vw", style "height" "100vh" ]
        [ -- Only need to pass the proper MessageToast
          MessageToast.view model.simpleMessageToast
        ...
        ]
```

However, the `MessageToast` can be customized in a certain extent by overriding attributes (and therefore also stylings) using provided functions (`overrideContainerAttributes`, `overrideToastAttributes`, `overrideMessageAttributes`, `overrideIconAttributes`). [For further informations see docs.](http://package.elm-lang.org/packages/mercurymedia/elm-message-toast/latest/MessageToast)

```elm
view : Model -> Html Msg
view model =
    div [ style "width" "100vw", style "height" "100vh" ]
        [ -- Stylings (or in general Html.Attribute's) of the MessageToast view can be overridden
          -- NOTE: Does not need to be initialized with `initCustom`
          model.customMessageToast
            |> MessageToast.overrideContainerAttributes [ style "top" "20px", style "bottom" "auto" ]
            |> MessageToast.overrideToastAttributes [ style "font-size" "1rem" ]
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
    MessageToast.subscriptions model.simpleMessageToast
```

**However, if this functionality of automatically disappearing messages is not wanted, this part can be skipped.**

#### Use it

To show a message popup simply call one of the 4 type functions (`danger`, `info`, `success`, `warning`) for the defined `MessageToast` and update it to the model.

```elm
-- Message that assigns a new "Danger" message to the MessageToast handler.

ShowDanger ->
    ( { model | customMessageToast = MessageToast.danger model.customMessageToast "Something critical happened." }, Cmd.none )
```

## Example

An example can be found in the `examples/` folder. To build the example and view it in the browser you can simply run `make` from inside the `examples/` folder.

---

[<img src="https://cdn.chimpify.net/5c5ab20aa85872ea638b4568/2019/03/logo-mercury-media.svg" width="150">](https://getmercury.io/)
