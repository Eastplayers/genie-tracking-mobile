package ai.founderos.mobiletracker.example

import android.content.Context
import android.content.SharedPreferences
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * Integration tests for the configuration flow
 * 
 * Tests the complete configuration lifecycle including:
 * - Configuration persistence and loading
 * - Configuration validation
 * - Environment URL mapping
 * - Configuration changes
 * 
 * Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 3.2, 3.3, 3.4
 */
@RunWith(RobolectricTestRunner::class)
class ConfigurationIntegrationTest {
    
    private lateinit var context: Context
    private lateinit var sharedPreferences: SharedPreferences
    
    @Before
    fun setup() {
        context = RuntimeEnvironment.getApplication()
        // Clear any existing preferences
        sharedPreferences = context.getSharedPreferences(PreferencesKeys.PREFS_NAME, Context.MODE_PRIVATE)
        sharedPreferences.edit().clear().commit()
    }
    
    /**
     * Test 8.1: Full configuration flow end-to-end
     * 
     * Scenario: Launch app → Show configuration screen → Enter values → Initialize → Show demo screen
     * Requirements: 1.1, 1.2, 1.6
     */
    @Test
    fun testFullConfigurationFlowEndToEnd() {
        // Step 1: Verify no configuration exists initially
        val initialConfig = ConfigurationManager.loadConfiguration(context)
        assertNull(initialConfig, "No configuration should exist initially")
        
        // Step 2: Create a valid configuration
        val config = TrackerConfiguration(
            apiKey = "test-api-key-12345",
            brandId = "test-brand-123",
            environment = Environment.QC,
            userId = "test-user-001"
        )
        
        // Step 3: Validate the configuration
        val validationResult = config.validate()
        assertTrue(validationResult is ValidationResult.Valid, "Configuration should be valid")
        
        // Step 4: Save configuration
        ConfigurationManager.saveConfiguration(context, config)
        
        // Step 5: Verify configuration was saved
        val savedConfig = ConfigurationManager.loadConfiguration(context)
        assertNotNull(savedConfig, "Configuration should be saved")
        assertEquals(config.apiKey, savedConfig.apiKey, "API Key should match")
        assertEquals(config.brandId, savedConfig.brandId, "Brand ID should match")
        assertEquals(config.environment, savedConfig.environment, "Environment should match")
        assertEquals(config.userId, savedConfig.userId, "User ID should match")
        
        // Step 6: Verify configuration exists check
        assertTrue(ConfigurationManager.hasConfiguration(context), "Configuration should exist")
    }
    
    /**
     * Test 8.2: Persistence across app restarts
     * 
     * Scenario: Save configuration → Kill app → Relaunch → Verify auto-initialization
     * Requirements: 2.2
     */
    @Test
    fun testPersistenceAcrossAppRestarts() {
        // Step 1: Create and save configuration
        val originalConfig = TrackerConfiguration(
            apiKey = "persistent-key-xyz",
            brandId = "persistent-brand",
            environment = Environment.PRODUCTION,
            userId = "persistent-user"
        )
        
        ConfigurationManager.saveConfiguration(context, originalConfig)
        
        // Step 2: Simulate app restart by clearing memory and reloading
        // (In real scenario, app would be killed and relaunched)
        val reloadedConfig = ConfigurationManager.loadConfiguration(context)
        
        // Step 3: Verify configuration persisted correctly
        assertNotNull(reloadedConfig, "Configuration should persist after restart")
        assertEquals(originalConfig.apiKey, reloadedConfig.apiKey, "API Key should persist")
        assertEquals(originalConfig.brandId, reloadedConfig.brandId, "Brand ID should persist")
        assertEquals(originalConfig.environment, reloadedConfig.environment, "Environment should persist")
        assertEquals(originalConfig.userId, reloadedConfig.userId, "User ID should persist")
    }
    
    /**
     * Test 8.3: Reconfiguration flow
     * 
     * Scenario: Initialize with config A → Click settings → Change to config B → Verify reinitialize
     * Requirements: 3.2, 3.3, 3.4
     */
    @Test
    fun testReconfigurationFlow() {
        // Step 1: Save initial configuration (Config A)
        val configA = TrackerConfiguration(
            apiKey = "config-a-key",
            brandId = "brand-a",
            environment = Environment.QC,
            userId = "user-a"
        )
        
        ConfigurationManager.saveConfiguration(context, configA)
        var loadedConfig = ConfigurationManager.loadConfiguration(context)
        assertEquals(configA.apiKey, loadedConfig?.apiKey, "Config A should be saved")
        
        // Step 2: User clicks settings and changes to Config B
        val configB = TrackerConfiguration(
            apiKey = "config-b-key",
            brandId = "brand-b",
            environment = Environment.PRODUCTION,
            userId = "user-b"
        )
        
        // Step 3: Validate new configuration
        val validationResult = configB.validate()
        assertTrue(validationResult is ValidationResult.Valid, "Config B should be valid")
        
        // Step 4: Save new configuration
        ConfigurationManager.saveConfiguration(context, configB)
        
        // Step 5: Verify configuration changed
        loadedConfig = ConfigurationManager.loadConfiguration(context)
        assertNotNull(loadedConfig, "Configuration should exist")
        assertEquals(configB.apiKey, loadedConfig.apiKey, "API Key should be updated to Config B")
        assertEquals(configB.brandId, loadedConfig.brandId, "Brand ID should be updated to Config B")
        assertEquals(configB.environment, loadedConfig.environment, "Environment should be updated to Config B")
        assertEquals(configB.userId, loadedConfig.userId, "User ID should be updated to Config B")
    }
    
