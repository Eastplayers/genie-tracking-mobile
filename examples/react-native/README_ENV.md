# Environment Configuration for React Native Example

This guide explains how to configure environment variables for the React Native example app.

## Quick Setup (Simple Approach)

### Option 1: Using react-native-config (Recommended)

1. Install react-native-config:

   ```bash
   npm install react-native-config
   cd ios && pod install && cd ..
   ```

2. Copy the example environment file:

   ```bash
   cp .env.example .env
   ```

3. Edit `.env` with your actual values:

   ```
   BRAND_ID=your_brand_id_here
   API_URL=https://api.your-tracking-platform.com
   X_API_KEY=your_api_key_here
   DEBUG=true
   ```

4. Update `config.ts` to use react-native-config:

   ```typescript
   import Config from 'react-native-config'

   export const AppConfig = {
     brandId: Config.BRAND_ID || '',
     apiUrl: Config.API_URL || '',
     xApiKey: Config.X_API_KEY,
     debug: Config.DEBUG === 'true',
   }
   ```

5. Rebuild the app:
   ```bash
   npm run android
   # or
   npm run ios
   ```

### Option 2: Using react-native-dotenv (Simpler)

1. Install dependencies:

   ```bash
   npm install react-native-dotenv
   npm install --save-dev @types/react-native-dotenv
   ```

2. Update `babel.config.js`:

   ```javascript
   module.exports = {
     presets: ['module:metro-react-native-babel-preset'],
     plugins: [
       [
         'module:react-native-dotenv',
         {
           moduleName: '@env',
           path: '.env',
           safe: false,
           allowUndefined: true,
         },
       ],
     ],
   }
   ```

3. Create `types/env.d.ts`:

   ```typescript
   declare module '@env' {
     export const BRAND_ID: string
     export const API_URL: string
     export const X_API_KEY: string
     export const DEBUG: string
   }
   ```

4. Copy and edit `.env`:

   ```bash
   cp .env.example .env
   # Edit .env with your values
   ```

5. Use in your code:
   ```typescript
   import { BRAND_ID, API_URL, X_API_KEY, DEBUG } from '@env'
   ```

### Option 3: Manual Configuration (No Dependencies)

If you don't want to add dependencies, you can create a config file:

1. Create `config.local.ts` (gitignored):

   ```typescript
   export const AppConfig = {
     brandId: 'your_brand_id',
     apiUrl: 'https://api.your-platform.com',
     xApiKey: 'your_api_key',
     debug: true,
   }
   ```

2. Add to `.gitignore`:

   ```
   config.local.ts
   ```

3. Import in your app:
   ```typescript
   import { AppConfig } from './config.local'
   ```

## Usage in Code

### With react-native-config:

```typescript
import MobileTracker from '@mobiletracker/react-native'
import Config from 'react-native-config'

// Initialize tracker
await MobileTracker.init({
  apiKey: Config.BRAND_ID,
  config: {
    debug: Config.DEBUG === 'true',
    apiUrl: Config.API_URL,
    xApiKey: Config.X_API_KEY,
  },
})
```

### With the config helper:

```typescript
import MobileTracker from '@mobiletracker/react-native'
import { AppConfig, validateConfig } from './config'

// Validate configuration
try {
  validateConfig()
} catch (error) {
  console.error('Configuration error:', error)
  return
}

// Initialize tracker
await MobileTracker.init({
  apiKey: AppConfig.brandId,
  config: {
    debug: AppConfig.debug,
    apiUrl: AppConfig.apiUrl,
    xApiKey: AppConfig.xApiKey,
  },
})
```

## Different Environments

### Development vs Production

Create multiple .env files:

- `.env` - Default configuration
- `.env.development` - Development settings
- `.env.production` - Production settings
- `.env.staging` - Staging settings

With react-native-config, specify the environment:

```bash
# iOS
ENVFILE=.env.production npm run ios

# Android
ENVFILE=.env.production npm run android
```

### Example .env files:

**.env.development:**

```
BRAND_ID=dev_brand_123
API_URL=https://api-dev.tracking-platform.com
X_API_KEY=sk_dev_abc123
DEBUG=true
```

**.env.production:**

```
BRAND_ID=prod_brand_456
API_URL=https://api.tracking-platform.com
X_API_KEY=sk_prod_xyz789
DEBUG=false
```

## Security Notes

- ⚠️ Never commit `.env` files to version control
- ⚠️ Never hardcode credentials in source code
- ✅ Use different values for development and production
- ✅ Rotate API keys regularly
- ✅ Use `.env.example` as a template (safe to commit)

## Troubleshooting

**Issue**: Environment variables are undefined

- Make sure `.env` file exists
- Rebuild the app completely (not just refresh)
- For iOS: `cd ios && pod install && cd ..`
- Clear Metro bundler cache: `npm start -- --reset-cache`

**Issue**: Changes to .env not reflected

- Stop Metro bundler
- Rebuild the app (not just reload)
- For react-native-config, you must rebuild native code

**Issue**: TypeScript errors with @env

- Make sure `types/env.d.ts` is created
- Add to `tsconfig.json`:
  ```json
  {
    "compilerOptions": {
      "typeRoots": ["./types", "./node_modules/@types"]
    }
  }
  ```

**Issue**: Works on iOS but not Android (or vice versa)

- react-native-config requires native rebuild for both platforms
- Run `npm run android` and `npm run ios` separately

## Recommended Setup

For most projects, we recommend **react-native-config** because:

- ✅ Works with native code (iOS and Android)
- ✅ Supports multiple environments
- ✅ No Metro bundler dependency
- ✅ Values available at build time
- ✅ More secure (not in JS bundle)

## Example Complete Setup

```bash
# 1. Install dependencies
npm install react-native-config
cd ios && pod install && cd ..

# 2. Create .env file
cp .env.example .env

# 3. Edit .env with your values
nano .env

# 4. Rebuild app
npm run android
npm run ios

# 5. Test configuration
# Your app should now load values from .env
```
