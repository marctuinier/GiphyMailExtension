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

    private let itemSpacing: CGFloat = 4
    private let columns = 2

    override func viewDidLoad() {
        super.viewDidLoad()

        giphyCollectionView.register(YourGifCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("YourGifCollectionViewItem"))
        giphyCollectionView.delegate = self
        giphyCollectionView.dataSource = self
        giphyCollectionView.registerForDraggedTypes([.fileURL])
        giphySearchBar.delegate = self

        loadTrending()
    }

    // MARK: - Data Loading

    private func loadTrending() {
        apiClient.fetchTrending { [weak self] result in
            self?.handleFetchResult(result)
        }
    }

    func fetchGiphy(withQuery query: String) {
        searchTimer?.invalidate()

        searchTimer = Timer.scheduledTimer(withTimeInterval: searchDelay, repeats: false) { [weak self] _ in
            guard !query.isEmpty else {
                self?.loadTrending()
                return
            }

            self?.apiClient.fetchGiphy(withQuery: query) { [weak self] result in
                self?.handleFetchResult(result)
            }
        }
    }

    private func handleFetchResult(_ result: Result<[String], Error>) {
        switch result {
        case .success(let newGifUrls):
            let newGifs = newGifUrls.compactMap { urlString -> Gif? in
                guard let url = URL(string: urlString) else { return nil }
                return Gif(url: url)
            }
            DispatchQueue.main.async { [weak self] in
                self?.gifs = newGifs
                self?.giphyCollectionView.reloadData()
            }
        case .failure(let error):
            print("Failed to fetch GIFs: \(error)")
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

    // MARK: - NSCollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let totalSpacing = itemSpacing * CGFloat(columns - 1)
        let availableWidth = collectionView.bounds.width - totalSpacing
        let side = floor(availableWidth / CGFloat(columns))
        return NSSize(width: side, height: side)
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
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

    // MARK: - Double-Click to Insert

    func insertGif(at indexPath: IndexPath) {
        let gif = gifs[indexPath.item]

        DispatchQueue.global(qos: .userInitiated).async {
            guard let gifData = try? Data(contentsOf: gif.url) else { return }

            let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
            let tempFile = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("gif")

            guard let _ = try? gifData.write(to: tempFile) else { return }

            DispatchQueue.main.async {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.writeObjects([tempFile as NSURL])

                let fakeEvent = NSEvent.keyEvent(
                    with: .keyDown,
                    location: .zero,
                    modifierFlags: .command,
                    timestamp: ProcessInfo.processInfo.systemUptime,
                    windowNumber: 0,
                    context: nil,
                    characters: "v",
                    charactersIgnoringModifiers: "v",
                    isARepeat: false,
                    keyCode: 9
                )

                if let event = fakeEvent {
                    NSApp.sendEvent(event)
                }
            }
        }
    }
}
