package ai.founderos.mobiletracker.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import ai.founderos.mobiletracker.MobileTracker
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        setContent {
            MaterialTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    MainActivityContent(applicationContext)
                }
            }
        }
    }
}

/**
 * Main content composable that handles screen transitions and initialization
 * 
 * Requirements: 1.1, 1.6, 2.2, 2.3
 */
@Composable
fun MainActivityContent(context: android.content.Context) {
    // State management for screen transitions
    var isInitialized by remember { mutableStateOf(false) }
    var showConfigurationScreen by remember { mutableStateOf(false) }
    var currentConfiguration by remember { mutableStateOf<TrackerConfiguration?>(null) }
    var initializationError by remember { mutableStateOf("") }
    var isReconfiguring by remember { mutableStateOf(false) }
    
    // Check for persisted configuration on first composition
    LaunchedEffect(Unit) {
        val persistedConfig = ConfigurationManager.loadConfiguration(context)
        if (persistedConfig != null) {
            // Configuration exists, initialize automatically
            currentConfiguration = persistedConfig
            initializeTracker(context, persistedConfig) { success, error ->
                if (success) {
                    isInitialized = true
                    showConfigurationScreen = false
                } else {
                    initializationError = error
                    showConfigurationScreen = true
                }
            }
        } else {
            // No configuration exists, show configuration screen
            showConfigurationScreen = true
        }
    }
    
    if (showConfigurationScreen) {
        ConfigurationScreen(
            onInitialize = { config ->
                // Validate configuration
                val validationResult = config.validate()
                when (validationResult) {
                    is ValidationResult.Valid -> {
                        // Check if this is a reconfiguration (configuration changed)
                        val configChanged = currentConfiguration != null && currentConfiguration != config
                        
                        if (configChanged && isInitialized) {
                            // Reset tracker before reinitializing with new configuration
                            // Requirements: 3.3, 3.4
                            MobileTracker.getInstance().reset(true)
                            isReconfiguring = true
                        }
                        
                        // Save configuration to SharedPreferences
                        ConfigurationManager.saveConfiguration(context, config)
                        currentConfiguration = config
                        
                        // Initialize tracker
                        initializeTracker(context, config) { success, error ->
                            if (success) {
                                isInitialized = true
                                showConfigurationScreen = false
                                initializationError = ""
                                isReconfiguring = false
                            } else {
                                initializationError = error
                                isReconfiguring = false
                            }
                        }
                    }
                    is ValidationResult.Error -> {
                        initializationError = validationResult.message
                    }
                }
            },
            initialConfig = currentConfiguration
        )
    } else if (isInitialized) {
        MobileTrackerExampleApp(
            isInitialized = true,
            onSettingsClick = {
                showConfigurationScreen = true
            },
            onResetAll = {
                if (context != null) {
                    ConfigurationManager.clearConfiguration(context)
                    UserDataManager.clearUserData(context)
                }
                isInitialized = false
                showConfigurationScreen = true
                currentConfiguration = null
            },
            context = context
        )
    }
}

/**
 * Initialize the MobileTracker SDK with the given configuration
 * 
 * Requirements: 1.2, 1.6, 2.1
 * 
 * @param context Android context
 * @param config The tracker configuration
 * @param callback Callback with success status and error message
 */
