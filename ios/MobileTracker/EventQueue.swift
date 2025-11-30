import Foundation

/// Thread-safe event queue with FIFO eviction policy
class EventQueue {
    // MARK: - Properties
    
    /// Maximum number of events the queue can hold
    private let maxSize: Int
    
    /// Internal storage for events
    private var events: [Event] = []
    
    /// Serial dispatch queue for thread-safe operations
    private let queue = DispatchQueue(label: "com.mobiletracker.eventqueue")
    
    // MARK: - Initialization
    
    /// Initialize event queue with maximum size
    /// - Parameter maxSize: Maximum number of events to store (default: 100)
    init(maxSize: Int = 100) {
        self.maxSize = maxSize
    }
    
    // MARK: - Public Methods
    
    /// Add an event to the queue
    /// If queue is at max capacity, removes oldest event (FIFO eviction)
    /// - Parameter event: Event to add to the queue
    func enqueue(_ event: Event) {
        queue.sync {
            // If queue is at max size, remove oldest event (FIFO eviction)
            if events.count >= maxSize {
                events.removeFirst()
            }
            
            // Add new event to the end
            events.append(event)
        }
    }
    
    /// Retrieve and remove all events from the queue
    /// - Returns: Array of all events in the queue
    func dequeue() -> [Event] {
        return queue.sync {
            let allEvents = events
            events.removeAll()
            return allEvents
        }
    }
    
    /// Remove all events from the queue
    func clear() {
        queue.sync {
            events.removeAll()
        }
    }
    
    /// Get current number of events in the queue (for testing/debugging)
    /// - Returns: Number of events currently in the queue
    func count() -> Int {
        return queue.sync {
            return events.count
        }
    }
}
