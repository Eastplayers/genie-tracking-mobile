import React, { useState } from 'react'
import {
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
  ActivityIndicator,
} from 'react-native'
import { Picker } from '@react-native-picker/picker'
import {
  TrackerConfiguration,
  validateConfiguration,
} from './configurationManager'

export interface ConfigurationScreenProps {
  onInitialize: (config: TrackerConfiguration) => Promise<void>
  initialValues?: Partial<TrackerConfiguration>
}

export function ConfigurationScreen({
  onInitialize,
  initialValues,
}: ConfigurationScreenProps): React.JSX.Element {
  const [apiKey, setApiKey] = useState(initialValues?.apiKey || '')
  const [brandId, setBrandId] = useState(initialValues?.brandId || '')
  const [userId, setUserId] = useState(initialValues?.userId || '')
  const [environment, setEnvironment] = useState<'qc' | 'production'>(
    initialValues?.environment || 'qc'
  )
  const [errors, setErrors] = useState<string[]>([])
  const [isLoading, setIsLoading] = useState(false)

  const handleInitialize = async () => {
    const config: TrackerConfiguration = {
      apiKey,
      brandId,
      userId,
      environment,
    }

    const validation = validateConfiguration(config)

    if (!validation.valid) {
      setErrors(validation.errors)
      return
    }

    setErrors([])
    setIsLoading(true)

    try {
      await onInitialize(config)
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : 'Unknown error occurred'
      setErrors([`Initialization failed: ${errorMessage}`])
    } finally {
      setIsLoading(false)
    }
  }

  const isInitializeDisabled = !apiKey.trim() || !brandId.trim() || isLoading

  return (
    <ScrollView
      style={styles.container}
      contentContainerStyle={styles.scrollContent}
    >
      <Text style={styles.title}>Configure Tracker</Text>

      <Text style={styles.subtitle}>
        Enter your API credentials to initialize the tracking SDK
      </Text>

      {/* API Key Input */}
      <View style={styles.inputGroup}>
        <Text style={styles.label}>API Key *</Text>
        <TextInput
          style={styles.input}
          placeholder="Enter your API key"
          value={apiKey}
          onChangeText={setApiKey}
          secureTextEntry
          editable={!isLoading}
          placeholderTextColor="#999"
        />
      </View>

      {/* Brand ID Input */}
      <View style={styles.inputGroup}>
        <Text style={styles.label}>Brand ID *</Text>
        <TextInput
          style={styles.input}
          placeholder="Enter your brand ID"
          value={brandId}
          onChangeText={setBrandId}
          editable={!isLoading}
          placeholderTextColor="#999"
        />
      </View>

      {/* User ID Input */}
      <View style={styles.inputGroup}>
        <Text style={styles.label}>User ID (optional)</Text>
        <TextInput
          style={styles.input}
          placeholder="Enter user ID (optional)"
          value={userId}
          onChangeText={setUserId}
          editable={!isLoading}
          placeholderTextColor="#999"
        />
      </View>

      {/* Environment Picker */}
      <View style={styles.inputGroup}>
        <Text style={styles.label}>Environment *</Text>
        <View style={styles.pickerContainer}>
          <Picker
            selectedValue={environment}
            onValueChange={(value: string) =>
              setEnvironment(value as 'qc' | 'production')
            }
            enabled={!isLoading}
            style={styles.picker}
          >
            <Picker.Item label="QC" value="qc" />
            <Picker.Item label="Production" value="production" />
          </Picker>
        </View>
      </View>

      {/* Error Messages */}
      {errors.length > 0 && (
        <View style={styles.errorContainer}>
          <Text style={styles.errorTitle}>Validation Errors:</Text>
          {errors.map((error, index) => (
            <Text key={index} style={styles.errorText}>
              • {error}
            </Text>
          ))}
        </View>
      )}

      {/* Initialize Button */}
      <TouchableOpacity
        style={[styles.button, isInitializeDisabled && styles.buttonDisabled]}
        onPress={handleInitialize}
        disabled={isInitializeDisabled}
      >
        {isLoading ? (
          <View style={styles.loadingContainer}>
            <ActivityIndicator color="#fff" size="small" />
            <Text style={styles.buttonText}>Initializing...</Text>
          </View>
        ) : (
          <Text style={styles.buttonText}>Initialize Tracker</Text>
        )}
      </TouchableOpacity>

      {/* Required Fields Note */}
      <Text style={styles.requiredNote}>* Required fields</Text>
    </ScrollView>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollContent: {
    padding: 20,
    paddingBottom: 40,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 8,
    color: '#333',
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    marginBottom: 24,
  },
  inputGroup: {
    marginBottom: 20,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
    marginBottom: 8,
  },
  input: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    color: '#333',
  },
  pickerContainer: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    overflow: 'hidden',
  },
  picker: {
    height: 50,
  },
  errorContainer: {
    backgroundColor: '#ffebee',
    borderWidth: 1,
    borderColor: '#ef5350',
    borderRadius: 8,
    padding: 12,
    marginBottom: 20,
  },
  errorTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#d32f2f',
    marginBottom: 8,
  },
  errorText: {
    fontSize: 13,
    color: '#c62828',
    marginBottom: 4,
  },
  button: {
    backgroundColor: '#2196f3',
    paddingVertical: 14,
    paddingHorizontal: 20,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 16,
    minHeight: 50,
  },
  buttonDisabled: {
    backgroundColor: '#bdbdbd',
    opacity: 0.6,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  loadingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  requiredNote: {
    fontSize: 12,
    color: '#999',
    textAlign: 'center',
    marginTop: 8,
  },
})

export default ConfigurationScreen
