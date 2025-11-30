package ai.founderos.mobiletracker.models

import kotlinx.serialization.Serializable

/**
 * Represents a tracking event with all associated data
 * 
 * @property type Event type: "track", "identify", or "screen"
 * @property name Event name (for track and screen events)
 * @property userId User identifier (if user has been identified)
 * @property traits User traits (for identify events or after identification)
 * @property properties Event properties (for track and screen events)
 * @property context Automatic context data
 * @property timestamp ISO 8601 formatted timestamp
 */
@Serializable
data class Event(
    val type: String,
    val name: String? = null,
    val userId: String? = null,
    val traits: Map<String, JsonElement>? = null,
    val properties: Map<String, JsonElement>? = null,
    val context: EventContext,
    val timestamp: String
) {
    companion object {
        /**
         * Helper function to convert Map<String, Any> to Map<String, JsonElement>
         */
        fun convertToJsonElementMap(map: Map<String, Any>?): Map<String, JsonElement>? {
            return map?.mapValues { JsonElement(it.value) }
        }
    }
}
