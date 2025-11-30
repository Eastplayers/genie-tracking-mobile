package com.mobiletracker

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Bundle
import kotlinx.coroutines.*
import java.util.Timer
import kotlin.concurrent.schedule

/**
 * Main Mobile Tracking SDK class for Android
 * 
 * Web Reference: examples/originalWebScript/core/tracker.ts - FounderOS class
 * 
 * This class mirrors the web implementation's API surface and behavior,
 * managing initialization, event tracking, user identification, and session management.
 * 
 * Usage:
 * ```
 * // Initialize the SDK
 * MobileTracker.getInstance().initialize(context, "925", TrackerConfig(debug = true))
 * 
 * // Track an event
 * MobileTracker.getInstance().track("BUTTON_CLICK", mapOf("button" to "signup"))
 * 
 * // Identify a user
 * MobileTracker.getInstance().identify("user123", mapOf("email" to "user@example.com"))
 * 
 * // Set metadata
 * MobileTracker.getInstance().setMetadata(mapOf("plan" to "premium"))
 * 
 * // Reset tracking
 * MobileTracker.getInstance().reset()
 * ```
 */
class MobileTracker private constructor() {
    
    companion object {
        @Volatile
        private var instance: MobileTracker? = null
        
        /**
         * Get the singleton instance of MobileTracker
         * Web Reference: tracker.ts line 665
         * 
         * @return The MobileTracker instance
         */
        fun getInstance(): MobileTracker {
            return instance ?: synchronized(this) {
                instance ?: MobileTracker().also { instance = it }
            }
        }
    }
    
    // Properties matching web implementation
    // Web Reference: tracker.ts lines 39-47
    
    private var config: TrackerConfig = TrackerConfig.default()  // web: line 39
    private var apiClient: ApiClient? = null  // web: line 40
    private var brandId: String = ""  // web: line 41
    private var initialized: Boolean = false  // web: line 42
    private var isInitPending: Boolean = false  // web: line 43
    private var initJob: Job? = null  // web: line 44 (initPromise in web)
    private val pendingTrackCalls = mutableListOf<Triple<String, Map<String, Any>?, Map<String, Any>?>>()  // web: line 46
    private var lastTrackedUrl: String? = null  // web: line 47
    private var initializationFailed: Boolean = false  // Track if initialization has failed
    private val MAX_PENDING_EVENTS = 100  // Limit pending events to prevent memory issues
    
    private var context: Context? = null
    
    /**
     * Initialize the tracker with brand ID and configuration
     * Web Reference: tracker.ts lines 56-104
     * 
     * @param context Android application context
     * @param brandId Your brand ID (string or number)
     * @param config Configuration options
     */
    suspend fun initialize(context: Context, brandId: String, config: TrackerConfig? = null) {
        // If already initialized, return immediately (web: lines 63-68)
        if (initialized) {
            if (this.config.debug) {
                println("[MobileTracker] Already initialized")
            }
            return
        }
        
        // If initialization is already in progress, wait for it to complete (web: lines 70-77)
        if (isInitPending && initJob != null) {
            if (this.config.debug) {
                println("[MobileTracker] Initialization already in progress, waiting...")
            }
            initJob?.join()
            return
        }
        
        // Set pending state (web: line 80)
        isInitPending = true
        
        // Create 30-second timeout (web: lines 82-89)
        val timeoutTimer = Timer()
        timeoutTimer.schedule(30000) {
            if (this@MobileTracker.config.debug) {
                println("[MobileTracker] Initialization timeout - resetting state")
            }
            isInitPending = false
            initJob = null
        }
        
        // Create and store the initialization job (web: line 92)
        initJob = CoroutineScope(Dispatchers.IO).launch {
            try {
                performInitialization(context, brandId, config)
            } finally {
                // Clear timeout if initialization completes normally (web: lines 96-99)
                timeoutTimer.cancel()
            }
        }
        
        initJob?.join()
    }
    
