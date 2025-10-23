````markdown
# 🛡️ Zeb Permissions Helper

*A clean, customizable, and developer-friendly way to handle permissions in Flutter.*

[![pub package](https://img.shields.io/pub/v/zeb_permissions_helper.svg)](https://pub.dev/packages/zeb_permissions_helper)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%9D%A4-blue.svg)](https://flutter.dev)
[![GitHub Repo](https://img.shields.io/badge/GitHub-zeb--permissions--helper-000?logo=github)](https://github.com/dev-zeb/zeb_permissions_helper)

---

## 💖 Support the Project

If this package helps you, please consider:

- ⭐ Star the repo on GitHub: [zeb_permissions_helper](https://github.com/dev-zeb/zeb_permissions_helper)
- 💙 Like the package on pub.dev: [pub.dev/packages/zeb_permissions_helper](https://pub.dev/packages/zeb_permissions_helper)

Your support motivates continued improvements and maintenance!

---

## 🚀 Overview

**Zeb Permissions Helper** simplifies handling app permissions in Flutter with:

- Unified API across packages (`permission_handler`, `location`, `flutter_local_notifications`)
- Customizable dialogs and messages
- Sequential permission requests
- Configurable fallback and override behavior
- Graceful handling of permanently denied permissions

---

## 📦 Installation

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  zeb_permissions_helper: ^1.1.2
````

Then run:

```bash
flutter pub get
```

---

## 🧠 Key Features

| Feature                          | Description                                                               |
| -------------------------------- | ------------------------------------------------------------------------- |
| 🧩 **Unified API**               | Request permissions easily without worrying about specific package logic  |
| ⚙️ **Configurable**              | Customize messages, dialog visibility, and underlying permission packages |
| 🪄 **Custom Dialogs**            | Override built-in dialogs for a tailored UX                               |
| 🔁 **Sequential Requests**       | Request multiple permissions with built-in delay and flow control         |
| 🚫 **Permanent Denial Handling** | Automatically prompt users to open app settings                           |
| 📱 **Platform-Safe**             | Automatically resolves Android/iOS platform differences                   |
| 💬 **Friendly Defaults**         | Provides sensible explanations for all common permissions                 |

---

## 🧩 Supported Permissions

| Permission             | Enum                              | Example Usage                             |
| ---------------------- | --------------------------------- | ----------------------------------------- |
| Notifications          | `ZebPermission.notification`      | To request push/local notification access |
| Camera                 | `ZebPermission.camera`            | Capture photos or use video calls         |
| Photos / Gallery       | `ZebPermission.photos`            | Access photo library or gallery           |
| Microphone             | `ZebPermission.microphone`        | Use for calls or recordings               |
| Location (General)     | `ZebPermission.location`          | Map and delivery tracking                 |
| Location (When in Use) | `ZebPermission.locationWhenInUse` | For foreground location use               |
| Location (Always)      | `ZebPermission.locationAlways`    | For background tracking                   |
| Storage                | `ZebPermission.storage`           | File saving or access                     |
| System Alert Window    | `ZebPermission.systemAlertWindow` | Display overlays (e.g., call bubbles)     |

---

## 📦 Supported Packages

| Underlying Package                                                                    | Used For                   | Notes                                    |
| ------------------------------------------------------------------------------------- | -------------------------- | ---------------------------------------- |
| [`permission_handler`](https://pub.dev/packages/permission_handler)                   | All general permissions    | Default package                          |
| [`location`](https://pub.dev/packages/location)                                       | Location-based permissions | Optional for fine-grained control        |
| [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) | Notification permissions   | Used on iOS for accurate status checking |

---

## 💡 Usage Examples

### 1️⃣ Request a single permission

```dart
final helper = ZebPermissionsHelper();

final result = await helper.requestPermission(
  context,
  ZebPermission.camera,
);

if (result.isGranted) {
  print("Camera permission granted!");
} else {
  print("Camera permission denied or permanently denied.");
}
```

---

### 2️⃣ Request with custom purpose dialog text

```dart
final result = await helper.requestPermission(
  context,
  ZebPermission.microphone,
  requestConfig: SingleRequestConfig(
    dialogText: const DialogText(
      title: "Microphone Access",
      explanation: "We need access so you can talk during calls.",
      caution: "Please enable the microphone in settings for calls.",
    ),
  ),
);
```

---

### 3️⃣ Request multiple permissions sequentially

```dart
final results = await helper.requestPermissionsSequentially(
  context,
  sequentialConfig: SequentialRequestConfig(
    permissions: [
      ZebPermission.camera,
      ZebPermission.microphone,
      ZebPermission.locationWhenInUse,
    ],
    delayBetweenRequests: const Duration(milliseconds: 500),
  ),
);

for (final res in results) {
  debugPrint("${res.permission} → Granted: ${res.isGranted}");
}
```

---

### 4️⃣ Customize default texts and behaviors

```dart
final config = ZebPermissionsConfig(
  showDialogsByDefault: true,
  defaultPackage: PermissionPackage.permissionHandler,
  overrides: {
    ZebPermission.notification: AppPermissionData(
      permission: ZebPermission.notification,
      dialogText: const DialogText(
        title: "Allow Notifications",
        explanation:
            "Stay up to date with real-time order and chat alerts.",
        caution:
            "Notifications are disabled. Please enable them in Settings.",
      ),
    ),
  },
);

final helper = ZebPermissionsHelper(config: config);
```

---

### 5️⃣ Check if a permission is already granted

```dart
final isGranted =
    await helper.isPermissionGranted(ZebPermission.locationAlways);

if (isGranted) {
  print("Location Always permission already granted!");
}
```

---

## 🧩 Custom Permanently Denied Dialog (Advanced)

You can fully override the default “Open Settings” dialog by providing a custom builder:

```dart
final helper = ZebPermissionsHelper(
  config: ZebPermissionsConfig(
    permanentlyDeniedDialogBuilder: (context, data, onOpenSettings) {
      return AlertDialog(
        title: Text("Custom ${data.permission.name} Dialog"),
        content: Text(data.dialogText.caution),
        actions: [
          TextButton(
            onPressed: onOpenSettings,
            child: const Text("Go to Settings"),
          ),
        ],
      );
    },
  ),
);
```

---

## ⚙️ Utility Helpers

| Method                                      | Description                                                                     |
| ------------------------------------------- | ------------------------------------------------------------------------------- |
| `resolvePermission(ZebPermission original)` | Resolves Android SDK–specific permission differences (e.g., `photos → storage`) |
| `getPackageForPermission()`                 | Determines the correct permission package to use based on configuration         |

---

## 🧪 Example Project

You can check a working example in the [`example/`](example) directory.
It demonstrates requesting multiple permissions with custom dialogs and configurations.

---

## 🤝 Contributing

We’d love your help to make **Zeb Permissions Helper** even better!
Here’s how you can contribute:

1. 🍴 Fork the [repository](https://github.com/dev-zeb/zeb_permissions_helper)
2. 🧩 Create a feature or fix branch (`feature/my-new-feature`)
3. 🧪 Add tests and run `flutter test`
4. 🧾 Commit your changes (`git commit -m "Add new feature"`)
5. 🚀 Push to your branch and create a Pull Request

---

## 📜 License

This package is licensed under the **MIT License**.
See the [LICENSE](LICENSE) file for details.

---

## 💬 Credits

Developed with ❤️ by **Sufi Aurangzeb Hossain**

> Simplifying permission handling for every Flutter app.
> “Great code is not about complexity — it’s about clarity.”

`````
