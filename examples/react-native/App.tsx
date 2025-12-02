import React, { useEffect, useState } from 'react'
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
  Alert,
} from 'react-native'
import MobileTracker from '@mobiletracker/react-native'
import { ConfigurationScreen } from './src/ConfigurationScreen'
import { useConfigurationManager } from './src/useConfigurationManager'
import { TrackerConfiguration } from './src/configurationManager'

function DemoScreen({
  onSettings,
  currentConfig,
}: {
  onSettings: () => void
  currentConfig: TrackerConfiguration | null
}): React.JSX.Element {
  const [userId, setUserId] = useState('')
  const [eventName, setEventName] = useState('')
  const [screenName, setScreenName] = useState('')
  const [metadataKey, setMetadataKey] = useState('')
  const [metadataValue, setMetadataValue] = useState('')
  const [profileName, setProfileName] = useState('')
  const [profileEmail, setProfileEmail] = useState('')
  const [statusMessage, setStatusMessage] = useState('Ready to track events')

  const handleIdentify = () => {
    if (!userId.trim()) {
      Alert.alert('Error', 'Please enter a user ID')
      return
    }

    const traits = {
      email: `${userId}@example.com`,
      plan: 'premium',
      signupDate: new Date().toISOString(),
    }

    MobileTracker.identify(userId, traits)
    setStatusMessage(`✅ Identified user: ${userId}`)
    console.log('Identified user:', userId, 'with traits:', traits)
  }

  const handleTrackEvent = () => {
    if (!eventName.trim()) {
      Alert.alert('Error', 'Please enter an event name')
      return
    }

    const properties = {
      source: 'react_native_example',
      timestamp: Date.now(),
    }

    MobileTracker.track(eventName, properties)
    setStatusMessage(`✅ Tracked event: ${eventName}`)
    console.log('Tracked event:', eventName, 'with properties:', properties)
    setEventName('')
  }

  const handleTrackScreen = () => {
    if (!screenName.trim()) {
      Alert.alert('Error', 'Please enter a screen name')
      return
    }

    const properties = {
      previousScreen: 'home',
      loadTime: 0.5,
    }

    MobileTracker.screen(screenName, properties)
    setStatusMessage(`✅ Tracked screen: ${screenName}`)
    console.log('Tracked screen:', screenName, 'with properties:', properties)
    setScreenName('')
  }

  const handleButtonClick = () => {
    const properties = {
      buttonName: 'quick_action',
      buttonType: 'primary',
      screen: 'home',
    }

    MobileTracker.track('BUTTON_CLICKED', properties)
    setStatusMessage('✅ Tracked: BUTTON_CLICKED')
    console.log('Tracked: BUTTON_CLICKED')
  }

  const handlePurchase = () => {
    const properties = {
      productId: 'premium_plan',
      price: 29.99,
      currency: 'USD',
      items: [{ name: 'Premium Plan', quantity: 1 }],
    }

    MobileTracker.track('PURCHASE_COMPLETED', properties)
    setStatusMessage('✅ Tracked: PURCHASE_COMPLETED')
    console.log('Tracked: PURCHASE_COMPLETED')
  }

  const handleSignup = () => {
    const properties = {
      method: 'email',
      source: 'react_native_app',
    }

    MobileTracker.track('USER_SIGNUP', properties)
    setStatusMessage('✅ Tracked: USER_SIGNUP')
    console.log('Tracked: USER_SIGNUP')
  }

  const handleSetMetadata = async () => {
    if (!metadataKey.trim() || !metadataValue.trim()) {
      Alert.alert('Error', 'Please enter both key and value')
      return
    }

    try {
      const metadata = {
        [metadataKey]: metadataValue,
        timestamp: Date.now(),
      }

      await MobileTracker.setMetadata(metadata)
      setStatusMessage(`✅ Metadata set: ${metadataKey} = ${metadataValue}`)
      console.log('Set metadata:', metadata)
      setMetadataKey('')
      setMetadataValue('')
    } catch (error) {
      console.error('Error setting metadata:', error)
      Alert.alert('Error', 'Failed to set metadata')
    }
  }

  const handleUpdateProfile = async () => {
    if (!profileName.trim() && !profileEmail.trim()) {
      Alert.alert('Error', 'Please enter at least name or email')
      return
    }

    try {
      const profileData: any = {}
      if (profileName.trim()) {
        profileData.name = profileName
      }
      if (profileEmail.trim()) {
        profileData.email = profileEmail
      }

      await MobileTracker.set(profileData)
      setStatusMessage('✅ Profile updated')
      console.log('Updated profile:', profileData)
      setProfileName('')
      setProfileEmail('')
    } catch (error) {
      console.error('Error updating profile:', error)
      Alert.alert('Error', 'Failed to update profile')
    }
  }

  const handleResetSession = () => {
    MobileTracker.reset(false)
    setStatusMessage('✅ Session reset (Brand ID preserved)')
    console.log('Reset tracking session')
  }

  const handleResetAll = () => {
    Alert.alert(
      'Reset All Data',
      'This will clear all tracking data including Brand ID. Continue?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Reset',
          style: 'destructive',
          onPress: () => {
            MobileTracker.reset(true)
            setStatusMessage('✅ All tracking data reset')
            console.log('Reset all tracking data including Brand ID')
          },
        },
      ]
    )
  }

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" />
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.headerContainer}>
          <Text style={styles.title}>MobileTracker Demo</Text>
          <TouchableOpacity style={styles.settingsButton} onPress={onSettings}>
            <Text style={styles.settingsButtonText}>⚙️ Settings</Text>
          </TouchableOpacity>
        </View>

        {/* Status Message */}
        <View style={styles.statusCard}>
          <Text style={styles.statusText}>{statusMessage}</Text>
        </View>

        {/* Identify Section */}
        <View style={[styles.card, styles.identifyCard]}>
          <Text style={styles.cardTitle}>Identify User</Text>
          <TextInput
            style={styles.input}
            placeholder="User ID"
            value={userId}
            onChangeText={setUserId}
            autoCapitalize="none"
          />
          <TouchableOpacity
            style={[styles.button, styles.identifyButton]}
            onPress={handleIdentify}
            disabled={!userId.trim()}
          >
            <Text style={styles.buttonText}>Identify</Text>
          </TouchableOpacity>
        </View>

        {/* Track Event Section */}
        <View style={[styles.card, styles.trackCard]}>
          <Text style={styles.cardTitle}>Track Event</Text>
          <TextInput
            style={styles.input}
            placeholder="Event Name"
            value={eventName}
            onChangeText={setEventName}
          />
          <TouchableOpacity
            style={[styles.button, styles.trackButton]}
            onPress={handleTrackEvent}
            disabled={!eventName.trim()}
          >
            <Text style={styles.buttonText}>Track Event</Text>
          </TouchableOpacity>
        </View>

        {/* Screen Tracking Section */}
        <View style={[styles.card, styles.screenCard]}>
          <Text style={styles.cardTitle}>Track Screen</Text>
          <TextInput
            style={styles.input}
            placeholder="Screen Name"
            value={screenName}
            onChangeText={setScreenName}
          />
          <TouchableOpacity
            style={[styles.button, styles.screenButton]}
            onPress={handleTrackScreen}
            disabled={!screenName.trim()}
          >
            <Text style={styles.buttonText}>Track Screen</Text>
          </TouchableOpacity>
        </View>

        {/* Set Metadata Section */}
        <View style={[styles.card, styles.metadataCard]}>
          <Text style={styles.cardTitle}>Set Metadata</Text>
          <TextInput
            style={styles.input}
            placeholder="Metadata Key"
            value={metadataKey}
            onChangeText={setMetadataKey}
          />
          <TextInput
            style={styles.input}
            placeholder="Metadata Value"
            value={metadataValue}
            onChangeText={setMetadataValue}
          />
          <TouchableOpacity
            style={[styles.button, styles.metadataButton]}
            onPress={handleSetMetadata}
            disabled={!metadataKey.trim() || !metadataValue.trim()}
          >
            <Text style={styles.buttonText}>Set Metadata</Text>
          </TouchableOpacity>
        </View>

        {/* Update Profile Section */}
        <View style={[styles.card, styles.profileCard]}>
          <Text style={styles.cardTitle}>Update Profile (set)</Text>
          <TextInput
            style={styles.input}
            placeholder="Name"
            value={profileName}
            onChangeText={setProfileName}
          />
          <TextInput
            style={styles.input}
            placeholder="Email"
            value={profileEmail}
            onChangeText={setProfileEmail}
            keyboardType="email-address"
            autoCapitalize="none"
          />
          <TouchableOpacity
            style={[styles.button, styles.profileButton]}
            onPress={handleUpdateProfile}
            disabled={!profileName.trim() && !profileEmail.trim()}
          >
            <Text style={styles.buttonText}>Update Profile</Text>
          </TouchableOpacity>
        </View>

        {/* Quick Actions */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Quick Actions</Text>
          <TouchableOpacity
            style={[styles.button, styles.outlineButton]}
            onPress={handleButtonClick}
          >
            <Text style={styles.outlineButtonText}>Track Button Click</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.button, styles.outlineButton]}
            onPress={handlePurchase}
          >
            <Text style={styles.outlineButtonText}>Track Purchase</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.button, styles.outlineButton]}
            onPress={handleSignup}
          >
            <Text style={styles.outlineButtonText}>Track Signup</Text>
          </TouchableOpacity>
        </View>

        {/* Reset Section */}
        <View style={[styles.card, styles.resetCard]}>
          <Text style={styles.cardTitle}>Reset Tracking</Text>
          <TouchableOpacity
            style={[styles.button, styles.resetButton]}
            onPress={handleResetSession}
          >
            <Text style={styles.resetButtonText}>Reset Session</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.button, styles.resetButton]}
            onPress={handleResetAll}
          >
            <Text style={styles.resetButtonText}>
              Reset All (including Brand ID)
            </Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  )
}

