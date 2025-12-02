package ai.founderos.mobiletracker

import android.content.Context
import android.os.Build
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.serialization.Contextual
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.buildJsonArray
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import java.util.UUID
import java.util.concurrent.TimeUnit

/**
 * ApiClient handles all backend communication for the Mobile Tracking SDK
 * 
 * Web Reference: examples/originalWebScript/utils/api.ts - ApiClient class
 * 
 * This class mirrors the web implementation's API surface and behavior,
 * managing session creation, event tracking, profile updates, and storage.
 */
class ApiClient(
    private val config: TrackerConfig,
    brandId: String,
    private val context: Context
) {
    private val storagePrefix = "__GT_${brandId}_"
    private val storage = StorageManager(context, storagePrefix)
    private val locationManager: LocationManager by lazy {
        LocationManager(context, this, config)
    }
    
    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()
    
    private val json = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
    }
    
    companion object {
        private val JSON_MEDIA_TYPE = "application/json; charset=utf-8".toMediaType()
    }
    
    /**
     * Get HTTP headers for API requests
     * Web Reference: api.ts lines 20-32
     */
    private fun getHeaders(): Map<String, String> {
        val headers = mutableMapOf(
            "Content-Type" to "application/json"
        )
        
        // Add x-api-key if provided
        config.xApiKey?.let {
            headers["x-api-key"] = it
        }
        
        return headers
    }
    
    // MARK: - Storage Methods (Cookie-like operations)
    // Web Reference: api.ts lines 37-127
    
    /**
     * Get a value from storage (like getCookie in web)
     * Web Reference: api.ts lines 37-52
     */
    private fun getCookie(name: String): String? {
        return storage.retrieve(name)
    }
    
    /**
     * Write a value to storage (like writeCookie in web)
     * Web Reference: api.ts lines 54-97
     */
    private fun writeCookie(name: String, value: String, expires: Int? = null, domain: String? = null) {
        storage.save(name, value, expires)
    }
    
    /**
     * Clear a value from storage (like clearCookie in web)
     * Web Reference: api.ts lines 99-127
     */
    private fun clearCookie(name: String, domain: String? = null) {
        storage.remove(name)
    }
    
    /**
     * Clear all tracking cookies and localStorage
     * Web Reference: api.ts lines 132-148
     */
    fun clearAllTrackingCookies() {
        val cookiesToClear = listOf("device_id", "session_id", "session_email", "identify_id")
        
        cookiesToClear.forEach { cookieName ->
            clearCookie(cookieName)
        }
        
        if (config.debug) {
            println("[ApiClient] All tracking cookies cleared")
        }
    }
    
    // MARK: - Device ID Methods
    // Web Reference: api.ts lines 175-249
    
    /**
     * Generate a UUID for device identification
     * Web Reference: api.ts lines 175-184
     */
    private fun generateUUID(): String {
        return UUID.randomUUID().toString()
    }
    
    /**
     * Detect the operating system
     * Web Reference: api.ts lines 186-199
     */
    private fun detectOS(): String {
        return "Android"
    }
    
    /**
     * Get the current device ID, used for cross-domain tracking
     * Web Reference: api.ts line 231
     */
    fun getDeviceId(): String? {
        return getCookie("device_id")
    }
    
    /**
     * Generate and save a new device ID
     * Web Reference: api.ts lines 233-235
     */
    suspend fun writeDeviceId(): String = withContext(Dispatchers.IO) {
        val deviceId = generateUUID()
        writeCookie("device_id", deviceId, expires = 365, domain = config.cookieDomain)
        deviceId
    }
    
    /**
     * Get comprehensive device information
     * Web Reference: api.ts lines 225-249
     */
    suspend fun getDeviceInfo(): DeviceInfo = withContext(Dispatchers.IO) {
        val osName = detectOS()
        
        // Get or generate unique device ID
        var deviceId = getCookie("device_id")
        if (deviceId == null) {
            deviceId = generateUUID()
            writeCookie("device_id", deviceId, expires = 365, domain = config.cookieDomain)
        }
        
        // Detect device type based on screen size/configuration
        val deviceType = detectDeviceType()
        
        DeviceInfo(
            device_id = deviceId,
            os_name = osName,
            device_type = deviceType
        )
    }
    
    /**
     * Detect device type (Mobile, Tablet, Desktop)
     */
    private fun detectDeviceType(): String {
        val configuration = context.resources.configuration
        val screenLayout = configuration.screenLayout and android.content.res.Configuration.SCREENLAYOUT_SIZE_MASK
        
        return when (screenLayout) {
            android.content.res.Configuration.SCREENLAYOUT_SIZE_XLARGE -> "Tablet"
            android.content.res.Configuration.SCREENLAYOUT_SIZE_LARGE -> "Tablet"
            else -> "Mobile"
        }
    }
    
    // MARK: - Session Methods
    // Web Reference: api.ts lines 251-362
    
    /**
     * Create a new tracking session with the backend
     * Web Reference: api.ts lines 251-291
     */
    suspend fun createTrackingSession(brandId: Int): String? = withContext(Dispatchers.IO) {
        try {
            if (config.debug) {
                println("[ApiClient] Starting createTrackingSession for brand: $brandId")
            }
            
            val deviceData = getDeviceInfo()
            
            if (config.debug) {
                println("[ApiClient] Device info: device_id=${deviceData.device_id}, os=${deviceData.os_name}, type=${deviceData.device_type}")
            }
            
            // Build payload matching web structure
            val payload = buildJsonObject {
                put("device_id", JsonPrimitive(deviceData.device_id))
                put("os_name", JsonPrimitive(deviceData.os_name))
                put("device_type", JsonPrimitive(deviceData.device_type))
                put("brand_id", JsonPrimitive(brandId))
            }
            
            val jsonPayload = payload.toString()
            
            val requestBody = jsonPayload.toRequestBody(JSON_MEDIA_TYPE)
            val requestBuilder = Request.Builder()
                .url("${config.getEffectiveApiUrl()}/v2/tracking-session")
                .post(requestBody)
            
            // Add headers
            getHeaders().forEach { (key, value) ->
                requestBuilder.addHeader(key, value)
            }
            
            val request = requestBuilder.build()
            
            if (config.debug) {
                println("[ApiClient] Creating session - POST ${request.url}")
                println("[ApiClient] Headers: ${request.headers}")
                println("[ApiClient] Payload: $jsonPayload")
            }
            
            val response = client.newCall(request).execute()
            
            if (!response.isSuccessful) {
                val responseBody = response.body?.string()
                if (config.debug) {
                    println("[ApiClient] ❌ Failed to create session: HTTP ${response.code}")
                    println("[ApiClient] Response body: $responseBody")
                }
                return@withContext null
            }
            
            val responseBody = response.body?.string()
            if (responseBody == null) {
                if (config.debug) {
                    println("[ApiClient] ❌ Empty response body")
                }
                return@withContext null
            }
            
            if (config.debug) {
                println("[ApiClient] ✅ Session creation response: $responseBody")
            }
            
            // Parse response to extract session ID
            val jsonResponse = json.parseToJsonElement(responseBody).jsonObject
            val sessionId = jsonResponse["data"]?.jsonObject?.get("id")?.jsonPrimitive?.content
            
            if (config.debug) {
                println("[ApiClient] Extracted session ID: ${sessionId ?: "null"}")
            }
            
            if (sessionId != null) {
                writeCookie("session_id", sessionId, expires = 365, domain = config.cookieDomain)
                
                if (config.debug) {
                    println("[ApiClient] ✅ Session ID saved to storage: $sessionId")
                }
                
                // Request location update (async, non-blocking)
                // Web Reference: api.ts line 280
                CoroutineScope(Dispatchers.IO).launch {
                    locationManager.requestLocationUpdate(sessionId)
                }
            } else {
                if (config.debug) {
                    println("[ApiClient] ❌ Failed to extract session ID from response")
                }
            }
            
            sessionId
        } catch (e: Exception) {
            if (config.debug) {
                println("[ApiClient] ❌ Exception creating tracking session: ${e.message}")
                e.printStackTrace()
            }
            null
        }
    }
    
    /**
     * Update session location
     * Web Reference: api.ts lines 348-362
     */
    suspend fun updateSessionLocation(sessionId: String, location: LocationData): Boolean = withContext(Dispatchers.IO) {
        try {
            val jsonPayload = json.encodeToString(LocationData.serializer(), location)
            val requestBody = jsonPayload.toRequestBody(JSON_MEDIA_TYPE)
            
            val requestBuilder = Request.Builder()
                .url("${config.getEffectiveApiUrl()}/v2/tracking-session/$sessionId/location")
                .put(requestBody)
            
            getHeaders().forEach { (key, value) ->
                requestBuilder.addHeader(key, value)
            }
            
            val request = requestBuilder.build()
            val response = client.newCall(request).execute()
            
            if (!response.isSuccessful) {
                if (config.debug) {
                    println("[ApiClient] Failed to update session location: ${response.code}")
                }
                return@withContext false
            }
            
            if (config.debug) {
                println("[ApiClient] Session location updated successfully")
            }
            
            true
        } catch (e: Exception) {
            if (config.debug) {
                println("[ApiClient] Error updating session location: ${e.message}")
            }
            false
        }
    }
    
    /**
     * Update session email
     * Web Reference: api.ts lines 324-346
     */
    suspend fun updateSessionEmail(sessionId: String, newEmail: String, brandId: Int): String? = withContext(Dispatchers.IO) {
        try {
            val payload = buildJsonObject {
                put("email", JsonPrimitive(newEmail))
                put("brand_id", JsonPrimitive(brandId))
            }
            
            val jsonPayload = payload.toString()
            
            val requestBody = jsonPayload.toRequestBody(JSON_MEDIA_TYPE)
            val requestBuilder = Request.Builder()
                .url("${config.getEffectiveApiUrl()}/v2/tracking-session/$sessionId/email_v2")
                .put(requestBody)
            
            getHeaders().forEach { (key, value) ->
                requestBuilder.addHeader(key, value)
            }
            
            val request = requestBuilder.build()
            val response = client.newCall(request).execute()
            
            if (!response.isSuccessful) {
                if (config.debug) {
                    println("[ApiClient] Failed to update session email: ${response.code}")
                }
                return@withContext null
            }
            
            writeCookie("session_email", newEmail, expires = 365, domain = config.cookieDomain)
            
            val responseBody = response.body?.string()
            if (responseBody != null) {
                val jsonResponse = json.parseToJsonElement(responseBody).jsonObject
                val newSessionId = jsonResponse["data"]?.jsonObject?.get("id")?.jsonPrimitive?.content
                
                if (newSessionId != null && newSessionId != sessionId) {
                    writeCookie("session_id", newSessionId, expires = 365, domain = config.cookieDomain)
                    return@withContext newSessionId
                }
            }
            
            sessionId
        } catch (e: Exception) {
            if (config.debug) {
                println("[ApiClient] Error updating session email: ${e.message}")
            }
            null
        }
    }
    
    // MARK: - Profile and Metadata Methods
    // Web Reference: api.ts lines 367-450
    
    /**
     * Update customer profile
     * Web Reference: api.ts lines 367-410
     */
    suspend fun updateProfile(data: UpdateProfileData, brandId: Int): Boolean = withContext(Dispatchers.IO) {
        try {
            val identifyId = getCookie("identify_id")
            val userId = data.user_id
            val sessionId = getCookie("session_id")
            
            // If user_id provided and differs from stored identify_id, call identifyById first
            if (userId != null && sessionId != null && identifyId != userId) {
                identifyById(sessionId, userId)
            }
            
            // Build payload matching web structure
            // Web Reference: api.ts lines 390-407
            val payload = buildJsonObject {
                data.email?.let { put("email", JsonPrimitive(it)) }
                data.name?.let { put("name", JsonPrimitive(it)) }
                data.phone?.let { put("phone", JsonPrimitive(it)) }
                data.gender?.let { put("gender", JsonPrimitive(it)) }
                data.business_domain?.let { put("business_domain", JsonPrimitive(it)) }
                data.birthday?.let { put("birthday", JsonPrimitive(it)) }
                data.metadata?.let { metadata ->
                    put("metadata", buildJsonObject {
                        metadata.forEach { (key, value) ->
                            when (value) {
                                is String -> put(key, JsonPrimitive(value))
                                is Number -> put(key, JsonPrimitive(value))
                                is Boolean -> put(key, JsonPrimitive(value))
                                is Map<*, *> -> put(key, buildJsonObject {
                                    value.forEach { (k, v) ->
                                        when (v) {
                                            is String -> put(k.toString(), JsonPrimitive(v))
                                            is Number -> put(k.toString(), JsonPrimitive(v))
                                            is Boolean -> put(k.toString(), JsonPrimitive(v))
                                            else -> put(k.toString(), JsonPrimitive(v.toString()))
                                        }
                                    }
                                })
                                is List<*> -> put(key, buildJsonArray {
                                    value.forEach { item ->
                                        when (item) {
                                            is String -> add(JsonPrimitive(item))
                                            is Number -> add(JsonPrimitive(item))
                                            is Boolean -> add(JsonPrimitive(item))
                                            else -> add(JsonPrimitive(item.toString()))
                                        }
                                    }
                                })
                                else -> put(key, JsonPrimitive(value.toString()))
                            }
                        }
                    })
                }
                data.source?.let { put("source", JsonPrimitive(it)) }
                
                // Add extra fields (web: ...extra)
                data.extra?.forEach { (key, value) ->
                    when (value) {
                        is String -> put(key, JsonPrimitive(value))
                        is Number -> put(key, JsonPrimitive(value))
                        is Boolean -> put(key, JsonPrimitive(value))
                        is Map<*, *> -> put(key, buildJsonObject {
                            value.forEach { (k, v) ->
                                when (v) {
                                    is String -> put(k.toString(), JsonPrimitive(v))
                                    is Number -> put(k.toString(), JsonPrimitive(v))
                                    is Boolean -> put(k.toString(), JsonPrimitive(v))
                                    else -> put(k.toString(), JsonPrimitive(v.toString()))
                                }
                            }
                        })
                        else -> put(key, JsonPrimitive(value.toString()))
                    }
                }
                
                put("brand_id", JsonPrimitive(brandId))
                userId?.let { put("user_id", JsonPrimitive(it)) }
                sessionId?.let { put("session_id", JsonPrimitive(it)) }
            }
            
            val jsonPayload = payload.toString()
            
            val requestBody = jsonPayload.toRequestBody(JSON_MEDIA_TYPE)
            val requestBuilder = Request.Builder()
                .url("${config.getEffectiveApiUrl()}/v1/customer-profiles/set")
                .put(requestBody)
            
            getHeaders().forEach { (key, value) ->
                requestBuilder.addHeader(key, value)
            }
            
            val request = requestBuilder.build()
            val response = client.newCall(request).execute()
            
            if (!response.isSuccessful) {
                if (config.debug) {
                    println("[ApiClient] Failed to update profile: ${response.code}")
                }
                return@withContext false
            }
            
            if (config.debug) {
                println("[ApiClient] Customer profile updated successfully")
            }
            
            true
        } catch (e: Exception) {
            if (config.debug) {
                println("[ApiClient] Error updating customer profile: ${e.message}")
            }
            false
        }
    }
    
    /**
     * Set metadata for session context
     * Web Reference: api.ts lines 412-450
     */
    suspend fun setMetadata(metadata: Map<String, Any>, brandId: Int): Boolean = withContext(Dispatchers.IO) {
        try {
            val sessionId = getCookie("session_id")
            val userId = getCookie("identify_id")
            
            if (sessionId == null && userId == null) {
                if (config.debug) {
                    println("[ApiClient] No session_id or user_id available for metadata update")
                }
                return@withContext false
            }
            
            val payload = buildJsonObject {
                put("metadata", buildJsonObject {
                    metadata.forEach { (key, value) ->
                        when (value) {
                            is String -> put(key, JsonPrimitive(value))
                            is Number -> put(key, JsonPrimitive(value))
                            is Boolean -> put(key, JsonPrimitive(value))
                            is Map<*, *> -> put(key, buildJsonObject {
                                value.forEach { (k, v) ->
                                    when (v) {
                                        is String -> put(k.toString(), JsonPrimitive(v))
                                        is Number -> put(k.toString(), JsonPrimitive(v))
                                        is Boolean -> put(k.toString(), JsonPrimitive(v))
                                        else -> put(k.toString(), JsonPrimitive(v.toString()))
                                    }
                                }
                            })
                            is List<*> -> put(key, buildJsonArray {
                                value.forEach { item ->
                                    when (item) {
                                        is String -> add(JsonPrimitive(item))
                                        is Number -> add(JsonPrimitive(item))
                                        is Boolean -> add(JsonPrimitive(item))
                                        else -> add(JsonPrimitive(item.toString()))
                                    }
                                }
                            })
                            else -> put(key, JsonPrimitive(value.toString()))
                        }
                    }
                })
                put("brand_id", JsonPrimitive(brandId))
                userId?.let { put("user_id", JsonPrimitive(it)) }
                sessionId?.let { put("session_id", JsonPrimitive(it)) }
            }
            
            val jsonPayload = payload.toString()
            
            val requestBody = jsonPayload.toRequestBody(JSON_MEDIA_TYPE)
            val requestBuilder = Request.Builder()
                .url("${config.getEffectiveApiUrl()}/v1/customer-profiles/set")
                .put(requestBody)
            
            getHeaders().forEach { (key, value) ->
                requestBuilder.addHeader(key, value)
            }
            
            val request = requestBuilder.build()
            val response = client.newCall(request).execute()
            
            if (!response.isSuccessful) {
                if (config.debug) {
                    println("[ApiClient] Failed to update metadata: ${response.code}")
                }
                return@withContext false
            }
            
            if (config.debug) {
                println("[ApiClient] Metadata updated successfully")
            }
            
            true
        } catch (e: Exception) {
            if (config.debug) {
                println("[ApiClient] Error updating metadata: ${e.message}")
            }
            false
        }
    }
    
    /**
     * Identify user by ID
     * Web Reference: api.ts lines 530-568
     */
    suspend fun identifyById(sessionId: String, userId: String): String? = withContext(Dispatchers.IO) {
        try {
            val emptyBody = ByteArray(0).toRequestBody(null)
            val requestBuilder = Request.Builder()
                .url("${config.getEffectiveApiUrl()}/v2/tracking-session/$sessionId/identify/$userId")
                .put(emptyBody)
            
            getHeaders().forEach { (key, value) ->
                requestBuilder.addHeader(key, value)
            }
            
            val request = requestBuilder.build()
            val response = client.newCall(request).execute()
            
            if (!response.isSuccessful) {
                if (config.debug) {
                    println("[ApiClient] Failed to identify user: ${response.code}")
                }
                return@withContext null
            }
            
            writeCookie("identify_id", userId, expires = 365, domain = config.cookieDomain)
            
            val responseBody = response.body?.string()
            if (responseBody != null) {
                val jsonResponse = json.parseToJsonElement(responseBody).jsonObject
                val newSessionId = jsonResponse["data"]?.jsonObject?.get("id")?.jsonPrimitive?.content
                
                if (newSessionId != null && newSessionId != sessionId) {
                    writeCookie("session_id", newSessionId, expires = 365, domain = config.cookieDomain)
                    return@withContext newSessionId
                }
            }
            
            sessionId
        } catch (e: Exception) {
            if (config.debug) {
                println("[ApiClient] Error identifying user: ${e.message}")
            }
            null
        }
    }
    
    // MARK: - Event Tracking
    // Web Reference: api.ts lines 452-486
    
    /**
     * Track an event
     * Web Reference: api.ts lines 452-486
     */
    suspend fun trackEvent(
        brandId: Int,
        sessionId: String,
        eventName: String,
        eventData: Map<String, Any>? = null
    ): Boolean = withContext(Dispatchers.IO) {
        try {
            // Build payload matching web structure
            val payload = buildJsonObject {
                put("brand_id", JsonPrimitive(brandId))
                put("session_id", JsonPrimitive(sessionId))
                put("event_name", JsonPrimitive(eventName.uppercase().replace(" ", "_")))
                eventData?.let { data ->
                    put("data", buildJsonObject {
                        data.forEach { (key, value) ->
                            when (value) {
                                is String -> put(key, JsonPrimitive(value))
                                is Number -> put(key, JsonPrimitive(value))
                                is Boolean -> put(key, JsonPrimitive(value))
                                is List<*> -> put(key, buildJsonArray {
                                    value.forEach { item ->
                                        when (item) {
                                            is String -> add(JsonPrimitive(item))
                                            is Number -> add(JsonPrimitive(item))
                                            is Boolean -> add(JsonPrimitive(item))
                                            is Map<*, *> -> add(buildJsonObject {
                                                item.forEach { (k, v) ->
                                                    when (v) {
                                                        is String -> put(k.toString(), JsonPrimitive(v))
                                                        is Number -> put(k.toString(), JsonPrimitive(v))
                                                        is Boolean -> put(k.toString(), JsonPrimitive(v))
                                                        else -> put(k.toString(), JsonPrimitive(v.toString()))
                                                    }
                                                }
                                            })
                                            else -> add(JsonPrimitive(item.toString()))
                                        }
                                    }
                                })
                                else -> put(key, JsonPrimitive(value.toString()))
                            }
                        }
                    })
                }
                
                // Add flow_context for non-VIEW_PAGE events (web behavior)
                // Detect current active screen name and use that as url
                if (eventName != "VIEW_PAGE") {
                    val currentActivity = getCurrentActivityName()
                    if (currentActivity != null) {
                        put("flow_context", buildJsonObject {
                            put("url", JsonPrimitive(currentActivity))
                            put("title", JsonPrimitive(currentActivity))
                        })
                    }
                }
            }
            val jsonPayload = payload.toString()
            
            val requestBody = jsonPayload.toRequestBody(JSON_MEDIA_TYPE)
            val requestBuilder = Request.Builder()
                .url("${config.getEffectiveApiUrl()}/v2/tracking-session-data")
                .post(requestBody)
            
            getHeaders().forEach { (key, value) ->
                requestBuilder.addHeader(key, value)
            }
            
            val request = requestBuilder.build()
            
            if (config.debug) {
                println("[ApiClient] Tracking event - POST ${request.url}")
                println("[ApiClient] Event: $eventName")
                println("[ApiClient] Payload: $jsonPayload")
            }
            
            val response = client.newCall(request).execute()
            
            if (!response.isSuccessful) {
                if (config.debug) {
                    println("[ApiClient] Failed to track event: ${response.code}")
                    println("[ApiClient] Response body: ${response.body?.string()}")
                }
                return@withContext false
            }
            
            if (config.debug) {
                println("[ApiClient] Event tracked successfully: $eventName")
            }
            
            true
        } catch (e: Exception) {
            if (config.debug) {
                println("[ApiClient] Error tracking event: ${e.message}")
            }
            false
        }
    }
    
    // MARK: - Storage Helper Methods
    // Web Reference: api.ts lines 488-575
    
    /**
     * Get session ID from storage
     * Web Reference: api.ts lines 488-490
     */
    fun getSessionId(): String? {
        return getCookie("session_id")
    }
    
    /**
     * Set session ID in storage
     * Web Reference: api.ts lines 492-496
     */
    fun setSessionId(sessionId: String) {
        writeCookie("session_id", sessionId, expires = 365, domain = config.cookieDomain)
    }
    
    /**
     * Get session email from storage
     * Web Reference: api.ts line 498-500
     */
    fun getSessionEmail(): String? {
        return getCookie("session_email")
    }
    
    /**
     * Get brand ID from storage
     * Web Reference: api.ts lines 502-511
     */
    fun getBrandId(): Int? {
        val brandId = getCookie("brand_id")
        return brandId?.toIntOrNull()
    }
    
    /**
     * Set brand ID in storage
     * Web Reference: api.ts lines 513-517
     */
    fun setBrandId(brandId: Int) {
        writeCookie("brand_id", brandId.toString(), expires = 365, domain = config.cookieDomain)
    }
    
    /**
     * Link visitor to session
     * Web Reference: api.ts lines 570-590
     */
    suspend fun linkVisitorToSession(payload: LinkVisitorToSession): Boolean = withContext(Dispatchers.IO) {
        try {
            val jsonPayload = json.encodeToString(LinkVisitorToSession.serializer(), payload)
            val requestBody = jsonPayload.toRequestBody(JSON_MEDIA_TYPE)
            
            val requestBuilder = Request.Builder()
                .url("${config.getEffectiveApiUrl()}/v2/tracking-session/link-session")
                .post(requestBody)
            
            getHeaders().forEach { (key, value) ->
                requestBuilder.addHeader(key, value)
            }
            
            val request = requestBuilder.build()
            val response = client.newCall(request).execute()
            
            if (!response.isSuccessful) {
                return@withContext false
            }
            
            val responseBody = response.body?.string()
            if (responseBody != null) {
                val jsonResponse = json.parseToJsonElement(responseBody).jsonObject
                val sessionId = jsonResponse["data"]?.jsonObject?.get("id")?.jsonPrimitive?.content
                
                if (sessionId != null) {
                    writeCookie("session_id", sessionId, expires = 365, domain = config.cookieDomain)
                }
            }
            
            true
        } catch (e: Exception) {
            if (config.debug) {
                println("[ApiClient] Error linking visitor to session: ${e.message}")
            }
            false
        }
    }
    
    /**
     * Clear a cookie by name
     * Web Reference: api.ts lines 592-594
     */
    fun clearCookieByName(name: String, domain: String? = null) {
        clearCookie(name, domain ?: config.cookieDomain)
    }
    
    /**
     * Get the current activity name for screen tracking
     * Returns the simple class name of the current activity
     */
    private fun getCurrentActivityName(): String? {
        return try {
            val activityManager = context.getSystemService(android.content.Context.ACTIVITY_SERVICE) as? android.app.ActivityManager
            val tasks = activityManager?.getRunningTasks(1)
            if (!tasks.isNullOrEmpty()) {
                val topActivity = tasks[0].topActivity
                topActivity?.shortClassName?.substringAfterLast('.')
            } else {
                null
            }
        } catch (e: Exception) {
            if (config.debug) {
                println("[ApiClient] Error getting current activity name: ${e.message}")
            }
            null
        }
    }
}

