package ai.founderos.mobiletracker.example

/**
 * Environment selection for the MobileTracker SDK
 */
enum class Environment {
    QC,
    PRODUCTION;

    /**
     * Returns a user-friendly string representation for display in UI
     */
    override fun toString(): String = when (this) {
        QC -> "QC"
        PRODUCTION -> "Production"
    }
}
