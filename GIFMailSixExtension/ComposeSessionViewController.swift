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

    var gifs: [Gif] = []
    let apiClient = APIClient()
    var searchTimer: Timer?
    let searchDelay: TimeInterval = 1.0

    private let itemSpacing: CGFloat = 2
    private let columns = 3

    private lazy var giphySearchBar: NSSearchField = {
        let sf = NSSearchField()
        sf.placeholderString = "Search GIFs..."
        sf.translatesAutoresizingMaskIntoConstraints = false
        sf.delegate = self
        return sf
    }()

    private lazy var scrollView: NSScrollView = {
        let sv = NSScrollView()
        sv.hasVerticalScroller = true
        sv.autohidesScrollers = true
        sv.hasHorizontalScroller = false
        sv.borderType = .noBorder
        sv.drawsBackground = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var giphyCollectionView: NSCollectionView = {
        let cv = NSCollectionView()
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = itemSpacing
        flowLayout.minimumLineSpacing = itemSpacing
        flowLayout.sectionInset = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cv.collectionViewLayout = flowLayout
        cv.isSelectable = true
        cv.backgroundColors = [.clear]
        cv.register(YourGifCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("YourGifCollectionViewItem"))
        cv.delegate = self
        cv.dataSource = self
        cv.registerForDraggedTypes([.fileURL])
        cv.autoresizingMask = [.width]
        return cv
    }()

    override func loadView() {
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 320, height: 320))
        container.translatesAutoresizingMaskIntoConstraints = false
        self.view = container
        self.preferredContentSize = NSSize(width: 320, height: 320)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 320),
            view.heightAnchor.constraint(equalToConstant: 320),
        ])

        view.addSubview(giphySearchBar)
        view.addSubview(scrollView)
        scrollView.documentView = giphyCollectionView

        NSLayoutConstraint.activate([
            giphySearchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            giphySearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            giphySearchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            scrollView.topAnchor.constraint(equalTo: giphySearchBar.bottomAnchor, constant: 6),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        loadTrending()
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        let clipWidth = scrollView.contentView.bounds.width
        if giphyCollectionView.frame.width != clipWidth {
            giphyCollectionView.setFrameSize(NSSize(width: clipWidth, height: giphyCollectionView.frame.height))
        }
        giphyCollectionView.collectionViewLayout?.invalidateLayout()
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
        return NSSize(width: max(side, 10), height: max(side, 10))
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
