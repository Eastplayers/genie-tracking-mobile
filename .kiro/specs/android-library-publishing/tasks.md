# Implementation Plan

- [x] 1. Set up basic Maven publishing configuration

  - Add `maven-publish` plugin to android/build.gradle
  - Configure publication with AAR artifact
  - Define library metadata (groupId, artifactId, version)
  - _Requirements: 1.1, 1.2_

- [x] 2. Configure POM metadata

  - Add library name, description, and URL
  - Configure license information (MIT)
  - Add developer information
  - Add SCM (source control management) URLs
  - _Requirements: 2.3_

- [x] 3. Set up local Maven publishing

  - Configure mavenLocal() repository
  - Create publishToMavenLocal task
  - Test publishing to ~/.m2/repository
  - _Requirements: 4.1, 4.2, 4.4_

- [x] 4. Configure test consumer project

  - Use existing examples/android project as test consumer
  - Add mavenLocal() repository to build.gradle
  - Add gradle.properties flag to switch between project reference and Maven dependency
  - Update build.gradle to support both: `implementation project(':android')` and `implementation 'ai.founderos:mobile-tracking-sdk:0.1.0'`
  - Test with Maven dependency and verify library classes are accessible
  - Document how to switch between local project and published library modes
  - _Requirements: 4.5_

- [x] 5. Configure sources and javadoc JARs

  - Add task to generate sources JAR
  - Add task to generate javadoc JAR
  - Include both JARs in publication
  - _Requirements: 1.3_

- [x] 6. Set up JitPack compatibility

  - Ensure group and version are properly configured
  - Create jitpack.yml with JDK configuration
  - Add JitPack badge to README
  - _Requirements: 3.3_

- [x] 7. Create version management system

  - Extract version to gradle.properties
  - Create version validation
  - Document semantic versioning guidelines
  - _Requirements: 1.5_

- [ ] 8. Update README with JitPack instructions

  - Add JitPack repository configuration example
  - Add JitPack dependency declaration
  - Add instructions for creating release tags
  - Document version resolution
  - _Requirements: 5.1, 5.2, 5.3_

- [ ]\* 9. Configure Maven Central publishing (optional)

  - Add signing plugin configuration
  - Configure Sonatype OSSRH repository
  - Add credential management from gradle.properties
  - Create closeAndReleaseRepository task
  - _Requirements: 2.1, 2.2, 2.4_

- [ ] 10. Create publishing documentation

  - Create PUBLISHING.md with step-by-step guides
  - Document each publishing method
  - Add troubleshooting section
  - Create release checklist
  - _Requirements: 5.1, 5.2, 5.4_

- [ ] 11. Test complete publishing workflow
  - Publish to local Maven and verify
  - Create Git tag and test JitPack build
  - Verify consumer can use published library
  - Test with ProGuard/R8 enabled
  - _Requirements: 1.4, 3.4, 4.2_
