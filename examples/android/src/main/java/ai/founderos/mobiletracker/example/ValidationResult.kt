package ai.founderos.mobiletracker.example

/**
 * Sealed class representing the result of validation
 */
sealed class ValidationResult {
    /**
     * Indicates that validation passed
     */
    object Valid : ValidationResult()

    /**
     * Indicates that validation failed with an error message
     * 
     * @property message The error message describing what validation failed
     */
    data class Error(val message: String) : ValidationResult()
}
