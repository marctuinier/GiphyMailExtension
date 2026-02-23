//
//  ComposeSessionViewController
//  GIFMailSixExtension
//
//  Created by Marc Tuinier on 9/16/23.
//

import Cocoa
import MailKit

struct Gif {
    let url: URL
}

class ComposeSessionViewController: MEExtensionViewController, NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout, NSDraggingSource, NSSearchFieldDelegate {

    @IBOutlet weak var giphySearchBar: NSSearchField!
    @IBOutlet weak var giphyCollectionView: NSCollectionView!

    var gifs: [Gif] = []
    let apiClient = APIClient()
    var searchTimer: Timer?
    let searchDelay: TimeInterval = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()

        giphyCollectionView.register(YourGifCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("YourGifCollectionViewItem"))
        giphyCollectionView.delegate = self
        giphyCollectionView.dataSource = self
        giphyCollectionView.registerForDraggedTypes([.fileURL])
        giphySearchBar.delegate = self
    }

    func fetchGiphy(withQuery query: String) {
        searchTimer?.invalidate()

        searchTimer = Timer.scheduledTimer(withTimeInterval: searchDelay, repeats: false) { [weak self] _ in
            guard !query.isEmpty else { return }

            self?.apiClient.fetchGiphy(withQuery: query) { [weak self] result in
                switch result {
                case .success(let newGifUrls):
                    let newGifs = newGifUrls.compactMap { urlString -> Gif? in
                        guard let url = URL(string: urlString) else { return nil }
                        return Gif(url: url)
                    }
                    DispatchQueue.main.async {
                        self?.gifs = newGifs
                        self?.giphyCollectionView.reloadData()
                    }
                case .failure(let error):
                    print("Failed to fetch GIFs: \(error)")
                }
            }
        }
    }

    // MARK: - NSSearchFieldDelegate

    func controlTextDidChange(_ obj: Notification) {
        if let searchField = obj.object as? NSSearchField {
            fetchGiphy(withQuery: searchField.stringValue)
        }
    }

    // MARK: - NSCollectionViewDataSource

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("YourGifCollectionViewItem"), for: indexPath)
        if let gifItem = item as? YourGifCollectionViewItem {
            gifItem.configure(with: gifs[indexPath.item])
        }
        return item
    }

    // MARK: - NSCollectionViewDelegate

    func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexPaths: Set<IndexPath>, with event: NSEvent) -> Bool {
        return true
    }

    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> (any NSPasteboardWriting)? {
        let gif = gifs[indexPath.item]

        if let gifData = try? Data(contentsOf: gif.url) {
            let pasteboardItem = NSPasteboardItem()
            pasteboardItem.setData(gifData, forType: .fileURL)
            return pasteboardItem
        }

        return nil
    }

    // MARK: - NSDraggingSource

    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .copy
    }
}
