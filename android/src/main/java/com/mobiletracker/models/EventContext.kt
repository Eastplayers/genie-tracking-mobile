package com.mobiletracker.models

import kotlinx.serialization.Serializable

/**
 * Context information automatically added to all events
 * 
 * @property platform Platform identifier ("android")
 * @property osVersion Operating system version
 * @property appVersion Application version (if available)
 */
@Serializable
data class EventContext(
    val platform: String,
    val osVersion: String,
    val appVersion: String? = null
)
