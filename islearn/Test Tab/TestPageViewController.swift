//import UIKit
//import AVKit
//import AVFoundation
//extension Array {
//    subscript(safe index: Int) -> Element? {
//        return indices.contains(index) ? self[index] : nil
//    }
//}
//
//class TestPageViewController: UIViewController {
//    
//    var test : Test?
//    
//    @IBOutlet weak var TestQuestionLabel: UILabel!
//    
//    @IBOutlet weak var videoView: UIView!
//    
//    @IBOutlet weak var optionAButton: UIButton!
//    
//    @IBOutlet weak var optionBButton: UIButton!
//    
//    @IBOutlet weak var optionCButton: UIButton!
//    
//    @IBOutlet weak var optionDButton: UIButton!
//    
//    @IBOutlet weak var videoOptionA: UIView!
//    
//    @IBOutlet weak var videoOptionB: UIView!
//    
//    @IBOutlet weak var videoOptionC: UIView!
//    
//    @IBOutlet weak var mcqAStack: UIStackView!
//    
//    @IBOutlet weak var mcqBStack: UIStackView!
//    
//    @IBOutlet weak var GestureAStack: UIStackView!
//    
//    @IBOutlet weak var GestureAWordLabel: UILabel!
//    
//    @IBOutlet weak var GestureACameraView: UIView!
//    
//    let videoCapture = VideoCapture()
//    
//    var previewLayer : AVCaptureVideoPreviewLayer?
//    
//    var pointsLayer = CAShapeLayer()
//    
//    var actionDetected = false
//    
//    var questionNumber = 0
//    
//    var currentScore : Double = 0
//    
//    var testXP : Double = 0
//    
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationItem.title = "\(test?.title ?? "")"
//        loadQuestion()
//        
//        optionAButton.layer.cornerRadius = 20
//        optionBButton.layer.cornerRadius = 20
//        optionCButton.layer.cornerRadius = 20
//        optionDButton.layer.cornerRadius = 20
//        setupVideoPreview()
//        videoCapture.predictor.delegate = self
//        
//        let tapA = UITapGestureRecognizer(target: self, action: #selector(mcqBOptionTapped(_:)))
//        videoOptionA.addGestureRecognizer(tapA)
//        videoOptionA.tag = 1
//
//        let tapB = UITapGestureRecognizer(target: self, action: #selector(mcqBOptionTapped(_:)))
//        videoOptionB.addGestureRecognizer(tapB)
//        videoOptionB.tag = 2
//
//        let tapC = UITapGestureRecognizer(target: self, action: #selector(mcqBOptionTapped(_:)))
//        videoOptionC.addGestureRecognizer(tapC)
//        videoOptionC.tag = 3
//        
//        videoOptionA.isUserInteractionEnabled = true
//        videoOptionB.isUserInteractionEnabled = true
//        videoOptionC.isUserInteractionEnabled = true
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        if let presentingVC = self.presentingViewController as? TestListCollectionViewController {
//            presentingVC.hideLoadingIndicator()
//        }
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        videoCapture.endCaptureSession()
//    }
//    
//    private func setupVideoPreview() {
//        videoCapture.startCaptureSession()
//        
//        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
//        
//        guard let previewLayer = previewLayer else { return }
//        
//        GestureACameraView.layer.addSublayer(previewLayer)
//        previewLayer.frame = GestureACameraView.frame
//        
//        GestureACameraView.layer.addSublayer(pointsLayer)
//        pointsLayer.frame = GestureACameraView.frame
//        
//    }
//    
//    
//    @IBAction func optionSelectedMCQB(_ sender : UIButton){
//        let impactMedium = UIImpactFeedbackGenerator(style: .medium)
//        impactMedium.impactOccurred()
//        print("MCQB button tapped: tag = \(sender.tag)")
//        if let test {
//            if (sender.tag == test.questions[questionNumber].answer) {
//                currentScore += 0.3
//                testXP += Double(test.questions[questionNumber].questionXP)
//            }
//            
//            questionNumber+=1
//            
//            if(questionNumber < test.questions.count){
//                loadQuestion()
//                
//            }else{
//                performSegue(withIdentifier: "Results", sender: [currentScore,testXP])
//            }
//            
//        }
//    }
//    
//    
//    @IBAction func GestureASkipButtonPressed(_ sender: UIButton) {
//        if let test{
//            questionNumber+=1
//            if(questionNumber < test.questions.count){
//                loadQuestion()
//                
//            }else{
//                performSegue(withIdentifier: "Results", sender: [currentScore,testXP])
//            }
//        }
//    }
//    
//    @IBAction func optionSelectedMCQA(_ sender: UIButton) {
//        
//        let impactMedium = UIImpactFeedbackGenerator(style: .medium)
//            impactMedium.impactOccurred()
//
//            guard let test else { return }
//
//            if sender.tag == (test.questions[questionNumber].answer) {
//                currentScore += 0.2
//                testXP += Double(test.questions[questionNumber].questionXP)
//                sender.backgroundColor = .systemGreen
//            } else {
//                sender.backgroundColor = .systemRed
//                highlightCorrectAnswer(test.questions[questionNumber].answer!)
//            }
//
//            questionNumber += 1
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                if self.questionNumber < self.test!.questions.count {
//                    self.loadQuestion()
//                } else {
//                    self.performSegue(withIdentifier: "Results", sender: [self.currentScore, self.testXP])
//                }
//            }
//    }
//    
//    private func highlightCorrectAnswer(_ correctAnswer: Int) {
//        switch correctAnswer {
//        case 1: optionAButton.backgroundColor = .systemGreen
//        case 2: optionBButton.backgroundColor = .systemGreen
//        case 3: optionCButton.backgroundColor = .systemGreen
//        case 4: optionDButton.backgroundColor = .systemGreen
//        default: break
//        }
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destination = segue.destination as? TestResultViewController{
//            if(sender as? [Double] == nil){
//                return
//            }
//            let temp = sender as! [Double]
//            destination.testScore = temp[0]
//            destination.testID = test?.testID ?? 0
//            destination.testXP = Int(temp[1])
//        }
//    }
//    
//    func loadQuestion(){
//        
//        TestQuestionLabel.text = "Q\(questionNumber + 1): " + (test?.questions[questionNumber].questionStatement ?? "")
//        
//        let givenTestType = test?.testType
//        let givenQuestionType = test?.questions[questionNumber].questionType
//        
//        mcqAStack.isHidden = true
//        mcqBStack.isHidden = true
//        GestureAStack.isHidden = true
//        videoCapture.endCaptureSession()
//        
//        if givenTestType == .classic {
//            if givenQuestionType == .mcqA {
//                
//                mcqAStack.isHidden = false
//                mcqBStack.isHidden = true
//                
//                optionAButton.setTitle(test?.questions[questionNumber].options?[0], for: .normal)
//                optionAButton.tag = 1
//                optionAButton.backgroundColor = .accent
//                
//                optionBButton.setTitle(test?.questions[questionNumber].options?[1], for: .normal)
//                optionBButton.tag = 2
//                optionBButton.backgroundColor = .accent
//                
//                optionCButton.setTitle(test?.questions[questionNumber].options?[2], for: .normal)
//                optionCButton.tag = 3
//                optionCButton.backgroundColor = .accent
//                
//                optionDButton.setTitle(test?.questions[questionNumber].options?[3], for: .normal)
//                optionDButton.tag = 4
//                optionDButton.backgroundColor = .accent
//                
//                if let answerIndex = test?.questions[questionNumber].answer,
//                               let options = test?.questions[questionNumber].options,
//                               answerIndex < options.count {
//                                
//                                let videoName = options[answerIndex - 1]
//                                
//                                // Decide bucket based on whether videoName is number or not
//                                let bucketName = Int(videoName) != nil ? "numbers" : "alphabets"
//                                
//                                let baseURL = "https://ydhprtlbxlswgcscajdd.supabase.co/storage/v1/object/public"
//                                let fileName = "\(videoName.uppercased()).mp4"
//                                let urlString = "\(baseURL)/\(bucketName)/\(fileName)"
//                                
//                                if let url = URL(string: urlString) {
//                                    let player = AVPlayer(url: url)
//                                    let layer = AVPlayerLayer(player: player)
//                                    layer.frame = videoView.bounds
//                                    videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
//                                    videoView.layer.addSublayer(layer)
//                                    player.play()
//                                }
//                            }
//                
//            } else if givenQuestionType == .mcqB {
//                mcqAStack.isHidden = true
//                            mcqBStack.isHidden = false
//                            
//                            if let options = test?.questions[questionNumber].options as? [String], options.count >= 3 {
//                                for (index, option) in options.prefix(3).enumerated() {
//                                    let videoURLString = "https://ydhprtlbxlswgcscajdd.supabase.co/storage/v1/object/public/alphabets/\(option.uppercased()).mp4"
//                                    print("Video URL for option \(index + 1): \(videoURLString)")
//                                    switch index {
//                                    case 0:
//                                        loadVideo(for: videoOptionA, urlString: videoURLString)
//                                    case 1:
//                                        loadVideo(for: videoOptionB, urlString: videoURLString)
//                                    case 2:
//                                        loadVideo(for: videoOptionC, urlString: videoURLString)
//                                    default:
//                                        break
//                                    }
//                                }
//                            } else {
//                                print("Error: Options are not of type [String] or less than 3 options available")
//                            }
//            }
//        } else {
//            if givenQuestionType == .wordGesture {
//                setupVideoPreview()
//                GestureAStack.isHidden = false
//                GestureAWordLabel.text = test?.questions[questionNumber].gestureWord
//                videoCapture.startCaptureSession()
//            }
//        }
//    }
//
//    func loadVideo(for view: UIView, urlString: String) {
//        if let url = URL(string: urlString) {
//            let player = AVPlayer(url: url)
//            let layer = AVPlayerLayer(player: player)
//            
//            layer.frame = view.bounds
//            view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
//            view.layer.addSublayer(layer)
//            player.play()
//        } else {
//            print("Error: Invalid URL \(urlString)")
//        }
//    }
//    
//    @objc func mcqBOptionTapped(_ sender: UITapGestureRecognizer) {
//        let impactMedium = UIImpactFeedbackGenerator(style: .medium)
//        impactMedium.impactOccurred()
//        
//        guard let tappedView = sender.view else { return }
//        guard let test else { return }
//        
//        let selectedTag = tappedView.tag
//        let correctAnswer = test.questions[questionNumber].answer
//
//        print("Selected tag: \(selectedTag), Correct answer: \(correctAnswer)")
//
//        
//        if selectedTag == test.questions[questionNumber].answer {
//            currentScore += 0.2
//            testXP += Double(test.questions[questionNumber].questionXP)
//            tappedView.layer.borderColor = UIColor.systemGreen.cgColor
//            tappedView.layer.borderWidth = 4
//        } else {
//            tappedView.layer.borderColor = UIColor.systemRed.cgColor
//            tappedView.layer.borderWidth = 4
//
//            if let correctTag = test.questions[questionNumber].answer {
//                let correctView = [videoOptionA, videoOptionB, videoOptionC].first { $0.tag == correctTag }
//                correctView?.layer.borderColor = UIColor.systemGreen.cgColor
//                correctView?.layer.borderWidth = 4
//            }
//        }
//        
//        questionNumber += 1
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//            if self.questionNumber < self.test!.questions.count {
//                self.loadQuestion()
//            } else {
//                self.performSegue(withIdentifier: "Results", sender: [self.currentScore, self.testXP])
//            }
//        }
//    }
//
//    
//    @IBSegueAction func TestCancel(_ coder: NSCoder) -> TestResultViewController? {
//        let result : TestResultViewController? = TestResultViewController(coder: coder)
//        
//        result?.testScore = 0
//        
//        let alertController = UIAlertController(title: "Quit Test?", message: nil, preferredStyle: .alert)
//        
//        let yes = UIAlertAction(title: "Yes", style: .default) { ( _ ) in
//            
//            if let result {
//                result.testID = self.test?.testID
//                self.videoCapture.endCaptureSession()
//                self.performSegue(withIdentifier: "Results", sender : [0,0])
//            }
//        }
//        
//        let no = UIAlertAction(title: "No", style: .destructive)
//        
//        alertController.addAction(yes)
//        
//        alertController.addAction(no)
//        
//        present(alertController, animated: true)
//        
//        return result
//    }
//}
//
//
//extension TestPageViewController : PredictorDelegate {
//    func predictor(_ predictor: Predictor, didLabelAction action: String, with confidence: Double) {
//        guard confidence >= 0.9, actionDetected == false else { return }
//            actionDetected = true
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.actionDetected = false
//                
//                guard let expectedAction = self.test?.questions[self.questionNumber].gestureWord,
//                      !expectedAction.isEmpty else {
//                    self.showAlert(title: "Error", message: "Expected gesture is not defined.")
//                    return
//                }
//
//                if action == expectedAction {
//                    self.performSegue(withIdentifier: "Results", sender: [1, 100])
//                } else {
//                    self.showAlert(title: "Gesture Not Detected", message: "Please try again or skip the question.")
//                }
//            }
//    }
//    
//    func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//    
//    func predictor(_ predictor: Predictor, didFindRecoganisedPoints points: [CGPoint]) {
//        guard let previewLayer else {return}
//        
//        let convertedPoints = points.map {
//            previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
//        }
//        
//        let combinedPath = CGMutablePath()
//        
//        for point in convertedPoints {
//            let dotPath = UIBezierPath(ovalIn: CGRect(x: point.x, y: point.y, width: 10, height: 10))
//            combinedPath.addPath(dotPath.cgPath)
//        }
//        
//        pointsLayer.path = combinedPath
//        
//        DispatchQueue.main.async {
//            self.pointsLayer.didChangeValue(for: \.path)
//        }
//    }
//}
//


import UIKit
import AVKit
import AVFoundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

class TestPageViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var TestQuestionLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var optionAButton: UIButton!
    @IBOutlet weak var optionBButton: UIButton!
    @IBOutlet weak var optionCButton: UIButton!
    @IBOutlet weak var optionDButton: UIButton!
    @IBOutlet weak var videoOptionA: UIView!
    @IBOutlet weak var videoOptionB: UIView!
    @IBOutlet weak var videoOptionC: UIView!
    @IBOutlet weak var mcqAStack: UIStackView!
    @IBOutlet weak var mcqBStack: UIStackView!
    @IBOutlet weak var GestureAStack: UIStackView!
    @IBOutlet weak var GestureAWordLabel: UILabel!
    @IBOutlet weak var GestureACameraView: UIView!

    @IBOutlet weak var mcqbButtonC: UIButton!
    @IBOutlet weak var mcqbButtonB: UIButton!
    @IBOutlet weak var mcqbButtonA: UIButton!
    // MARK: - Properties
    var test: Test?
    var questionNumber = 0
    var currentScore: Double = 0
    var testXP: Double = 0
    var previewLayer: AVCaptureVideoPreviewLayer?
    var actionDetected = false
    let videoCapture = VideoCapture()
    var pointsLayer = CAShapeLayer()
    
    let loader = UIActivityIndicatorView(style: .large)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = test?.title
        
        loader.center = view.center
        loader.hidesWhenStopped = true
        view.addSubview(loader)
        
        setupVideoPreview()
//        videoCapture.predictor.delegate = self
        configureButtons()
        setupTapGestures()
        loadQuestion()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        videoCapture.endCaptureSession()
    }

    // MARK: - Setup Methods
    private func setupVideoPreview() {
        videoCapture.startCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
        guard let previewLayer else { return }

        previewLayer.frame = GestureACameraView.bounds
        GestureACameraView.layer.addSublayer(previewLayer)
        pointsLayer.frame = GestureACameraView.bounds
        GestureACameraView.layer.addSublayer(pointsLayer)
    }

    private func configureButtons() {
        [optionAButton, optionBButton, optionCButton, optionDButton].forEach {
            $0?.layer.cornerRadius = 20
        }
        
        [optionAButton, optionBButton, optionCButton, optionDButton].forEach {
            $0?.backgroundColor = .accent
        }

    }

    private func setupTapGestures() {
        [videoOptionA, videoOptionB, videoOptionC].enumerated().forEach { index, view in
            let tap = UITapGestureRecognizer(target: self, action: #selector(mcqBOptionTapped(_:)))
            view?.addGestureRecognizer(tap)
            view?.tag = index + 1
            view?.isUserInteractionEnabled = true
        }
    }

    // MARK: - Load Question
    func loadQuestion() {
        guard let test = test else { return }
        resetUI()

        TestQuestionLabel.text = "Q\(questionNumber + 1): \(test.questions[questionNumber].questionStatement)"

        let question = test.questions[questionNumber]

        switch (test.testType, question.questionType) {
        case (.classic, .mcqA):
            mcqAStack.isHidden = false
            [optionAButton, optionBButton, optionCButton, optionDButton].enumerated().forEach {
                $0.element?.setTitle(question.options?[safe: $0.offset], for: .normal)
                $0.element?.tag = $0.offset + 1
            }
            playCorrectVideo(for: question)

        case (.classic, .mcqB):
            mcqBStack.isHidden = false
            loadVideoOptions(options: question.options)

        case (_, .wordGesture):
            GestureAStack.isHidden = false
            GestureAWordLabel.text = question.gestureWord
            videoCapture.startCaptureSession()

        default:
            break
        }
    }

    func resetUI() {
        [optionAButton, optionBButton, optionCButton, optionDButton].forEach {
            $0?.backgroundColor = .accent
        }


        [videoOptionA, videoOptionB, videoOptionC].forEach {
            $0?.layer.borderWidth = 0
        }

        videoCapture.endCaptureSession()
        mcqAStack.isHidden = true
        mcqBStack.isHidden = true
        GestureAStack.isHidden = true
    }

//    func playCorrectVideo(for question: Question) {
//        guard let answerIndex = question.answer,
//              let videoName = question.options?[safe: answerIndex - 1] else { return }
//
//        let bucket = Int(videoName) != nil ? "numbers" : "alphabets"
//        let urlString = "https://ydhprtlbxlswgcscajdd.supabase.co/storage/v1/object/public/\(bucket)/\(videoName.uppercased()).mp4"
//        guard let url = URL(string: urlString) else { return }
//
//        let playerItem = AVPlayerItem(url: url)
//        let player = AVPlayer(playerItem: playerItem)
//        let layer = AVPlayerLayer(player: player)
//        layer.frame = videoView.bounds
//        videoView.layer.sublayers?.removeAll()
//        videoView.layer.addSublayer(layer)
//
//        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { _ in
//            player.seek(to: .zero)
//            player.play()
//        }
//
//        player.play()
//    }
    
    func playCorrectVideo(for question: Question) {
        loader.startAnimating()
        guard let answer = test?.questions[questionNumber].answer else { return }
        guard let videoName = test?.questions[questionNumber].options?[safe: answer - 1] else { return }
        var bucket = ""
        if Int(videoName) != nil {
            bucket = "numbers"
        } else {
            bucket = "alphabets"
        }
        
        let urlString = "https://ydhprtlbxlswgcscajdd.supabase.co/storage/v1/object/public/\(bucket)/\(videoName.uppercased()).mp4"
        let url = URL(string: urlString)!
        let playerItem = AVPlayerItem(url: url)
        
        // Load asynchronously
        playerItem.asset.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                var error: NSError?
                let status = playerItem.asset.statusOfValue(forKey: "playable", error: &error)
                if status == .loaded {
                    let player = AVPlayer(playerItem: playerItem)
                    let layer = AVPlayerLayer(player: player)
                    layer.frame = self.videoView.bounds
                    self.videoView.layer.sublayers?.removeAll()
                    self.videoView.layer.addSublayer(layer)
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { _ in
                        player.seek(to: .zero)
                        player.play()
                    }
                    player.play()
                    self.loader.stopAnimating()
                } else {
                    self.loader.stopAnimating()
                    print("Error loading video: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }

//    func loadVideoOptions(options: [String]?) {
//        guard let options = options, options.count >= 3 else { return }
//
//        let views = [videoOptionA, videoOptionB, videoOptionC]
//
//        for (i, option) in options.prefix(3).enumerated() {
//            let urlString = "https://ydhprtlbxlswgcscajdd.supabase.co/storage/v1/object/public/alphabets/\(option.uppercased()).mp4"
//            if let url = URL(string: urlString), let view = views[i] {
//                let playerItem = AVPlayerItem(url: url)
//                let player = AVPlayer(playerItem: playerItem)
//                let layer = AVPlayerLayer(player: player)
//                layer.frame = view.bounds
//                view.layer.sublayers?.removeAll()
//                view.layer.addSublayer(layer)
//
//           
//                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { _ in
//                    player.seek(to: .zero)
//                    player.play()
//                }
//
//                player.play()
//            }
//        }
//    }
    
    func loadVideoOptions(options: [String]?) {
        guard let options = options, options.count >= 3 else { return }
        loader.startAnimating()
        let views = [videoOptionA, videoOptionB, videoOptionC]
        var videosLoaded = 0
        
        for i in 0..<3 {
            let option = options[i]
            let urlString = "https://ydhprtlbxlswgcscajdd.supabase.co/storage/v1/object/public/alphabets/\(option.uppercased()).mp4"
            guard let url = URL(string: urlString) else { continue }
            let playerItem = AVPlayerItem(url: url)
            
            playerItem.asset.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    var error: NSError?
                    let status = playerItem.asset.statusOfValue(forKey: "playable", error: &error)
                    if status == .loaded {
                        let player = AVPlayer(playerItem: playerItem)
                        if let view = views[i] {
                            let layer = AVPlayerLayer(player: player)
                            layer.frame = view.bounds
                            view.layer.sublayers?.removeAll()
                            view.layer.addSublayer(layer)
                            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { _ in
                                player.seek(to: .zero)
                                player.play()
                            }
                            player.play()
                        }
                        videosLoaded += 1
                        if videosLoaded == 3 {
                            self.loader.stopAnimating()
                        }
                    } else {
                        self.loader.stopAnimating()
                        print("Error loading video: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }

    // MARK: - Button Actions
    @IBAction func optionSelectedMCQA(_ sender: UIButton) {
        guard let test = test else { return }
        let answer = test.questions[questionNumber].answer

        if sender.tag == answer {
            handleCorrectAnswer()
            sender.backgroundColor = .systemGreen
        } else {
            sender.backgroundColor = .systemRed
            highlightCorrectAnswer(answer)
        }

        proceedToNextQuestion()
    }

    @IBAction func optionSelectedMCQB(_ sender: UIButton) {
        if sender.tag == test?.questions[questionNumber].answer {
            handleCorrectAnswer()
        }
        

        proceedToNextQuestion()

    }

    @objc func mcqBOptionTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view, let answer = test?.questions[questionNumber].answer else { return }

        if view.tag == answer {
            handleCorrectAnswer()
            view.layer.borderColor = UIColor.systemGreen.cgColor
        } else {
            view.layer.borderColor = UIColor.systemRed.cgColor
            if let correctView = [videoOptionA, videoOptionB, videoOptionC].first(where: { $0.tag == answer }) {
                correctView.layer.borderColor = UIColor.systemGreen.cgColor
                correctView.layer.borderWidth = 4
            }
        }
        view.layer.borderWidth = 4
        
            proceedToNextQuestion()
    }

    @IBAction func GestureASkipButtonPressed(_ sender: UIButton) {
        proceedToNextQuestion()
    }

    func highlightCorrectAnswer(_ correct: Int?) {
        switch correct {
        case 1: optionAButton.backgroundColor = .systemGreen
        case 2: optionBButton.backgroundColor = .systemGreen
        case 3: optionCButton.backgroundColor = .systemGreen
        case 4: optionDButton.backgroundColor = .systemGreen
        default: break
        }
    }

    func handleCorrectAnswer() {
        currentScore += 0.2
        testXP += Double(test?.questions[questionNumber].questionXP ?? 0)
    }

    func proceedToNextQuestion() {
        questionNumber += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if self.questionNumber < self.test?.questions.count ?? 0 {
                self.loadQuestion()
            } else {
                self.performSegue(withIdentifier: "Results", sender: [self.currentScore, self.testXP])
            }
        }
    }

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resultVC = segue.destination as? TestResultViewController, let data = sender as? [Double] {
            resultVC.testScore = data[0]
            resultVC.testXP = Int(data[1])
            resultVC.testID = test?.testID ?? 0
        }
    }

    @IBSegueAction func TestCancel(_ coder: NSCoder) -> TestResultViewController? {
        let resultVC = TestResultViewController(coder: coder)
        resultVC?.testScore = 0

        let alert = UIAlertController(title: "Quit Test?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            self.videoCapture.endCaptureSession()
            self.performSegue(withIdentifier: "Results", sender: [0.0, 0.0])
        })
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        present(alert, animated: true)

        return resultVC
    }
}

// MARK: - Gesture Delegate
extension TestPageViewController: PredictorDelegate {
    func predictor(_ predictor: Predictor, didLabelAction action: String, with confidence: Double) {
        guard confidence >= 0.9, !actionDetected else { return }

        actionDetected = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.actionDetected = false

            guard let expected = self.test?.questions[self.questionNumber].gestureWord else {
                self.showAlert(title: "Error", message: "Expected gesture not defined.")
                return
            }

            if action == expected {
                self.currentScore += 0.5
                self.testXP += Double(self.test?.questions[self.questionNumber].questionXP ?? 0)
                self.proceedToNextQuestion()
            } else {
                self.showAlert(title: "Gesture Not Detected", message: "Please try again or skip.")
            }
        }
    }

    func predictor(_ predictor: Predictor, didFindRecoganisedPoints points: [CGPoint]) {
        guard let previewLayer = previewLayer else { return }
        let convertedPoints = points.map { previewLayer.layerPointConverted(fromCaptureDevicePoint: $0) }

        let path = CGMutablePath()
        convertedPoints.forEach {
            let dot = UIBezierPath(ovalIn: CGRect(origin: $0, size: CGSize(width: 10, height: 10)))
            path.addPath(dot.cgPath)
        }

        pointsLayer.path = path
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


//import UIKit
//import AVKit
//import AVFoundation
//
//extension Array {
//    subscript(safe index: Int) -> Element? {
//        return indices.contains(index) ? self[index] : nil
//    }
//}
//
//class TestPageViewController: UIViewController {
//    
//    @IBOutlet weak var TestQuestionLabel: UILabel!
//    @IBOutlet weak var videoView: UIView!
//    @IBOutlet weak var optionAButton: UIButton!
//    @IBOutlet weak var optionBButton: UIButton!
//    @IBOutlet weak var optionCButton: UIButton!
//    @IBOutlet weak var optionDButton: UIButton!
//    @IBOutlet weak var videoOptionA: UIView!
//    @IBOutlet weak var videoOptionB: UIView!
//    @IBOutlet weak var videoOptionC: UIView!
//    @IBOutlet weak var mcqAStack: UIStackView!
//    @IBOutlet weak var mcqBStack: UIStackView!
//    @IBOutlet weak var GestureAStack: UIStackView!
//    @IBOutlet weak var GestureAWordLabel: UILabel!
//    @IBOutlet weak var GestureACameraView: UIView!
//    
//    @IBOutlet weak var mcqbButtonC: UIButton!
//    @IBOutlet weak var mcqbButtonB: UIButton!
//    @IBOutlet weak var mcqbButtonA: UIButton!
//    
//    var test: Test?
//    var questionNumber = 0
//    var currentScore: Double = 0
//    var testXP: Double = 0
//    var previewLayer: AVCaptureVideoPreviewLayer?
//    var actionDetected = false
//    let videoCapture = VideoCapture()
//    var pointsLayer = CAShapeLayer()
//    
//    // Activity Indicator loader
//    let loader = UIActivityIndicatorView(style: .large)
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationItem.title = test?.title
//        
//        // Setup loader
//        loader.center = view.center
//        loader.hidesWhenStopped = true
//        view.addSubview(loader)
//        
//        videoCapture.startCaptureSession()
//        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
//        guard let previewLayer else { return }
//        
//        previewLayer.frame = GestureACameraView.bounds
//        GestureACameraView.layer.addSublayer(previewLayer)
//        pointsLayer.frame = GestureACameraView.bounds
//        GestureACameraView.layer.addSublayer(pointsLayer)
//        
//        optionAButton.layer.cornerRadius = 20
//        optionBButton.layer.cornerRadius = 20
//        optionCButton.layer.cornerRadius = 20
//        optionDButton.layer.cornerRadius = 20
//        
//        optionAButton.backgroundColor = .accent
//        optionBButton.backgroundColor = .accent
//        optionCButton.backgroundColor = .accent
//        optionDButton.backgroundColor = .accent
//        
//        let tapGestureA = UITapGestureRecognizer(target: self, action: #selector(mcqBOptionTapped(_:)))
//        videoOptionA.addGestureRecognizer(tapGestureA)
//        videoOptionA.tag = 1
//        videoOptionA.isUserInteractionEnabled = true
//        
//        let tapGestureB = UITapGestureRecognizer(target: self, action: #selector(mcqBOptionTapped(_:)))
//        videoOptionB.addGestureRecognizer(tapGestureB)
//        videoOptionB.tag = 2
//        videoOptionB.isUserInteractionEnabled = true
//        
//        let tapGestureC = UITapGestureRecognizer(target: self, action: #selector(mcqBOptionTapped(_:)))
//        videoOptionC.addGestureRecognizer(tapGestureC)
//        videoOptionC.tag = 3
//        videoOptionC.isUserInteractionEnabled = true
//        
//        loadQuestion()
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        videoCapture.endCaptureSession()
//    }
//    
//    func loadQuestion() {
//        TestQuestionLabel.text = "Q\(questionNumber + 1): \(test?.questions[questionNumber].questionStatement ?? "")"
//        
//        optionAButton.backgroundColor = .accent
//        optionBButton.backgroundColor = .accent
//        optionCButton.backgroundColor = .accent
//        optionDButton.backgroundColor = .accent
//        
//        videoOptionA.layer.borderWidth = 0
//        videoOptionB.layer.borderWidth = 0
//        videoOptionC.layer.borderWidth = 0
//        
//        videoCapture.endCaptureSession()
//        mcqAStack.isHidden = true
//        mcqBStack.isHidden = true
//        GestureAStack.isHidden = true
//        
//        let question = test?.questions[questionNumber]
//        
//        if test?.testType == .classic && question?.questionType == .mcqA {
//            mcqAStack.isHidden = false
//            
//            optionAButton.setTitle(question?.options?[safe: 0], for: .normal)
//            optionBButton.setTitle(question?.options?[safe: 1], for: .normal)
//            optionCButton.setTitle(question?.options?[safe: 2], for: .normal)
//            optionDButton.setTitle(question?.options?[safe: 3], for: .normal)
//            
//            optionAButton.tag = 1
//            optionBButton.tag = 2
//            optionCButton.tag = 3
//            optionDButton.tag = 4
//            
//            playCorrectVideo()
//        }
//        
//        if test?.testType == .classic && question?.questionType == .mcqB {
//            mcqBStack.isHidden = false
//            
//            loadVideoOptions()
//        }
//        
//        if question?.questionType == .wordGesture {
//            GestureAStack.isHidden = false
//            GestureAWordLabel.text = question?.gestureWord
//            videoCapture.startCaptureSession()
//        }
//    }
//    
//    func playCorrectVideo() {
//        loader.startAnimating()
//        guard let answer = test?.questions[questionNumber].answer else { return }
//        guard let videoName = test?.questions[questionNumber].options?[safe: answer - 1] else { return }
//        var bucket = ""
//        if Int(videoName) != nil {
//            bucket = "numbers"
//        } else {
//            bucket = "alphabets"
//        }
//        
//        let urlString = "https://ydhprtlbxlswgcscajdd.supabase.co/storage/v1/object/public/\(bucket)/\(videoName.uppercased()).mp4"
//        let url = URL(string: urlString)!
//        let playerItem = AVPlayerItem(url: url)
//        
//        // Load asynchronously
//        playerItem.asset.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//                var error: NSError?
//                let status = playerItem.asset.statusOfValue(forKey: "playable", error: &error)
//                if status == .loaded {
//                    let player = AVPlayer(playerItem: playerItem)
//                    let layer = AVPlayerLayer(player: player)
//                    layer.frame = self.videoView.bounds
//                    self.videoView.layer.sublayers?.removeAll()
//                    self.videoView.layer.addSublayer(layer)
//                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { _ in
//                        player.seek(to: .zero)
//                        player.play()
//                    }
//                    player.play()
//                    self.loader.stopAnimating()
//                } else {
//                    self.loader.stopAnimating()
//                    print("Error loading video: \(error?.localizedDescription ?? "Unknown error")")
//                }
//            }
//        }
//    }
//    
//    func loadVideoOptions() {
//        guard let options = test?.questions[questionNumber].options else { return }
//        loader.startAnimating()
//        let views = [videoOptionA, videoOptionB, videoOptionC]
//        var videosLoaded = 0
//        
//        for i in 0..<3 {
//            let option = options[i]
//            let urlString = "https://ydhprtlbxlswgcscajdd.supabase.co/storage/v1/object/public/alphabets/\(option.uppercased()).mp4"
//            guard let url = URL(string: urlString) else { continue }
//            let playerItem = AVPlayerItem(url: url)
//            
//            playerItem.asset.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
//                DispatchQueue.main.async {
//                    guard let self = self else { return }
//                    var error: NSError?
//                    let status = playerItem.asset.statusOfValue(forKey: "playable", error: &error)
//                    if status == .loaded {
//                        let player = AVPlayer(playerItem: playerItem)
//                        if let view = views[i] {
//                            let layer = AVPlayerLayer(player: player)
//                            layer.frame = view.bounds
//                            view.layer.sublayers?.removeAll()
//                            view.layer.addSublayer(layer)
//                            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { _ in
//                                player.seek(to: .zero)
//                                player.play()
//                            }
//                            player.play()
//                        }
//                        videosLoaded += 1
//                        if videosLoaded == 3 {
//                            self.loader.stopAnimating()
//                        }
//                    } else {
//                        self.loader.stopAnimating()
//                        print("Error loading video: \(error?.localizedDescription ?? "Unknown error")")
//                    }
//                }
//            }
//        }
//    }
//    
//    @IBAction func optionSelectedMCQA(_ sender: UIButton) {
//        if sender.tag == test?.questions[questionNumber].answer {
//            currentScore += 0.2
//            testXP += Double(test?.questions[questionNumber].questionXP ?? 0)
//            sender.backgroundColor = .systemGreen
//        } else {
//            sender.backgroundColor = .systemRed
//            
//            if test?.questions[questionNumber].answer == 1 {
//                optionAButton.backgroundColor = .systemGreen
//            } else if test?.questions[questionNumber].answer == 2 {
//                optionBButton.backgroundColor = .systemGreen
//            } else if test?.questions[questionNumber].answer == 3 {
//                optionCButton.backgroundColor = .systemGreen
//            } else if test?.questions[questionNumber].answer == 4 {
//                optionDButton.backgroundColor = .systemGreen
//            }
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//            self.questionNumber += 1
//            if self.questionNumber < (self.test?.questions.count ?? 0) {
//                self.loadQuestion()
//            } else {
//                self.performSegue(withIdentifier: "Results", sender: [self.currentScore, self.testXP])
//            }
//        }
//    }
//    
//    @IBAction func optionSelectedMCQB(_ sender: UIButton) {
//        if sender.tag == test?.questions[questionNumber].answer {
//            currentScore += 0.2
//            testXP += Double(test?.questions[questionNumber].questionXP ?? 0)
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//            self.questionNumber += 1
//            if self.questionNumber < (self.test?.questions.count ?? 0) {
//                self.loadQuestion()
//            } else {
//                self.performSegue(withIdentifier: "Results", sender: [self.currentScore, self.testXP])
//            }
//        }
//    }
//    
//    @objc func mcqBOptionTapped(_ sender: UITapGestureRecognizer) {
//        guard let view = sender.view else { return }
//        if view.tag == test?.questions[questionNumber].answer {
//            currentScore += 0.2
//            testXP += Double(test?.questions[questionNumber].questionXP ?? 0)
//            view.layer.borderColor = UIColor.systemGreen.cgColor
//            view.layer.borderWidth = 4
//        } else {
//            view.layer.borderColor = UIColor.systemRed.cgColor
//            view.layer.borderWidth = 4
//            
//            if test?.questions[questionNumber].answer == 1 {
//                videoOptionA.layer.borderColor = UIColor.systemGreen.cgColor
//                videoOptionA.layer.borderWidth = 4
//            } else if test?.questions[questionNumber].answer == 2 {
//                videoOptionB.layer.borderColor = UIColor.systemGreen.cgColor
//                videoOptionB.layer.borderWidth = 4
//            } else if test?.questions[questionNumber].answer == 3 {
//                videoOptionC.layer.borderColor = UIColor.systemGreen.cgColor
//                videoOptionC.layer.borderWidth = 4
//            }
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//            self.questionNumber += 1
//            if self.questionNumber < (self.test?.questions.count ?? 0) {
//                self.loadQuestion()
//            } else {
//                self.performSegue(withIdentifier: "Results", sender: [self.currentScore, self.testXP])
//            }
//        }
//    }
//    
//    @IBAction func GestureASkipButtonPressed(_ sender: UIButton) {
//        questionNumber += 1
//        if questionNumber < (test?.questions.count ?? 0) {
//            loadQuestion()
//        } else {
//            performSegue(withIdentifier: "Results", sender: [currentScore, testXP])
//        }
//    }
//    
//        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            if let resultVC = segue.destination as? TestResultViewController, let data = sender as? [Double] {
//                resultVC.testScore = data[0]
//                resultVC.testXP = Int(data[1])
//                resultVC.testID = test?.testID ?? 0
//            }
//        }
//    
//        @IBSegueAction func TestCancel(_ coder: NSCoder) -> TestResultViewController? {
//            let resultVC = TestResultViewController(coder: coder)
//            resultVC?.testScore = 0
//    
//            let alert = UIAlertController(title: "Quit Test?", message: nil, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
//                self.videoCapture.endCaptureSession()
//                self.performSegue(withIdentifier: "Results", sender: [0.0, 0.0])
//            })
//            alert.addAction(UIAlertAction(title: "No", style: .cancel))
//            present(alert, animated: true)
//    
//            return resultVC
//        }
//}
//
