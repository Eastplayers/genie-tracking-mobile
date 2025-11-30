package ai.founderos.mobiletracker

import ai.founderos.mobiletracker.models.Event
import ai.founderos.mobiletracker.models.EventContext
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

class EventQueueTest {
    private lateinit var queue: EventQueue
    
    @Before
    fun setup() {
        queue = EventQueue(maxSize = 3)
    }
    
    private fun createTestEvent(name: String): Event {
        return Event(
            type = "track",
            name = name,
            userId = null,
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
    fun testEnqueueAddsEvent() {
        val event = createTestEvent("test_event")
        queue.enqueue(event)
        
        assertEquals(1, queue.size())
    }
    
    @Test
    fun testDequeueReturnsAllEvents() {
        val event1 = createTestEvent("event1")
        val event2 = createTestEvent("event2")
        
        queue.enqueue(event1)
        queue.enqueue(event2)
        
        val events = queue.dequeue()
        
        assertEquals(2, events.size)
        assertEquals("event1", events[0].name)
        assertEquals("event2", events[1].name)
        assertEquals(0, queue.size())
    }
    
    @Test
    fun testClearRemovesAllEvents() {
        queue.enqueue(createTestEvent("event1"))
        queue.enqueue(createTestEvent("event2"))
        
        queue.clear()
        
        assertEquals(0, queue.size())
    }
    
    @Test
    fun testFIFOEvictionWhenMaxSizeExceeded() {
        // Queue has max size of 3
        queue.enqueue(createTestEvent("event1"))
        queue.enqueue(createTestEvent("event2"))
        queue.enqueue(createTestEvent("event3"))
        
        // Adding 4th event should evict the first one
        queue.enqueue(createTestEvent("event4"))
        
        assertEquals(3, queue.size())
        
        val events = queue.dequeue()
        
        // event1 should be evicted, remaining should be event2, event3, event4
        assertEquals(3, events.size)
        assertEquals("event2", events[0].name)
        assertEquals("event3", events[1].name)
        assertEquals("event4", events[2].name)
    }
    
    @Test
    fun testMultipleEvictionsInSequence() {
        // Fill queue to max
        queue.enqueue(createTestEvent("event1"))
        queue.enqueue(createTestEvent("event2"))
        queue.enqueue(createTestEvent("event3"))
        
        // Add two more events, should evict first two
        queue.enqueue(createTestEvent("event4"))
        queue.enqueue(createTestEvent("event5"))
        
        val events = queue.dequeue()
        
        assertEquals(3, events.size)
        assertEquals("event3", events[0].name)
        assertEquals("event4", events[1].name)
        assertEquals("event5", events[2].name)
    }
}
