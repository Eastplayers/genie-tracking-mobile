package com.mobiletracker.models

import kotlinx.serialization.KSerializer
import kotlinx.serialization.Serializable
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.descriptors.buildClassSerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.*

/**
 * Type-erased wrapper for encoding/decoding arbitrary JSON values
 * Similar to iOS AnyCodable, this allows handling nested objects and arrays
 */
@Serializable(with = JsonElementSerializer::class)
data class JsonElement(val value: Any?)

/**
 * Custom serializer for JsonElement that handles arbitrary JSON structures
 */
object JsonElementSerializer : KSerializer<JsonElement> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("JsonElement")
    
    override fun serialize(encoder: Encoder, value: JsonElement) {
        val jsonEncoder = encoder as? JsonEncoder 
            ?: throw IllegalStateException("JsonElement can only be serialized with Json format")
        
        val element = toJsonElement(value.value)
        jsonEncoder.encodeJsonElement(element)
    }
    
    override fun deserialize(decoder: Decoder): JsonElement {
        val jsonDecoder = decoder as? JsonDecoder
            ?: throw IllegalStateException("JsonElement can only be deserialized with Json format")
        
        val element = jsonDecoder.decodeJsonElement()
        return JsonElement(fromJsonElement(element))
    }
    
    private fun toJsonElement(value: Any?): kotlinx.serialization.json.JsonElement {
        return when (value) {
            null -> JsonNull
            is Boolean -> JsonPrimitive(value)
            is Number -> JsonPrimitive(value)
            is String -> JsonPrimitive(value)
            is Map<*, *> -> {
                val map = value.entries.associate { 
                    it.key.toString() to toJsonElement(it.value)
                }
                JsonObject(map)
            }
            is List<*> -> {
                JsonArray(value.map { toJsonElement(it) })
            }
            else -> JsonPrimitive(value.toString())
        }
    }
    
    private fun fromJsonElement(element: kotlinx.serialization.json.JsonElement): Any? {
        return when (element) {
            is JsonNull -> null
            is JsonPrimitive -> {
                when {
                    element.isString -> element.content
                    element.content == "true" -> true
                    element.content == "false" -> false
                    element.content.toLongOrNull() != null -> element.content.toLong()
                    element.content.toDoubleOrNull() != null -> element.content.toDouble()
                    else -> element.content
                }
            }
            is JsonObject -> {
                element.entries.associate { (key, value) ->
                    key to fromJsonElement(value)
                }
            }
            is JsonArray -> {
                element.map { fromJsonElement(it) }
            }
        }
    }
}
