# PWA App Icons

This directory contains the app icons for the LIGTAS PWA.

## Required Icons

You need to create two PNG icons from your logo (`oro-cervo.png`):

1. **icon-192.png** - 192x192 pixels
2. **icon-512.png** - 512x512 pixels

## How to Create Icons

### Option 1: Online Tool (Easiest)
1. Go to https://realfavicongenerator.net/ or https://www.pwabuilder.com/imageGenerator
2. Upload your `oro-cervo.png` logo
3. Download the generated icons
4. Rename them to `icon-192.png` and `icon-512.png`
5. Place them in this directory

### Option 2: Using Image Editor
1. Open `oro-cervo.png` in an image editor (Photoshop, GIMP, etc.)
2. Resize to 192x192 pixels, export as `icon-192.png`
3. Resize to 512x512 pixels, export as `icon-512.png`
4. Place both files in this directory

### Option 3: Command Line (ImageMagick)
```bash
# Install ImageMagick first
convert oro-cervo.png -resize 192x192 web/public/icons/icon-192.png
convert oro-cervo.png -resize 512x512 web/public/icons/icon-512.png
```

## Temporary Workaround

Until you create proper icons, the PWA will use the existing `oro-cervo.png` as a fallback.
