package com.mobiletracker

/**
 * Configuration storage for the Mobile Tracking SDK
 * 
 * @property apiKey The API key for authenticating with the backend
 * @property endpoint The backend server URL where events are sent
 * @property maxQueueSize Maximum number of events to store in the queue (default: 100)
 */
data class Configuration(
    val apiKey: String,
    val endpoint: String,
    val maxQueueSize: Int = 100
)
