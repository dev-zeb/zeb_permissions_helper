# 📜 Changelog

All notable changes to **Zeb Permissions Helper** will be documented in this file.  
This project follows [Semantic Versioning](https://semver.org/).

---

## [1.1.2] — Hotfix: Minor README Formatting Fixes — 2025-10-23

### 🛠️ Fixed

- Corrected **code block formatting** in `README.md` for better readability on pub.dev and GitHub.
- Fixed **misaligned code fences** in Dart snippets (caused by extra newlines and indentation).
- Resolved Markdown rendering issues in feature tables and example sections.
- Ensured consistent code font and syntax highlighting across all examples.

### 🧾 Updated

- Verified that all code snippets are copy-paste ready.
- Minor punctuation and grammar improvements for clarity and flow.

---

## [1.1.1] — Documentation & README Enhancements — 2025-10-22

### 🧾 Updated

- Improved **README.md** with better presentation and usability:
    - Added **GitHub repository badge** and star encouragement section.
    - Added **Contributing** section for community involvement.
    - Reorganized feature tables for clarity and consistent alignment.
    - Enhanced description and badges for better pub.dev visibility.
- Refined code snippets and usage examples for clarity.
- Minor grammar and typography improvements across documentation.

---

## [1.1.0] — Major UX & API Improvements for Permission Handling — 2025-10-20

### ✨ Enhancements

- Refactored `ZebPermissionsHelperImpl` for a cleaner and more predictable permission flow.
- Simplified setup — no need to install `permission_handler` manually.
- Added developer-overridable custom dialog for permanently denied permissions.
- Introduced `packageOverrides` allowing use of libraries like `location` or `notification` instead
  of `permission_handler`.
- Improved internal architecture for extensibility and multi-package support.
- Added detailed documentation comments for all public APIs.

### 🐛 Fixes

- Fixed issue where the purpose dialog was reappearing after permanent denial.
- Added cross-platform exception handling for OS/version-specific quirks.
- Improved UX when a permission is permanently denied (customizable “Open Settings” dialog).

### 🧩 Example App

- Modified the `example` project files.
- Added a comprehensive example project demonstrating:
    - Single, multiple, and sequential permission flows
    - Onboarding-style permission requests
    - Custom dialog and UI overrides
    - Permission status overview page
    - Handling edge cases and invalid permissions
- Example app now includes pages for:
    - Sequential permission requests
    - Permission status management
    - Custom UI configuration examples

---

## [1.0.0] — Initial Internal Prototype — 2025-10-15

### 🧪 Internal

- Created initial project structure following clean architecture.
- Implemented foundational permission abstraction using `ZebPermission` enum.
- Added test coverage for base permission logic and request flows.
- Prepared base example app for internal validation.

---

## 📦 Upcoming

### 🚧 Planned

- Support for **web permissions** (camera, microphone).
- In-app **permission dashboard widget** for user-facing control.
- Integration tests for advanced multi-package permission scenarios.

---

*Developed with ❤️ by Sufi Aurangzeb Hossain*
> “Great code is not about complexity — it’s about clarity.”
