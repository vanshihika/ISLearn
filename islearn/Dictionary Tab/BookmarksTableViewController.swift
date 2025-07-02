import UIKit

class BookmarksTableViewController: UITableViewController {

    private var emptyStateView: UIView!
    private var bookmarkedWords: [Word] = []
    private var currentUserId: UUID? {
        ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        setupEmptyStateView()
        setupNavigationBarAppearance()
        loadBookmarksFromSupabase()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadBookmarksFromSupabase()
    }

    private func setupNavigationBarAppearance() {
        if let navigationController = navigationController {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
    }

    private func loadBookmarksFromSupabase() {
        guard let userId = currentUserId else {
            print("🚨 ERROR: No logged in user.")
            return
        }

        Task {
            await BookMarkedWords.sharedInstance.fetchBookmarksFromSupabase(for: userId)
            await updateBookmarks() // <-- call the async version
        }
    }

    func updateBookmarks() async {
        let bookmarkedWords = BookMarkedWords.sharedInstance.getBookmarkedWords()
        self.bookmarkedWords = bookmarkedWords
        updateUI()
    }


    func updateUI() {
        emptyStateView.isHidden = !bookmarkedWords.isEmpty
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - TableView

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        bookmarkedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmark", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let word = bookmarkedWords[indexPath.row]
        content.text = word.wordName
        content.secondaryText = word.wordDefinition
        cell.contentConfiguration = content
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBookmarkDetail",
           let indexPath = tableView.indexPathForSelectedRow {
            let wordViewController = segue.destination as! DictionaryWordsViewController
            wordViewController.word = bookmarkedWords[indexPath.row]
        }
    }

    // MARK: - Empty State View

    private func setupEmptyStateView() {
        emptyStateView = UIView()
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            emptyStateView.heightAnchor.constraint(equalToConstant: 200)
        ])

        let imageView = UIImageView(image: UIImage(systemName: "bookmark.slash"))
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(imageView)

        let messageLabel = UILabel()
        messageLabel.text = "No bookmarks yet!\nStart saving your favorite words."
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 2
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = .gray
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),

            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor)
        ])
    }
}
