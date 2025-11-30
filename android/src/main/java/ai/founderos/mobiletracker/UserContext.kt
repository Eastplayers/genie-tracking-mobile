package ai.founderos.mobiletracker

/**
 * User context management for storing user identification data
 * 
 * @property userId The unique identifier for the user
 * @property traits User attributes and characteristics
 */
data class UserContext(
    var userId: String? = null,
    var traits: Map<String, Any>? = null
)