private fun initializeTracker(
    context: android.content.Context,
    config: TrackerConfiguration,
    callback: (success: Boolean, error: String) -> Unit
) {
    kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.IO).launch {
        try {
            println("🔄 Starting MobileTracker initialization...")
            println("   Brand ID: ${config.brandId}")
            println("   API URL: ${config.apiUrl}")
            println("   API Key: ${config.apiKey.take(8)}...")
            
            MobileTracker.getInstance().initialize(
                context = context,
                brandId = config.brandId,
                config = ai.founderos.mobiletracker.TrackerConfig(
                    debug = true,
                    apiUrl = config.apiUrl,
                    xApiKey = config.apiKey
                )
            )
            println("✅ MobileTracker initialized successfully")
            callback(true, "")
        } catch (e: Exception) {
            println("❌ Failed to initialize MobileTracker: ${e.message}")
            e.printStackTrace()
            callback(false, "Failed to initialize: ${e.message}")
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MobileTrackerExampleApp(
    isInitialized: Boolean,
    onSettingsClick: (() -> Unit)? = null,
    onResetAll: (() -> Unit)? = null,
    context: android.content.Context? = null
) {
    var userId by remember { mutableStateOf("") }
    var eventName by remember { mutableStateOf("") }
    var screenName by remember { mutableStateOf("") }
    var metadataKey by remember { mutableStateOf("") }
    var metadataValue by remember { mutableStateOf("") }
    var profileName by remember { mutableStateOf("") }
    var profileEmail by remember { mutableStateOf("") }
    var statusMessage by remember { mutableStateOf(if (isInitialized) "Ready to track events" else "Initializing...") }
    val coroutineScope = rememberCoroutineScope()
    
    // Load persisted user data on first composition
    LaunchedEffect(Unit) {
        if (context != null) {
            val userData = UserDataManager.loadUserData(context)
            if (userData != null) {
                userId = userData.userId
                profileName = userData.name
                profileEmail = userData.email
            }
        }
    }
    
    // Update status message when initialization completes
    LaunchedEffect(isInitialized) {
        if (isInitialized) {
            statusMessage = "✅ SDK initialized - Ready to track events"
        }
    }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("MobileTracker Demo") },
                actions = {
                    if (isInitialized && onSettingsClick != null) {
                        IconButton(onClick = onSettingsClick) {
                            Icon(
                                imageVector = androidx.compose.material.icons.Icons.Default.Settings,
                                contentDescription = "Settings"
                            )
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer,
                    titleContentColor = MaterialTheme.colorScheme.onPrimaryContainer
                )
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Status message
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Text(
                    text = statusMessage,
                    modifier = Modifier.padding(16.dp),
                    style = MaterialTheme.typography.bodySmall
                )
            }
            
            // Identify Section
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.3f)
                )
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "Identify User",
                        style = MaterialTheme.typography.titleMedium
                    )
                    
                    OutlinedTextField(
                        value = userId,
                        onValueChange = { userId = it },
                        label = { Text("User ID") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    
                    Button(
                        onClick = {
                            coroutineScope.launch {
                                MobileTracker.getInstance().identify(userId)
                                // Save user data for future sessions
                                if (context != null) {
                                    UserDataManager.saveUserData(context, userId, profileName, profileEmail)
                                }
                                statusMessage = "✅ Identified user: $userId"
                                println("Identified user: $userId")
                            }
                        },
                        modifier = Modifier.fillMaxWidth(),
                        enabled = isInitialized && userId.isNotEmpty()
                    ) {
                        Text("Identify")
                    }
                }
            }

            // Update Profile Section
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "Update Profile (set)",
                        style = MaterialTheme.typography.titleMedium
                    )
                    
                    OutlinedTextField(
                        value = profileName,
                        onValueChange = { profileName = it },
                        label = { Text("Name") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    
                    OutlinedTextField(
                        value = profileEmail,
                        onValueChange = { profileEmail = it },
                        label = { Text("Email") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    
                    Button(
                        onClick = {
                            coroutineScope.launch {
                                val profileData = mutableMapOf<String, Any>()
                                if (profileName.isNotEmpty()) {
                                    profileData["name"] = profileName
                                }
                                if (profileEmail.isNotEmpty()) {
                                    profileData["email"] = profileEmail
                                }
                                
                                MobileTracker.getInstance().set(profileData)
                                // Save user data for future sessions
                                if (context != null) {
                                    UserDataManager.saveUserData(context, userId, profileName, profileEmail)
                                }
                                statusMessage = "✅ Profile updated"
                                println("Updated profile: $profileData")
                                // profileName = ""
                                // profileEmail = ""
                            }
                        },
                        modifier = Modifier.fillMaxWidth(),
                        enabled = profileName.isNotEmpty() || profileEmail.isNotEmpty()
                    ) {
                        Text("Update Profile")
                    }
                }
            }
            
            // Track Event Section
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.secondaryContainer.copy(alpha = 0.3f)
                )
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "Track Event",
                        style = MaterialTheme.typography.titleMedium
                    )
                    
                    OutlinedTextField(
                        value = eventName,
                        onValueChange = { eventName = it },
                        label = { Text("Event Name") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    
                    Button(
                        onClick = {
                            coroutineScope.launch {
                                val properties = mapOf(
                                    "source" to "android_example",
                                    "timestamp" to System.currentTimeMillis()
                                )
                                
                                MobileTracker.getInstance().track(eventName, properties)
                                statusMessage = "✅ Tracked event: $eventName"
                                println("Tracked event: $eventName with properties: $properties")
                                eventName = ""
                            }
                        },
                        modifier = Modifier.fillMaxWidth(),
                        enabled = isInitialized && eventName.isNotEmpty(),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = MaterialTheme.colorScheme.secondary
                        )
                    ) {
                        Text("Track Event")
                    }
                }
            }
            
            // Screen Tracking Section (Manual)
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.tertiaryContainer.copy(alpha = 0.3f)
                )
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "Track Screen (Manual)",
                        style = MaterialTheme.typography.titleMedium
                    )
                    
                    Text(
                        text = "Note: Screen tracking is automatic. Use this for manual tracking if needed.",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    
                    OutlinedTextField(
                        value = screenName,
                        onValueChange = { screenName = it },
                        label = { Text("Screen Name") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    
                    Button(
                        onClick = {
                            coroutineScope.launch {
                                val properties = mapOf(
                                    "screen" to screenName,
                                    "previousScreen" to "home",
                                    "loadTime" to 0.5
                                )
                                
                                MobileTracker.getInstance().track("VIEW_PAGE", properties)
                                statusMessage = "✅ Tracked screen: $screenName"
                                println("Tracked screen: $screenName with properties: $properties")
                                screenName = ""
                            }
                        },
                        modifier = Modifier.fillMaxWidth(),
                        enabled = screenName.isNotEmpty(),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = MaterialTheme.colorScheme.tertiary
                        )
                    ) {
                        Text("Track Screen")
                    }
                }
            }
            
            // Set Metadata Section
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.tertiaryContainer.copy(alpha = 0.5f)
                )
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "Set Metadata",
                        style = MaterialTheme.typography.titleMedium
                    )
                    
                    OutlinedTextField(
                        value = metadataKey,
                        onValueChange = { metadataKey = it },
                        label = { Text("Metadata Key") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    
                    OutlinedTextField(
                        value = metadataValue,
                        onValueChange = { metadataValue = it },
                        label = { Text("Metadata Value") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    
                    Button(
                        onClick = {
                            coroutineScope.launch {
                                val metadata = mapOf(
                                    metadataKey to metadataValue,
                                    "timestamp" to System.currentTimeMillis()
                                )
                                
                                MobileTracker.getInstance().setMetadata(metadata)
                                statusMessage = "✅ Metadata set: $metadataKey = $metadataValue"
                                println("Set metadata: $metadata")
                                metadataKey = ""
                                metadataValue = ""
                            }
                        },
                        modifier = Modifier.fillMaxWidth(),
                        enabled = metadataKey.isNotEmpty() && metadataValue.isNotEmpty(),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = MaterialTheme.colorScheme.tertiary
                        )
                    ) {
                        Text("Set Metadata")
                    }
                }
            }
            
            // Quick Actions
            Card {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "Quick Actions",
                        style = MaterialTheme.typography.titleMedium
                    )
                    
                    OutlinedButton(
                        onClick = {
                            coroutineScope.launch {
                                val properties = mapOf(
                                    "buttonName" to "quick_action",
                                    "buttonType" to "primary",
                                    "screen" to "home"
                                )
                                
                                MobileTracker.getInstance().track("BUTTON_CLICKED", properties)
                                statusMessage = "✅ Tracked: BUTTON_CLICKED"
                                println("Tracked: BUTTON_CLICKED")
                            }
                        },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("Track Button Click")
                    }
                    
                    OutlinedButton(
                        onClick = {
                            coroutineScope.launch {
                                val properties = mapOf(
                                    "productId" to "premium_plan",
                                    "price" to 29.99,
                                    "currency" to "USD",
                                    "items" to listOf(
                                        mapOf("name" to "Premium Plan", "quantity" to 1)
                                    )
                                )
                                
                                MobileTracker.getInstance().track("PURCHASE_COMPLETED", properties)
                                statusMessage = "✅ Tracked: PURCHASE_COMPLETED"
                                println("Tracked: PURCHASE_COMPLETED")
                            }
                        },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("Track Purchase")
                    }
                    
                    OutlinedButton(
                        onClick = {
                            coroutineScope.launch {
                                val properties = mapOf(
                                    "method" to "email",
                                    "source" to "android_app"
                                )
                                
                                MobileTracker.getInstance().track("USER_SIGNUP", properties)
                                statusMessage = "✅ Tracked: USER_SIGNUP"
                                println("Tracked: USER_SIGNUP")
                            }
                        },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("Track Signup")
                    }
                }
            }
            
            // Reset Section
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.errorContainer.copy(alpha = 0.3f)
                )
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "Reset Tracking",
                        style = MaterialTheme.typography.titleMedium
                    )
                    
                    OutlinedButton(
                        onClick = {
                            MobileTracker.getInstance().reset(false)
                            // Clear user data when resetting session
                            if (context != null) {
                                UserDataManager.clearUserData(context)
                            }
                            statusMessage = "✅ Session reset (Brand ID preserved)"
                            println("Reset tracking session")
                        },
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.outlinedButtonColors(
                            contentColor = MaterialTheme.colorScheme.error
                        )
                    ) {
                        Text("Reset Session (Keep Brand ID)")
                    }
                    
                    OutlinedButton(
                        onClick = {
                            MobileTracker.getInstance().reset(true)
                            // Clear user data when resetting all
                            if (context != null) {
                                UserDataManager.clearUserData(context)
                            }
                            statusMessage = "✅ All tracking data reset - returning to configuration"
                            println("Reset all tracking data including Brand ID")
                            // Call the callback to clear configuration and return to configuration screen
                            onResetAll?.invoke()
                        },
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.outlinedButtonColors(
                            contentColor = MaterialTheme.colorScheme.error
                        )
                    ) {
                        Text("Reset All (including Brand ID)")
                    }
                }
            }
        }
    }
}
