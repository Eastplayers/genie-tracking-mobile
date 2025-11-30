package com.mobiletracker.bridge

import com.facebook.react.bridge.*
import com.mobiletracker.MobileTracker
import com.mobiletracker.TrackerError

/**
 * React Native bridge module for Mobile Tracking SDK (Android)
 * 
 * This module exposes the native Android SDK functionality to React Native
 * JavaScript code. It handles data serialization between JavaScript and native
 * Android, and forwards all calls to the underlying MobileTracker SDK.
 * 
 * Usage from React Native:
 * ```javascript
 * import { NativeModules } from 'react-native';
 * const { MobileTrackerBridge } = NativeModules;
 * 
 * // Initialize with brand ID and API key
 * await MobileTrackerBridge.initialize({
 *   brandId: '925',  // Brand ID
 *   apiKey: 'api_key',  // Brand ID
 *   endpoint: 'https://tracking.api.qc.founder-os.ai/api',
 *   x_api_key: 'your-api-key',  // API key for authentication
 *   debug: true
 * });
 * 
 * // Track event
 * MobileTrackerBridge.track('Button Clicked', { button_name: 'signup' });
 * 
 * // Identify user
 * MobileTrackerBridge.identify('user123', { email: 'user@example.com' });
 * 
 * // Track screen
 * MobileTrackerBridge.screen('Home Screen', { section: 'main' });
 * ```
 */
class MobileTrackerBridge(reactContext: ReactApplicationContext) : 
    ReactContextBaseJavaModule(reactContext) {
    
    /**
     * Name of the module as exposed to React Native
     * This must match the name used in JavaScript: NativeModules.MobileTrackerBridge
     */
    override fun getName(): String = "MobileTrackerBridge"
    
    /**
     * Initialize the Mobile Tracking SDK
     * 
     * Forwards initialization to the native Android SDK with validation.
     * Returns a promise that resolves on success or rejects with an error.
     * 
     * @param config ReadableMap containing configuration:
     *   - apiKey: Brand ID (identifies your application/brand)
     *   - endpoint: Backend API URL
     *   - x_api_key: API key for authentication
     *   - debug: Enable debug logging (optional)
     * @param promise Promise to resolve/reject based on initialization result
     */
    @ReactMethod
    fun initialize(config: ReadableMap, promise: Promise) {
        try {
            val brandId = config.getString("apiKey") ?: throw IllegalArgumentException("Brand ID (apiKey) is required")
            val apiUrl = config.getString("endpoint") ?: throw IllegalArgumentException("API URL (endpoint) is required")
            val xApiKey = config.getString("x_api_key")
            val debug = config.getBoolean("debug")
            
            val trackerConfig = com.mobiletracker.TrackerConfig(
                debug = debug,
                apiUrl = apiUrl,
                xApiKey = xApiKey
            )
            
            kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.IO).launch {
                try {
                    MobileTracker.getInstance().initialize(
                        context = reactApplicationContext,
                        brandId = brandId,
                        config = trackerConfig
                    )
                    kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Main) {
                        promise.resolve(null)
                    }
                } catch (e: Exception) {
                    kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Main) {
                        promise.reject("INIT_ERROR", e.message, e)
                    }
                }
            }
        } catch (e: Exception) {
            promise.reject("INIT_ERROR", e.message, e)
        }
    }
    
    /**
     * Track a custom event
     * 
     * Forwards the event to the native SDK. Converts React Native ReadableMap
     * to a native Kotlin Map for properties.
     * 
     * @param event The name of the event to track
     * @param properties Optional ReadableMap of event properties
     */
    @ReactMethod
    fun track(event: String, properties: ReadableMap?) {
        val propsMap = properties?.toHashMap()
        MobileTracker.getInstance().track(event, propsMap)
    }
    
    /**
     * Identify a user with a unique ID and traits
     * 
     * Forwards user identification to the native SDK. Converts React Native
     * ReadableMap to a native Kotlin Map for traits.
     * 
     * @param userId The unique identifier for the user
     * @param traits Optional ReadableMap of user attributes
     */
    @ReactMethod
    fun identify(userId: String, traits: ReadableMap?) {
        val traitsMap = traits?.toHashMap()
        MobileTracker.getInstance().identify(userId, traitsMap)
    }
    
    /**
     * Track a screen view
     * 
     * Forwards screen tracking to the native SDK. Converts React Native
     * ReadableMap to a native Kotlin Map for properties.
     * 
     * @param name The name of the screen
     * @param properties Optional ReadableMap of screen properties
     */
    @ReactMethod
    fun screen(name: String, properties: ReadableMap?) {
        val propsMap = properties?.toHashMap()
        MobileTracker.getInstance().screen(name, propsMap)
    }
    
    /**
     * Set metadata for tracking context
     * 
     * Forwards metadata to the native SDK. Converts React Native ReadableMap
     * to a native Kotlin Map. Returns a promise that resolves on success or
     * rejects with an error.
     * 
     * Web Reference: tracker.ts lines 426-461
     * 
     * @param metadata ReadableMap of metadata key-value pairs
     * @param promise Promise to resolve/reject based on operation result
     */
    @ReactMethod
    fun setMetadata(metadata: ReadableMap, promise: Promise) {
        try {
            val metadataMap = metadata.toHashMap()
            kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.IO).launch {
                try {
                    MobileTracker.getInstance().setMetadata(metadataMap)
                    kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Main) {
                        promise.resolve(null)
                    }
                } catch (e: Exception) {
                    kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Main) {
                        promise.reject("SET_METADATA_ERROR", e.message, e)
                    }
                }
            }
        } catch (e: Exception) {
            promise.reject("SET_METADATA_ERROR", e.message, e)
        }
    }
    
    /**
     * Update user profile with new data
     * 
     * Forwards profile data to the native SDK. Converts React Native ReadableMap
     * to a native Kotlin Map. Returns a promise that resolves on success or
     * rejects with an error.
     * 
     * Web Reference: tracker.ts lines 381-403
     * 
     * @param profileData ReadableMap of profile data key-value pairs
     * @param promise Promise to resolve/reject based on operation result
     */
    @ReactMethod
    fun set(profileData: ReadableMap, promise: Promise) {
        try {
            val profileMap = profileData.toHashMap()
            kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.IO).launch {
                try {
                    MobileTracker.getInstance().set(profileMap)
                    kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Main) {
                        promise.resolve(null)
                    }
                } catch (e: Exception) {
                    kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Main) {
                        promise.reject("SET_PROFILE_ERROR", e.message, e)
                    }
                }
            }
        } catch (e: Exception) {
            promise.reject("SET_PROFILE_ERROR", e.message, e)
        }
    }
    
    /**
     * Reset tracker state and clear all stored data
     * 
     * Forwards reset command to the native SDK. This clears session data,
     * device ID, and other tracking information.
     * 
     * Web Reference: tracker.ts lines 463-502
     * 
     * @param all If true, also clear brand_id
     */
    @ReactMethod
    fun reset(all: Boolean) {
        MobileTracker.getInstance().reset(all)
    }
    
    /**
     * Reset tracker state (convenience method without parameters)
     * 
     * Calls reset with all=false by default
     */
    @ReactMethod
    fun resetDefault() {
        MobileTracker.getInstance().reset(false)
    }
}
