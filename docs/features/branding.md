# Branding

## Logo
`assets/logo/logo.png` is the only logo file: a ~496×503 rounded-square icon (teal→blue gradient, white wallet with the taka sign and a growth arrow, transparent corners). It is the only file bundled in the app (`AppLogo`, registered in `pubspec.yaml`).

## In the app
`lib/core/ui/app_logo.dart` (`AppLogo`, `AppLogo.name`) is used on the sign-in screen, the loading gate, the first-sync screen and the Settings header. It decodes at device-pixel size and needs no clipping.

## Launcher icon and splash
- Config: `flutter_launcher_icons.yaml`, `flutter_native_splash.yaml` (both dev dependencies).
- Regenerate: `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`, then do a full rebuild (hot reload does not pick these up).
- Android uses regular (non-adaptive) icons because the logo already carries its own shape and gradient; an adaptive icon would mask and shrink it.
- The icons and splash currently in `android/` and `ios/` were generated from a **temporary padded copy** of the logo (square canvas upscaled to 1024 px; an opaque iOS copy on a matching gradient, zoomed 7% so the logo's own edge sits under iOS's mask; and a splash image with the logo at ~45% of a 1152 px canvas so Android 12's circular mask never crops it). Those temporary files were deleted afterwards.
- Regenerating straight from `logo.png` gives close but not identical results (a slight stretch from the 496×503 aspect, an unpadded splash on Android 12). It is optional; the existing native files are fine. For the best result, supply a square master of 1024 px or more.