/**
 * Configuration for the tracker
 * Web Reference: types/index.ts TrackerConfig interface
 */
data class TrackerConfig(
    val debug: Boolean = false,
    val apiUrl: String? = null,
    val xApiKey: String? = null,
    val crossSiteCookie: Boolean = false,
    val cookieDomain: String? = null,
    val cookieExpiration: Int = 365
) {
    companion object {
        /** Default API URL for the tracking backend */
        const val DEFAULT_API_URL = "https://tracking.api.founder-os.ai/api"
        
        fun default() = TrackerConfig()
    }
    
    /** Get the effective API URL (returns default if apiUrl is null or empty) */
    fun getEffectiveApiUrl(): String {
        return if (!apiUrl.isNullOrEmpty()) apiUrl else DEFAULT_API_URL
    }
}

/**
 * Device information for session creation
 * Web Reference: types/index.ts DeviceInfo interface
 */
@Serializable
data class DeviceInfo(
    val device_id: String,
    val os_name: String,
    val device_type: String
)

/**
 * Location data for geolocation tracking
 * Web Reference: types/index.ts LocationData interface
 */
@Serializable
data class LocationData(
    val latitude: Double,
    val longitude: Double,
    val accuracy: Double
)

/**
 * Profile update data
 * Web Reference: types/index.ts UpdateProfileData interface
 */
data class UpdateProfileData(
    val name: String? = null,
    val phone: String? = null,
    val gender: String? = null,
    val business_domain: String? = null,
    val metadata: Map<String, Any>? = null,
    val email: String? = null,
    val source: String? = null,
    val birthday: String? = null,
    val user_id: String? = null,
    val extra: Map<String, Any>? = null  // Support for additional custom fields (web: ...extra)
)

/**
 * Link visitor to session payload
 * Web Reference: types/index.ts LinkVisitorToSession interface
 */
@Serializable
data class LinkVisitorToSession(
    val session_id: String,
    val user_id: String
)