    /**
     * Test 8.4: Error handling - blank fields
     * 
     * Scenario: Try to initialize with blank fields → Verify error display
     * Requirements: 1.3
     */
    @Test
    fun testErrorHandlingBlankFields() {
        // Test blank API Key
        val configBlankApiKey = TrackerConfiguration(
            apiKey = "",
            brandId = "test-brand",
            environment = Environment.QC
        )
        
        val resultBlankApiKey = configBlankApiKey.validate()
        assertTrue(resultBlankApiKey is ValidationResult.Error, "Should reject blank API Key")
        assertEquals("API Key is required", (resultBlankApiKey as ValidationResult.Error).message)
        
        // Test blank Brand ID
        val configBlankBrandId = TrackerConfiguration(
            apiKey = "test-key",
            brandId = "",
            environment = Environment.QC
        )
        
        val resultBlankBrandId = configBlankBrandId.validate()
        assertTrue(resultBlankBrandId is ValidationResult.Error, "Should reject blank Brand ID")
        assertEquals("Brand ID is required", (resultBlankBrandId as ValidationResult.Error).message)
        
        // Test both blank
        val configBothBlank = TrackerConfiguration(
            apiKey = "",
            brandId = "",
            environment = Environment.QC
        )
        
        val resultBothBlank = configBothBlank.validate()
        assertTrue(resultBothBlank is ValidationResult.Error, "Should reject both blank")
    }
    
    /**
     * Test 8.4: Error handling - invalid credentials
     * 
     * Scenario: Try to initialize with invalid credentials → Verify error handling
     * Requirements: 1.3
     */
    @Test
    fun testErrorHandlingInvalidCredentials() {
        // Test whitespace-only API Key
        val configWhitespaceApiKey = TrackerConfiguration(
            apiKey = "   ",
            brandId = "test-brand",
            environment = Environment.QC
        )
        
        val resultWhitespaceApiKey = configWhitespaceApiKey.validate()
        assertTrue(resultWhitespaceApiKey is ValidationResult.Error, "Should reject whitespace-only API Key")
        
        // Test whitespace-only Brand ID
        val configWhitespaceBrandId = TrackerConfiguration(
            apiKey = "test-key",
            brandId = "   ",
            environment = Environment.QC
        )
        
        val resultWhitespaceBrandId = configWhitespaceBrandId.validate()
        assertTrue(resultWhitespaceBrandId is ValidationResult.Error, "Should reject whitespace-only Brand ID")
    }
    
    /**
     * Test 8.5: Configuration clearing
     * 
     * Scenario: Clear configuration → Relaunch app → Verify configuration screen shown
     * Requirements: 2.3
     */
    @Test
    fun testConfigurationClearing() {
        // Step 1: Save a configuration
        val config = TrackerConfiguration(
            apiKey = "test-key",
            brandId = "test-brand",
            environment = Environment.QC
        )
        
        ConfigurationManager.saveConfiguration(context, config)
        assertTrue(ConfigurationManager.hasConfiguration(context), "Configuration should exist")
        
        // Step 2: Clear configuration
        ConfigurationManager.clearConfiguration(context)
        
        // Step 3: Verify configuration is cleared
        assertFalse(ConfigurationManager.hasConfiguration(context), "Configuration should be cleared")
        assertNull(ConfigurationManager.loadConfiguration(context), "Loaded configuration should be null")
    }
    
    /**
     * Test QC Environment URL mapping
     * 
     * Requirements: 1.4
     */
    @Test
    fun testQCEnvironmentURLMapping() {
        val config = TrackerConfiguration(
            apiKey = "test-key",
            brandId = "test-brand",
            environment = Environment.QC
        )
        
        assertEquals(
            "https://tracking.api.qc.founder-os.ai/api",
            config.apiUrl,
            "QC environment should map to correct URL"
        )
    }
    
    /**
     * Test Production Environment URL mapping
     * 
     * Requirements: 1.5
     */
    @Test
    fun testProductionEnvironmentURLMapping() {
        val config = TrackerConfiguration(
            apiKey = "test-key",
            brandId = "test-brand",
            environment = Environment.PRODUCTION
        )
        
        assertEquals(
            "https://tracking.api.founder-os.ai/api",
            config.apiUrl,
            "Production environment should map to correct URL"
        )
    }
}
