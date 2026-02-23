# GiphyMailExtension

A native macOS Mail extension that lets you search and insert GIFs from [Giphy](https://giphy.com) directly into your emails.

![Demo](home-gif.gif)

## Features

- Search the entire Giphy library from within Mail's compose window
- Preview GIF results in a scrollable grid
- Drag and drop GIFs directly into your email
- Debounced search to keep things responsive
- Sandboxed and privacy-respecting — only makes network requests to the Giphy API

## Requirements

- macOS 14.0 (Sonoma) or later
- Apple Mail

## Installation

### From DMG (recommended)

1. Download the latest `.dmg` from [Releases](https://github.com/marctuinier/GiphyMailExtension/releases)
2. Open the DMG and drag **GIFMailSix** to your Applications folder
3. Launch GIFMailSix once to register the extension
4. Open **System Settings → General → Login Items & Extensions → Mail Extensions**
5. Enable **GIFMailSixExtension**

### From Source

1. Clone this repository
2. Open `GIFMailSix.xcodeproj` in Xcode
3. Build and run the `GIFMailSix` scheme
4. Enable the extension in System Settings as described above

## Usage

1. Open Apple Mail and compose a new message
2. Click the **Giphy** icon in the compose toolbar
3. Type your search query
4. Click and drag a GIF into the email body

## Tech Stack

- **Swift** — 100%
- **MailKit** — Apple's framework for Mail extensions
- **Giphy API** — GIF search and retrieval
- **AppKit** — `NSCollectionView` for the GIF grid, `NSDraggingSource` for drag-and-drop

## Project Structure

```
GIFMailSix/                     # Host application (SwiftUI)
├── GIFMailSixApp.swift
└── ContentView.swift

GIFMailSixExtension/            # Mail extension (AppKit + MailKit)
├── MailExtension.swift         # MEExtension entry point
├── ComposeSessionHandler.swift # MEComposeSessionHandler
├── ComposeSessionViewController.swift
├── APIClient.swift             # Giphy API client
├── YourGifCollectionViewItem.swift
└── Info.plist
```

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## Attribution

GIF search powered by [Giphy](https://giphy.com).
