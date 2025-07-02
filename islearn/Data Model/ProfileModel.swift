import UIKit
import Foundation
import Supabase

struct ProfileUpdate: Encodable {
    let id: UUID
    let learned_signs: [String]
}

struct Profile: Codable {
    var id: UUID
    var name: String
    var image: String?
    var totalExperiencePoints: Int
    var currentStreak: Int
    var userLongestStreak: Int 
    var notifications: Bool
    var wordsLearned: Int
    var lastActiveDate: Date?
    var showOnboarding: Bool
    var learnedSigns: [String]
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, image, notifications
        case showOnboarding = "show_onboarding"
        case totalExperiencePoints = "total_experience_points"
        case currentStreak = "current_streak"
        case userLongestStreak = "user_longest_streak"
        case wordsLearned = "words_learned"
        case lastActiveDate = "last_active_date"
        case learnedSigns = "learned_signs"
        case createdAt = "created_at"
    }

    mutating func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let lastActiveDay = lastActiveDate else {
            currentStreak = 1
            lastActiveDate = today
            userLongestStreak = max(userLongestStreak, currentStreak)
            return
        }

        let dayDifference = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastActiveDay), to: today).day ?? 0

        if dayDifference == 1 {
            currentStreak += 1
        } else if dayDifference > 1 {
            currentStreak = 1
        }

        lastActiveDate = today
        userLongestStreak = max(userLongestStreak, currentStreak)
    }

    func getUIImage() -> UIImage? {
        guard let image = image,
              let data = Data(base64Encoded: image) else { return nil }
        return UIImage(data: data)
    }
}

class ProfileDataModel {
    static let sharedInstance = ProfileDataModel()
    private var profiles: [Profile] = []
    private var currentUserID: UUID?

