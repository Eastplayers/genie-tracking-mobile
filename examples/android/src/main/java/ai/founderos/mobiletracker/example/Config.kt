package ai.founderos.mobiletracker.example

/**
 * Configuration helper to access environment variables from BuildConfig
 */
object Config {
    /** Default API URL */
    const val DEFAULT_API_URL = "https://tracking.api.founder-os.ai/api"
    
    /**
     * Brand ID for tracking (REQUIRED)
     */
    val brandId: String
        get() = BuildConfig.BRAND_ID
    
    /**
     * API URL for tracking backend (optional, defaults to production URL)
     */
    val apiUrl: String?
        get() = BuildConfig.API_URL.takeIf { it.isNotEmpty() }
    
    /**
     * API key for authenticated requests (REQUIRED)
     */
    val xApiKey: String?
        get() = BuildConfig.X_API_KEY.takeIf { it.isNotEmpty() }
    
    /**
     * Debug mode flag
     */
    val debug: Boolean
        get() = BuildConfig.DEBUG.toBoolean()
    
    /**
     * Validate that required configuration is present
     */
    fun validate() {
        require(brandId.isNotEmpty()) { "BRAND_ID is required. Check your local.env file." }
        require(xApiKey != null) { "X_API_KEY is required. Check your local.env file." }
        
        // API URL is optional, will use default if not provided
        apiUrl?.let { url ->
            require(url.startsWith("http")) { "API_URL must be a valid URL" }
        }
    }
}
