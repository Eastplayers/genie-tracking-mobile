package ai.founderos.mobiletracker.example

/**
 * Configuration for the MobileTracker SDK with environment selection
 * 
 * @property apiKey The API key for authenticating with the backend (X-API-KEY header)
 * @property brandId Unique identifier for the tracking brand/organization
 * @property environment The environment to use (QC or Production)
 * @property userId Optional user ID for tracking
 */
data class TrackerConfiguration(
    val apiKey: String,
    val brandId: String,
    val environment: Environment,
    val userId: String = ""
) {
    /**
     * Computed property that maps environment to the correct API URL
     */
    val apiUrl: String
        get() = when (environment) {
            Environment.QC -> "https://tracking.api.qc.founder-os.ai/api"
            Environment.PRODUCTION -> "https://tracking.api.founder-os.ai/api"
        }

    /**
     * Validates the configuration
     * 
     * @return ValidationResult.Valid if configuration is valid, ValidationResult.Error otherwise
     */
    fun validate(): ValidationResult {
        return when {
            apiKey.isBlank() -> ValidationResult.Error("API Key is required")
            brandId.isBlank() -> ValidationResult.Error("Brand ID is required")
            else -> ValidationResult.Valid
        }
    }
}