    private let storageURL: URL = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("profiles_list").appendingPathExtension("plist")
    }()
    

    private init() {
        loadProfiles()
    }

    func createUserProfile(for user: User) async throws -> Profile {
        let userID = user.id
        let defaultImage = UIImage(systemName: "person.fill") ?? UIImage()
        let imageData = defaultImage.pngData()
        let base64Image = imageData?.base64EncodedString()
        let tempUser = user.email?.components(separatedBy: "@").first ?? "User"

        let newProfile = Profile(
            id: userID,
            name: tempUser,
            image: base64Image,
            totalExperiencePoints: 0,
            currentStreak: 0,
            userLongestStreak: 0,
            notifications: false,
            wordsLearned: 0,
            lastActiveDate: nil,
            showOnboarding: true,
            learnedSigns: [],
            createdAt: Date()
        )

        setCurrentUser(profile: newProfile)

        do {
            _ = try await SupabaseManager.shared.client
                .from("profiles")
                .insert(newProfile)
                .execute()

            return newProfile
        } catch {
            throw error
        }
    }

    func fetchUserProfile(user: User) async -> Profile {
        do {
            print("Fetching user profile for user ID: \(user.id)")
            let response: Profile = try await SupabaseManager.shared.client
                .from("profiles")
                .select()
                .eq("id", value: user.id)
                .single()
                .execute()
                .value
            
            setCurrentUser(profile: response)
            return response
            
        } catch {
            print("Failed to fetch user profile: \(error)")
            return Profile(
                id: UUID(),
                name: "",
                totalExperiencePoints: 0,
                currentStreak: 0,
                userLongestStreak: 0,
                notifications: true,
                wordsLearned: 0,
                showOnboarding: true,
                learnedSigns: [],
                createdAt: Date()
            )
        }
    }

    private func saveProfileLocally(_ profile: Profile) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
        } else {
            profiles.append(profile)
        }
        saveProfiles()
    }

    private func loadProfiles() {
        let decoder = PropertyListDecoder()
        if let data = try? Data(contentsOf: storageURL),
           let decodedProfiles = try? decoder.decode([Profile].self, from: data) {
            profiles = decodedProfiles
        }
    }

    private func saveProfiles() {
        let encoder = PropertyListEncoder()
        if let encodedData = try? encoder.encode(profiles) {
            try? encodedData.write(to: storageURL, options: .atomic)
        }
    }

    func setCurrentUser(profile: Profile) {
//        print("Setting current user profile: \(profile.id)")
//        if !profiles.contains(where: { $0.id == profile.id }) {
//            profiles.append(profile)
//        }
//        currentUserID = profile.id
        print("Setting current user profile: \(profile.id)")
            if !profiles.contains(where: { $0.id == profile.id }) {
                profiles.append(profile)
            }
            currentUserID = profile.id
    }

    func getCurrentUserProfile() -> Profile? {
//        guard let id = currentUserID else { return nil }
//        return profiles.first(where: { $0.id == id })
        guard let id = currentUserID else {
                print("No current user ID found.")
                return nil
            }
            guard let profile = profiles.first(where: { $0.id == id }) else {
                print("No profile found for user ID: \(id)")
                return nil
            }
            return profile
    }

    func updateProfileData(_ username: String, _ userProfile: UIImage, _ userNotif: Bool) {
        guard let id = currentUserID,
              let index = profiles.firstIndex(where: { $0.id == id }) else { return }

        if let imageData = userProfile.jpegData(compressionQuality: 0.8) {
            profiles[index].image = imageData.base64EncodedString()
        }

        profiles[index].name = username
        profiles[index].notifications = userNotif
        saveProfiles()
    }

    func updateExperiencePoints(_ points: Int) async {
        guard let id = currentUserID,
              let index = profiles.firstIndex(where: { $0.id == id }) else { return }

        profiles[index].totalExperiencePoints += points
        saveProfiles()

        do {
            let update = ["total_experience_points": profiles[index].totalExperiencePoints]

            _ = try await SupabaseManager.shared.client
                .from("profiles")
                .update(update)
                .eq("id", value: id.uuidString)
                .execute()
        } catch {
            
        }
    }

    func updateCurrentStreak(for userId: UUID) {
        guard let index = profiles.firstIndex(where: { $0.id == userId }) else { return }

        var profile = profiles[index]
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var currentStreak = profile.currentStreak
        var longestStreak = profile.userLongestStreak
        var lastActiveDate = profile.lastActiveDate

        if let lastDate = lastActiveDate {
            let dayDifference = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastDate), to: today).day ?? 0
            currentStreak = dayDifference == 1 ? currentStreak + 1 : (dayDifference > 1 ? 1 : currentStreak)
        } else {
            currentStreak = 1
        }

        longestStreak = max(longestStreak, currentStreak)
        lastActiveDate = today

        profile.currentStreak = currentStreak
        profile.userLongestStreak = longestStreak
        profile.lastActiveDate = lastActiveDate
        profiles[index] = profile
        saveProfiles()

        Task {
            do {
                let isoDate = ISO8601DateFormatter().string(from: today)
                try await SupabaseManager.shared.client
                    .from("profiles")
                    .update([
                        "current_streak": AnyEncodable(currentStreak),
                        "user_longest_streak": AnyEncodable(longestStreak),
                        "last_active_date": AnyEncodable(isoDate)
                    ])
                    .eq("id", value: userId)
                    .execute()

                BadgesDataModel.sharedInstance.checkAndUnlockBadges(for: userId)
            } catch {
                // Handle silently or log if necessary
            }
        }
    }

    func addLearnedSign(for userId: UUID, newSign: String) async {
        do {
            struct LearnedSignsOnly: Decodable {
                let learned_signs: [String]?
            }

            let response: [LearnedSignsOnly] = try await SupabaseManager.shared.client
                .from("profiles")
                .select("learned_signs")
                .eq("id", value: userId)
                .limit(1)
                .execute()
                .value

            var learnedSigns = response.first?.learned_signs ?? []

            guard !learnedSigns.contains(newSign) else { return }

            learnedSigns.append(newSign)

            try await SupabaseManager.shared.client
                .from("profiles")
                .update(["learned_signs": learnedSigns])
                .eq("id", value: userId)
                .execute()

        } catch {
            // Log or handle if needed
        }
    }

    func updateWordsLearnedCount(for userId: UUID) async throws {
        struct LearnedSignsOnly: Decodable {
            let learned_signs: [String]?
        }

        let response: [LearnedSignsOnly] = try await SupabaseManager.shared.client
            .from("profiles")
            .select("learned_signs")
            .eq("id", value: userId)
            .limit(1)
            .execute()
            .value

        let learnedSigns = response.first?.learned_signs ?? []
        let updatedCount = learnedSigns.count

        try await SupabaseManager.shared.client
            .from("profiles")
            .update(["words_learned": updatedCount])
            .eq("id", value: userId)
            .execute()
    }

    func updateProfileDataFromBase64(_ username: String, _ imageBase64: String, _ userNotif: Bool) {
        guard let userId = currentUserID,
              let index = profiles.firstIndex(where: { $0.id == userId }) else { return }

        profiles[index].name = username
        profiles[index].image = imageBase64
        profiles[index].notifications = userNotif
        saveProfiles()

        struct ProfileUpdate: Encodable {
            let name: String
            let image: String
            let notifications: Bool
        }

        let updatedProfile = ProfileUpdate(name: username, image: imageBase64, notifications: userNotif)

        Task {
            do {
                _ = try await SupabaseManager.shared.client
                    .from("profiles")
                    .update(updatedProfile)
                    .eq("id", value: userId)
                    .execute()
            } catch {
                // Handle silently or log if needed
            }
        }
    }

    func getLearnedSigns() -> [String] {
        guard let id = currentUserID,
              let profile = profiles.first(where: { $0.id == id }) else { return [] }
        return profile.learnedSigns
    }

    func getNotificationSettings() -> Bool {
        guard let id = currentUserID else { return true }
        return profiles.first(where: { $0.id == id })?.notifications ?? true
    }

    func setOnboardingCompleted() {
        guard let id = currentUserID,
              let index = profiles.firstIndex(where: { $0.id == id }) else { return }
        profiles[index].showOnboarding = false
        saveProfiles()
    }

    func deleteProfile(_ id: UUID) {
        profiles.removeAll { $0.id == id }
        if id == currentUserID {
            currentUserID = nil
        }
        saveProfiles()
    }

    func decodeProfile(from data: Data) throws -> Profile {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let formatter = ISO8601DateFormatter()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)

            if let date = formatter.date(from: dateStr) {
                return date
            }

            let fallbackFormatter = DateFormatter()
            fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            if let fallbackDate = fallbackFormatter.date(from: dateStr) {
                return fallbackDate
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateStr)")
        }

        return try decoder.decode(Profile.self, from: data)
    }
}

struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init<T: Encodable>(_ wrapped: T) {
        self._encode = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

