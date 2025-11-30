package com.mobiletracker

import android.content.Context
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mock
import org.mockito.Mockito.*
import org.mockito.junit.MockitoJUnitRunner
import android.content.SharedPreferences
import java.io.File

@RunWith(MockitoJUnitRunner::class)
class StorageManagerTest {
    
    @Mock
    private lateinit var mockContext: Context
    
    @Mock
    private lateinit var mockSharedPreferences: SharedPreferences
    
    @Mock
    private lateinit var mockEditor: SharedPreferences.Editor
    
    private lateinit var tempDir: File
    private lateinit var storageManager: StorageManager
    private val testPrefix = "__GT_123_"
    
    @Before
    fun setup() {
        // Create a temporary directory for file backup
        tempDir = createTempDir("tracker_backup_test")
        
        // Mock SharedPreferences behavior
        `when`(mockContext.getSharedPreferences("MobileTracker", Context.MODE_PRIVATE))
            .thenReturn(mockSharedPreferences)
        `when`(mockSharedPreferences.edit()).thenReturn(mockEditor)
        `when`(mockEditor.putString(anyString(), anyString())).thenReturn(mockEditor)
        `when`(mockEditor.remove(anyString())).thenReturn(mockEditor)
        `when`(mockEditor.apply()).then { }
        
        // Mock filesDir to use our temp directory
        `when`(mockContext.filesDir).thenReturn(tempDir.parentFile)
        
        storageManager = StorageManager(mockContext, testPrefix)
    }
    
    @Test
    fun testSaveToPrimaryStorage() {
        val key = "session_id"
        val value = "test-session-123"
        
        storageManager.save(key, value)
        
        // Verify SharedPreferences was called with prefixed key
        verify(mockEditor).putString(testPrefix + key, value)
        verify(mockEditor).apply()
    }
    
    @Test
    fun testRetrieveFromPrimaryStorage() {
        val key = "session_id"
        val value = "test-session-123"
        val fullKey = testPrefix + key
        
        `when`(mockSharedPreferences.getString(fullKey, null)).thenReturn(value)
        
        val result = storageManager.retrieve(key)
        
        assertEquals(value, result)
        verify(mockSharedPreferences).getString(fullKey, null)
    }
    
    @Test
    fun testRetrieveReturnsNullWhenNotFound() {
        val key = "nonexistent_key"
        val fullKey = testPrefix + key
        
        `when`(mockSharedPreferences.getString(fullKey, null)).thenReturn(null)
        
        val result = storageManager.retrieve(key)
        
        assertNull(result)
    }
    
    @Test
    fun testRemoveFromBothStorages() {
        val key = "session_id"
        val fullKey = testPrefix + key
        
        storageManager.remove(key)
        
        // Verify removal from SharedPreferences
        verify(mockEditor).remove(fullKey)
        verify(mockEditor).apply()
    }
    
    @Test
    fun testClearRemovesAllKeysWithPrefix() {
        val allKeys = mapOf(
            testPrefix + "session_id" to "value1",
            testPrefix + "device_id" to "value2",
            "other_key" to "value3"
        )
        
        `when`(mockSharedPreferences.all).thenReturn(allKeys)
        
        storageManager.clear()
        
        // Verify only prefixed keys are removed
        verify(mockEditor).remove(testPrefix + "session_id")
        verify(mockEditor).remove(testPrefix + "device_id")
        verify(mockEditor, never()).remove("other_key")
        verify(mockEditor).apply()
    }
    
    @Test
    fun testSaveWithExpiration() {
        val key = "session_id"
        val value = "test-session-123"
        val expires = 365
        
        // Expiration is accepted but not enforced (for compatibility)
        storageManager.save(key, value, expires)
        
        verify(mockEditor).putString(testPrefix + key, value)
        verify(mockEditor).apply()
    }
    
    @Test
    fun testPrefixFormat() {
        val brandId = "456"
        val expectedPrefix = "__GT_${brandId}_"
        
        val manager = StorageManager(mockContext, expectedPrefix)
        
        manager.save("test_key", "test_value")
        
        verify(mockEditor).putString(expectedPrefix + "test_key", "test_value")
    }
}
