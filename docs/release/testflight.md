# TestFlight Release Setup

This repository is prepared to ship the iOS app with the bundle identifier `com.hhsoll.recordtravel`.

## One-time Apple setup

1. Sign in to Xcode with a paid Apple Developer Program account.
2. Open `/Users/sol/Desktop/travelRecord/apps/mobile_app/ios/Runner.xcworkspace`.
3. In `Runner > Signing & Capabilities`:
   - Select your Apple Team.
   - Keep `Automatically manage signing` enabled.
   - Confirm the bundle identifier is `com.hhsoll.recordtravel`.
4. Create the same app in App Store Connect.

## Build and upload

Run from `/Users/sol/Desktop/travelRecord/apps/mobile_app`:

```bash
flutter build ipa --build-name 1.0.0 --build-number 2
```

Upload the generated IPA from `build/ios/ipa/` with Transporter or Xcode Organizer.

## TestFlight

- Use `Internal Testing` for your own device or team members first.
- Increase the build number for every new upload.
- If App Store Connect says the build is already used, bump `--build-number` and rebuild.
