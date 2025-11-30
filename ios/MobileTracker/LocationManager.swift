import Foundation
import CoreLocation

/// Location Manager for geolocation tracking
/// Web Reference: api.ts lines 300-362
@available(iOS 13.0, macOS 10.15, *)
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager
    private let apiClient: ApiClient
    private let config: TrackerConfig
    private var sessionId: String?
    private var locationContinuation: CheckedContinuation<LocationData?, Never>?
    
    /// Initialize LocationManager with API client and configuration
    init(apiClient: ApiClient, config: TrackerConfig) {
        self.apiClient = apiClient
        self.config = config
        self.locationManager = CLLocationManager()
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// Request location update for a session
    /// Web Reference: api.ts lines 300-322
    func requestLocationUpdate(_ sessionId: String) async {
        self.sessionId = sessionId
        
        #if os(iOS)
        // Check if location services are available
        guard CLLocationManager.locationServicesEnabled() else {
            if config.debug {
                print("[LocationManager] Location services not enabled")
            }
            return
        }
        
        // Check authorization status
        let authStatus: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            authStatus = locationManager.authorizationStatus
        } else {
            authStatus = CLLocationManager.authorizationStatus()
        }
        
        switch authStatus {
        case .notDetermined:
            // Request permission when in use
            locationManager.requestWhenInUseAuthorization()
            return
        case .restricted, .denied:
            if config.debug {
                print("[LocationManager] Location access denied or restricted")
            }
            return
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission granted, request location
            await requestCurrentLocation()
        @unknown default:
            if config.debug {
                print("[LocationManager] Unknown authorization status")
            }
            return
        }
        #else
        if config.debug {
            print("[LocationManager] Location services only available on iOS")
        }
        #endif
    }
    
    /// Request current location
    private func requestCurrentLocation() async {
        let locationData = await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            
            // Request a single location update
            if #available(iOS 14.0, *) {
                locationManager.requestLocation()
            } else {
                // For iOS 13, start updating location and stop after first update
                locationManager.startUpdatingLocation()
            }
        }
        
        // If we got location data, update the session
        if let locationData = locationData, let sessionId = self.sessionId {
            let success = await apiClient.updateSessionLocation(sessionId, location: locationData)
            
            if config.debug {
                if success {
                    print("[LocationManager] Session location updated successfully")
                } else {
                    print("[LocationManager] Failed to update session location")
                }
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    /// Handle location updates
    /// Web Reference: api.ts lines 312-318 (success callback)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Stop updating location for iOS 13 compatibility
        if #available(iOS 14.0, *) {
            // iOS 14+ uses requestLocation() which stops automatically
        } else {
            manager.stopUpdatingLocation()
        }
        
        guard let location = locations.first else {
            locationContinuation?.resume(returning: nil)
            locationContinuation = nil
            return
        }
        
        // Extract latitude, longitude, accuracy
        // Web Reference: api.ts lines 313-316
        let locationData = LocationData(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            accuracy: location.horizontalAccuracy
        )
        
        locationContinuation?.resume(returning: locationData)
        locationContinuation = nil
    }
    
    /// Handle location errors
    /// Web Reference: api.ts lines 320-323 (error callback)
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if config.debug {
            print("[LocationManager] Error getting geolocation: \(error.localizedDescription)")
        }
        
        locationContinuation?.resume(returning: nil)
        locationContinuation = nil
    }
    
    /// Handle authorization changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        #if os(iOS)
        let authStatus: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            authStatus = manager.authorizationStatus
        } else {
            authStatus = CLLocationManager.authorizationStatus()
        }
        
        // If permission was just granted, request location
        if (authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways),
           let sessionId = self.sessionId {
            Task {
                await requestLocationUpdate(sessionId)
            }
        }
        #endif
    }
}
