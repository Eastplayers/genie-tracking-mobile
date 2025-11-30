package ai.founderos.mobiletracker

import ai.founderos.mobiletracker.models.Event
import java.util.LinkedList

/**
 * Thread-safe event queue with FIFO eviction policy
 * 
 * This class manages a queue of events with a maximum size limit.
 * When the queue reaches its maximum size, the oldest events are
 * automatically evicted to make room for new events (FIFO eviction).
 * 
 * All operations are thread-safe using synchronized blocks.
 * 
 * @property maxSize Maximum number of events the queue can hold
 */
class EventQueue(private val maxSize: Int) {
    private val events = LinkedList<Event>()
    
    /**
     * Adds an event to the queue
     * 
     * If the queue is at maximum capacity, the oldest event is removed
     * before adding the new event (FIFO eviction policy).
     * 
     * @param event The event to add to the queue
     */
    @Synchronized
    fun enqueue(event: Event) {
        // If queue is at max size, remove oldest event (FIFO eviction)
        if (events.size >= maxSize) {
            events.removeFirst()
        }
        events.addLast(event)
    }
    
    /**
     * Retrieves and removes all events from the queue
     * 
     * @return List of all events that were in the queue
     */
    @Synchronized
    fun dequeue(): List<Event> {
        val eventList = events.toList()
        events.clear()
        return eventList
    }
    
    /**
     * Removes all events from the queue
     */
    @Synchronized
    fun clear() {
        events.clear()
    }
    
    /**
     * Returns the current number of events in the queue
     * 
     * @return The size of the queue
     */
    @Synchronized
    fun size(): Int {
        return events.size
    }
}
