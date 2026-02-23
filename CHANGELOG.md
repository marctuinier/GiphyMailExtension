# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2026-02-23

### Changed

- Rewrote extension UI to be fully programmatic (no XIB/NIB dependency)
- Search bar and GIF grid now fill the entire extension panel edge-to-edge
- Collection view items dynamically size to fill available width in a 3-column grid
- Adopted Auto Layout for search bar and scroll view positioning
- Used frame-based autoresizing for collection view inside scroll view (fixes layout issues)
- Eliminated Mail's XIB caching issues by removing dependency on Interface Builder files

### Fixed

- GIF grid no longer renders as tiny circles or a single column
- No more dead space on sides or bottom of the extension panel
- Extension layout now reliably matches the designed size on every launch

## [1.1.0] - 2026-02-23

### Added

- MIT License
- CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format
- Comprehensive .gitignore for Xcode/Swift projects
- DMG release for easy installation

### Changed

- Renamed app from "GIFMailSix" to "Gif Mail"
- Updated extension display name to "Gif Mail Extension"
- Updated project for Swift 6 and modern macOS compatibility (macOS 14+)
- Updated deployment targets to macOS 14.0 (Sonoma)
- Improved URL encoding for Giphy API search queries
- Modernized Swift concurrency patterns
- Removed pre-built app bundle from repository in favor of building from source
- Cleaned up unused example.com email validation boilerplate
- Removed unnecessary custom X-CustomHeader injection

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

[unreleased]: https://github.com/marctuinier/GiphyMailExtension/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/marctuinier/GiphyMailExtension/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/marctuinier/GiphyMailExtension/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/marctuinier/GiphyMailExtension/releases/tag/v1.0.0
