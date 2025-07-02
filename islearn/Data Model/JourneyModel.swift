//import Foundation
//import UIKit
//import CryptoKit
//import Supabase
//
//extension UIColor {
//    static let themeColor = UIColor(red: 0/255, green: 161/255, blue: 255/255, alpha: 1.0)
//}
//
//struct RectangularButton: Codable {
//    var id: UUID
//    var color: Color
//    var title: String
//    var description: String
//    
//    init(id: UUID = UUID(), color: Color, title: String, description: String) {
//        self.id = id
//        self.color = color
//        self.title = title
//        self.description = description
//    }
//}
//
//struct Exercise: Codable {
//    var id: UUID
//    var sectionId: UUID
//    var name: String
//    var video: String
//    
//    init(id: UUID = UUID(), sectionId: UUID, name: String, video: String) {
//        self.id = id
//        self.sectionId = sectionId
//        self.name = name
//        self.video = video
//    }
//}
//
//struct Section: Codable {
//    var id: UUID
//    var title: String
//    var exercises: [Exercise]
//    
//    init(id: UUID = UUID(), title: String, exercises: [Exercise]) {
//        self.id = id
//        self.title = title
//        self.exercises = exercises
//    }
//}
//
//struct JourneyExercise: Codable {
//    let id: UUID
//    let section_id: UUID
//    let name: String
//    let video: String
//    let created_at: String
//}
//
//struct JourneySection: Codable {
//    let id: UUID
//    let title: String
//    let created_at: String
//}
//
//struct UserJourneyProgress: Codable {
//    let user_id: UUID
//    let exercise_id: UUID
//    let completed: Bool
//    let is_locked: Bool
//}
//
//struct Journey: Codable {
//    var id: UUID
//    var section: [Section]
//    
//    init(id: UUID = UUID(), section: [Section]) {
//        self.id = id
//        self.section = section
//    }
//}
//
//struct UserExerciseProgress: Codable {
//    var userId: UUID
//    var exerciseId: UUID
//    var completed: Bool
//    var isLocked: Bool
//}
//
//class JourneyDataModel {
//    static var shared = JourneyDataModel()
//    private var userJourneys: [UUID: Journey] = [:]
//    private var userProgressMap: [UUID: [UUID: UserExerciseProgress]] = [:]
//
//    private init() {
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let archiveURl = documentsDirectory.appendingPathComponent("user_journeys").appendingPathExtension("plist")
//        
//        let propertyDecoder = PropertyListDecoder()
//        if let retrievedData = try? Data(contentsOf: archiveURl),
//           let decodedUserJourneys = try? propertyDecoder.decode([String: Journey].self, from: retrievedData) {
//            for (key, value) in decodedUserJourneys {
//                if let uuid = UUID(uuidString: key) {
//                    userJourneys[uuid] = value
//                }
//            }
//        }
//    }
//
//    func getJourney(for userId: UUID, forceRefresh: Bool = false) async throws -> Journey {
//        if !forceRefresh, let cached = userJourneys[userId] {
//            return cached
//        }
//
//        let client = SupabaseManager.shared.client
//
//        let rawSections: [JourneySection] = try await client
//            .from("journey_sections")
//            .select()
//            .order("title", ascending: true)
//            .execute()
//            .value
//
//        let progressList: [UserJourneyProgress] = try await client
//            .from("user_journey_progress")
//            .select()
//            .eq("user_id", value: userId)
//            .execute()
//            .value
//
//        let progressMap = Dictionary(uniqueKeysWithValues: progressList.map { ($0.exercise_id, $0) })
//
//        var allSections: [Section] = []
//
//        for rawSection in rawSections {
//            let rawExercises: [JourneyExercise] = try await client
//                .from("journey_exercises")
//                .select()
//                .eq("section_id", value: rawSection.id)
//                .order("name", ascending: true)
//                .execute()
//                .value
//
//            var exercises: [Exercise] = []
//
//            for (index, rawExercise) in rawExercises.enumerated() {
//                let progress = progressMap[rawExercise.id]
//                let completed = progress?.completed ?? false
//                let isLocked = progress?.is_locked ?? (index != 0)
//
//                let exercise = Exercise(
//                    id: rawExercise.id,
//                    sectionId: rawExercise.section_id,
//                    name: rawExercise.name,
//                    video: rawExercise.video
//                )
//                exercises.append(exercise)
//
//                var userProgressDict = userProgressMap[userId] ?? [:]
//                userProgressDict[rawExercise.id] = UserExerciseProgress(
//                    userId: userId,
//                    exerciseId: rawExercise.id,
//                    completed: completed,
//                    isLocked: isLocked
//                )
//                userProgressMap[userId] = userProgressDict
//            }
//
//            allSections.append(Section(id: rawSection.id, title: rawSection.title, exercises: exercises))
//        }
//
//        let journey = Journey(id: UUID(), section: allSections)
//        userJourneys[userId] = journey
//        return journey
//    }
//
//    func initializeProgressIfNeeded(for userId: UUID, journey: Journey) async throws {
//        let client = SupabaseManager.shared.client
//        let existingProgress: [UserJourneyProgress] = try await client
//            .from("user_journey_progress")
//            .select()
//            .eq("user_id", value: userId)
//            .execute()
//            .value
//
//        let existingExerciseIds = Set(existingProgress.map { $0.exercise_id })
//        let allExercises = journey.section.flatMap { $0.exercises }
//
//        var newProgress: [UserJourneyProgress] = []
//        for (index, exercise) in allExercises.enumerated() {
//            if !existingExerciseIds.contains(exercise.id) {
//                newProgress.append(
//                    UserJourneyProgress(
//                        user_id: userId,
//                        exercise_id: exercise.id,
//                        completed: false,
//                        is_locked: index != 0
//                    )
//                )
//            }
//        }
//
//        if !newProgress.isEmpty {
//            try await client
//                .from("user_journey_progress")
//                .insert(newProgress)
//                .execute()
//        }
//    }
//
//    func completeExercise(for userId: UUID, sectionTitle: String, exerciseName: String) async {
//        do {
//            if userJourneys[userId] == nil {
//                let journey = try await getJourney(for: userId)
//                userJourneys[userId] = journey
//            }
//
//            guard let journey = userJourneys[userId],
//                  let section = journey.section.first(where: { $0.title == sectionTitle }),
//                  let exercise = section.exercises.first(where: { $0.name == exerciseName }) else {
//                return
//            }
//
//            let client = SupabaseManager.shared.client
//            let progress = UserJourneyProgress(
//                user_id: userId,
//                exercise_id: exercise.id,
//                completed: true,
//                is_locked: false
//            )
//
//            Task {
//                try await BadgesDataModel.sharedInstance.checkAndUnlockBadges(for: userId)
//            }
//
//            try await client
//                .from("user_journey_progress")
//                .upsert(progress, onConflict: "user_id,exercise_id")
//                .execute()
//
//            try await unlockNextExercise(for: userId, in: sectionTitle, after: exerciseName)
//
//            if let sectionIndex = journey.section.firstIndex(where: { $0.title == sectionTitle }),
//               exerciseName == journey.section[sectionIndex].exercises.last?.name {
//                try await unlockFirstExerciseOfNextSection(for: userId, from: sectionIndex)
//            }
//
//        } catch {
//            print("❌ Error in completeExercise: \(error)")
//        }
//    }
//
//    func unlockNextExercise(for userId: UUID, in sectionTitle: String, after exerciseName: String) async throws {
//        guard let journey = userJourneys[userId],
//              let section = journey.section.first(where: { $0.title == sectionTitle }),
//              let currentIndex = section.exercises.firstIndex(where: { $0.name == exerciseName }),
//              currentIndex + 1 < section.exercises.count else { return }
//
//        let nextExercise = section.exercises[currentIndex + 1]
//        let client = SupabaseManager.shared.client
//
//        let progress = UserJourneyProgress(
//            user_id: userId,
//            exercise_id: nextExercise.id,
//            completed: false,
//            is_locked: false
//        )
//
//        try await client
//            .from("user_journey_progress")
//            .upsert(progress, onConflict: "user_id,exercise_id")
//            .execute()
//    }
//
//    func unlockFirstExerciseOfNextSection(for userId: UUID, from sectionIndex: Int) async throws {
//        guard let journey = userJourneys[userId],
//              sectionIndex + 1 < journey.section.count else { return }
//
//        let nextSection = journey.section[sectionIndex + 1]
//        guard let nextExercise = nextSection.exercises.first else { return }
//
//        let client = SupabaseManager.shared.client
//
//        let progress = UserJourneyProgress(
//            user_id: userId,
//            exercise_id: nextExercise.id,
//            completed: false,
//            is_locked: false
//        )
//
//        try await client
//            .from("user_journey_progress")
//            .upsert(progress, onConflict: "user_id,exercise_id")
//            .execute()
//    }
//
//    func isExerciseCompleted(for userId: UUID, sectionTitle: String, exerciseName: String) -> Bool {
//        guard let journey = userJourneys[userId],
//              let section = journey.section.first(where: { $0.title == sectionTitle }),
//              let exercise = section.exercises.first(where: { $0.name == exerciseName }) else {
//            return false
//        }
//
//        return userProgressMap[userId]?[exercise.id]?.completed ?? false
//    }
//
//    func isExerciseLocked(for userId: UUID, sectionTitle: String, exerciseName: String) -> Bool {
//        guard let journey = userJourneys[userId],
//              let section = journey.section.first(where: { $0.title == sectionTitle }),
//              let exercise = section.exercises.first(where: { $0.name == exerciseName }) else {
//            return true
//        }
//
//        if let progress = userProgressMap[userId]?[exercise.id] {
//            return progress.isLocked
//        }
//
//        if let progress = userProgressMap[userId]?.first(where: { (_, prog) in
//            userJourneys[userId]?.section
//                .flatMap({ $0.exercises })
//                .first(where: { $0.id == prog.exerciseId })?.name == exerciseName
//        })?.value {
//            return progress.isLocked
//        }
//
//        return true
//    }
//
////    func deleteData(for userId: UUID) {
////        userJourneys[userId] = nil
////    }
//    
//    func deleteData(for userId: UUID) {
//            UserDefaults.standard.removeObject(forKey: "journey_\(userId)")
//    }
//
//    func deleteAllData() {
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let archiveURl = documentsDirectory.appendingPathComponent("user_journeys").appendingPathExtension("plist")
//        try? FileManager.default.removeItem(at: archiveURl)
//        userJourneys = [:]
//    }
//}
//
//
//
////extension UUID {
////    static func deterministic(from string: String) -> UUID {
////        let hash = SHA256.hash(data: Data(string.utf8))
////        let uuidBytes = Array(hash.prefix(16))
////        return UUID(uuid: (
////            uuidBytes[0], uuidBytes[1], uuidBytes[2], uuidBytes[3],
////            uuidBytes[4], uuidBytes[5],
////            uuidBytes[6], uuidBytes[7],
////            uuidBytes[8], uuidBytes[9],
////            uuidBytes[10], uuidBytes[11], uuidBytes[12], uuidBytes[13], uuidBytes[14], uuidBytes[15]
////        ))
////    }
////}
//
//
import Foundation
import UIKit
import CryptoKit
import Supabase