function App(): React.JSX.Element {
  const [isInitialized, setIsInitialized] = useState(false)
  const [showConfigScreen, setShowConfigScreen] = useState(false)
  const [currentConfig, setCurrentConfig] =
    useState<TrackerConfiguration | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const configManager = useConfigurationManager()

  useEffect(() => {
    const initializeApp = async () => {
      try {
        const savedConfig = await configManager.loadConfiguration()
        if (savedConfig) {
          setCurrentConfig(savedConfig)
          await initializeTracker(savedConfig)
          setIsInitialized(true)
          setShowConfigScreen(false)
        } else {
          setShowConfigScreen(true)
        }
      } catch (error) {
        console.error('Failed to load configuration:', error)
        setShowConfigScreen(true)
      } finally {
        setIsLoading(false)
      }
    }

    initializeApp()
  }, [])

  const initializeTracker = async (config: TrackerConfiguration) => {
    try {
      const apiUrl = configManager.getApiUrl(config.environment)
      console.log('🔄 Starting MobileTracker initialization...')
      console.log('   Brand ID:', config.brandId)
      console.log('   API URL:', apiUrl)
      console.log('   API Key:', config.apiKey.substring(0, 8) + '...')

      await MobileTracker.init({
        apiKey: config.brandId,
        endpoint: apiUrl,
        debug: true,
        x_api_key: config.apiKey,
      })

      if (config.userId) {
        MobileTracker.identify(config.userId)
      }

      console.log('✅ MobileTracker initialized successfully')
    } catch (error) {
      console.error('❌ Failed to initialize MobileTracker:', error)
      throw error
    }
  }

  const handleInitialize = async (config: TrackerConfiguration) => {
    try {
      await configManager.saveConfiguration(config)
      setCurrentConfig(config)
      await initializeTracker(config)
      setIsInitialized(true)
      setShowConfigScreen(false)
    } catch (error) {
      console.error('Failed to initialize:', error)
      throw error
    }
  }

  const handleReconfigure = async (config: TrackerConfiguration) => {
    try {
      MobileTracker.reset(true)
      await handleInitialize(config)
    } catch (error) {
      console.error('Failed to reconfigure:', error)
      throw error
    }
  }

  if (isLoading) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.centerContainer}>
          <Text style={styles.loadingText}>Loading configuration...</Text>
        </View>
      </SafeAreaView>
    )
  }

  if (showConfigScreen) {
    return (
      <SafeAreaView style={styles.container}>
        <StatusBar barStyle="dark-content" />
        <ConfigurationScreen
          onInitialize={handleInitialize}
          initialValues={currentConfig || undefined}
        />
      </SafeAreaView>
    )
  }

  return (
    <DemoScreen
      onSettings={() => setShowConfigScreen(true)}
      currentConfig={currentConfig}
    />
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  centerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    fontSize: 16,
    color: '#666',
  },
  scrollContent: {
    padding: 16,
  },
  headerContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
    flex: 1,
  },
  settingsButton: {
    backgroundColor: '#f0f0f0',
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  settingsButtonText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
  },
  statusCard: {
    backgroundColor: '#e0e0e0',
    padding: 16,
    borderRadius: 8,
    marginBottom: 16,
  },
  statusText: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
  },
  card: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 12,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  identifyCard: {
    backgroundColor: '#e3f2fd',
  },
  trackCard: {
    backgroundColor: '#e8f5e9',
  },
  screenCard: {
    backgroundColor: '#fff3e0',
  },
  metadataCard: {
    backgroundColor: '#f3e5f5',
  },
  profileCard: {
    backgroundColor: '#e0f2f1',
  },
  resetCard: {
    backgroundColor: '#ffebee',
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 12,
    color: '#333',
  },
  input: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    marginBottom: 12,
    fontSize: 16,
  },
  button: {
    padding: 14,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 4,
  },
  identifyButton: {
    backgroundColor: '#2196f3',
  },
  trackButton: {
    backgroundColor: '#4caf50',
  },
  screenButton: {
    backgroundColor: '#ff9800',
  },
  metadataButton: {
    backgroundColor: '#9c27b0',
  },
  profileButton: {
    backgroundColor: '#00897b',
  },
  outlineButton: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: '#9c27b0',
    marginBottom: 8,
  },
  resetButton: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: '#d32f2f',
    marginBottom: 8,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  outlineButtonText: {
    color: '#9c27b0',
    fontSize: 16,
    fontWeight: '600',
  },
  resetButtonText: {
    color: '#d32f2f',
    fontSize: 16,
    fontWeight: '600',
  },
})

export default App
