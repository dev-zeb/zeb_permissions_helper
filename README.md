## 🛡️ Zeb Permissions Helper

A powerful, flexible Flutter package that simplifies managing permissions across different libraries — with customizable UI dialogs, sequential flows, and unified APIs.

---

### 🚀 Overview

`zeb_permissions_helper` provides a consistent and developer-friendly way to request permissions in Flutter apps.
It allows you to:

* Choose **which underlying package** to use for specific permissions
  (e.g., `location` for GPS, `permission_handler` for camera/mic).
* Display **purpose dialogs** explaining *why* a permission is needed.
* Request **single**, **multiple**, or **sequential** permissions with minimal code.
* Handle **results, errors, and fallbacks** gracefully across iOS and Android.

---

### 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  zeb_permissions_helper: ^1.0.0
```

Then run:

```bash
flutter pub get
```

---

### ⚙️ Import

```dart
import 'package:zeb_permissions_helper/zeb_permissions_helper.dart';
```

---

### 🧩 Basic Usage

#### ✅ Single Permission

```dart
final helper = ZebPermissionsHelper();

final result = await helper.requestPermission(
  context,
  Permission.camera,
  requestConfig: const SingleRequestConfig(
    showPurposeDialog: true,
    dialogText: DialogText(
      title: 'Camera Access Required',
      explanation: 'We need camera access to let you capture profile photos.',
      caution: 'Please enable this permission in settings if denied.',
    ),
  ),
);

print('Granted: ${result.isGranted}, Used package: ${result.usedPackage}');
```

---

### 🔁 Multiple Permissions

```dart
final results = await helper.requestMultiplePermissions(
  context,
  [Permission.camera, Permission.microphone, Permission.photos],
  requestConfigs: {
    Permission.camera: const SingleRequestConfig(showPurposeDialog: false),
  },
);

for (final r in results) {
  print('${r.permission}: ${r.isGranted ? "GRANTED" : "DENIED"}');
}
```

---

### 🔄 Sequential Flow (Onboarding Style)

```dart
final results = await helper.requestPermissionsSequentially(
  context,
  sequentialConfig: SequentialRequestConfig(
    permissions: [
      Permission.camera,
      Permission.location,
      Permission.notification,
    ],
    packageOverrides: {
      Permission.location: PermissionPackage.location,
      Permission.notification: PermissionPackage.notifications,
    },
    showPurposeDialogs: true,
    delayBetweenRequests: Duration(milliseconds: 500),
  ),
);

for (final r in results) {
  print('${r.permission}: ${r.isGranted ? "GRANTED" : "DENIED"}');
}
```

---

### 🧠 Key Features

| Feature                      | Description                                                          |
| ---------------------------- | -------------------------------------------------------------------- |
| 🧩 **Unified API**           | Request permissions using one consistent interface.                  |
| 🧭 **Multi-package support** | Choose between `permission_handler`, `location`, or custom packages. |
| 💬 **Purpose dialogs**       | Inform users *why* you need a permission before requesting it.       |
| ⏱ **Sequential requests**    | Handle onboarding-style permission flows easily.                     |
| ⚙️ **Highly configurable**   | Customize delay, UI, and package mapping.                            |
| 🧾 **Structured results**    | Access `isGranted`, `usedPackage`, and `error` fields.               |

---

### 🧪 Example App

This package includes a full example app demonstrating:

* Single permission flow
* Multiple permissions
* Sequential permission onboarding
* Custom dialog texts
* Status checks and edge cases

Run the example:

```bash
cd example
flutter run
```

---

### 🧰 Classes & Configs

#### `ZebPermissionsHelper`

The main class used to handle permission requests.

#### `SingleRequestConfig`

Configuration for a single permission request:

* `package`: choose which library to use
* `dialogText`: customize the dialog text
* `showPurposeDialog`: whether to show a pre-request dialog

#### `SequentialRequestConfig`

Controls sequential permission requests:

* `permissions`: list of permissions to request
* `packageOverrides`: map of permission → package
* `showPurposeDialogs`: whether to show purpose dialogs before each request
* `delayBetweenRequests`: optional delay between each step

#### `DialogText`

Defines the title, explanation, and caution messages shown in dialogs.

---

### 🧾 Example UI Scenarios

You can test the flows directly from the example app’s home page:

| Example                  | Description                                                   |
| ------------------------ | ------------------------------------------------------------- |
| **Single Permission**    | Requests a single permission with or without a custom dialog. |
| **Multiple Permissions** | Requests several permissions simultaneously.                  |
| **Sequential Flow**      | Demonstrates onboarding-style permission handling.            |
| **Status Check**         | Checks if a permission is already granted.                    |
| **Edge Case Test**       | Tests unknown permissions and fallback handling.              |

---

### 📱 Platform Support

| Platform | Supported | Notes                                         |
| -------- | --------- | --------------------------------------------- |
| Android  | ✅         | Integrates with permission_handler / location |
| iOS      | ✅         | Works with iOS permission APIs                |
| Web      | ⚠️        | Limited, depending on the chosen package      |

---

### 🧩 Dependencies

* [`permission_handler`](https://pub.dev/packages/permission_handler)
* [`location`](https://pub.dev/packages/location)
* (Optionally) other permission-specific packages

---

### 🧑‍💻 Contributing

Contributions, issues, and feature requests are welcome!
Feel free to open a PR or issue on [GitHub](https://github.com/dev-zeb/zeb_permissions_helper/issues).

---

### 📄 License

This project is licensed under the [MIT License](LICENSE).

---

### 🌟 Author

Developed by **Sufi Aurangzeb Hossain**

> Simplifying permission handling for every Flutter app.

---

### 🪄 Badges

```markdown
[![pub package](https://img.shields.io/pub/v/zeb_permissions_helper.svg)](https://pub.dev/packages/zeb_permissions_helper)
[![likes](https://img.shields.io/pub/likes/zeb_permissions_helper)](https://pub.dev/packages/zeb_permissions_helper)
[![points](https://img.shields.io/pub/points/zeb_permissions_helper)](https://pub.dev/packages/zeb_permissions_helper)
[![popularity](https://img.shields.io/pub/popularity/zeb_permissions_helper)](https://pub.dev/packages/zeb_permissions_helper)
```

---

Would you like me to include a **License file (MIT)** and **example folder structure** section for your repo as well (so your GitHub looks professional and ready for pub.dev)?
