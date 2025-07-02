//import UIKit
//import Foundation
//import Supabase
//import UserNotifications
//
//struct Achievement: Codable {
//    var id: UUID
//    var achievementId: Int
//    var name: String
//    var description: String
//    var currentLevel: Int
//    var currentProgress: Double
//    var maxProgress: Double {
//        didSet {
//            switch self.achievementId {
//            case 1: self.description = "Learn \(Int(maxProgress)) Signs!"
//            case 2: self.description = "Score 200+ XP in \(Int(maxProgress)) Tests!"
//            case 3: self.description = "Complete \(Int(maxProgress)) tests!"
//            case 4: self.description = "Maintain \(Int(maxProgress)) streak!"
//            default: break
//            }
//        }
//    }
//    var completionXP: Int
//    var isCompleted: Bool {
//        return currentLevel == 4
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case achievementId = "achievement_id"
//        case name
//        case description
//        case currentLevel = "current_level"
//        case currentProgress = "current_progress"
//        case maxProgress = "max_progress"
//        case completionXP = "completion_xp"
//    }
//}
//
//struct AchievementUpdate: Encodable {
//    let current_progress: Double
//    let current_level: Int
//    let max_progress: Double
//    let completion_xp: Int
//    let is_completed: Bool
//}
//
//class AchievementDataModel {
//    static let sharedInstance = AchievementDataModel()
//    private var userAchievements: [UUID: [Achievement]] = [:]
//
//    private init() {}
//
//    private func getCurrentUserID() -> UUID? {
//        return ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
//    }
//
//    func fetchUserAchievementsFromSupabase() async throws -> [Achievement] {
//        guard let userId = getCurrentUserID() else {
//            throw NSError(domain: "No user ID", code: 401)
//        }
//
//        let response: PostgrestResponse<[Achievement]> = try await SupabaseManager.shared
//            .from("achievements")
//            .select()
//            .eq("user_id", value: userId.uuidString)
//            .execute()
//
//        return response.value
//    }
//
//    func updateAchievementInSupabase(_ achievement: Achievement, userId: UUID) async throws {
//        let update = AchievementUpdate(
//            current_progress: achievement.currentProgress,
//            current_level: achievement.currentLevel,
//            max_progress: achievement.maxProgress,
//            completion_xp: achievement.completionXP,
//            is_completed: achievement.isCompleted
//        )
//
//        do {
//            _ = try await SupabaseManager.shared
//                .from("achievements")
//                .update(update)
//                .eq("user_id", value: userId.uuidString)
//                .eq("achievement_id", value: achievement.achievementId)
//                .execute()
//        } catch {
//            throw error
//        }
//    }
//
//    func syncFromSupabase() async {
//        guard let userId = getCurrentUserID() else { return }
//        do {
//            let achievements = try await fetchUserAchievementsFromSupabase()
//            userAchievements[userId] = achievements
//        } catch {
//            print("Failed to fetch from Supabase: \(error.localizedDescription)")
//        }
//    }
//
//    func updateProgress(achievementId: Int, increment: Double) {
//        guard let userId = getCurrentUserID() else { return }
//        ensureUserAchievementsExist(for: userId)
//        guard let index = userAchievements[userId]!.firstIndex(where: { $0.achievementId == achievementId }) else { return }
//
//        var achievement = userAchievements[userId]![index]
//
//        if !achievement.isCompleted {
//            if achievement.currentLevel <= 3 {
//                achievement.currentProgress += increment
//                if achievement.currentProgress >= achievement.maxProgress {
//                    achievement.currentLevel += 1
//                    sendAchievementNotification(for: achievement)
//
//                    achievement.currentProgress = achievement.currentProgress.truncatingRemainder(dividingBy: achievement.maxProgress)
//                    achievement.maxProgress *= 1.5
//                    achievement.completionXP = Int(Double(achievement.completionXP) * 1.5)
//
//                    Task {
//                        try await ProfileDataModel.sharedInstance.updateExperiencePoints(achievement.completionXP)
//                    }
//                }
//            }
//        } else {
//            achievement.name = "Completed!"
//            achievement.currentLevel = 4
//            achievement.currentProgress = achievement.maxProgress
//        }
//
//        userAchievements[userId]![index] = achievement
//
//        Task {
//            do {
//                try await updateAchievementInSupabase(achievement, userId: userId)
//            } catch {
//                print("Supabase update error: \(error.localizedDescription)")
//            }
//        }
//    }
//
//    func getAchievementData(_ index: Int) -> Achievement? {
//        guard let userId = getCurrentUserID() else { return nil }
//        ensureUserAchievementsExist(for: userId)
//        return userAchievements[userId]?[index]
//    }
//
//    func getAchievementCount() -> Int {
//        guard let userId = getCurrentUserID() else { return 0 }
//        ensureUserAchievementsExist(for: userId)
//        return userAchievements[userId]?.count ?? 0
//    }
//
//    private func ensureUserAchievementsExist(for userId: UUID) {
//        if userAchievements[userId] == nil {
//            userAchievements[userId] = loadDefaultAchievements()
//        }
//    }
//
//    func updateStreakKeeperAchievement(with streakCount: Int) {
//        let progress = min(Double(streakCount), 100.0)
//        updateProgress(achievementId: 4, increment: progress)
//    }
//
//    private func loadDefaultAchievements() -> [Achievement] {
//        return [
//            Achievement(id: UUID(), achievementId: 1, name: "Sign Apprentice", description: "Learn 5 Signs!", currentLevel: 1, currentProgress: 0, maxProgress: 5, completionXP: 100),
//            Achievement(id: UUID(), achievementId: 2, name: "Test Conqueror", description: "Score 200+ XP in 5 Tests!", currentLevel: 1, currentProgress: 0, maxProgress: 5, completionXP: 150),
//            Achievement(id: UUID(), achievementId: 3, name: "Test Titan", description: "Complete 5 tests!", currentLevel: 1, currentProgress: 0, maxProgress: 5, completionXP: 200),
//            Achievement(id: UUID(), achievementId: 4, name: "Streak Guardian", description: "Maintain 100 streak!", currentLevel: 1, currentProgress: 0, maxProgress: 10, completionXP: 250),
//        ]
//    }
//
//    private func sendAchievementNotification(for achievement: Achievement) {
//        let notification = UNMutableNotificationContent()
//        notification.body = "Achievement Unlocked!"
//        notification.title = achievement.name
//        notification.sound = .default
//
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//        let request = UNNotificationRequest(identifier: "AchievementNotification", content: notification, trigger: trigger)
//
//        if ProfileDataModel.sharedInstance.getNotificationSettings() {
//            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//        }
//    }
//
//
//    func resetToDefault(for userId: UUID) {
//        userAchievements[userId] = loadDefaultAchievements()
//    }
//
//    func deleteData(for userId: UUID) {
//        userAchievements.removeValue(forKey: userId)
//    }
//}


