//import UIKit
//import AVKit
//import AVFoundation
//
//class wordsDetailViewController: UIViewController {
//    
//    var word: Word?
//    var currentUserId: UUID?
//
//    @IBOutlet weak var wordNameLabel: UILabel!
//    @IBOutlet weak var wordDescriptionLabel: UILabel!
//    @IBOutlet weak var videoView: UIView!
//    @IBOutlet weak var gestureView: UIView!
//    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
//
//    let videoCapture = VideoCapture()
//    var previewLayer: AVCaptureVideoPreviewLayer?
//
//    let loader = UIActivityIndicatorView(style: .large)
//
//    
//    override func viewDidLoad() {
//        
//        super.viewDidLoad()
//        navigationController?.navigationBar.tintColor = .accent
//
//        loader.center = view.center
//        loader.hidesWhenStopped = true
//        view.addSubview(loader)
//
//        
//        if word == nil { return }
//                
//        if currentUserId == nil {
//            currentUserId = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
//        }
//                
//        setupDoneButton()
//        guard let word = word, let currentUserId = currentUserId else { return }
//
//        wordDescriptionLabel.text = word.wordDefinition
//        self.title = word.wordName
//
//        setupVideoPreview()
//        loadVideo(for: word)
//        updateBookmarkButton()
//    }
//    
//    private func setupVideoPreview() {
//        videoCapture.startCaptureSession()
//        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
//        guard let previewLayer = previewLayer else { return }
//
//        previewLayer.videoGravity = .resizeAspectFill
//    }
//    
//    private func updateBookmarkButton() {
//        guard let word = word, let currentUserId = currentUserId else { return }
//
//        Task {
//            let bookmarkedWords = await BookMarkedWords.sharedInstance.getBookmarkedWords()
//            let isBookmarked = bookmarkedWords.contains { $0.id == word.id }
//            bookmarkButton.image = UIImage(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
//        }
//    }
//
//
//    @IBAction func bookmarkBtnTapped(_ sender: UIBarButtonItem) {
//        guard let word = word, let currentUserId = currentUserId else { return }
//        
//        Task {
//            await BookMarkedWords.sharedInstance.toggleBookmarkedWords(word, for: currentUserId)
//            await updateBookmarkButton()
//            NotificationCenter.default.post(name: NSNotification.Name("BookmarksUpdated"), object: nil)
//        }
//    }
//    
//    private func loadVideo(for word: Word) {
//        let baseURL = "https://ydhprtlbxlswgcscajdd.supabase.co/storage/v1/object/public/words/"
//        guard let videoURL = URL(string: baseURL + word.videoURL) else {
//            print("Invalid video URL")
//            return
//        }
//
//        loader.startAnimating()
//
//        let asset = AVAsset(url: videoURL)
//        let playerItem = AVPlayerItem(asset: asset)
//
//        asset.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//
//                var error: NSError?
//                let status = asset.statusOfValue(forKey: "playable", error: &error)
//
//                if status == .loaded {
//                    let player = AVPlayer(playerItem: playerItem)
//                    let playerLayer = AVPlayerLayer(player: player)
//                    playerLayer.videoGravity = .resizeAspectFill
//                    playerLayer.frame = self.videoView.bounds
//
//                    self.videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
//                    self.videoView.layer.addSublayer(playerLayer)
//
//                    player.play()
//                } else {
//                    print("Error loading video: \(error?.localizedDescription ?? "Unknown error")")
//                }
//
//                self.loader.stopAnimating()
//            }
//        }
//    }
//
//    private func setupDoneButton() {
//        let doneButton = UIButton(type: .system)
//        doneButton.setTitle("Done", for: .normal)
//        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .semibold) // <-- bigger font
//        doneButton.setTitleColor(.white, for: .normal)
//        doneButton.backgroundColor = .accent
//        doneButton.layer.cornerRadius = 10
//        doneButton.translatesAutoresizingMaskIntoConstraints = false
//        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
//
//        view.addSubview(doneButton)
//
//        NSLayoutConstraint.activate([
//            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
//            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35),
//            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
//            doneButton.heightAnchor.constraint(equalToConstant: 50)
//        ])
//    }
//
//
//    @objc private func doneButtonTapped() {
//        navigationController?.popViewController(animated: true)
//    }
//
//}
//

import UIKit
import AVKit
import AVFoundation

class wordsDetailViewController: UIViewController {
    
    var word: Word?
    var currentUserId: UUID?

    @IBOutlet weak var wordNameLabel: UILabel!
    @IBOutlet weak var wordDescriptionLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var gestureView: UIView!
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!

    let videoCapture = VideoCapture()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer? 

    let loader = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .accent

        loader.center = view.center
        loader.hidesWhenStopped = true
        view.addSubview(loader)

        if word == nil { return }

        if currentUserId == nil {
            currentUserId = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
        }

        setupDoneButton()
        guard let word = word, let currentUserId = currentUserId else { return }

        wordDescriptionLabel.text = word.wordDefinition
        self.title = word.wordName

        setupVideoPreview()
        loadVideo(for: word)
        updateBookmarkButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoView.bounds // Ensures layer matches view size after layout
    }

    private func setupVideoPreview() {
        videoCapture.startCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
    }

    private func updateBookmarkButton() {
        guard let word = word, let currentUserId = currentUserId else { return }

        Task {
            let bookmarkedWords = await BookMarkedWords.sharedInstance.getBookmarkedWords()
            let isBookmarked = bookmarkedWords.contains { $0.id == word.id }
            bookmarkButton.image = UIImage(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
        }
    }

    @IBAction func bookmarkBtnTapped(_ sender: UIBarButtonItem) {
        guard let word = word, let currentUserId = currentUserId else { return }

        Task {
            await BookMarkedWords.sharedInstance.toggleBookmarkedWords(word, for: currentUserId)
            await updateBookmarkButton()
            NotificationCenter.default.post(name: NSNotification.Name("BookmarksUpdated"), object: nil)
        }
    }

    private func loadVideo(for word: Word) {
        let baseURL = "https://ydhprtlbxlswgcscajdd.supabase.co/storage/v1/object/public/words/"
        guard let videoURL = URL(string: baseURL + word.videoURL) else {
            print("Invalid video URL")
            return
        }

        loader.startAnimating()

        let asset = AVAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)

        asset.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }

                var error: NSError?
                let status = asset.statusOfValue(forKey: "playable", error: &error)

                if status == .loaded {
                    self.player = AVPlayer(playerItem: playerItem)         // Save player reference
                    let newPlayerLayer = AVPlayerLayer(player: self.player)
                    newPlayerLayer.videoGravity = .resizeAspectFill
                    newPlayerLayer.frame = self.videoView.bounds

                    self.videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                    self.videoView.layer.addSublayer(newPlayerLayer)
                    self.playerLayer = newPlayerLayer // Save it for resizing

                    // Add observer to loop video
                    NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(self.playerDidFinishPlaying),
                                                           name: .AVPlayerItemDidPlayToEndTime,
                                                           object: playerItem)

                    self.player?.play()
                } else {
                    print("Error loading video: \(error?.localizedDescription ?? "Unknown error")")
                }

                self.loader.stopAnimating()
            }
        }
    }

    @objc private func playerDidFinishPlaying(notification: Notification) {
        player?.seek(to: .zero)
        player?.play()
    }

    private func setupDoneButton() {
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = .accent
        doneButton.layer.cornerRadius = 10
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)

        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func doneButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
