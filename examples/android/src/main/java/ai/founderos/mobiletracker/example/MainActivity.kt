package ai.founderos.mobiletracker.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import ai.founderos.mobiletracker.MobileTracker
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    private var isInitialized by mutableStateOf(false)
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize the SDK when activity is created
        // TODO: Replace with your actual credentials
        val brandId = "7366"  // Replace with your Brand ID
        val apiKey = "03dbd95123137cc76b075f50107d8d2d"  // Replace with your API key
        val apiUrl = "https://tracking.api.qc.founder-os.ai/api"  // Replace with your API endpoint URL
        
        // Initialize in a coroutine and update state when complete
        kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.IO).launch {
            try {
                println("🔄 Starting MobileTracker initialization...")
                println("   Brand ID: $brandId")
                println("   API URL: $apiUrl")
                println("   API Key: ${apiKey.take(8)}...")
                
                MobileTracker.getInstance().initialize(
                    context = applicationContext,
                    brandId = brandId,
                    config = ai.founderos.mobiletracker.TrackerConfig(
                        debug = true,
                        apiUrl = apiUrl,
                        xApiKey = apiKey
                    )
                )
                println("✅ MobileTracker initialized successfully")
                isInitialized = true
            } catch (e: Exception) {
                println("❌ Failed to initialize MobileTracker: ${e.message}")
                e.printStackTrace()
                isInitialized = false
            }
        }
        
        setContent {
            MaterialTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    MobileTrackerExampleApp(isInitialized)
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MobileTrackerExampleApp(isInitialized: Boolean) {
    var userId by remember { mutableStateOf("") }
    var eventName by remember { mutableStateOf("") }
    var screenName by remember { mutableStateOf("") }
    var metadataKey by remember { mutableStateOf("") }
    var metadataValue by remember { mutableStateOf("") }
    var profileName by remember { mutableStateOf("") }
    var profileEmail by remember { mutableStateOf("") }
    var statusMessage by remember { mutableStateOf(if (isInitialized) "Ready to track events" else "Initializing...") }
    val coroutineScope = rememberCoroutineScope()
    
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
                                val traits = mapOf(
                                    "email" to "${userId}@example.com",
                                    "plan" to "premium",
                                    "signupDate" to System.currentTimeMillis()
                                )
                                
                                MobileTracker.getInstance().identify(userId, traits)
                                statusMessage = "✅ Identified user: $userId"
                                println("Identified user: $userId with traits: $traits")
                            }
                        },
                        modifier = Modifier.fillMaxWidth(),
                        enabled = isInitialized && userId.isNotEmpty()
                    ) {
                        Text("Identify")
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
                                statusMessage = "✅ Profile updated"
                                println("Updated profile: $profileData")
                                profileName = ""
                                profileEmail = ""
                            }
                        },
                        modifier = Modifier.fillMaxWidth(),
                        enabled = profileName.isNotEmpty() || profileEmail.isNotEmpty()
                    ) {
                        Text("Update Profile")
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
                            statusMessage = "✅ Session reset (Brand ID preserved)"
                            println("Reset tracking session")
                        },
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.outlinedButtonColors(
                            contentColor = MaterialTheme.colorScheme.error
                        )
                    ) {
                        Text("Reset Session")
                    }
                    
                    OutlinedButton(
                        onClick = {
                            MobileTracker.getInstance().reset(true)
                            statusMessage = "✅ All tracking data reset"
                            println("Reset all tracking data including Brand ID")
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