extension UIColor {
    static let themeColor = UIColor(red: 0/255, green: 161/255, blue: 255/255, alpha: 1.0)
}

struct RectangularButton: Codable {
    var id: UUID
    var color: Color
    var title: String
    var description: String

    init(id: UUID = UUID(), color: Color, title: String, description: String) {
        self.id = id
        self.color = color
        self.title = title
        self.description = description
    }
}

struct Exercise: Codable {
    var id: UUID
    var sectionId: UUID
    var name: String
    var video: String

    init(id: UUID = UUID(), sectionId: UUID, name: String, video: String) {
        self.id = id
        self.sectionId = sectionId
        self.name = name
        self.video = video
    }
}

struct Section: Codable {
    var id: UUID
    var title: String
    var exercises: [Exercise]

    init(id: UUID = UUID(), title: String, exercises: [Exercise]) {
        self.id = id
        self.title = title
        self.exercises = exercises
    }
}

struct JourneyExercise: Codable {
    let id: UUID
    let section_id: UUID
    let name: String
    let video: String
    let created_at: String
}

struct JourneySection: Codable {
    let id: UUID
    let title: String
    let created_at: String
}

struct UserJourneyProgress: Codable {
    let user_id: UUID
    let exercise_id: UUID
    let completed: Bool
    let is_locked: Bool
}

