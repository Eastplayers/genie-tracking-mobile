package com.mobiletracker.bridge

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager

/**
 * React Native package that registers the MobileTrackerBridge module
 * 
 * This package must be added to the React Native application's package list
 * in MainApplication.java/kt:
 * 
 * ```kotlin
 * override fun getPackages(): List<ReactPackage> {
 *     return PackageList(this).packages.apply {
 *         add(MobileTrackerPackage())
 *     }
 * }
 * ```
 */
class MobileTrackerPackage : ReactPackage {
    
    /**
     * Create and return the list of native modules to register
     * 
     * @param reactContext The React Native application context
     * @return List containing the MobileTrackerBridge module
     */
    override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
        return listOf(MobileTrackerBridge(reactContext))
    }
    
    /**
     * Create and return the list of view managers
     * 
     * This SDK doesn't provide any custom UI components, so returns empty list
     * 
     * @param reactContext The React Native application context
     * @return Empty list
     */
    override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
        return emptyList()
    }
}
