# iOS Example App

A complete iOS example application demonstrating the MobileTracker SDK.

## Quick Start

```bash
cd examples/ios
open MobileTrackerExample/MobileTrackerExample.xcodeproj
```

Then in Xcode:

1. Wait for package dependencies to resolve (~10 seconds)
2. Select an iPhone simulator (e.g., iPhone 16 Pro)
3. Press `Cmd+R` to build and run

## Features Demonstrated

- ✅ SDK initialization with brand ID and API key
- ✅ User identification with profile data
- ✅ Event tracking with custom attributes
- ✅ Screen view tracking
- ✅ Session-level metadata
- ✅ Profile updates using set()
- ✅ Session reset functionality
- ✅ Complete reset including brand ID

## Recreate Project

If you need to regenerate the Xcode project:

```bash
./create-project.sh
```

## Project Structure

```
examples/ios/
├── MobileTrackerExample/          # Xcode project
│   ├── MobileTrackerExample/      # Source files
│   │   ├── ExampleApp.swift       # App entry point
│   │   ├── ContentView.swift      # Main UI
│   │   └── Assets.xcassets/       # App assets
│   └── MobileTrackerExample.xcodeproj/
├── create-project.sh              # Script to regenerate project
└── README.md                      # This file
```

## Configuration

The example uses demo credentials (see `MobileTrackerExample/MobileTrackerExample/ExampleApp.swift`):

- Brand ID: `7366`
- API Key: `03dbd95123137cc76b075f50107d8d2d`
- API URL: `https://tracking.api.qc.founder-os.ai/api`

Replace these with your actual credentials before deploying.

## Troubleshooting

### Package Resolution Issues

```
File → Packages → Reset Package Caches
File → Packages → Resolve Package Versions
```

### Build Errors

```
Product → Clean Build Folder (Cmd+Shift+K)
Product → Build (Cmd+B)
```

### Simulator Issues

```bash
# List available simulators
xcrun simctl list devices available

# Boot a specific simulator
xcrun simctl boot "iPhone 16 Pro"
```

## Learn More

- See `MobileTrackerExample/README.md` for detailed project documentation
- See `../../API_REFERENCE.md` for complete API reference
- Check `../../ios/` for SDK source code