struct Journey: Codable {
    var id: UUID
    var section: [Section]

    init(id: UUID = UUID(), section: [Section]) {
        self.id = id
        self.section = section
    }
}

struct UserExerciseProgress: Codable {
    var userId: UUID
    var exerciseId: UUID
    var completed: Bool
    var isLocked: Bool
}

actor JourneyCache {
    private var userJourneys: [UUID: Journey] = [:]
    private var userProgressMap: [UUID: [UUID: UserExerciseProgress]] = [:]

    func getJourney(for userId: UUID) -> Journey? {
        return userJourneys[userId]
    }

    func setJourney(_ journey: Journey, for userId: UUID) {
        userJourneys[userId] = journey
    }

    func getProgress(for userId: UUID, exerciseId: UUID) -> UserExerciseProgress? {
        return userProgressMap[userId]?[exerciseId]
    }

    func setProgress(for userId: UUID, progress: UserExerciseProgress) {
        if userProgressMap[userId] == nil {
            userProgressMap[userId] = [:]
        }
        userProgressMap[userId]?[progress.exerciseId] = progress
    }

    func getAllProgress(for userId: UUID) -> [UUID: UserExerciseProgress]? {
        return userProgressMap[userId]
    }

    func clearAll() {
        userJourneys.removeAll()
        userProgressMap.removeAll()
    }
}