    /**
     * Perform the actual initialization logic
     * Web Reference: tracker.ts lines 106-172
     * 
     * @param context Android application context
     * @param brandId Brand ID
     * @param config Configuration options
     */
    private suspend fun performInitialization(context: Context, brandId: String, config: TrackerConfig?) {
        try {
            // Validate brandId is non-empty (web: lines 112-114)
            if (brandId.isEmpty()) {
                throw IllegalArgumentException("Brand ID is required")
            }
            
            // Validate brandId is numeric (web: lines 116-118)
            if (brandId.toIntOrNull() == null) {
                throw IllegalArgumentException("Brand ID must be a number")
            }
            
            // Store brandId (web: line 121)
            this.brandId = brandId
            
            // Merge config with defaults (web: line 122)
            this.config = config ?: TrackerConfig.default()
            
            // Validate config (web: lines 124-128)
            validateConfig(this.config)
            
            // Store context
            this.context = context.applicationContext
            
            // Create ApiClient instance (web: lines 131-132)
            this.apiClient = ApiClient(this.config, brandId, context.applicationContext)
            
            // Set brandId on ApiClient (web: line 133)
            this.apiClient?.setBrandId(brandId.toInt())
            
            // Check for existing session: sessionId = apiClient.getSessionId()
            var sessionId = this.apiClient?.getSessionId()
            
            if (this.config.debug) {
                println("[MobileTracker] Existing session ID: ${sessionId ?: "none"}")
            }
            
            // If no sessionId: create session via apiClient.createTrackingSession()
            if (sessionId == null) {
                if (this.config.debug) {
                    println("[MobileTracker] Creating new tracking session...")
                }
                sessionId = this.apiClient?.createTrackingSession(brandId.toInt())
                
                if (this.config.debug) {
                    println("[MobileTracker] Session created: ${if (sessionId != null) "success ($sessionId)" else "failed"}")
                }
                
                // If session creation failed, throw an error
                if (sessionId == null) {
                    throw IllegalStateException("Failed to create tracking session - check network connectivity and API credentials")
                }
            }
            
            // Mark as initialized (web: line 136)
            initialized = true
            
            if (this.config.debug) {
                println("[MobileTracker] ✅ Marked as initialized")
                println("[MobileTracker] Final session ID: ${this.apiClient?.getSessionId()}")
            }
            
            // Initialize background services async (web: lines 147-149)
            withContext(Dispatchers.Main) {
                setupPageViewTracking()
            }
            
            if (this.config.debug) {
                println("[MobileTracker] ✅ Initialization completed successfully")
            }
        } catch (error: Exception) {
            // Catch errors gracefully, never crash (web: lines 150-155)
            initializationFailed = true
            if (this.config.debug) {
                println("[MobileTracker] ❌ Initialization failed: ${error.message}")
                println("[MobileTracker] Error type: ${error.javaClass.simpleName}")
                error.printStackTrace()
            }
            // DO NOT re-throw error to prevent crashing the app
        } finally {
            // Set isInitPending = false in finally (web: line 157)
            isInitPending = false
            
            // Flush pending track calls (web: lines 159-161)
            if (initialized) {
                flushPendingTrackCalls()
            } else if (initializationFailed && this.config.debug) {
                // Clear pending events if initialization failed
                if (pendingTrackCalls.isNotEmpty()) {
                    println("[MobileTracker] ⚠️ Discarding ${pendingTrackCalls.size} pending events due to initialization failure")
                    pendingTrackCalls.clear()
                }
            }
        }
    }
    
    /**
     * Validate configuration
     * Web Reference: tracker.ts lines 124-128
     */
    private fun validateConfig(config: TrackerConfig) {
        // Basic validation - can be extended as needed
        if (config.apiUrl.isNullOrEmpty()) {
            throw IllegalArgumentException("API URL is required in configuration")
        }
    }
    
