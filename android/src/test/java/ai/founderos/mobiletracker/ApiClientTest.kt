package ai.founderos.mobiletracker

import android.content.Context
import kotlinx.coroutines.runBlocking
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * Unit tests for ApiClient
 * 
 * Tests core functionality of the ApiClient class including:
 * - Device ID generation and retrieval
 * - Session creation
 * - Event tracking
 * - Profile updates
 * - Storage operations
 */
class ApiClientTest {
    
    private lateinit var mockWebServer: MockWebServer
    private lateinit var mockContext: Context
    private lateinit var apiClient: ApiClient
    
    @Before
    fun setup() {
        mockWebServer = MockWebServer()
        mockWebServer.start()
        
        mockContext = mock(Context::class.java)
        val mockResources = mock(android.content.res.Resources::class.java)
        val mockConfiguration = mock(android.content.res.Configuration::class.java)
        
        `when`(mockContext.resources).thenReturn(mockResources)
        `when`(mockResources.configuration).thenReturn(mockConfiguration)
        `when`(mockContext.filesDir).thenReturn(java.io.File(System.getProperty("java.io.tmpdir")))
        
        mockConfiguration.screenLayout = android.content.res.Configuration.SCREENLAYOUT_SIZE_NORMAL
        
        val config = TrackerConfig(
            debug = true,
            apiUrl = mockWebServer.url("/").toString().trimEnd('/'),
            xApiKey = "test-api-key"
        )
        
        apiClient = ApiClient(config, "123", mockContext)
    }
    
    @After
    fun teardown() {
        mockWebServer.shutdown()
    }
    
    @Test
    fun testDeviceIdGeneration() = runBlocking {
        // Generate a device ID
        val deviceId = apiClient.writeDeviceId()
        
        // Verify it's a valid UUID format
        assertNotNull(deviceId)
        assertTrue(deviceId.matches(Regex("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")))
    }
    
    @Test
    fun testGetDeviceInfo() = runBlocking {
        val deviceInfo = apiClient.getDeviceInfo()
        
        assertNotNull(deviceInfo)
        assertEquals("Android", deviceInfo.os_name)
        assertNotNull(deviceInfo.device_id)
        assertTrue(deviceInfo.device_type in listOf("Mobile", "Tablet"))
    }
    
    @Test
    fun testCreateTrackingSession() = runBlocking {
        // Mock successful session creation response
        val mockResponse = MockResponse()
            .setResponseCode(200)
            .setBody("""{"data": {"id": "session-123"}}""")
        mockWebServer.enqueue(mockResponse)
        
        val sessionId = apiClient.createTrackingSession(123)
        
        assertNotNull(sessionId)
        assertEquals("session-123", sessionId)
        
        // Verify the request
        val request = mockWebServer.takeRequest()
        assertEquals("POST", request.method)
        assertTrue(request.path!!.contains("/v2/tracking-session"))
        assertEquals("test-api-key", request.getHeader("x-api-key"))
    }
    
    @Test
    fun testCreateTrackingSessionFailure() = runBlocking {
        // Mock failed session creation response
        val mockResponse = MockResponse()
            .setResponseCode(500)
        mockWebServer.enqueue(mockResponse)
        
        val sessionId = apiClient.createTrackingSession(123)
        
        assertNull(sessionId)
    }
    
    @Test
    fun testTrackEvent() = runBlocking {
        // Mock successful event tracking response
        val mockResponse = MockResponse()
            .setResponseCode(200)
        mockWebServer.enqueue(mockResponse)
        
        val result = apiClient.trackEvent(
            brandId = 123,
            sessionId = "session-123",
            eventName = "BUTTON_CLICK",
            eventData = mapOf("button" to "purchase")
        )
        
        assertTrue(result)
        
        // Verify the request
        val request = mockWebServer.takeRequest()
        assertEquals("POST", request.method)
        assertTrue(request.path!!.contains("/v2/tracking-session-data"))
        assertTrue(request.body.readUtf8().contains("BUTTON_CLICK"))
    }
    
    @Test
    fun testUpdateProfile() = runBlocking {
        // Mock successful profile update response
        val mockResponse = MockResponse()
            .setResponseCode(200)
        mockWebServer.enqueue(mockResponse)
        
        val profileData = UpdateProfileData(
            name = "John Doe",
            email = "john@example.com",
            user_id = "user-123"
        )
        
        val result = apiClient.updateProfile(profileData, 123)
        
        assertTrue(result)
        
        // Verify the request
        val request = mockWebServer.takeRequest()
        assertEquals("PUT", request.method)
        assertTrue(request.path!!.contains("/v1/customer-profiles/set"))
        val body = request.body.readUtf8()
        assertTrue(body.contains("John Doe"))
        assertTrue(body.contains("john@example.com"))
    }
    
    @Test
    fun testSetMetadata() = runBlocking {
        // First set a session ID
        apiClient.setSessionId("session-123")
        
        // Mock successful metadata update response
        val mockResponse = MockResponse()
            .setResponseCode(200)
        mockWebServer.enqueue(mockResponse)
        
        val metadata = mapOf("plan" to "premium", "feature_flags" to listOf("new_ui"))
        val result = apiClient.setMetadata(metadata, 123)
        
        assertTrue(result)
        
        // Verify the request
        val request = mockWebServer.takeRequest()
        assertEquals("PUT", request.method)
        assertTrue(request.path!!.contains("/v1/customer-profiles/set"))
        val body = request.body.readUtf8()
        assertTrue(body.contains("premium"))
    }
    
    @Test
    fun testStorageHelperMethods() {
        // Test session ID storage
        apiClient.setSessionId("session-456")
        assertEquals("session-456", apiClient.getSessionId())
        
        // Test brand ID storage
        apiClient.setBrandId(789)
        assertEquals(789, apiClient.getBrandId())
    }
    
    @Test
    fun testClearAllTrackingCookies() {
        // Set some values
        apiClient.setSessionId("session-123")
        apiClient.setBrandId(456)
        
        // Clear tracking cookies
        apiClient.clearAllTrackingCookies()
        
        // Verify session_id is cleared but brand_id remains (not in the clear list)
        assertNull(apiClient.getSessionId())
        // Note: brand_id should remain as it's not in the cookiesToClear list
        assertEquals(456, apiClient.getBrandId())
    }
}