import UIKit
import Foundation
import Supabase
import UserNotifications

struct Achievement: Codable {
    var id: UUID
    var achievementId: Int
    var name: String
    var description: String
    var currentLevel: Int
    var currentProgress: Double
    var maxProgress: Double {
        didSet {
            updateDescription()
        }
    }
    var completionXP: Int
    var isCompleted: Bool {
        return currentLevel == 4
    }

    enum CodingKeys: String, CodingKey {
        case id
        case achievementId = "achievement_id"
        case name
        case description
        case currentLevel = "current_level"
        case currentProgress = "current_progress"
        case maxProgress = "max_progress"
        case completionXP = "completion_xp"
    }
    
    mutating func updateDescription() {
        switch self.achievementId {
        case 1: self.description = "Learn \(Int(maxProgress)) Signs!"
        case 2: self.description = "Score \(Int(maxProgress) * 40)+ XP in \(Int(maxProgress)) Tests!"
        case 3: self.description = "Complete \(Int(maxProgress)) tests!"
        case 4: self.description = "Maintain \(Int(maxProgress)) streak!"
        default: break
        }
    }
}

struct AchievementUpdate: Encodable {
    let current_progress: Double
    let current_level: Int
    let max_progress: Double
    let completion_xp: Int
    let is_completed: Bool
    let description: String
}

class AchievementDataModel {
    static let sharedInstance = AchievementDataModel()
    private var userAchievements: [UUID: [Achievement]] = [:]

    private init() {}

    private func getCurrentUserID() -> UUID? {
        return ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
    }

    func fetchUserAchievementsFromSupabase() async throws -> [Achievement] {
        guard let userId = getCurrentUserID() else {
            throw NSError(domain: "No user ID", code: 401)
        }
        
        print("🟡 Starting achievement sync from Supabase...")

        let response: PostgrestResponse<[Achievement]> = try await SupabaseManager.shared.client
            .from("achievements")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("achievement_id", ascending: true)
            .execute()
        
        print("🟢 Fetched \(response.value.count) achievements from Supabase")
            if let first = response.value.first {
                print("📦 First achievement: \(first.name), Level: \(first.currentLevel)")
            }

        return response.value
    }

    func updateAchievementInSupabase(_ achievement: Achievement, userId: UUID) async throws {
        var update = AchievementUpdate(
            current_progress: achievement.currentProgress,
            current_level: achievement.currentLevel,
            max_progress: achievement.maxProgress,
            completion_xp: achievement.completionXP,
            is_completed: achievement.isCompleted,
            description: achievement.description
        )

        if(achievement.isCompleted==true){
            let temp = "Completed!"
            update = AchievementUpdate(
                current_progress: achievement.currentProgress,
                current_level: achievement.currentLevel,
                max_progress: achievement.maxProgress,
                completion_xp: achievement.completionXP,
                is_completed: achievement.isCompleted,
                description: temp
            )
        }
        do {
            _ = try await SupabaseManager.shared.client
                .from("achievements")
                .update(update)
                .eq("user_id", value: userId.uuidString)
                .eq("achievement_id", value: achievement.achievementId)
                .execute()
        } catch {
            throw error
        }
    }
    
