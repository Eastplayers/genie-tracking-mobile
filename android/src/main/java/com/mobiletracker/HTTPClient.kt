package com.mobiletracker

import com.mobiletracker.models.Event
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import okhttp3.Call
import okhttp3.Callback
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.Response
import java.io.IOException
import java.util.concurrent.TimeUnit

/**
 * HTTP client for sending events to the backend
 * 
 * Uses OkHttp for reliable HTTP communication with the analytics backend.
 * Events are serialized to JSON and sent via POST request with API key authentication.
 */
class HTTPClient(private val client: OkHttpClient = createDefaultClient()) {
    
    companion object {
        private val JSON_MEDIA_TYPE = "application/json; charset=utf-8".toMediaType()
        
        /**
         * Creates a default OkHttp client with appropriate timeout settings
         */
        private fun createDefaultClient(): OkHttpClient {
            return OkHttpClient.Builder()
                .connectTimeout(30, TimeUnit.SECONDS)
                .writeTimeout(30, TimeUnit.SECONDS)
                .readTimeout(30, TimeUnit.SECONDS)
                .build()
        }
    }
    
    private val json = Json {
        encodeDefaults = true
        ignoreUnknownKeys = true
    }
    
    /**
     * Send events to the backend endpoint
     * 
     * @param events List of events to send
     * @param endpoint Backend endpoint URL
     * @param apiKey API key for authentication
     * @param callback Callback with result (success or error)
     */
    fun send(
        events: List<Event>,
        endpoint: String,
        apiKey: String,
        callback: (Result<Unit>) -> Unit
    ) {
        // Validate endpoint
        if (endpoint.isBlank()) {
            callback(Result.failure(HTTPClientError.InvalidEndpoint))
            return
        }
        
        // Serialize events to JSON
        val jsonPayload = try {
            json.encodeToString(events)
        } catch (e: Exception) {
            callback(Result.failure(HTTPClientError.SerializationFailed(e)))
            return
        }
        
        // Create request body
        val requestBody = jsonPayload.toRequestBody(JSON_MEDIA_TYPE)
        
        // Build HTTP request
        val request = Request.Builder()
            .url(endpoint)
            .post(requestBody)
            .addHeader("Content-Type", "application/json")
            .addHeader("X-API-Key", apiKey)
            .build()
        
        // Send request asynchronously
        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                callback(Result.failure(HTTPClientError.NetworkError(e)))
            }
            
            override fun onResponse(call: Call, response: Response) {
                response.use {
                    if (response.isSuccessful) {
                        callback(Result.success(Unit))
                    } else {
                        callback(Result.failure(HTTPClientError.HttpError(response.code)))
                    }
                }
            }
        })
    }
}

/**
 * Errors that can occur during HTTP operations
 */
sealed class HTTPClientError : Exception() {
    object InvalidEndpoint : HTTPClientError() {
        override val message: String = "Invalid endpoint URL"
    }
    
    data class SerializationFailed(override val cause: Throwable) : HTTPClientError() {
        override val message: String = "Failed to serialize events to JSON: ${cause.message}"
    }
    
    data class NetworkError(override val cause: Throwable) : HTTPClientError() {
        override val message: String = "Network error: ${cause.message}"
    }
    
    data class HttpError(val statusCode: Int) : HTTPClientError() {
        override val message: String = "HTTP error with status code: $statusCode"
    }
}
