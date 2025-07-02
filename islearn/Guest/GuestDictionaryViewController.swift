//
//  GuestDictionaryViewController.swift
//  islearn
//
//  Created by Vanshika Choudhary on 8/5/25.
//

import UIKit

class GuestDictionaryViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    
    private var allWords: [Word] = []
    private var filteredWords: [Word] = []
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search words"
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "WordCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Dictionary"
        navigationItem.largeTitleDisplayMode = .always

        setupViews()
        setupConstraints()
        loadWords()
    }
    
    private func setupViews() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor) // fixed!
        ])
    }

    
    private func loadWords() {
        WordDataModel.sharedInstance.fetchWordsFromBackend { [weak self] result in
            switch result {
            case .success(let words):
                self?.allWords = words
                self?.filteredWords = words
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch words: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let word = filteredWords[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = word.wordName
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let alert = UIAlertController(
                title: "Oops!",
                message: "To look up a word, sign up.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
    }
    
    // MARK: - SearchBar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredWords = allWords
        } else {
            filteredWords = allWords.filter {
                $0.wordName.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
    
    
    @IBAction func bookmarkButtonClicked(_ sender: Any) {
        let alert = UIAlertController(
                title: "Oops!",
                message: "To make progress, sign up.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredWords = allWords
        tableView.reloadData()
    }
}
