# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Updated project for Swift 6 and modern macOS compatibility (macOS 14+)
- Updated deployment targets to macOS 14.0 (Sonoma)
- Improved URL encoding for Giphy API search queries
- Modernized Swift concurrency patterns
- Removed pre-built app bundle from repository in favor of building from source
- Cleaned up unused example.com email validation boilerplate
- Removed unnecessary custom X-CustomHeader injection

### Added

- MIT License
- CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format
- Comprehensive .gitignore for Xcode/Swift projects
- DMG release for easy installation

### Fixed

- Build compatibility with Xcode 16+ and Swift 6
- Search queries with special characters now properly URL-encoded

## [1.0.0] - 2023-09-16

### Added

- Initial release of GIFMailSix macOS Mail extension
- Giphy search integration in Mail compose window
- GIF preview grid with collection view
- Drag-and-drop GIFs directly into email compose body
- Debounced search with 1-second delay to avoid excessive API calls
- App sandbox with network client entitlement for Giphy API access
- Giphy attribution icon in compose toolbar

[unreleased]: https://github.com/marctuinier/GiphyMailExtension/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/marctuinier/GiphyMailExtension/releases/tag/v1.0.0
