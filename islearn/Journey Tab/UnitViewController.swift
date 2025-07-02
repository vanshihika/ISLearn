//import UIKit
//import AVKit
//import AVFoundation
//
//class UnitViewController: UIViewController {
//    
//    @IBOutlet weak var buttonTitle: UILabel!
//    @IBOutlet weak var videoView: UIView!
//    @IBOutlet weak var completedButton: UIButton!
//    
//    var exercise: Exercise?
//    var sectionTitle: String?
//    var currentUserId: UUID?
//    
//    var videoPlayer: AVPlayer?
//    var videoPlayerLayer: AVPlayerLayer?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .black
//
//        guard let currentUserId = currentUserId, let exercise = exercise, let sectionTitle = sectionTitle else { return }
//
//        buttonTitle.text = exercise.name
//        navigationItem.title = sectionTitle
//
//        Task {
//            let isCompleted = await JourneyDataModel.shared.isExerciseCompleted(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)
//            let isLocked = await JourneyDataModel.shared.isExerciseLocked(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)
//
//            completedButton.isEnabled = !isCompleted && !isLocked
//            completedButton.setTitle(isCompleted ? "Completed" : "Mark as Completed", for: .normal)
//        }
//
//        setupVideoPlayer()
//    }
//
//    
//    func setupVideoPlayer() {
//        guard videoPlayer == nil else { return }
//        guard let exercise = exercise, let sectionTitle = sectionTitle else { return }
//
//        let videoPlayer = AVPlayer()
//        let videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
//
//        videoPlayerLayer.videoGravity = .resizeAspectFill
//        videoPlayerLayer.frame = videoView.bounds
//        videoView.layer.addSublayer(videoPlayerLayer)
//
//        self.videoPlayer = videoPlayer
//        self.videoPlayerLayer = videoPlayerLayer
//
//        let fileName = "\(exercise.name).mp4"
//        let bucketName = sectionTitle.lowercased()
//
//        let baseURL = "https://ydhprtlbxlswgcscajdd/storage/v1/object/public"
//        let videoURLString = "\(baseURL)/\(bucketName)/\(fileName)"
//
//        guard let videoURL = URL(string: videoURLString) else { return }
//
//        let playerItem = AVPlayerItem(url: videoURL)
//        self.videoPlayer?.replaceCurrentItem(with: playerItem)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
//
//        self.videoPlayer?.rate = 1.0
//        self.videoPlayer?.play()
//    }
//
//    @objc func videoDidEnd(notification: Notification) {
//        guard let playerItem = notification.object as? AVPlayerItem else { return }
//        playerItem.seek(to: CMTime.zero)
//        videoPlayer?.play()
//    }
//
//    @IBAction func markAsCompletedTapped(_ sender: UIButton) {
//        Task {
//            guard let currentUserId = currentUserId,
//                  let exercise = exercise,
//                  let sectionTitle = sectionTitle else {
//                return
//            }
//
//            do {
//                let completed = try await JourneyDataModel.shared.isExerciseCompleted(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)
//
//                if completed { return }
//
//                try await JourneyDataModel.shared.completeExercise(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)
//                try await AchievementDataModel.sharedInstance.updateProgress(achievementId: 1, increment: 1)
//                try await ProfileDataModel.sharedInstance.addLearnedSign(for: currentUserId, newSign: exercise.name)
//                try await ProfileDataModel.sharedInstance.updateWordsLearnedCount(for: currentUserId)
//                await ProfileDataModel.sharedInstance.updateCurrentStreak(for: currentUserId)
//
//                DispatchQueue.main.async {
//                    sender.setTitle("Completed", for: .normal)
//                    sender.isEnabled = false
//                }
//
//                let userJourney = try await JourneyDataModel.shared.getJourney(for: currentUserId)
//
//                if let section = userJourney.section.first(where: { $0.title == sectionTitle }),
//                   let exerciseIndex = section.exercises.firstIndex(where: { $0.name == exercise.name }),
//                   exerciseIndex + 1 < section.exercises.count {
//                    
//                    let nextExercise = section.exercises[exerciseIndex + 1]
//
//                    let isLocked = try await JourneyDataModel.shared.isExerciseLocked(for: currentUserId, sectionTitle: sectionTitle, exerciseName: nextExercise.name)
//
//                    if isLocked {
//                        try await JourneyDataModel.shared.unlockNextExercise(for: currentUserId, in: sectionTitle, after: exercise.name)
//                    }
//                }
//
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "Completed", message: "Great job!", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
//                        self.navigationController?.popViewController(animated: true)
//                    }))
//                    self.present(alert, animated: true)
//                }
//
//            } catch {
//                // Handle error
//            }
//        }
//    }
//}

import UIKit
import AVKit
import AVFoundation

class UnitViewController: UIViewController {

    @IBOutlet weak var buttonTitle: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var completedButton: UIButton!

    var exercise: Exercise?
    var sectionTitle: String?
    var currentUserId: UUID?

    private var videoPlayer: AVPlayer?
    private var videoPlayerLayer: AVPlayerLayer?

    private var videoEndObserver: NSObjectProtocol?

    private let loader = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setupLoader()
        setupUI()
        setupVideoPlayer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Center loader
        loader.center = CGPoint(x: videoView.bounds.midX, y: videoView.bounds.midY)

