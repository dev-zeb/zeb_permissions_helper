# 📱 Zeb Permissions Example

A showcase app demonstrating how to use the `zeb_permissions` package to handle various permission request flows in Flutter with clean, predictable, and customizable UI.

---

## 🚀 Overview

This example demonstrates real-world use cases of permission handling using `ZebPermissionsHelper`.  
It includes different permission request patterns, customizable dialogs, and user experience flows for both Android and iOS.

---

## 🧩 Features

- 🔹 **Single permission** request example (e.g., camera, location, storage)
- 🔹 **Sequential permission flow** (ask permissions one after another)
- 🔹 **Multiple permissions** with combined request handling
- 🔹 **Onboarding-style flow** for first-time permission requests
- 🔹 **Custom dialogs** for:
    - Purpose explanation before requesting permission
    - Permanently denied permissions (with “Open Settings” option)
- 🔹 **Permission status overview page**
- 🔹 **Customizable UI overrides**
- 🔹 Handles platform quirks and invalid permission scenarios gracefully

---

## 🧠 Project Structure

```

example/
│
├── lib/
│   ├── main.dart                   # Entry point
│   ├── screens/
│   │   ├── home_screen.dart        # Lists all permission examples
│   │   ├── single_permission_page.dart
│   │   ├── sequential_permissions_page.dart
│   │   ├── custom_dialogs_page.dart
│   │   └── permission_status_page.dart
│   │
│   ├── widgets/
│   │   └── custom_dialogs.dart     # Example custom dialogs
│   │
│   └── helpers/
│       └── example_permissions_helper.dart
│
├── pubspec.yaml
└── README.md                       # This file

```

---

## ⚙️ Running the Example

Make sure you have Flutter installed and configured.

```bash
cd example
flutter pub get
flutter run
```

---

## 🧱 How It Works

1. **Purpose Dialog** — shows users *why* you need a permission before asking for it.
2. **Permission Request** — handled by `ZebPermissionsHelperImpl`, managing logic internally.
3. **Custom Denied Dialog** — if user denies permanently, shows a configurable dialog with an *“Open
   Settings”* button.
4. **Sequential Flow** — automatically chains permission requests in the defined order.

---

## 🎨 Customization

You can override:

* Dialog texts and titles
* Button labels (“Allow”, “Deny”, “Open Settings”)
* Purpose message per permission
* Entire dialog widget via custom builder

Example:

```dart
ZebPermissionsHelperImpl (
  showCustomDeniedDialog: (context, permission) {
    return MyCustomDeniedDialog(permission: permission);
  },
);
```

---

## 🧰 Permissions Demonstrated

| Permission    | Flow Example | Notes                                                            |
|---------------|--------------|------------------------------------------------------------------|
| Camera        | Single       | Shows purpose dialog and denied dialog                           |
| Location      | Sequential   | Used after camera example                                        |
| Notifications | Custom       | Uses `packageOverrides` to simulate alternative permission logic |
| Storage       | Combined     | Part of multiple permission flow                                 |

---

## 🧾 License

This example project is part of the **`zeb_permissions_helper`** package and follows the same
license.

---

Developed with ❤️ by **Sufi Aurangzeb Hossain**
