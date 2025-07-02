import Foundation
import UIKit
import PostgREST

struct Badge: Codable, Identifiable, Equatable {
    var id: UUID
    var badgeId: Int
    var name: String
    var description: String
    var isCompleted: Bool

    var displayColor: UIColor {
        return isCompleted ? .systemOrange : .systemGray4
    }

    enum CodingKeys: String, CodingKey {
        case id
        case badgeId = "badge_id"
        case name
        case description
        case isCompleted = "is_completed"
    }
}

struct BadgeUpdate: Encodable {
    let is_completed: Bool
}

class BadgesDataModel {
    static let sharedInstance = BadgesDataModel()

    private var userBadges: [UUID: [Badge]] = [:]

    private let predefinedBadges: [Badge] = [
        Badge(id: UUID(), badgeId: 1, name: "1", description: "Complete lessons for 10 days straight!", isCompleted: false),
        Badge(id: UUID(), badgeId: 2, name: "25", description: "Complete lessons for 25 days straight!", isCompleted: false),
        Badge(id: UUID(), badgeId: 3, name: "50", description: "Complete lessons for 50 days straight!", isCompleted: false),
        Badge(id: UUID(), badgeId: 4, name: "100", description: "Complete lessons for 100 days straight!", isCompleted: false)
    ]

    private init() {}

    private func getCurrentUserID() -> UUID? {
        return ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
    }

    // MARK: - Supabase

    func fetchUserBadgesFromSupabase() async throws -> [Badge] {
        guard let userId = getCurrentUserID() else {
            throw NSError(domain: "No user ID", code: 401)
        }

        let response: PostgrestResponse<[Badge]> = try await SupabaseManager.shared.client
            .from("badges")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()

        return response.value
    }

    func updateBadgeInSupabase(_ badge: Badge) async throws {
        guard let userId = getCurrentUserID() else {
            throw NSError(domain: "No user ID", code: 401)
        }

        let update = BadgeUpdate(is_completed: true)

        _ = try await SupabaseManager.shared.client
            .from("badges")
            .update(update)
            .eq("user_id", value: userId.uuidString)
            .eq("badge_id", value: badge.badgeId)
            .execute()
    }

    func insertInitialBadgesToSupabaseIfNeeded(for userId: UUID) async {
        struct BadgeUpsert: Encodable {
            let id: UUID
            let badge_id: Int
            let user_id: UUID
            let name: String
            let description: String
            let is_completed: Bool
        }

        do {
            let existingBadges = try await fetchUserBadgesFromSupabase()

            if existingBadges.isEmpty {
                let badgesToInsert: [BadgeUpsert] = predefinedBadges.map {
                    BadgeUpsert(
                        id: UUID(),
                        badge_id: $0.badgeId,
                        user_id: userId,
                        name: $0.name,
                        description: $0.description,
                        is_completed: false
                    )
                }

                _ = try await SupabaseManager.shared.client
                    .from("badges")
                    .upsert(badgesToInsert, onConflict: "user_id,badge_id")
                    .execute()
            }
        } catch {
            // Silent fail — optionally handle/log
        }
    }

    func syncFromSupabase() async {
        guard let userId = getCurrentUserID() else { return }

        do {
            let badges = try await fetchUserBadgesFromSupabase()
            userBadges[userId] = badges
        } catch {
            // Silent fail — optionally handle/log
        }
    }

    // MARK: - Local Logic

    func getBadgesData(_ id: Int) -> Badge? {
        guard let userId = getCurrentUserID() else { return nil }
        ensureUserBadgesExist(for: userId)
        return userBadges[userId]?.first(where: { $0.badgeId == id })
    }

    func updateBadgeStatus(badgeId: Int) {
        guard let userId = getCurrentUserID() else { return }
        ensureUserBadgesExist(for: userId)

        guard let index = userBadges[userId]?.firstIndex(where: { $0.badgeId == badgeId }) else {
            return
        }

        var badge = userBadges[userId]![index]

        if !badge.isCompleted {
            badge.isCompleted = true
            userBadges[userId]![index] = badge

            Task {
                do {
                    try await updateBadgeInSupabase(badge)
                } catch {
                    // Silent fail — optionally handle/log
                }
            }
        }
    }

    func checkAndUnlockBadges(for userId: UUID) {
        ensureUserBadgesExist(for: userId)

        let currentStreak = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.currentStreak ?? 0

        for badge in userBadges[userId]! where !badge.isCompleted {
            switch badge.badgeId {
                case 1 where currentStreak >= 1,
                     2 where currentStreak >= 25,
                     3 where currentStreak >= 50,
                     4 where currentStreak >= 100:
                    updateBadgeStatus(badgeId: badge.badgeId)
                default: break
            }
        }
    }

    func ensureUserBadgesExist(for userId: UUID) {
        if userBadges[userId] == nil {
            let initializedBadges = predefinedBadges.map {
                Badge(
                    id: UUID(),
                    badgeId: $0.badgeId,
                    name: $0.name,
                    description: $0.description,
                    isCompleted: false
                )
            }
            userBadges[userId] = initializedBadges
            Task {
                await insertInitialBadgesToSupabaseIfNeeded(for: userId)
            }
        }
    }

    func getBadgesCount() -> Int {
        guard let userId = getCurrentUserID() else { return 0 }
        ensureUserBadgesExist(for: userId)
        return userBadges[userId]?.count ?? 0
    }

//    func resetToDefault(for userId: UUID) {
//        userBadges[userId] = predefinedBadges.map {
//            Badge(
//                id: UUID(),
//                badgeId: $0.badgeId,
//                name: $0.name,
//                description: $0.description,
//                isCompleted: false
//            )
//        }
//    }
    
    func deleteData(for userId: UUID) {
            UserDefaults.standard.removeObject(forKey: "badges_\(userId)")
        }

        func resetToDefault(for userId: UUID) {
            let defaultBadgesData = predefinedBadges.map {
                        [
                            "id": $0.id.uuidString,
                            "badgeId": $0.badgeId,
                            "name": $0.name,
                            "description": $0.description,
                            "isCompleted": $0.isCompleted
                        ]
                    }
                    UserDefaults.standard.set(defaultBadgesData, forKey: "badges_\(userId)")
        }
}

