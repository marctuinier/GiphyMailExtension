//
//  YourGifCollectionViewItem.swift
//  GIFMailSixExtension
//
//  Created by Marc Tuinier on 9/16/23.
//

import Cocoa

class YourGifCollectionViewItem: NSCollectionViewItem {

    @IBOutlet weak var gifImageView: NSImageView!

    var gif: Gif?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.registerForDraggedTypes([.fileURL])
    }

    func configure(with gif: Gif) {
        self.gif = gif

        URLSession.shared.dataTask(with: gif.url) { [weak self] data, _, error in
            guard error == nil, let data = data, let image = NSImage(data: data) else { return }

            DispatchQueue.main.async {
                self?.gifImageView?.image = image
            }
        }.resume()
    }

    override func mouseDown(with event: NSEvent) {
        guard let collectionView = self.collectionView,
              collectionView.indexPath(for: self) != nil,
              let draggingSource = collectionView.delegate as? NSCollectionViewDelegate & NSDraggingSource,
              let gif = self.gif,
              let gifData = try? Data(contentsOf: gif.url) else { return }

        do {
            let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
            let tempFile = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("gif")
            try gifData.write(to: tempFile)

            let pasteboardItem = NSPasteboardItem()
            if let urlData = tempFile.absoluteString.data(using: .utf8) {
                pasteboardItem.setData(urlData, forType: .fileURL)
            }

            let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
            draggingItem.setDraggingFrame(self.view.bounds, contents: self.view)

            _ = collectionView.beginDraggingSession(with: [draggingItem], event: event, source: draggingSource)
        } catch {
            print("Error creating temporary file: \(error)")
        }
    }
}
