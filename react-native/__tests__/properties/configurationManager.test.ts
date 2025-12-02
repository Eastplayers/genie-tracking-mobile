import fc from 'fast-check'
import {
  validateConfiguration,
  getApiUrl,
  ENVIRONMENT_URLS,
  TrackerConfiguration,
} from '../../../examples/react-native/src/configurationManager'

describe('Configuration Manager - Property-Based Tests', () => {
  // Generators for property-based testing
  const nonEmptyStringArb = fc
    .string({ minLength: 1 })
    .filter((s) => s.trim().length > 0)
  const environmentArb = fc.oneof(fc.constant('qc'), fc.constant('production'))
  const configurationArb = fc.record({
    apiKey: nonEmptyStringArb,
    brandId: nonEmptyStringArb,
    userId: fc.string(),
    environment: environmentArb,
  })

  describe('Property 2: QC Environment URL Mapping', () => {
    it('should return correct QC environment URL', () => {
      fc.assert(
        fc.property(fc.constant('qc'), (environment) => {
          const url = getApiUrl(environment as 'qc' | 'production')
          expect(url).toBe(ENVIRONMENT_URLS.qc)
          expect(url).toBe('https://tracking.api.qc.founder-os.ai/api')
        }),
        { numRuns: 100 }
      )
    })
  })

  describe('Property 3: Production Environment URL Mapping', () => {
    it('should return correct Production environment URL', () => {
      fc.assert(
        fc.property(fc.constant('production'), (environment) => {
          const url = getApiUrl(environment as 'qc' | 'production')
          expect(url).toBe(ENVIRONMENT_URLS.production)
          expect(url).toBe('https://tracking.api.founder-os.ai/api')
        }),
        { numRuns: 100 }
      )
    })
  })

  describe('Property 4: Validation Rejects Invalid Input', () => {
    it('should reject configuration with blank apiKey', () => {
      fc.assert(
        fc.property(
          fc.record({
            apiKey: fc.oneof(fc.constant(''), fc.constant('   ')),
            brandId: nonEmptyStringArb,
          }),
          (config) => {
            const result = validateConfiguration(config)
            expect(result.valid).toBe(false)
            expect(result.errors.length).toBeGreaterThan(0)
            expect(
              result.errors.some((e: string) => e.includes('API Key'))
            ).toBe(true)
          }
        ),
        { numRuns: 100 }
      )
    })

    it('should reject configuration with blank brandId', () => {
      fc.assert(
        fc.property(
          fc.record({
            apiKey: nonEmptyStringArb,
            brandId: fc.oneof(fc.constant(''), fc.constant('   ')),
          }),
          (config) => {
            const result = validateConfiguration(config)
            expect(result.valid).toBe(false)
            expect(result.errors.length).toBeGreaterThan(0)
            expect(
              result.errors.some((e: string) => e.includes('Brand ID'))
            ).toBe(true)
          }
        ),
        { numRuns: 100 }
      )
    })

    it('should reject configuration with both blank apiKey and brandId', () => {
      fc.assert(
        fc.property(
          fc.record({
            apiKey: fc.oneof(fc.constant(''), fc.constant('   ')),
            brandId: fc.oneof(fc.constant(''), fc.constant('   ')),
          }),
          (config) => {
            const result = validateConfiguration(config)
            expect(result.valid).toBe(false)
            expect(result.errors.length).toBe(2)
          }
        ),
        { numRuns: 100 }
      )
    })
  })

  describe('Property 5: Validation Accepts Valid Input', () => {
    it('should accept configuration with non-blank apiKey and brandId', () => {
      fc.assert(
        fc.property(
          fc.record({
            apiKey: nonEmptyStringArb,
            brandId: nonEmptyStringArb,
          }),
          (config) => {
            const result = validateConfiguration(config)
            expect(result.valid).toBe(true)
            expect(result.errors.length).toBe(0)
          }
        ),
        { numRuns: 100 }
      )
    })
  })
})