        // Update videoPlayerLayer frame on layout changes (e.g., rotations)
        videoPlayerLayer?.frame = videoView.bounds
    }

    private func setupLoader() {
        loader.color = .white
        loader.hidesWhenStopped = true
        loader.translatesAutoresizingMaskIntoConstraints = false
        videoView.addSubview(loader)

        // Constraints to center loader exactly inside videoView
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: videoView.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: videoView.centerYAnchor)
        ])
    }

    private func setupUI() {
        guard let currentUserId = currentUserId,
              let exercise = exercise,
              let sectionTitle = sectionTitle else { return }

        buttonTitle.text = exercise.name
        navigationItem.title = sectionTitle

        Task {
            let isCompleted = await JourneyDataModel.shared.isExerciseCompleted(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)
            let isLocked = await JourneyDataModel.shared.isExerciseLocked(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)

            DispatchQueue.main.async {
                self.completedButton.isEnabled = !isCompleted && !isLocked
                self.completedButton.setTitle(isCompleted ? "Completed" : "Mark as Completed", for: .normal)
            }
        }
    }

    private func setupVideoPlayer() {
        guard videoPlayer == nil,
              let exercise = exercise,
              let sectionTitle = sectionTitle else { return }

        let fileName = "\(exercise.name).mp4"
        let bucketName = sectionTitle.lowercased()
        let baseURL = "https://ydhprtlbxlswgcscajdd.supabase.co/storage/v1/object/public"
        let videoURLString = "\(baseURL)/\(bucketName)/\(fileName)"

        guard let videoURL = URL(string: videoURLString) else { return }

        loader.startAnimating()

        let asset = AVAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)

        asset.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                var error: NSError?
                let status = asset.statusOfValue(forKey: "playable", error: &error)

                if status == .loaded {
                    self.videoPlayer = AVPlayer(playerItem: playerItem)

                    if let existingLayer = self.videoPlayerLayer {
                        existingLayer.removeFromSuperlayer()
                    }

                    let playerLayer = AVPlayerLayer(player: self.videoPlayer)
                    playerLayer.videoGravity = .resizeAspect
                    playerLayer.frame = self.videoView.bounds
                    self.videoView.layer.addSublayer(playerLayer)
                    self.videoPlayerLayer = playerLayer

                    self.loader.stopAnimating()
                    self.videoPlayer?.play()

                    // Remove previous observer if exists
                    if let observer = self.videoEndObserver {
                        NotificationCenter.default.removeObserver(observer)
                        self.videoEndObserver = nil
                    }

                    // Add new observer safely
                    self.videoEndObserver = NotificationCenter.default.addObserver(
                        forName: .AVPlayerItemDidPlayToEndTime,
                        object: playerItem,
                        queue: .main) { [weak self] _ in
                            self?.videoDidEnd()
                        }
                } else {
                    self.loader.stopAnimating()
                    self.showAlert(title: "Error", message: "Unable to load video. Please check your internet or try again later.")
                }
            }
        }
    }

    @objc private func videoDidEnd() {
        videoPlayer?.seek(to: .zero)
        videoPlayer?.play()
    }

    @IBAction func markAsCompletedTapped(_ sender: UIButton) {
        Task {
            guard let currentUserId = currentUserId,
                  let exercise = exercise,
                  let sectionTitle = sectionTitle else {
                return
            }

            do {
                let completed = try await JourneyDataModel.shared.isExerciseCompleted(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)

                if completed { return }

                try await JourneyDataModel.shared.completeExercise(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)
                try await AchievementDataModel.sharedInstance.updateProgress(achievementId: 1, increment: 1)
                try await ProfileDataModel.sharedInstance.addLearnedSign(for: currentUserId, newSign: exercise.name)
                try await ProfileDataModel.sharedInstance.updateWordsLearnedCount(for: currentUserId)
                await ProfileDataModel.sharedInstance.updateCurrentStreak(for: currentUserId)

                DispatchQueue.main.async {
                    sender.setTitle("Completed", for: .normal)
                    sender.isEnabled = false
                }

                let userJourney = try await JourneyDataModel.shared.getJourney(for: currentUserId)

                if let section = userJourney.section.first(where: { $0.title == sectionTitle }),
                   let exerciseIndex = section.exercises.firstIndex(where: { $0.name == exercise.name }),
                   exerciseIndex + 1 < section.exercises.count {
                    
                    let nextExercise = section.exercises[exerciseIndex + 1]
                    let isLocked = try await JourneyDataModel.shared.isExerciseLocked(for: currentUserId, sectionTitle: sectionTitle, exerciseName: nextExercise.name)

                    if isLocked {
                        try await JourneyDataModel.shared.unlockNextExercise(for: currentUserId, in: sectionTitle, after: exercise.name)
                    }
                }

                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Completed", message: "Great job!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self.navigationController?.popViewController(animated: true)
                    })
                    self.present(alert, animated: true)
                }

            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Something went wrong while marking as completed.")
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alertVC, animated: true)
        }
    }

    deinit {
        if let observer = videoEndObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}



func loadVideoInto(view: UIView, from url: URL, loader: UIActivityIndicatorView? = nil) {
    loader?.startAnimating()

    let asset = AVAsset(url: url)
    let item = AVPlayerItem(asset: asset)

    item.asset.loadValuesAsynchronously(forKeys: ["playable"]) { [weak view] in
        DispatchQueue.main.async {
            guard let view = view else {
                loader?.stopAnimating()
                return
            }

            var error: NSError?
            let status = item.asset.statusOfValue(forKey: "playable", error: &error)

            if status == .loaded {
                let player = AVPlayer(playerItem: item)
                let layer = AVPlayerLayer(player: player)

                layer.videoGravity = .resizeAspect
                layer.frame = view.bounds

                view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                view.layer.addSublayer(layer)

                loader?.stopAnimating()
                player.play()
            } else {
                loader?.stopAnimating()
                print("Failed to load video: \(String(describing: error))")
            }
        }
    }
}
