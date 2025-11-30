# Fix "Missing Package Product 'MobileTracker'" Error

If you see the error:

```
missing package product 'MobileTracker'
```

or

```
the package manifest at '/Users/.../examples/ios/Package.swift' cannot be accessed
```

## Root Cause

This error occurs when the Xcode project has an incorrect relative path to the Swift Package. The project is located at `examples/ios/MobileTrackerExample/` and needs to reference the package at `ios/`, which requires a relative path of `../../../ios` (not `../../ios`).

## Solution

The `create-project.sh` script has been fixed to use the correct relative path. Simply regenerate the project:

```bash
cd examples/ios
./create-project.sh
open MobileTrackerExample/MobileTrackerExample.xcodeproj
```

## If You Still See Caching Issues

If you regenerated the project but still see errors, this may be an Xcode caching issue with local Swift Package dependencies. Here's how to fix it:

## Quick Fix (Try This First)

1. **Close Xcode completely** (Cmd+Q)
2. Run this command from the project root:

```bash
# Clear all Xcode and Swift PM caches
rm -rf ~/Library/Developer/Xcode/DerivedData/MobileTrackerExample-*
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf examples/ios/MobileTrackerExample/.swiftpm
```

3. **Open the project again:**

```bash
open examples/ios/MobileTrackerExample/MobileTrackerExample.xcodeproj
```

4. In Xcode, immediately do:
   - **File → Packages → Reset Package Caches**
   - **File → Packages → Resolve Package Versions**
   - Wait for resolution to complete (watch the status bar)
   - Build the project (⌘B)

## Alternative: Reset Package Reference in Xcode

If the quick fix doesn't work:

1. Open the project in Xcode
2. In the Project Navigator, select the **MobileTrackerExample** project (blue icon at top)
3. Select the **MobileTrackerExample** target
4. Go to the **Frameworks, Libraries, and Embedded Content** section
5. Remove the MobileTracker package if present
6. Go to **File → Add Package Dependencies...**
7. Click **Add Local...** button
8. Navigate to and select the `ios` folder (the one containing Package.swift)
9. Click **Add Package**
10. Select **MobileTracker** from the products list
11. Click **Add Package**

## Verify Package is Valid

You can verify the package builds correctly:

```bash
cd ios
swift build
```

This should complete successfully.

## Verify Package Path

The project references the SDK at `../../ios` (relative path from the .xcodeproj location).

Verify the path is correct:

```bash
cd examples/ios/MobileTrackerExample
ls -la ../../ios/Package.swift
# Should show: ../../ios/Package.swift
```

## Why This Happens

Xcode aggressively caches Swift Package references and sometimes gets confused with local packages, especially when:

- The package path changes
- Xcode is open when you modify Package.swift
- Derived data gets corrupted
- Multiple Xcode versions are installed

## Last Resort: Regenerate Project

If nothing else works, regenerate the entire example project:

```bash
cd examples/ios
./create-project.sh
open MobileTrackerExample/MobileTrackerExample.xcodeproj
```

Then immediately reset caches:

1. File → Packages → Reset Package Caches
2. File → Packages → Resolve Package Versions
3. Build (⌘B)
