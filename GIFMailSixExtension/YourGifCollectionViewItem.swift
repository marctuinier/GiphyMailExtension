//
//  YourGifCollectionViewItem.swift
//  GIFMailSixExtension
//
//  Created by Marc Tuinier on 9/16/23.
//

import Cocoa

class YourGifCollectionViewItem: NSCollectionViewItem {

    var gifImageView: NSImageView!
    var gif: Gif?

    override func loadView() {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.cornerRadius = 4
        container.layer?.masksToBounds = true

        let iv = NSImageView()
        iv.imageScaling = .scaleAxesIndependently
        iv.imageAlignment = .alignCenter
        iv.animates = true
        iv.wantsLayer = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iv)

        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: container.topAnchor),
            iv.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            iv.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        self.view = container
        self.gifImageView = iv
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

    override func prepareForReuse() {
        super.prepareForReuse()
        gifImageView?.image = nil
        gif = nil
    }

    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            guard let collectionView = self.collectionView,
                  let indexPath = collectionView.indexPath(for: self),
                  let controller = collectionView.delegate as? ComposeSessionViewController else { return }
            controller.insertGif(at: indexPath)
            return
        }

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
