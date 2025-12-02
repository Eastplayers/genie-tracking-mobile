package ai.founderos.mobiletracker.example

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

/**
 * Configuration screen for initializing the MobileTracker SDK
 * 
 * Allows users to input API key, brand ID, and select environment
 * before initializing the tracker.
 * 
 * Requirements: 1.1, 1.2, 1.3, 1.4, 1.5
 * 
 * @param onInitialize Callback when user clicks Initialize button with valid configuration
 * @param initialConfig Optional configuration to pre-fill the form
 */
@Suppress("AutoboxingStateCreationDetector")
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ConfigurationScreen(
    onInitialize: (TrackerConfiguration) -> Unit,
    initialConfig: TrackerConfiguration? = null
) {
    // State management for form fields
    val apiKeyState = remember { mutableStateOf(initialConfig?.apiKey ?: "") }
    val brandIdState = remember { mutableStateOf(initialConfig?.brandId ?: "") }
    val selectedEnvironmentState = remember { mutableStateOf(initialConfig?.environment ?: Environment.QC) }
    val errorMessageState = remember { mutableStateOf("") }
    val expandedEnvironmentMenuState = remember { mutableStateOf(false) }
    
    var apiKey by apiKeyState
    var brandId by brandIdState
    var selectedEnvironment by selectedEnvironmentState
    var errorMessage by errorMessageState
    var expandedEnvironmentMenu by expandedEnvironmentMenuState

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Configure Tracker") },
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
            // Title and description
            Text(
                text = "SDK Configuration",
                style = MaterialTheme.typography.headlineSmall
            )

            Text(
                text = "Enter your API credentials and select the environment to initialize the MobileTracker SDK.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Divider()

            // API Key input field
            OutlinedTextField(
                value = apiKey,
                onValueChange = {
                    apiKey = it
                    errorMessage = "" // Clear error when user starts typing
                },
                label = { Text("API Key *") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                isError = errorMessage.contains("API Key", ignoreCase = true)
            )

            // Brand ID input field
            OutlinedTextField(
                value = brandId,
                onValueChange = {
                    brandId = it
                    errorMessage = "" // Clear error when user starts typing
                },
                label = { Text("Brand ID *") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                isError = errorMessage.contains("Brand ID", ignoreCase = true)
            )

            // Environment dropdown
            Box(modifier = Modifier.fillMaxWidth()) {
                OutlinedButton(
                    onClick = { expandedEnvironmentMenu = true },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Environment: ${selectedEnvironment}")
                }

                DropdownMenu(
                    expanded = expandedEnvironmentMenu,
                    onDismissRequest = { expandedEnvironmentMenu = false },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Environment.values().forEach { env ->
                        DropdownMenuItem(
                            text = { Text(env.toString()) },
                            onClick = {
                                selectedEnvironment = env
                                expandedEnvironmentMenu = false
                            }
                        )
                    }
                }
            }

            Divider()

            // Error message display
            if (errorMessage.isNotEmpty()) {
                Card(
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.errorContainer
                    )
                ) {
                    Text(
                        text = errorMessage,
                        modifier = Modifier.padding(12.dp),
                        color = MaterialTheme.colorScheme.onErrorContainer,
                        style = MaterialTheme.typography.bodySmall
                    )
                }
            }

            // Initialize button
            Button(
                onClick = {
                    val config = TrackerConfiguration(
                        apiKey = apiKey,
                        brandId = brandId,
                        environment = selectedEnvironment,
                    )

                    val validationResult = config.validate()
                    when (validationResult) {
                        is ValidationResult.Valid -> {
                            onInitialize(config)
                        }
                        is ValidationResult.Error -> {
                            errorMessage = validationResult.message
                        }
                    }
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp),
                enabled = apiKey.isNotBlank() && brandId.isNotBlank()
            ) {
                Text("Initialize Tracker")
            }

            // Helper text
            Text(
                text = "* Required fields",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Spacer(modifier = Modifier.height(8.dp))
        }
    }
}
