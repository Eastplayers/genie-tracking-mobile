package ai.founderos.mobiletracker

import ai.founderos.mobiletracker.models.Event
import ai.founderos.mobiletracker.models.EventContext
import okhttp3.OkHttpClient
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

class HTTPClientTest {
    private lateinit var mockServer: MockWebServer
    private lateinit var httpClient: HTTPClient
    
    @Before
    fun setup() {
        mockServer = MockWebServer()
        mockServer.start()
        
        // Create HTTPClient with a client that doesn't retry
        val okHttpClient = OkHttpClient.Builder()
            .connectTimeout(5, TimeUnit.SECONDS)
            .writeTimeout(5, TimeUnit.SECONDS)
            .readTimeout(5, TimeUnit.SECONDS)
            .build()
        
        httpClient = HTTPClient(okHttpClient)
    }
    
    @After
    fun teardown() {
        mockServer.shutdown()
    }
    
    private fun createTestEvent(name: String): Event {
        return Event(
            type = "track",
            name = name,
            userId = "user123",
            traits = null,
            properties = null,
            context = EventContext(
                platform = "android",
                osVersion = "13",
                appVersion = "1.0.0"
            ),
            timestamp = "2025-11-27T10:00:00.000Z"
        )
    }
    
    @Test
    fun testSendEventsSuccess() {
        // Arrange
        mockServer.enqueue(MockResponse().setResponseCode(200))
        
        val events = listOf(createTestEvent("test_event"))
        val endpoint = mockServer.url("/events").toString()
        val apiKey = "test-api-key"
        
        val latch = CountDownLatch(1)
        var result: Result<Unit>? = null
        
        // Act
        httpClient.send(events, endpoint, apiKey) { res ->
            result = res
            latch.countDown()
        }
        
        // Wait for async callback
        latch.await(5, TimeUnit.SECONDS)
        
        // Assert
        assertTrue(result?.isSuccess == true)
        
        // Verify request
        val request = mockServer.takeRequest()
        assertEquals("POST", request.method)
        assertEquals("application/json", request.getHeader("Content-Type"))
        assertEquals("test-api-key", request.getHeader("X-API-Key"))
        assertNotNull(request.body)
    }
    
    @Test
    fun testSendEventsHttpError() {
        // Arrange
        mockServer.enqueue(MockResponse().setResponseCode(400))
        
        val events = listOf(createTestEvent("test_event"))
        val endpoint = mockServer.url("/events").toString()
        val apiKey = "test-api-key"
        
        val latch = CountDownLatch(1)
        var result: Result<Unit>? = null
        
        // Act
        httpClient.send(events, endpoint, apiKey) { res ->
            result = res
            latch.countDown()
        }
        
        // Wait for async callback
        latch.await(5, TimeUnit.SECONDS)
        
        // Assert
        assertTrue(result?.isFailure == true)
        val exception = result?.exceptionOrNull()
        assertTrue(exception is HTTPClientError.HttpError)
        assertEquals(400, (exception as HTTPClientError.HttpError).statusCode)
    }
    
    @Test
    fun testSendEventsInvalidEndpoint() {
        // Arrange
        val events = listOf(createTestEvent("test_event"))
        val endpoint = ""
        val apiKey = "test-api-key"
        
        val latch = CountDownLatch(1)
        var result: Result<Unit>? = null
        
        // Act
        httpClient.send(events, endpoint, apiKey) { res ->
            result = res
            latch.countDown()
        }
        
        // Wait for async callback
        latch.await(5, TimeUnit.SECONDS)
        
        // Assert
        assertTrue(result?.isFailure == true)
        val exception = result?.exceptionOrNull()
        assertTrue(exception is HTTPClientError.InvalidEndpoint)
    }
    
    @Test
    fun testSendMultipleEvents() {
        // Arrange
        mockServer.enqueue(MockResponse().setResponseCode(200))
        
        val events = listOf(
            createTestEvent("event1"),
            createTestEvent("event2"),
            createTestEvent("event3")
        )
        val endpoint = mockServer.url("/events").toString()
        val apiKey = "test-api-key"
        
        val latch = CountDownLatch(1)
        var result: Result<Unit>? = null
        
        // Act
        httpClient.send(events, endpoint, apiKey) { res ->
            result = res
            latch.countDown()
        }
        
        // Wait for async callback
        latch.await(5, TimeUnit.SECONDS)
        
        // Assert
        assertTrue(result?.isSuccess == true)
        
        // Verify request contains all events
        val request = mockServer.takeRequest()
        val body = request.body.readUtf8()
        assertTrue(body.contains("event1"))
        assertTrue(body.contains("event2"))
        assertTrue(body.contains("event3"))
    }
}
