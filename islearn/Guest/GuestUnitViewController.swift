import UIKit
import AVKit
import AVFoundation

class GuestUnitViewController: UIViewController {
    
    @IBOutlet weak var buttonTitle: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var completedButton: UIButton!
    
    var exercise: Exercise?
    var sectionTitle: String?
    
    var videoPlayer: AVPlayer?
    var videoPlayerLayer: AVPlayerLayer?
    
    var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        
        guard let exercise = exercise, let sectionTitle = sectionTitle else { return }
        
        buttonTitle.text = exercise.name
        navigationItem.title = sectionTitle
        
        completedButton.setTitle("Mark as Completed", for: .normal)
        completedButton.isEnabled = true
        
        setupVideoPlayer()
    }
    deinit {
        videoPlayer?.currentItem?.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self)
    }

    func setupVideoPlayer() {
        guard videoPlayer == nil else { return }
        guard let exercise = exercise, let sectionTitle = sectionTitle else { return }

        // Start loading
        activityIndicator.startAnimating()

        let videoPlayer = AVPlayer()
        let videoPlayerLayer = AVPlayerLayer(player: videoPlayer)

        videoPlayerLayer.videoGravity = .resizeAspectFill
        videoPlayerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(videoPlayerLayer)

        self.videoPlayer = videoPlayer
        self.videoPlayerLayer = videoPlayerLayer

        let fileName = "\(exercise.name).mp4"
        let bucketName = sectionTitle.lowercased()
        let baseURL = "https://ydhprtlbxlswgcscajdd.supabase.co/storage/v1/object/public"
        let videoURLString = "\(baseURL)/\(bucketName)/\(fileName)"

        guard let videoURL = URL(string: videoURLString) else {
            print("❌ Invalid video URL")
            activityIndicator.stopAnimating()
            return
        }

        let playerItem = AVPlayerItem(url: videoURL)
        self.videoPlayer?.replaceCurrentItem(with: playerItem)

        // Observe status to hide indicator when ready
        playerItem.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }


    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "status",
           let playerItem = object as? AVPlayerItem,
           playerItem.status == .readyToPlay {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.videoPlayer?.play()
            }
        } else if let playerItem = object as? AVPlayerItem,
                  playerItem.status == .failed {
            print("❌ Video failed to load")
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
    }


    
    @objc func videoDidEnd(notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem else { return }
        playerItem.seek(to: CMTime.zero)
        videoPlayer?.play()
    }
    
    @IBSegueAction func toNextUnit(_ coder: NSCoder, sender: Any?) -> GuestUnitViewController? {
        let nextVC = GuestUnitViewController(coder: coder)
        nextVC!.sectionTitle = (sender as! [Any])[1] as! String
        nextVC!.exercise = (sender as! [Any])[0] as! Exercise
//        nextVC!.currentUserId = (sender as! [Any])[2] as! UUID
        return nextVC
    }

    @IBAction func markAsCompletedTapped(_ sender: UIButton) {
        // Guests can't mark real completion, just show a success message.
        let alert = UIAlertController(title: "Oops!", message: "To make progress, sign up.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
    }
    
}
