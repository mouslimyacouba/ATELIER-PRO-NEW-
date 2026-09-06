# Fix Gradle Build Errors

The project is currently failing to build due to a combination of network issues (SSL/Connection Timeout), missing plugin applications, and potentially incompatible plugin versions for AGP 9.1.0 and Gradle 9.3.1.

## Proposed Changes

### Android Project Configuration

#### [MODIFY] [settings.gradle.kts](file:///C:/dev/atelierpro_mobile/android/settings.gradle.kts)
- Align Kotlin plugin version to `2.3.10` (or `2.3.20` if preferred) to match the latest stable for AGP 9.1.0.
- Ensure `google()` and `mavenCentral()` are available for plugin resolution.

#### [MODIFY] [app/build.gradle.kts](file:///C:/dev/atelierpro_mobile/android/app/build.gradle.kts)
- Apply the `org.jetbrains.kotlin.android` plugin. This is required because the `kotlin { ... }` block is used but the plugin isn't applied.
- This should resolve the `Configuration with name 'implementation' not found` and `'kotlin-android' plugin requires one of the Android Gradle plugins` errors if they are cascading from the app module.

#### [MODIFY] [build.gradle.kts](file:///C:/dev/atelierpro_mobile/android/build.gradle.kts)
- Add a check in `subprojects` to ensure Android plugins are applied before performing configuration that depends on them.

## Verification Plan

### Automated Tests
- Run `.\gradlew clean assembleDebug` in the `android` directory.

### Manual Verification
- Verify that the "Configuration with name 'implementation' not found" error is gone.
- Check if the Kotlin plugin resolves correctly.
