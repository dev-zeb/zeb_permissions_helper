## 1.1.0 — Major UX & API Improvements for Permission Handling
### ✨ Enhancements
- Refactored `ZebPermissionsHelperImpl` for a cleaner and more predictable permission flow.
- Simplified setup — no need to install `permission_handler` manually.
- Added developer-overridable custom dialog for permanently denied permissions.
- Introduced `packageOverrides` allowing use of libraries like `location` or `notification` instead of `permission_handler`.
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

## 1.0.0
- Initial release.
