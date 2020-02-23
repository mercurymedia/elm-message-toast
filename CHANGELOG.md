# Changelog

Users have now the possibility to provide a custom HTML layout for the MessageToast content.

## [2.0.0]

### **BREAKING CHANGE**

In order to allow a custom HTML layout, we changed the way how toasts are created.

Instead of creating toasts like:

```elm
MessageToast.warning model.messageToast "My warning message"
```

They are now created like:

```elm
model.messageToast
    |> MessageToast.warning
    |> MessageToast.withMessage "My warning message"
```

Even though the API changed slightly and will require changes by the user, we hope that MessageToast is still as easy to implement for users that wish to use MessageToast without any customization while remaining flexible and straightforward for those who need the ability to customize it.

### **Added** - Provide a user defined HTML layout

New way to use a custom HTML layout in the MessageToast can be done like:

```elm
model.messageToast
    |> MessageToast.warning
    |> MessageToast.withHtml (div [] [ text "My title", text "My warning message body" ])
```
