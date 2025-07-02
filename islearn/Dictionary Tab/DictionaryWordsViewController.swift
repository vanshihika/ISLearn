//import UIKit
//import AVKit
//import AVFoundation
//
//class DictionaryWordsViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
//
//    @IBOutlet weak var wordNameLabel: UILabel!
//    @IBOutlet weak var wordDescriptionLabel: UILabel!
//    @IBOutlet weak var videoView: UIView!
//    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
//    @IBOutlet weak var gestureCameraView: UIView!
//
//    let videoCapture = VideoCapture()
//    var previewLayer: AVCaptureVideoPreviewLayer?
//    
//    var word: Word?
//    var userId: UUID = UUID()
//    var currentUserId: UUID?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        guard let word = word else { return }
//        
//        if let userProfile = ProfileDataModel.sharedInstance.getCurrentUserProfile() {
//            currentUserId = userProfile.id
//            print("✅ Using current user ID: \(currentUserId!)")
//        } else {
//            currentUserId = UUID()
//            print("⚠️ No user logged in! Using dummy ID: \(currentUserId!)")
//        }
//        
//        wordDescriptionLabel.text = word.wordDefinition
//        self.title = word.wordName
//        
//        setupVideoPreview()
//        loadVideo(for: word)
//        
//        Task {
//            await updateBookmarkButton()
//        }
//    }
//
//    
//    private func setupVideoPreview() {
//        videoCapture.startCaptureSession()
//        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
//        guard let previewLayer = previewLayer else { return }
//        
//        previewLayer.videoGravity = .resizeAspectFill
//    }
//    
//    private func loadVideo(for word: Word) {
//        let baseURL = "https://ydhprtlbxlswgcscajdd.supabase.co/storage/v1/object/public/words/"
//        guard let videoURL = URL(string: baseURL + word.videoURL) else {
//            print("❌ Invalid video URL")
//            return
//        }
//
//        print("✅ Loading remote video URL: \(videoURL)")
//
//        let player = AVPlayer(url: videoURL)
//        let playerLayer = AVPlayerLayer(player: player)
//
//        playerLayer.videoGravity = .resizeAspectFill
//        playerLayer.frame = videoView.bounds
//
//        videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
//        videoView.layer.addSublayer(playerLayer)
//
//        player.play()
//    }
//
//    
//    private func updateBookmarkButton() async {
//        guard let word = word, let currentUserId = currentUserId else { return }
//        
//        let bookmarkedWords = await BookMarkedWords.sharedInstance.getBookmarkedWords()
//
//        let isBookmarked = bookmarkedWords.contains { $0.id == word.id }
//
//        bookmarkButton.image = UIImage(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
//    }
//
//
//    @IBAction func bookmarkBtnTapped(_ sender: UIBarButtonItem) {
//        guard let word = word, let currentUserId = currentUserId else { return }
//    
//        Task {
//            await BookMarkedWords.sharedInstance.toggleBookmarkedWords(word, for: currentUserId)
//        
//            await updateBookmarkButton()
//           
//            NotificationCenter.default.post(name: NSNotification.Name("BookmarksUpdated"), object: nil)
//        }
//    }
//}

import UIKit
import AVKit
import AVFoundation

class DictionaryWordsViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var wordNameLabel: UILabel!
    @IBOutlet weak var wordDescriptionLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    @IBOutlet weak var gestureCameraView: UIView!

    let videoCapture = VideoCapture()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var word: Word?
    var userId: UUID = UUID()
    var currentUserId: UUID?
    
    private var player: AVPlayer?  // Keep reference to AVPlayer

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let word = word else { return }
        
        if let userProfile = ProfileDataModel.sharedInstance.getCurrentUserProfile() {
            currentUserId = userProfile.id
            print("✅ Using current user ID: \(currentUserId!)")
        } else {
            currentUserId = UUID()
            print("⚠️ No user logged in! Using dummy ID: \(currentUserId!)")
        }
        
        wordDescriptionLabel.text = word.wordDefinition
        self.title = word.wordName
        
        setupVideoPreview()
        loadVideo(for: word)
        
        Task {
            await updateBookmarkButton()
        }
    }

    
    private func setupVideoPreview() {
        videoCapture.startCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
        guard let previewLayer = previewLayer else { return }
        
        previewLayer.videoGravity = .resizeAspectFill
    }
    
    private func loadVideo(for word: Word) {
        let baseURL = "https://ydhprtlbxlswgcscajdd.supabase.co/storage/v1/object/public/words/"
        guard let videoURL = URL(string: baseURL + word.videoURL) else {
            print("❌ Invalid video URL")
            return
        }

        print("✅ Loading remote video URL: \(videoURL)")

        player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)

        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = videoView.bounds

        videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        videoView.layer.addSublayer(playerLayer)

        // Remove previous observers before adding new one
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)

        player?.play()
    }

    @objc private func playerDidFinishPlaying(notification: Notification) {
        player?.seek(to: .zero)
        player?.play()
    }
    
    private func updateBookmarkButton() async {
        guard let word = word, let currentUserId = currentUserId else { return }
        
        let bookmarkedWords = await BookMarkedWords.sharedInstance.getBookmarkedWords()

        let isBookmarked = bookmarkedWords.contains { $0.id == word.id }

        bookmarkButton.image = UIImage(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
    }


    @IBAction func bookmarkBtnTapped(_ sender: UIBarButtonItem) {
        guard let word = word, let currentUserId = currentUserId else { return }
    
        Task {
            await BookMarkedWords.sharedInstance.toggleBookmarkedWords(word, for: currentUserId)
        
            await updateBookmarkButton()
           
            NotificationCenter.default.post(name: NSNotification.Name("BookmarksUpdated"), object: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

