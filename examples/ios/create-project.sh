#!/bin/bash

# Create Xcode Project for MobileTracker iOS Example
# This creates a minimal but complete Xcode project

set -e

PROJECT_NAME="MobileTrackerExample"
BUNDLE_ID="com.mobiletracker.example"

echo "🚀 Creating Xcode project: $PROJECT_NAME"
echo ""

# Clean up
if [ -d "$PROJECT_NAME" ]; then
    echo "⚠️  Removing existing project..."
    rm -rf "$PROJECT_NAME"
fi

# Create directory structure
echo "📁 Creating project structure..."
mkdir -p "$PROJECT_NAME/$PROJECT_NAME"
mkdir -p "$PROJECT_NAME/$PROJECT_NAME/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$PROJECT_NAME/$PROJECT_NAME/Preview Content"

# Copy source files
echo "📄 Copying source files..."
cp ExampleApp.swift "$PROJECT_NAME/$PROJECT_NAME/"
cp ContentView.swift "$PROJECT_NAME/$PROJECT_NAME/"

# Create Assets
cat > "$PROJECT_NAME/$PROJECT_NAME/Assets.xcassets/Contents.json" << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

cat > "$PROJECT_NAME/$PROJECT_NAME/Assets.xcassets/AppIcon.appiconset/Contents.json" << 'EOF'
{
  "images" : [
    {
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create project.pbxproj (Xcode project file)
echo "🔨 Creating Xcode project file..."

# Generate UUIDs for Xcode
APP_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
CONTENT_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
ASSETS_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
GROUP_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
TARGET_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
PROJECT_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
BUILD_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
SOURCES_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
RESOURCES_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
FRAMEWORKS_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
PACKAGE_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
PACKAGE_PROD_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')

mkdir -p "$PROJECT_NAME/$PROJECT_NAME.xcodeproj"

cat > "$PROJECT_NAME/$PROJECT_NAME.xcodeproj/project.pbxproj" << EOF
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 55;
	objects = {

/* Begin PBXBuildFile section */
		${APP_UUID} /* ExampleApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = ${APP_UUID}00 /* ExampleApp.swift */; };
		${CONTENT_UUID} /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = ${CONTENT_UUID}00 /* ContentView.swift */; };
		${ASSETS_UUID} /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = ${ASSETS_UUID}00 /* Assets.xcassets */; };
		${PACKAGE_PROD_UUID} /* MobileTracker in Frameworks */ = {isa = PBXBuildFile; productRef = ${PACKAGE_UUID} /* MobileTracker */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		${TARGET_UUID}00 /* ${PROJECT_NAME}.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = ${PROJECT_NAME}.app; sourceTree = BUILT_PRODUCTS_DIR; };
		${APP_UUID}00 /* ExampleApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ExampleApp.swift; sourceTree = "<group>"; };
		${CONTENT_UUID}00 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		${ASSETS_UUID}00 /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		${FRAMEWORKS_UUID} /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				${PACKAGE_PROD_UUID} /* MobileTracker in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		${PROJECT_UUID}00 = {
			isa = PBXGroup;
			children = (
				${GROUP_UUID} /* ${PROJECT_NAME} */,
				${TARGET_UUID}01 /* Products */,
			);
			sourceTree = "<group>";
		};
		${TARGET_UUID}01 /* Products */ = {
			isa = PBXGroup;
			children = (
				${TARGET_UUID}00 /* ${PROJECT_NAME}.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		${GROUP_UUID} /* ${PROJECT_NAME} */ = {
			isa = PBXGroup;
			children = (
				${APP_UUID}00 /* ExampleApp.swift */,
				${CONTENT_UUID}00 /* ContentView.swift */,
				${ASSETS_UUID}00 /* Assets.xcassets */,
			);
			path = ${PROJECT_NAME};
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		${TARGET_UUID} /* ${PROJECT_NAME} */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = ${BUILD_UUID} /* Build configuration list for PBXNativeTarget "${PROJECT_NAME}" */;
			buildPhases = (
				${SOURCES_UUID} /* Sources */,
				${FRAMEWORKS_UUID} /* Frameworks */,
				${RESOURCES_UUID} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = ${PROJECT_NAME};
			packageProductDependencies = (
				${PACKAGE_UUID} /* MobileTracker */,
			);
			productName = ${PROJECT_NAME};
			productReference = ${TARGET_UUID}00 /* ${PROJECT_NAME}.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		${PROJECT_UUID} /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1400;
				LastUpgradeCheck = 1400;
			};
			buildConfigurationList = ${PROJECT_UUID}01 /* Build configuration list for PBXProject "${PROJECT_NAME}" */;
			compatibilityVersion = "Xcode 13.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = ${PROJECT_UUID}00;
			packageReferences = (
				${PACKAGE_UUID}00 /* XCLocalSwiftPackageReference "MobileTracker" */,
			);
			productRefGroup = ${TARGET_UUID}01 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				${TARGET_UUID} /* ${PROJECT_NAME} */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		${RESOURCES_UUID} /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				${ASSETS_UUID} /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		${SOURCES_UUID} /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				${CONTENT_UUID} /* ContentView.swift in Sources */,
				${APP_UUID} /* ExampleApp.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		${BUILD_UUID}00 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"\$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_ID};
				PRODUCT_NAME = "\$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		${BUILD_UUID}01 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"\$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_ID};
				PRODUCT_NAME = "\$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
		${PROJECT_UUID}02 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++17";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"\$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		${PROJECT_UUID}03 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++17";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		${BUILD_UUID} /* Build configuration list for PBXNativeTarget "${PROJECT_NAME}" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				${BUILD_UUID}00 /* Debug */,
				${BUILD_UUID}01 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		${PROJECT_UUID}01 /* Build configuration list for PBXProject "${PROJECT_NAME}" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				${PROJECT_UUID}02 /* Debug */,
				${PROJECT_UUID}03 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */

/* Begin XCLocalSwiftPackageReference section */
		${PACKAGE_UUID}00 /* XCLocalSwiftPackageReference "MobileTracker" */ = {
			isa = XCLocalSwiftPackageReference;
			relativePath = ../../../ios;
		};
/* End XCLocalSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
		${PACKAGE_UUID} /* MobileTracker */ = {
			isa = XCSwiftPackageProductDependency;
			package = ${PACKAGE_UUID}00 /* XCLocalSwiftPackageReference "MobileTracker" */;
			productName = MobileTracker;
		};
/* End XCSwiftPackageProductDependency section */
	};
	rootObject = ${PROJECT_UUID} /* Project object */;
}
EOF

# Create workspace settings
mkdir -p "$PROJECT_NAME/$PROJECT_NAME.xcodeproj/project.xcworkspace"
cat > "$PROJECT_NAME/$PROJECT_NAME.xcodeproj/project.xcworkspace/contents.xcworkspacedata" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
EOF

mkdir -p "$PROJECT_NAME/$PROJECT_NAME.xcodeproj/project.xcworkspace/xcshareddata"
cat > "$PROJECT_NAME/$PROJECT_NAME.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>IDEDidComputeMac32BitWarning</key>
	<true/>
</dict>
</plist>
EOF

echo ""
echo "✅ Xcode project created successfully!"
echo ""
echo "📱 To open and run:"
echo ""
echo "   open $PROJECT_NAME/$PROJECT_NAME.xcodeproj"
echo ""
echo "Then in Xcode:"
echo "  1. Wait for package dependencies to resolve (may take a moment)"
echo "  2. Select an iPhone simulator from the device menu"
echo "  3. Press Cmd+R to build and run"
echo ""
echo "🎉 Your app is ready to run!"
echo ""
