package ai.founderos.mobiletracker

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.google.android.gms.tasks.CancellationTokenSource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import kotlin.coroutines.resume

/**
 * Location Manager for geolocation tracking
 * Web Reference: api.ts lines 300-362
 */
class LocationManager(
    private val context: Context,
    private val apiClient: ApiClient,
    private val config: TrackerConfig
) {
    private val fusedLocationClient: FusedLocationProviderClient =
        LocationServices.getFusedLocationProviderClient(context)
    
    /**
     * Request location update for a session
     * Web Reference: api.ts lines 300-322
     */
    suspend fun requestLocationUpdate(sessionId: String) = withContext(Dispatchers.Main) {
        // Check if location permissions are granted
        val fineLocationGranted = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
        
        val coarseLocationGranted = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_COARSE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
        
        if (!fineLocationGranted && !coarseLocationGranted) {
            if (config.debug) {
                println("[LocationManager] Location permissions not granted")
            }
            return@withContext
        }
        
        try {
            // Request current location
            val locationData = getCurrentLocation()
            
            if (locationData != null) {
                // Update session location on backend
                // Web Reference: api.ts line 314
                val success = apiClient.updateSessionLocation(sessionId, locationData)
                
                if (config.debug) {
                    if (success) {
                        println("[LocationManager] Session location updated successfully")
                    } else {
                        println("[LocationManager] Failed to update session location")
                    }
                }
            }
        } catch (e: Exception) {
            // Handle errors gracefully
            // Web Reference: api.ts lines 315-318
            if (config.debug) {
                println("[LocationManager] Error getting geolocation: ${e.message}")
            }
        }
    }
    
    /**
     * Get current location using FusedLocationProviderClient
     */
    @SuppressLint("MissingPermission")
    private suspend fun getCurrentLocation(): LocationData? = suspendCancellableCoroutine { continuation ->
        try {
            val cancellationTokenSource = CancellationTokenSource()
            
            // Set up cancellation
            continuation.invokeOnCancellation {
                cancellationTokenSource.cancel()
            }
            
            // Request current location with high accuracy
            fusedLocationClient.getCurrentLocation(
                Priority.PRIORITY_HIGH_ACCURACY,
                cancellationTokenSource.token
            ).addOnSuccessListener { location ->
                if (location != null) {
                    // Extract latitude, longitude, accuracy
                    // Web Reference: api.ts lines 313-316
                    val locationData = LocationData(
                        latitude = location.latitude,
                        longitude = location.longitude,
                        accuracy = location.accuracy.toDouble()
                    )
                    continuation.resume(locationData)
                } else {
                    if (config.debug) {
                        println("[LocationManager] Location is null")
                    }
                    continuation.resume(null)
                }
            }.addOnFailureListener { exception ->
                // Handle errors gracefully
                // Web Reference: api.ts lines 320-323
                if (config.debug) {
                    println("[LocationManager] Error getting geolocation: ${exception.message}")
                }
                continuation.resume(null)
            }
        } catch (e: SecurityException) {
            if (config.debug) {
                println("[LocationManager] Security exception: ${e.message}")
            }
            continuation.resume(null)
        }
    }
}