    /**
     * Track an event with optional attributes and metadata
     * Web Reference: tracker.ts lines 280-346
     * 
     * @param eventName The name of the event (e.g., 'BUTTON_CLICK', 'PAGE_VIEW')
     * @param attributes Event properties
     * @param metadata Technical metadata
     */
    suspend fun track(
        eventName: String,
        attributes: Map<String, Any>? = null,
        metadata: Map<String, Any>? = null
    ) {
        // If initialization failed, don't queue events
        if (initializationFailed) {
            if (config.debug) {
                println("[MobileTracker] ⚠️ Cannot track event '$eventName' - initialization failed")
            }
            return
        }
        
        // If init pending, queue event (web: lines 287-290)
        if (isInitPending) {
            if (pendingTrackCalls.size < MAX_PENDING_EVENTS) {
                pendingTrackCalls.add(Triple(eventName, attributes, metadata))
                if (config.debug) {
                    println("[MobileTracker] Initialization pending - queuing event: $eventName")
                }
            } else if (config.debug) {
                println("[MobileTracker] ⚠️ Event queue full - dropping event: $eventName")
            }
            return
        }
        
        // If not initialized, warn and return (web: lines 292-297)
        if (!initialized || apiClient == null) {
            if (config.debug) {
                println("[MobileTracker] ⚠️ Not initialized. Call initialize() first.")
            }
            return
        }
        
        // Get sessionId from apiClient (web: line 299)
        val sessionId = apiClient?.getSessionId()
        
        if (config.debug) {
            println("[MobileTracker] Tracking event: $eventName (session: ${sessionId ?: "none"})")
        }
        
        // If no sessionId, don't queue - this shouldn't happen if initialized properly
        if (sessionId == null) {
            if (config.debug) {
                println("[MobileTracker] ⚠️ Missing session ID - cannot track event: $eventName")
            }
            return
        }
        
        // Get brandId from apiClient (web: line 317)
        val brandId = apiClient?.getBrandId()
        
        if (brandId == null) {
            if (config.debug) {
                println("[MobileTracker] Missing brand ID")
            }
            return
        }
        
        // Merge attributes and metadata (web: line 323)
        val eventData = mutableMapOf<String, Any>()
        attributes?.let { eventData.putAll(it) }
        metadata?.let { eventData.putAll(it) }
        
        try {
            // Call apiClient.trackEvent() (web: line 326)
            val success = apiClient?.trackEvent(brandId, sessionId, eventName, eventData)
            
            // Log success/error in debug mode (web: lines 328-334)
            if (config.debug) {
                if (success == true) {
                    println("[MobileTracker] Event tracked: $eventName")
                } else {
                    println("[MobileTracker] Failed to track event: $eventName")
                }
            }
        } catch (error: Exception) {
            if (config.debug) {
                println("[MobileTracker] Error tracking event: ${error.message}")
            }
        }
    }
    
    /**
     * Identify a user with their ID and profile data
     * Web Reference: tracker.ts lines 348-379
     * 
     * @param userId Unique user identifier
     * @param profileData User profile information
     */
    suspend fun identify(userId: String, profileData: Map<String, Any>? = null) {
        // Check if initialized (web: lines 354-359)
        if (!initialized || apiClient == null) {
            if (config.debug) {
                println("[MobileTracker] Not initialized. Call initialize() first.")
            }
            return
        }
        
        // Validate user_id is not empty (web: lines 369-374)
        if (userId.isEmpty()) {
            if (config.debug) {
                println("[MobileTracker] user_id is required for identify()")
            }
            return
        }
        
        // Call updateProfile() with combined data (web: lines 376-378)
        val data = profileData?.toMutableMap() ?: mutableMapOf()
        data["user_id"] = userId
        
        updateProfile(data)
    }
    
    /**
     * Update user profile with new data
     * Web Reference: tracker.ts lines 381-403
     * 
     * @param profileData Profile data to update
     */
    suspend fun set(profileData: Map<String, Any>) {
        // Check if initialized (web: lines 387-392)
        if (!initialized || apiClient == null) {
            if (config.debug) {
                println("[MobileTracker] Not initialized. Call initialize() first.")
            }
            return
        }
        
        // Call updateProfile() with data (web: line 402)
        updateProfile(profileData)
    }
    
    /**
     * Update user profile with detailed data (internal method)
     * Web Reference: tracker.ts lines 405-424
     * 
     * @param data Profile data with specific fields
     */
    private suspend fun updateProfile(data: Map<String, Any>) {
        if (!initialized || apiClient == null) {
            if (config.debug) {
                println("[MobileTracker] Not initialized. Call initialize() first.")
            }
            return
        }
        
        val brandId = apiClient?.getBrandId()
        if (brandId == null) {
            if (config.debug) {
                println("[MobileTracker] No brand_id available")
            }
            return
        }
        
        try {
            // Convert map to UpdateProfileData
            val profileData = UpdateProfileData(
                name = data["name"] as? String,
                phone = data["phone"] as? String,
                gender = data["gender"] as? String,
                business_domain = data["business_domain"] as? String,
                metadata = data["metadata"] as? Map<String, Any>,
                email = data["email"] as? String,
                source = data["source"] as? String,
                birthday = data["birthday"] as? String,
                user_id = data["user_id"] as? String
            )
            
            val success = apiClient?.updateProfile(profileData, brandId)
            
            if (config.debug) {
                if (success == true) {
                    println("[MobileTracker] Profile updated successfully")
                } else {
                    println("[MobileTracker] Failed to update profile")
                }
            }
        } catch (error: Exception) {
            if (config.debug) {
                println("[MobileTracker] Error updating profile: ${error.message}")
            }
        }
    }
    
