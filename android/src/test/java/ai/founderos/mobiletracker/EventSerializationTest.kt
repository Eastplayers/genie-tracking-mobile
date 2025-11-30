package ai.founderos.mobiletracker

import ai.founderos.mobiletracker.models.Event
import ai.founderos.mobiletracker.models.EventContext
import ai.founderos.mobiletracker.models.JsonElement
import kotlinx.serialization.json.Json
import kotlinx.serialization.encodeToString
import kotlinx.serialization.decodeFromString
import org.junit.Test
import org.junit.Assert.*

/**
 * Unit tests for Event and EventContext JSON serialization
 */
class EventSerializationTest {
    
    private val json = Json { 
        prettyPrint = false
        ignoreUnknownKeys = true
    }
    
    @Test
    fun testEventContextSerialization() {
        val context = EventContext(
            platform = "android",
            osVersion = "13",
            appVersion = "1.0.0"
        )
        
        val jsonString = json.encodeToString(context)
        val decoded = json.decodeFromString<EventContext>(jsonString)
        
        assertEquals(context.platform, decoded.platform)
        assertEquals(context.osVersion, decoded.osVersion)
        assertEquals(context.appVersion, decoded.appVersion)
    }
    
    @Test
    fun testEventSerializationWithSimpleProperties() {
        val context = EventContext(
            platform = "android",
            osVersion = "13",
            appVersion = "1.0.0"
        )
        
        val event = Event(
            type = "track",
            name = "Button Clicked",
            userId = "user123",
            traits = mapOf(
                "email" to JsonElement("user@example.com"),
                "plan" to JsonElement("pro")
            ),
            properties = mapOf(
                "button_name" to JsonElement("signup"),
                "screen" to JsonElement("home")
            ),
            context = context,
            timestamp = "2025-11-27T10:30:00.000Z"
        )
        
        val jsonString = json.encodeToString(event)
        val decoded = json.decodeFromString<Event>(jsonString)
        
        assertEquals(event.type, decoded.type)
        assertEquals(event.name, decoded.name)
        assertEquals(event.userId, decoded.userId)
        assertEquals(event.timestamp, decoded.timestamp)
    }
    
    @Test
    fun testEventSerializationWithNestedProperties() {
        val context = EventContext(
            platform = "android",
            osVersion = "13",
            appVersion = null
        )
        
        val nestedMap = mapOf(
            "level1" to mapOf(
                "level2" to "value"
            )
        )
        
        val nestedList = listOf(1, 2, 3)
        
        val event = Event(
            type = "track",
            name = "Complex Event",
            userId = null,
            traits = null,
            properties = mapOf(
                "nested_object" to JsonElement(nestedMap),
                "nested_array" to JsonElement(nestedList),
                "string" to JsonElement("test"),
                "number" to JsonElement(42),
                "boolean" to JsonElement(true)
            ),
            context = context,
            timestamp = "2025-11-27T10:30:00.000Z"
        )
        
        val jsonString = json.encodeToString(event)
        val decoded = json.decodeFromString<Event>(jsonString)
        
        assertEquals(event.type, decoded.type)
        assertEquals(event.name, decoded.name)
        assertNotNull(decoded.properties)
        assertEquals(5, decoded.properties?.size)
    }
    
    @Test
    fun testConvertToJsonElementMap() {
        val inputMap = mapOf(
            "string" to "value",
            "number" to 42,
            "boolean" to true,
            "nested" to mapOf("key" to "value")
        )
        
        val result = Event.convertToJsonElementMap(inputMap)
        
        assertNotNull(result)
        assertEquals(4, result?.size)
        assertEquals("value", result?.get("string")?.value)
        assertEquals(42, result?.get("number")?.value)
        assertEquals(true, result?.get("boolean")?.value)
    }
    
    @Test
    fun testConvertToJsonElementMapWithNull() {
        val result = Event.convertToJsonElementMap(null)
        assertNull(result)
    }
}
