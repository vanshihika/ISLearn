import UIKit

class TestResultViewController: UIViewController {
    
    var currentUserId: UUID?
    var testID: Int?
    var testScore: Double?
    var testXP: Int?
    
    @IBOutlet weak var star1ImageView: UIImageView!
    @IBOutlet weak var star2ImageView: UIImageView!
    @IBOutlet weak var star3ImageView: UIImageView!
    @IBOutlet weak var star4ImageView: UIImageView!
    @IBOutlet weak var star5ImageView: UIImageView!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var resultComment1: UILabel!
    @IBOutlet weak var resultComment2: UILabel!
    @IBOutlet weak var resultXPLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 17.5, *) {
            let haptic = UIImpactFeedbackGenerator(style: .light, view: view)
            haptic.impactOccurred(intensity: 1)
        }
        
        currentUserId = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
        updateResultScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateResultScreen()
        
        guard let currentUserId = currentUserId else { return }
        Task {
            await TestDataModel.sharedInstance.fetchUserProgress(userId: currentUserId)
        }
    }
    
    func updateResultScreen() {
        guard let testID = testID, let testScore = testScore, let currentUserId = currentUserId,
              let test = TestDataModel.sharedInstance.giveTest(by: testID) else { return }
        
        [star1ImageView, star2ImageView, star3ImageView, star4ImageView, star5ImageView].forEach { $0?.isHidden = true }
        
        let previousScore = TestDataModel.sharedInstance.getScore(for: currentUserId, testId: test.id)
        
        let xpEarned = (previousScore >= Int(testScore * 5)) ? Int(Double(testXP!) * 0.1) : testXP!
        resultXPLabel.text = "+ \(xpEarned) XP"
        
        let scoreRanges: [(Double, Int, String, String)] = [
            (0.0, 0, "You need to work on your skills!", "Poor performance"),
            (0.2, 1, "Focus more", "Work More"),
            (0.4, 2, "More work can be done", "Practice More"),
            (0.6, 3, "Keep it up!", "Exceeded Expectations"),
            (0.8, 4, "Good Job!", "Good Performance"),
            (1.0, 5, "Awesome Work!", "Awesome Performance")
        ]
        
        for (threshold, stars, comment1, comment2) in scoreRanges {
            if testScore <= threshold {
                for i in 0..<stars {
                    [star1ImageView, star2ImageView, star3ImageView, star4ImageView, star5ImageView][i]?.isHidden = false
                }
                resultComment1.text = comment1
                resultComment2.text = comment2
                return
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? TestListCollectionViewController else { return }
        
        guard let testID = testID, let testScore = testScore, let testXP = testXP, let currentUserId = currentUserId else {
            return
        }
        
        guard let test = TestDataModel.sharedInstance.giveTest(by: testID) else { return }
        
        let newScore = Int(testScore * 5)
        let maxScore = test.questions.count
        let previousScore = TestDataModel.sharedInstance.getScore(for: currentUserId, testId: test.id)
        let finalScore = min(newScore, maxScore)

        if TestDataModel.sharedInstance.userTestScores[currentUserId] == nil {
            TestDataModel.sharedInstance.userTestScores[currentUserId] = [:]
        }
        TestDataModel.sharedInstance.userTestScores[currentUserId]?[test.id] = newScore
        

        Task {
            do {
//                await TestDataModel.sharedInstance.updateLatestScore(for: currentUserId, testID: testID, newScore: newScore)
//                var xpAwarded: Int
//                let isCompleted = true
//                if newScore > previousScore {
//                    xpAwarded = testXP
//                    try await ProfileDataModel.sharedInstance.updateExperiencePoints(xpAwarded)
//                    try await AchievementDataModel.sharedInstance.updateProgress(achievementId: 3, increment: 1)
//                    try await AchievementDataModel.sharedInstance.updateProgress(achievementId: 2, increment: Double(newScore))
//                    
//                    if newScore == maxScore {
//                        try await AchievementDataModel.sharedInstance.updateProgress(achievementId: 2, increment: 1)
//                    }
//                } else {
//                    xpAwarded = Int(Double(testXP) * 0.1)
//                    try await ProfileDataModel.sharedInstance.updateExperiencePoints(xpAwarded)
//                }
//                
//                await TestDataModel.sharedInstance.saveUserProgress(
//                    userId: currentUserId,
//                    testId: test.id,
//                    score: newScore,
//                    xpGained: xpAwarded,
//                    completed: isCompleted
//                )
                // Always update the stored score
                var xpAwarded: Int
                let isCompleted = true
                            await TestDataModel.sharedInstance.updateLatestScore(for: currentUserId, testID: testID, newScore: newScore)
                            
                            if newScore > previousScore {
                                xpAwarded = testXP
                            } else {
                                xpAwarded = Int(Double(testXP) * 0.1)
                            }

                            try await ProfileDataModel.sharedInstance.updateExperiencePoints(xpAwarded)
                            
                            // Update "Complete X Tests" Achievement
                            AchievementDataModel.sharedInstance.updateProgress(achievementId: 3, increment: 1)

                            // Update "Score X XP in X Tests" Achievement
                            AchievementDataModel.sharedInstance.updateProgress(achievementId: 2, increment: Double(newScore))
                            
                            // Optional: reward perfect score attempts
                            if newScore == maxScore {
                                AchievementDataModel.sharedInstance.updateProgress(achievementId: 2, increment: 1)
                            }

                            await TestDataModel.sharedInstance.saveUserProgress(
                                userId: currentUserId,
                                testId: test.id,
                                score: newScore,
                                xpGained: xpAwarded,
                                completed: isCompleted
                                )
            } catch {
                // Handle any errors
            }
        }
    }
}

