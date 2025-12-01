# npm Publishing Guide

## Pre-Publishing Checklist

Before publishing to npm, ensure:

### 1. Package Configuration ✅

- [x] `package.json` has correct name, version, description
- [x] `package.json` has repository, bugs, homepage fields
- [x] `package.json` has correct author information
- [x] `package.json` files field lists what to publish
- [x] `.npmignore` excludes unnecessary files
- [x] `README.md` exists with usage instructions

### 2. Code Quality

- [ ] All TypeScript compiles without errors: `npm run build`
- [ ] All tests pass: `npm test`
- [ ] Property-based tests pass: `npm run test:property`
- [ ] No console.log statements in production code
- [ ] Code follows project conventions

### 3. Native Dependencies

- [ ] iOS podspec is up to date (`MobileTrackerBridge.podspec`)
- [ ] Android build.gradle is configured correctly
- [ ] Native SDKs are published (iOS to CocoaPods, Android to JitPack)

### 4. Documentation

- [ ] README.md has installation instructions
- [ ] README.md has API documentation
- [ ] README.md has example usage
- [ ] CHANGELOG.md is updated (if exists)

### 5. Version Management

- [ ] Version follows semantic versioning (MAJOR.MINOR.PATCH)
- [ ] Version is bumped appropriately
- [ ] Git tag will be created after publishing

## Publishing Steps

### Option 1: Using the Script (Recommended)

```bash
cd react-native

# Publish with current version
./publish-npm.sh

# Publish with new version
./publish-npm.sh 0.2.0
```

The script will:

1. Check npm login status
2. Build TypeScript
3. Run tests
4. Show package contents
5. Confirm before publishing
6. Publish to npm
7. Provide next steps

### Option 2: Manual Publishing

```bash
cd react-native

# 1. Login to npm (if not already)
npm login

# 2. Update version (optional)
npm version patch  # or minor, major, or specific version like 0.2.0

# 3. Build TypeScript
npm run build

# 4. Run tests
npm test

# 5. Check what will be published
npm pack --dry-run

# 6. Publish
npm publish --access public
```

## After Publishing

### 1. Create Git Tag

```bash
# Get version from package.json
VERSION=$(node -p "require('./react-native/package.json').version")

# Create and push tag
git tag v$VERSION
git push origin v$VERSION
```

### 2. Verify Publication

```bash
# Check on npm
open https://www.npmjs.com/package/founder-os-tracker-react-native

# Test installation
npm install founder-os-tracker-react-native@latest
```

### 3. Update Documentation

- Update main README.md with new version
- Update example apps to use published version
- Announce release (if applicable)

## Version Guidelines

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0): Breaking changes
- **MINOR** (0.1.0): New features, backwards compatible
- **PATCH** (0.0.1): Bug fixes, backwards compatible

### Examples

```bash
# Bug fix
npm version patch  # 0.1.0 -> 0.1.1

# New feature
npm version minor  # 0.1.0 -> 0.2.0

# Breaking change
npm version major  # 0.1.0 -> 1.0.0

# Specific version
npm version 0.2.5
```

## Troubleshooting

### "You must be logged in to publish packages"

```bash
npm login
```

### "You do not have permission to publish"

Check package name isn't taken:

```bash
npm view founder-os-tracker-react-native
```

If taken, update name in `package.json`.

### "lib directory is empty"

Build TypeScript first:

```bash
npm run build
```

### Tests failing

Fix tests before publishing:

```bash
npm test
```

## Package Scope

This package is published as **public** (`--access public`).

To publish under an organization scope:

1. Update name in package.json: `@your-org/founder-os-tracker-react-native`
2. Publish: `npm publish --access public`

## Unpublishing

⚠️ **Warning**: Unpublishing is discouraged and has restrictions.

```bash
# Unpublish specific version (within 72 hours)
npm unpublish founder-os-tracker-react-native@0.1.0

# Deprecate instead (recommended)
npm deprecate founder-os-tracker-react-native@0.1.0 "Use version 0.2.0 instead"
```

## CI/CD Integration

For automated publishing, add to your CI/CD pipeline:

```yaml
# Example GitHub Actions
- name: Publish to npm
  run: |
    cd react-native
    echo "//registry.npmjs.org/:_authToken=${{ secrets.NPM_TOKEN }}" > ~/.npmrc
    npm run build
    npm test
    npm publish --access public
```

## Related Documentation

- [npm Publishing Guide](https://docs.npmjs.com/packages-and-modules/contributing-packages-to-the-registry)
- [Semantic Versioning](https://semver.org/)
- [React Native Library Publishing](https://reactnative.dev/docs/native-modules-setup)
