//
//  ComposeSessionViewController
//  GIFMailSixExtension
//
//  Created by Marc Tuinier on 9/16/23.
//

import Cocoa
import MailKit

// Data model for GIFs
struct Gif {
    let url: URL
    // Add other fields as needed
}

class ComposeSessionViewController: MEExtensionViewController, NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout, NSDraggingSource, NSSearchFieldDelegate {
    
    // MARK: Properties and Outlets
    
    @IBOutlet weak var giphySearchBar: NSSearchField!
    @IBOutlet weak var giphyCollectionView: NSCollectionView!
    
    var gifs: [Gif] = []
    let apiClient = APIClient()
    
    // Timer to delay API request
    var searchTimer: Timer?
    let searchDelay: TimeInterval = 1.0 // Adjust this interval as needed
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register item
        giphyCollectionView.register(YourGifCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("YourGifCollectionViewItem"))
        
        // Assign delegate and data source
        giphyCollectionView.delegate = self
        giphyCollectionView.dataSource = self

        // Register for drag-and-drop
        giphyCollectionView.registerForDraggedTypes([.fileURL])
        
        // Set up search field delegate
        giphySearchBar.delegate = self
    }
    
    // MARK: Giphy API Fetch
    
    // Function to fetch GIFs after a delay
    func fetchGiphy(withQuery query: String) {
        // Cancel the previous timer if it exists
        searchTimer?.invalidate()
        
        // Start a new timer with the specified delay
        searchTimer = Timer.scheduledTimer(withTimeInterval: searchDelay, repeats: false) { [weak self] _ in
            // Check if the query is empty before proceeding
            guard !query.isEmpty else {
                print("Query is empty, not proceeding with fetch.")
                return
            }
            
            print("Starting Giphy fetch for query: \(query)")
            
            self?.apiClient.fetchGiphy(withQuery: query) { result in
                switch result {
                case .success(let newGifUrls):
                    self?.gifs = newGifUrls.compactMap { urlString in
                        guard let url = URL(string: urlString) else { return nil }
                        return Gif(url: url)
                    }
                    
                    DispatchQueue.main.async {
                        self?.giphyCollectionView.reloadData()
                        print("Reloaded collection view with new GIFs")  // Print statement for debugging
                    }
                case .failure(let error):
                    print("Failed to fetch GIFs: \(error)")
                }
            }
        }
    }
    
    // MARK: NSSearchFieldDelegate
    
    func controlTextDidChange(_ obj: Notification) {
        if let searchField = obj.object as? NSSearchField {
            // Start the timer when text changes
            fetchGiphy(withQuery: searchField.stringValue)
        }
    }
    
    // MARK: NSCollectionViewDataSource
    
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
    
    // MARK: NSCollectionViewDelegate
    
    func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexPaths: Set<IndexPath>, with event: NSEvent) -> Bool {
        return true
    }

    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        let gif = gifs[indexPath.item]
        
        // Use the GIF data for drag-and-drop
        if let gifData = try? Data(contentsOf: gif.url) {
            let pasteboardItem = NSPasteboardItem()
            pasteboardItem.setData(gifData, forType: .fileURL)
            return pasteboardItem
        }
        
        return nil
    }
    
    // MARK: NSDraggingSource
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .copy // Allow copy operation
    }
    
    // MARK: NSCollectionViewDelegateFlowLayout
    
    // Add methods here to customize layout if needed
}