    /**
     * Set metadata for tracking context
     * Web Reference: tracker.ts lines 426-461
     * 
     * @param metadata Metadata object
     */
    suspend fun setMetadata(metadata: Map<String, Any>) {
        // Check if initialized (web: lines 432-437)
        if (!initialized || apiClient == null) {
            if (config.debug) {
                println("[MobileTracker] Not initialized. Call initialize() first.")
            }
            return
        }
        
        try {
            // Get brandId from apiClient (web: lines 443-449)
            val brandId = apiClient?.getBrandId()
            if (brandId == null) {
                if (config.debug) {
                    println("[MobileTracker] No brand_id available")
                }
                return
            }
            
            // Call apiClient.setMetadata() (web: line 451)
            val success = apiClient?.setMetadata(metadata, brandId)
            
            // Log success/error in debug mode (web: lines 453-459)
            if (config.debug) {
                if (success == true) {
                    println("[MobileTracker] Metadata set successfully")
                } else {
                    println("[MobileTracker] Failed to set metadata")
                }
            }
        } catch (error: Exception) {
            if (config.debug) {
                println("[MobileTracker] Error setting metadata: ${error.message}")
            }
        }
    }
    
    /**
     * Reset tracker state and clear all stored data
     * Web Reference: tracker.ts lines 463-502
     * 
     * @param all If true, also clear brand_id
     */
    fun reset(all: Boolean = false) {
        val storage = apiClient?.let { 
            StorageManager(context ?: return, "__GT_${brandId}_")
        } ?: return
        
        // Clear storage: session_id, device_id, session_email, identify_id (web: lines 469-479)
        val cookiesToClear = mutableListOf(
            "session_id",
            "device_id", 
            "session_email",
            "identify_id"
        )
        
        // If all=true, also clear brand_id (web: lines 470-472)
        if (all) {
            cookiesToClear.add("brand_id")
        }
        
        cookiesToClear.forEach { cookie ->
            storage.remove(cookie)
        }
        
        // Clear file backup items with brand prefix (web: lines 482-489)
        storage.clear()
        
        // Reset internal state: isInitPending, pendingTrackCalls, lastTrackedUrl (web: lines 492-494)
        isInitPending = false
        initializationFailed = false
        pendingTrackCalls.clear()
        lastTrackedUrl = null
        
        // Create new tracking session (web: lines 495-497)
        if (brandId.isNotEmpty()) {
            CoroutineScope(Dispatchers.IO).launch {
                apiClient?.createTrackingSession(brandId.toInt())
            }
        }
        
        // Log completion in debug mode (web: lines 499-501)
        if (config.debug) {
            println("[MobileTracker] Reset completed")
        }
    }
    
    /**
     * Flush pending track calls
     * Web Reference: tracker.ts lines 619-623
     */
    private suspend fun flushPendingTrackCalls() {
        if (config.debug && pendingTrackCalls.isNotEmpty()) {
            println("[MobileTracker] Flushing ${pendingTrackCalls.size} pending events")
        }
        
        // Create a copy to avoid infinite loop if track() re-queues events
        val eventsToFlush = pendingTrackCalls.toList()
        pendingTrackCalls.clear()
        
        eventsToFlush.forEach { (eventName, attributes, metadata) ->
            track(eventName, attributes, metadata)
        }
    }
    
    /**
     * Setup automatic page view tracking for screen changes
     * Web Reference: tracker.ts lines 625-662 (adapted for Android)
     */
    private fun setupPageViewTracking() {
        val ctx = context ?: return
        
        // Get application instance if context is an Application
        val application = when (ctx) {
            is Application -> ctx
            else -> ctx.applicationContext as? Application
        } ?: return
        
        // Track initial VIEW_PAGE event (web: lines 631-632)
        CoroutineScope(Dispatchers.IO).launch {
            val initialUrl = "app://initial"
            track("VIEW_PAGE", mapOf("url" to initialUrl))
            lastTrackedUrl = initialUrl
        }
        
        // Use ActivityLifecycleCallbacks to detect screen changes
        application.registerActivityLifecycleCallbacks(object : Application.ActivityLifecycleCallbacks {
            override fun onActivityResumed(activity: Activity) {
                // Track VIEW_PAGE when Activity resumes
                CoroutineScope(Dispatchers.IO).launch {
                    val currentUrl = "app://${activity.javaClass.simpleName}"
                    
                    // Only track if URL changed (web: lines 635-641)
                    if (currentUrl != lastTrackedUrl) {
                        lastTrackedUrl = currentUrl
                        track("VIEW_PAGE", mapOf("url" to currentUrl))
                    }
                }
            }
            
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
            override fun onActivityStarted(activity: Activity) {}
            override fun onActivityPaused(activity: Activity) {}
            override fun onActivityStopped(activity: Activity) {}
            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
            override fun onActivityDestroyed(activity: Activity) {}
        })
    }
}
