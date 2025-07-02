import UIKit
import PostgREST
import Foundation

struct Test: Codable {
    var id: UUID
    var title: String
    var description: String
    var questions: [Question]
    var themeColor: Color?
//    var previousScore: Int
    var newTest: Bool?
    var testID: Int?
    var testType: TestType?
    
    init(id: UUID = UUID(), title: String, description: String, questions: [Question], themeColor: Color? = nil, newTest: Bool? = nil, testID: Int? = nil, testType: TestType? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.questions = questions
        self.themeColor = themeColor
//        self.previousScore = previousScore
        self.newTest = newTest
        self.testID = testID
        self.testType = testType
    }
}

struct UserTestProgress: Encodable,Decodable {
    let user_id: String
    let test_id: String
    let score: Int
    let xp_gained: Int?
    let completed: Bool
}

struct Color: Codable {
    var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
    
    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    init(uiColor: UIColor) {
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}

enum TestType: String, Equatable, Codable {
    case classic, gesture
    
    var description: String {
        switch self {
        case .classic: return "Classic"
        case .gesture: return "Gesture"
        }
    }
    
    static func == (lhs: TestType, rhs: TestType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

class TestDataModel {
    var userTestScores: [UUID: [UUID: Int]] = [:]
    private var completedTests: [UUID: Set<UUID>] = [:]
    static var sharedInstance: TestDataModel = TestDataModel()

    let supabase = SupabaseManager.shared
    
    private var tests: [Test] = [
        Test(
            id:UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            title: "Alphabets",
            description: "Learn The Alphabets",
            questions: [
                Question(questionTitle: .test, questionStatement: "Identify the Sign A?", answer: 1, options: ["a", "k", "g"], questionType: .mcqB, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 3, options: ["A", "B","C","D"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["G", "H","K","I"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 4, options: ["A", "L","S","D"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 1, options: ["B", "R","U","H"], questionType: .mcqA, questionXP: 50),
            ],
            themeColor: Color(uiColor: .systemBlue),
//            previousScore: 0,
            testID: 11,
            testType: .classic
        ),
//        Test(
//            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
//            title: "Alphabets",
//            description: "Practice The Alphabets",
//            questions: [
//                Question(questionTitle: .test, questionStatement: "Perform The Sign", gestureWord: "A", questionType: .wordGesture, questionXP: 50),
//            ],
//            themeColor: Color(uiColor: .systemBlue),
////            previousScore: 0,
//            testID: 21,
//            testType: .gesture
//        ),
//        Test(
//            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
//            title: "Numbers",
//            description: "Practice The Numbers",
//            questions: [
//                Question(questionTitle: .test, questionStatement: "Perform The Sign", gestureWord: "5", questionType: .wordGesture, questionXP: 50),
//            ],
//            themeColor: Color(uiColor: .systemRed),
////            previousScore: 0,
//            testID: 22,
//            testType: .gesture
//        ),
        Test(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
            title: "Numbers",
            description: "Learn The Digits",
            questions: [
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 3, options: ["1", "9","8","4"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 1, options: ["2", "0","1","6"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["6", "9","0","1"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 4, options: ["1", "2","3","6"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 3, options: ["1", "7","2","9"], questionType: .mcqA, questionXP: 50),
            ],
            themeColor: Color(uiColor: .systemRed),
//            previousScore: 0,
            testID: 12,
            testType: .classic
        ),
        Test(
            title: "Coming Soon",
            description: "More content will be added in the future",
            questions: [],
            themeColor: Color(uiColor: .systemGray),
            testID: 15,
            testType: nil
        )
    ]

    func giveTest(by id: UUID) -> Test? {
        return tests.first { $0.id == id }
    }

    func giveTest(by testID: Int) -> Test? {
        return tests.first { $0.testID == testID }
    }
    
    func giveTest(by testID: Int, type: TestType) -> Test? {
        return tests.first { ($0.testType == type && $0.testID == testID) || ($0.testType == nil) }
    }
    
    func getAllTests() -> [Test] {
        return tests
    }
    
    func getTestsByType(type: TestType) -> [Test] {
        return tests.filter { $0.testType == type }
    }
    
    func giveTestCount(testType: TestType) -> Int {
        return (tests.filter { $0.testType == testType }.count) + 1
    }

    func getScore(for userId: UUID, testId: UUID) -> Int {
        return userTestScores[userId]?[testId] ?? 0
    }

    func isTestCompleted(userId: UUID, testId: UUID) -> Bool {
        return completedTests[userId]?.contains(testId) ?? false
    }
    
    func updateLatestScore(for userId: UUID, testID: Int, newScore: Int) async {
        if let test = giveTest(by: testID) {
            await updateScore(for: userId, testId: test.id, newScore: newScore)

//            if let testIndex = tests.firstIndex(where: { $0.id == test.id }) {
//                tests[testIndex].previousScore = newScore
//            }
        }
    }
    
//    func getLatestScore(for userId: UUID, testID: Int) async -> Int {
//        let hasUserData = userTestScores[userId] != nil && !userTestScores[userId]!.isEmpty
//        
//        if !hasUserData {
//            await fetchUserProgress(userId: userId)
//        }
//        
//        if let test = giveTest(by: testID) {
//            return getScore(for: userId, testId: test.id)
//        }
//        return 0
//    }
    
    func getLatestScore(for userId: UUID, testID: Int, forceRefresh: Bool = false) async -> Int {
        if forceRefresh {
            await fetchUserProgress(userId: userId)
        } else {
            let hasUserData = userTestScores[userId] != nil && !userTestScores[userId]!.isEmpty
            if !hasUserData {
                await fetchUserProgress(userId: userId)
            }
        }

        if let test = giveTest(by: testID) {
            return getScore(for: userId, testId: test.id)
        }
        return 0
    }


    @MainActor
    func updateScore(for userId: UUID, testId: UUID, newScore: Int, xpGained: Int = 0, completed: Bool = false) {
        if userTestScores[userId] == nil {
            userTestScores[userId] = [:]
        }
        userTestScores[userId]?[testId] = newScore

        if completed {
            if completedTests[userId] == nil {
                completedTests[userId] = []
            }
            completedTests[userId]?.insert(testId)
        }

        Task {
            await self.saveUserProgress(
                userId: userId,
                testId: testId,
                score: newScore,
                xpGained: xpGained,
                completed: completed
            )
        }
    }
    
    func fetchUserProgress(userId: UUID) async {
        do {
            // Fetch progress data as an array of UserTestProgress objects
            let response: PostgrestResponse<[UserTestProgress]> = try await SupabaseManager.shared.client
                .from("user_test_progress")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
            
            let progressList = response.value


            // Ensure the user-specific dictionaries are initialized
            await MainActor.run {
                if userTestScores[userId] == nil {
                    userTestScores[userId] = [:]
                }
                if completedTests[userId] == nil {
                    completedTests[userId] = []
                }
            }

            // Loop through each record and update local data
            for progress in progressList {
                guard let testUUID = UUID(uuidString: progress.test_id) else {
                    print("❌ Invalid UUID in test_id:", progress.test_id)
                    continue
                }

                await MainActor.run {
                    userTestScores[userId]?[testUUID] = progress.score
                    if progress.completed {
                        completedTests[userId]?.insert(testUUID)
                    }
                }
            }
        } catch {
            print("❌ Error fetching progress from Supabase:", error)
        }
    }


//    func fetchUserProgress(userId: UUID) async {
//        do {
//            // Assuming user_id is the column name in your table for filtering.
//            let response = try await SupabaseManager.shared
//                .from("user_test_progress")
//                .select()
//                .eq("user_id", value: userId) // Make sure to use the correct column name for user_id
//                .execute()
//             
//               
//
//            // Print the full response to see what it returns
//            print("📦 Full Response:", response)
//
//            // Ensure we get an array of rows in the response
//            guard let rows = response.value as? [[String: Any]] else {
//                print("❌ Could not cast response.value to [[String: Any]]")
//                return
//            }
//
//            print("✅ Rows Fetched:", rows)
//
//            // Make sure the userTestScores and completedTests are initialized properly
//            await MainActor.run {
//                if userTestScores[userId] == nil {
//                    userTestScores[userId] = [:]
//                }
//                if completedTests[userId] == nil {
//                    completedTests[userId] = []
//                }
//            }
//
//            // Iterate over each row and process the data
//            for row in rows {
//                guard
//                    let testIDString = row["test_id"] as? String,
//                    let testUUID = UUID(uuidString: testIDString),
//                    let score = row["score"] as? Int
//                else {
//                    continue
//                }
//
//                // Fetch additional fields (e.g., completed, xp_gained)
//                let completed = row["completed"] as? Bool ?? false
//                let xpGained = row["xp_gained"] as? Int ?? 0
//
//                await MainActor.run {
//                    userTestScores[userId]?[testUUID] = score
//                    if completed {
//                        completedTests[userId]?.insert(testUUID)
//                    }
//                }
//            }
//        } catch {
//            print("❌ Error fetching progress from Supabase:", error)
//        }
//    }

    
    
    func saveUserProgress(userId: UUID, testId: UUID, score: Int, xpGained: Int, completed: Bool) async {
        let progress = UserTestProgress(
            user_id: userId.uuidString,
            test_id: testId.uuidString,
            score: score,
            xp_gained: xpGained,
            completed: completed
        )

        do {
            let response = try await SupabaseManager.shared.client
                .from("user_test_progress")
                .upsert([progress], onConflict: "user_id, test_id")
                .execute()
            
            print("✅ Successfully saved progress to Supabase:", response)
        } catch {
            print("❌ Error saving progress to Supabase:", error)
        }
    }
    
    func deleteData(for userId: UUID) {
        UserDefaults.standard.removeObject(forKey: "testData_\(userId)")
    }
}



