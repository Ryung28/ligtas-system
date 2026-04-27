# Sound Asset Contract

This project uses one source folder for app sound files:

- `web/public/sounds`

Required files:

- `notification.mp3`
- `critical_alarm.mp3`

## Why sync is required

Web, Flutter assets, and Android notification channels do not read from the same path:

- Web playback reads from `web/public/sounds`
- Flutter in-app playback reads from `mobile/assets/sounds`
- Android notification channel sounds read from `mobile/android/app/src/main/res/raw`

## Permanent workflow

Run the sync command after updating any sound file:

```bash
cd web
npm run sync:sounds
```

This command copies required files from `web/public/sounds` to:

- `mobile/assets/sounds`
- `mobile/android/app/src/main/res/raw`

## Naming rules

For Android raw resources, keep filenames lowercase with underscores:

- `notification.mp3`
- `critical_alarm.mp3`

If you rename a file, update:

- `mobile/lib/.../AssetSource('sounds/<name>.mp3')`
- `RawResourceAndroidNotificationSound('<name_without_extension>')`
- `web/scripts/sync-sound-assets.js` required file list