class JourneyDataModel {
    static var shared = JourneyDataModel()
    private let cache = JourneyCache()
//    private let cache = JourneyCache()


    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURl = documentsDirectory.appendingPathComponent("user_journeys").appendingPathExtension("plist")

        let propertyDecoder = PropertyListDecoder()
        if let retrievedData = try? Data(contentsOf: archiveURl),
           let decodedUserJourneys = try? propertyDecoder.decode([String: Journey].self, from: retrievedData) {
            Task {
                for (key, value) in decodedUserJourneys {
                    if let uuid = UUID(uuidString: key) {
                        await cache.setJourney(value, for: uuid)
                    }
                }
            }
        }
    }

    func getJourney(for userId: UUID, forceRefresh: Bool = false) async throws -> Journey {
        if !forceRefresh, let cached = await cache.getJourney(for: userId) {
            return cached
        }

        let client = SupabaseManager.shared.client

        let rawSections: [JourneySection] = try await client
            .from("journey_sections")
            .select()
            .order("title", ascending: true)
            .execute()
            .value

        let progressList: [UserJourneyProgress] = try await client
            .from("user_journey_progress")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value

        let progressMap = Dictionary(uniqueKeysWithValues: progressList.map { ($0.exercise_id, $0) })

        var allSections: [Section] = []

        for rawSection in rawSections {
            let rawExercises: [JourneyExercise] = try await client
                .from("journey_exercises")
                .select()
                .eq("section_id", value: rawSection.id)
                .order("name", ascending: true)
                .execute()
                .value

            var exercises: [Exercise] = []

            for (index, rawExercise) in rawExercises.enumerated() {
                let progress = progressMap[rawExercise.id]
                let completed = progress?.completed ?? false
                let isLocked = progress?.is_locked ?? (index != 0)

                let exercise = Exercise(
                    id: rawExercise.id,
                    sectionId: rawExercise.section_id,
                    name: rawExercise.name,
                    video: rawExercise.video
                )
                exercises.append(exercise)

                let userProgress = UserExerciseProgress(
                    userId: userId,
                    exerciseId: rawExercise.id,
                    completed: completed,
                    isLocked: isLocked
                )
                await cache.setProgress(for: userId, progress: userProgress)
            }

            allSections.append(Section(id: rawSection.id, title: rawSection.title, exercises: exercises))
        }

        let journey = Journey(id: UUID(), section: allSections)
        await cache.setJourney(journey, for: userId)
        return journey
    }

    func completeExercise(for userId: UUID, sectionTitle: String, exerciseName: String) async {
        do {
            if await cache.getJourney(for: userId) == nil {
                let journey = try await getJourney(for: userId)
                await cache.setJourney(journey, for: userId)
            }

            guard let journey = await cache.getJourney(for: userId),
                  let section = journey.section.first(where: { $0.title == sectionTitle }),
                  let exercise = section.exercises.first(where: { $0.name == exerciseName }) else {
                return
            }

            let client = SupabaseManager.shared.client
            let progress = UserJourneyProgress(
                user_id: userId,
                exercise_id: exercise.id,
                completed: true,
                is_locked: false
            )

            Task {
                try await BadgesDataModel.sharedInstance.checkAndUnlockBadges(for: userId)
            }

            try await client
                .from("user_journey_progress")
                .upsert(progress, onConflict: "user_id,exercise_id")
                .execute()

            try await unlockNextExercise(for: userId, in: sectionTitle, after: exerciseName)

            if let sectionIndex = journey.section.firstIndex(where: { $0.title == sectionTitle }),
               exerciseName == journey.section[sectionIndex].exercises.last?.name {
                try await unlockFirstExerciseOfNextSection(for: userId, from: sectionIndex)
            }

        } catch {
            print("❌ Error in completeExercise: \(error)")
        }
    }


    func unlockFirstExerciseOfNextSection(for userId: UUID, from sectionIndex: Int) async throws {
        guard let journey = await cache.getJourney(for: userId),
                 sectionIndex + 1 < journey.section.count else { return }
   
           let nextSection = journey.section[sectionIndex + 1]
           guard let nextExercise = nextSection.exercises.first else { return }
   
           let client = SupabaseManager.shared.client
   
           let progress = UserJourneyProgress(
               user_id: userId,
               exercise_id: nextExercise.id,
               completed: false,
               is_locked: false
           )
   
           try await client
               .from("user_journey_progress")
               .upsert(progress, onConflict: "user_id,exercise_id")
               .execute()
       }
    
    func unlockNextExercise(for userId: UUID, in sectionTitle: String, after exerciseName: String) async throws {
        guard let journey = await cache.getJourney(for: userId),
                 let section = journey.section.first(where: { $0.title == sectionTitle }),
                 let currentIndex = section.exercises.firstIndex(where: { $0.name == exerciseName }),
                 currentIndex + 1 < section.exercises.count else { return }
   
           let nextExercise = section.exercises[currentIndex + 1]
           let client = SupabaseManager.shared.client
   
           let progress = UserJourneyProgress(
               user_id: userId,
               exercise_id: nextExercise.id,
               completed: false,
               is_locked: false
           )
   
           try await client
               .from("user_journey_progress")
               .upsert(progress, onConflict: "user_id,exercise_id")
               .execute()
       }
    
    
    func isExerciseCompleted(for userId: UUID, sectionTitle: String, exerciseName: String) async -> Bool {
        guard let journey = try? await cache.getJourney(for: userId),
              let section = journey.section.first(where: { $0.title == sectionTitle }),
              let exercise = section.exercises.first(where: { $0.name == exerciseName }) else {
            return false
        }

        if let progress = try? await cache.getProgress(for: userId, exerciseId: exercise.id) {
            return progress.completed
        }

        return false
    }

    func isExerciseLocked(for userId: UUID, sectionTitle: String, exerciseName: String) async -> Bool {
        guard let journey = try? await cache.getJourney(for: userId),
              let section = journey.section.first(where: { $0.title == sectionTitle }),
              let exercise = section.exercises.first(where: { $0.name == exerciseName }) else {
            return true
        }

        if let progress = try? await cache.getProgress(for: userId, exerciseId: exercise.id) {
            return progress.isLocked
        }

        if let allProgress = try? await cache.getAllProgress(for: userId),
           let progress = allProgress.first(where: { (_, prog) in
               journey.section.flatMap({ $0.exercises }).first(where: { $0.id == prog.exerciseId })?.name == exerciseName
           })?.value {
            return progress.isLocked
        }

        return true
    }

    func deleteData(for userId: UUID) {
        UserDefaults.standard.removeObject(forKey: "journey_\(userId)")
    }

    func deleteAllData() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURl = documentsDirectory.appendingPathComponent("user_journeys").appendingPathExtension("plist")
        try? FileManager.default.removeItem(at: archiveURl)
        Task {
            await cache.clearAll()
        }
    }
    
    func completedExercisesCount(for userId: UUID, in sectionTitle: String) async -> Int {
            guard let journey = try? await cache.getJourney(for: userId),
                  let section = journey.section.first(where: { $0.title == sectionTitle }) else {
                return 0
            }
            
            var count = 0
            for exercise in section.exercises {
                if let progress = try? await cache.getProgress(for: userId, exerciseId: exercise.id),
                   progress.completed {
                    count += 1
                }
            }
            return count
        }
}
