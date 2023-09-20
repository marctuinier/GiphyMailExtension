//
//  YourGifCollectionViewItem.swift
//  GIFMailSixExtension
//
//  Created by Marc Tuinier on 9/16/23.
//

import Cocoa

class YourGifCollectionViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var gifImageView: NSImageView!
    
    var gif: Gif? // Store the gif for later use in drag-and-drop
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("YourGifCollectionViewItem loaded")
        self.view.registerForDraggedTypes([.fileURL]) // Register for drag operations
    }
    
    func configure(with gif: Gif) {
        self.gif = gif // Save the gif
        let url = gif.url
        print("Attempting to load GIF from URL: \(url)")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error loading image: \(error)")
                return
            }

            if let data = data, let image = NSImage(data: data) {
                DispatchQueue.main.async {
                    self.gifImageView?.canDrawSubviewsIntoLayer = true
                    self.gifImageView?.image = image
                    print("Successfully loaded and displayed GIF")
                }
            } else {
                print("Could not initialize NSImage with data")
            }
        }.resume()
    }
    
    // Implement the mouseDown function for drag-and-drop
    override func mouseDown(with event: NSEvent) {
        guard let collectionView = self.collectionView else {
            print("CollectionView is nil")
            return
        }
        
        guard collectionView.indexPath(for: self) != nil else {
            print("Could not get indexPath")
            return
        }
        
        guard let draggingSource = collectionView.delegate as? NSCollectionViewDelegate & NSDraggingSource else {
            print("Delegate does not conform to NSDraggingSource")
            return
        }
        
        guard let gifData = try? Data(contentsOf: self.gif!.url) else {
            print("Failed to get GIF data")
            return
        }
        
        do {
            // Create a temporary file to hold the GIF data
            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
            let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("gif")
            try gifData.write(to: temporaryFileURL)
            
            // Create a pasteboard item with the URL data
            let pasteboardItem = NSPasteboardItem()
            if let urlData = temporaryFileURL.absoluteString.data(using: .utf8) {
                pasteboardItem.setData(urlData, forType: .fileURL)
            }
            
            // Create a dragging item and start the session
            let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
            draggingItem.setDraggingFrame(self.view.bounds, contents: self.view)
            
            _ = collectionView.beginDraggingSession(with: [draggingItem], event: event, source: draggingSource)
            print("Started dragging session")
        } catch {
            print("Error creating temporary file: \(error)")
        }
    }
}