    func syncFromSupabase() async {
        guard let userId = getCurrentUserID() else { return }
        do {
            let achievements = try await fetchUserAchievementsFromSupabase()
            userAchievements[userId] = achievements
        } catch {
            print("Failed to fetch from Supabase: \(error.localizedDescription)")
        }
    }

    func updateProgress(achievementId: Int, increment: Double) {
        guard let userId = getCurrentUserID() else { return }
        ensureUserAchievementsExist(for: userId)
        guard let index = userAchievements[userId]!.firstIndex(where: { $0.achievementId == achievementId }) else { return }

        var achievement = userAchievements[userId]![index]

        if !achievement.isCompleted {
            if achievement.currentLevel <= 3 {
                achievement.currentProgress += increment
                if achievement.currentProgress >= achievement.maxProgress {
                    achievement.currentLevel += 1
                    sendAchievementNotification(for: achievement)

                    achievement.currentProgress = achievement.currentProgress.truncatingRemainder(dividingBy: achievement.maxProgress)
                    achievement.maxProgress *= 1.5
                    achievement.completionXP = Int(Double(achievement.completionXP) * 1.5)

                    achievement.updateDescription()

                    Task {
                        try await ProfileDataModel.sharedInstance.updateExperiencePoints(achievement.completionXP)
                    }
                }
            }
        } else {
            achievement.name = "Completed!"
            achievement.currentLevel = 4
            achievement.currentProgress = achievement.maxProgress
        }

        userAchievements[userId]![index] = achievement

        Task {
            do {
                try await updateAchievementInSupabase(achievement, userId: userId)
            } catch {
                print("Supabase update error: \(error.localizedDescription)")
            }
        }
    }

    func getAchievementData(_ index: Int) -> Achievement? {
        guard let userId = getCurrentUserID() else { return nil }
        ensureUserAchievementsExist(for: userId)
        return userAchievements[userId]?[index]
    }

    func getAchievementCount() -> Int {
        guard let userId = getCurrentUserID() else { return 0 }
        ensureUserAchievementsExist(for: userId)
        return userAchievements[userId]?.count ?? 0
    }

    private func ensureUserAchievementsExist(for userId: UUID) {
        if userAchievements[userId] == nil {
            userAchievements[userId] = loadDefaultAchievements()
        }
    }

    func updateStreakKeeperAchievement(with streakCount: Int) {
        let progress = min(Double(streakCount), 100.0)
        updateProgress(achievementId: 4, increment: progress)
    }

        private func loadDefaultAchievements() -> [Achievement] {
            return [
                Achievement(id: UUID(), achievementId: 1, name: "Sign Apprentice", description: "Learn 5 Signs!", currentLevel: 1, currentProgress: 0, maxProgress: 5, completionXP: 100),
                Achievement(id: UUID(), achievementId: 2, name: "Test Conqueror", description: "Score 200+ XP in 5 Tests!", currentLevel: 1, currentProgress: 0, maxProgress: 5, completionXP: 150),
                Achievement(id: UUID(), achievementId: 3, name: "Test Titan", description: "Complete 5 tests!", currentLevel: 1, currentProgress: 0, maxProgress: 5, completionXP: 200),
                Achievement(id: UUID(), achievementId: 4, name: "Streak Guardian", description: "Maintain 100 streak!", currentLevel: 1, currentProgress: 0, maxProgress: 10, completionXP: 250),
            ]
        }

    private func sendAchievementNotification(for achievement: Achievement) {
        let notification = UNMutableNotificationContent()
        notification.body = "Achievement Unlocked!"
        notification.title = achievement.name
        notification.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "AchievementNotification", content: notification, trigger: trigger)

        if ProfileDataModel.sharedInstance.getNotificationSettings() {
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    func checkAndUnlockAchievements(for userId: UUID) async {
        do {
            let achievements = try await fetchUserAchievementsFromSupabase()
            userAchievements[userId] = achievements
        } catch {
            print("Failed to sync achievements: \(error.localizedDescription)")
            return
        }

        ensureUserAchievementsExist(for: userId)

        let currentStreak = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.currentStreak ?? 0
        updateProgress(achievementId: 4, increment: Double(currentStreak))
    }

    
    func deleteData(for userId: UUID) async {
            await withCheckedContinuation { continuation in
                UserDefaults.standard.removeObject(forKey: "achievements_\(userId)")
                continuation.resume()
            }
        }

        func resetToDefault(for userId: UUID) {
            let defaultAchievements = loadDefaultAchievements()
            UserDefaults.standard.set(defaultAchievements, forKey: "achievements_\(userId)")
        }
}

