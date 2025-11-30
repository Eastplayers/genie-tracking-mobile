import XCTest
@testable import MobileTracker

class StorageManagerTests: XCTestCase {
    var storageManager: StorageManager!
    let testPrefix = "__GT_test_"
    
    override func setUp() {
        super.setUp()
        storageManager = StorageManager(prefix: testPrefix)
        // Clean up before each test
        storageManager.clear()
    }
    
    override func tearDown() {
        // Clean up after each test
        storageManager.clear()
        super.tearDown()
    }
    
    // MARK: - Basic Save and Retrieve Tests
    
    func testSaveAndRetrieve() {
        // Test saving and retrieving a value
        storageManager.save(key: "test_key", value: "test_value")
        
        let retrieved = storageManager.retrieve(key: "test_key")
        XCTAssertEqual(retrieved, "test_value", "Retrieved value should match saved value")
    }
    
    func testRetrieveNonExistentKey() {
        // Test retrieving a key that doesn't exist
        let retrieved = storageManager.retrieve(key: "nonexistent")
        XCTAssertNil(retrieved, "Retrieving non-existent key should return nil")
    }
    
    func testSaveWithExpiration() {
        // Test saving with expiration parameter (not enforced, but should not crash)
        storageManager.save(key: "expiring_key", value: "expiring_value", expires: 365)
        
        let retrieved = storageManager.retrieve(key: "expiring_key")
        XCTAssertEqual(retrieved, "expiring_value", "Value with expiration should be retrievable")
    }
    
    // MARK: - Remove Tests
    
    func testRemove() {
        // Test removing a value
        storageManager.save(key: "remove_key", value: "remove_value")
        XCTAssertNotNil(storageManager.retrieve(key: "remove_key"), "Value should exist before removal")
        
        storageManager.remove(key: "remove_key")
        XCTAssertNil(storageManager.retrieve(key: "remove_key"), "Value should be nil after removal")
    }
    
    func testRemoveNonExistentKey() {
        // Test removing a key that doesn't exist (should not crash)
        storageManager.remove(key: "nonexistent")
        // If we get here without crashing, the test passes
        XCTAssertTrue(true)
    }
    
    // MARK: - Clear Tests
    
    func testClear() {
        // Test clearing all keys with prefix
        storageManager.save(key: "key1", value: "value1")
        storageManager.save(key: "key2", value: "value2")
        storageManager.save(key: "key3", value: "value3")
        
        XCTAssertNotNil(storageManager.retrieve(key: "key1"))
        XCTAssertNotNil(storageManager.retrieve(key: "key2"))
        XCTAssertNotNil(storageManager.retrieve(key: "key3"))
        
        storageManager.clear()
        
        XCTAssertNil(storageManager.retrieve(key: "key1"), "All keys should be cleared")
        XCTAssertNil(storageManager.retrieve(key: "key2"), "All keys should be cleared")
        XCTAssertNil(storageManager.retrieve(key: "key3"), "All keys should be cleared")
    }
    
    func testClearOnlyAffectsPrefixedKeys() {
        // Test that clear only removes keys with the correct prefix
        let otherStorage = StorageManager(prefix: "__GT_other_")
        otherStorage.save(key: "other_key", value: "other_value")
        
        storageManager.save(key: "test_key", value: "test_value")
        
        storageManager.clear()
        
        XCTAssertNil(storageManager.retrieve(key: "test_key"), "Test key should be cleared")
        XCTAssertNotNil(otherStorage.retrieve(key: "other_key"), "Other prefix key should remain")
        
        // Clean up
        otherStorage.clear()
    }
    
    // MARK: - Dual Storage Tests
    
    func testDualStorageFallback() {
        // Test that file backup works as fallback
        storageManager.save(key: "dual_key", value: "dual_value")
        
        // Manually remove from UserDefaults only
        let fullKey = testPrefix + "dual_key"
        UserDefaults.standard.removeObject(forKey: fullKey)
        
        // Should still retrieve from file backup
        let retrieved = storageManager.retrieve(key: "dual_key")
        XCTAssertEqual(retrieved, "dual_value", "Should retrieve from file backup when UserDefaults is empty")
    }
    
    func testOverwriteValue() {
        // Test overwriting an existing value
        storageManager.save(key: "overwrite_key", value: "original_value")
        XCTAssertEqual(storageManager.retrieve(key: "overwrite_key"), "original_value")
        
        storageManager.save(key: "overwrite_key", value: "new_value")
        XCTAssertEqual(storageManager.retrieve(key: "overwrite_key"), "new_value", "Value should be overwritten")
    }
    
    // MARK: - Special Characters Tests
    
    func testSpecialCharactersInKey() {
        // Test keys with special characters
        storageManager.save(key: "key:with:colons", value: "colon_value")
        XCTAssertEqual(storageManager.retrieve(key: "key:with:colons"), "colon_value")
    }
    
    func testSpecialCharactersInValue() {
        // Test values with special characters
        let specialValue = "value with spaces, symbols: !@#$%^&*(), and unicode: 你好"
        storageManager.save(key: "special_value_key", value: specialValue)
        XCTAssertEqual(storageManager.retrieve(key: "special_value_key"), specialValue)
    }
}
