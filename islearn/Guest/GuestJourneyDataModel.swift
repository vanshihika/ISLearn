import Foundation

class GuestJourneyDataModel {
    static let shared = GuestJourneyDataModel()
    private var guestJourney: Journey?

    private init() {}

    func getGuestJourney() async throws -> Journey {
        if let cached = guestJourney {
            return cached
        }

        let client = SupabaseManager.shared.client

        let rawSections: [JourneySection] = try await client
            .from("journey_sections")
            .select()
            .eq("title", value: "Alphabets")
            .order("title", ascending: true)
            .execute()
            .value

        guard let alphabetsSection = rawSections.first else {
            throw NSError(domain: "No 'Alphabets' section found", code: 0, userInfo: nil)
        }

        let rawExercises: [JourneyExercise] = try await client
            .from("journey_exercises")
            .select()
            .eq("section_id", value: alphabetsSection.id)
            .order("name", ascending: true)
            .range(from: 0, to: 7)
            .execute()
            .value

        let exercises = rawExercises.map {
            Exercise(id: $0.id, sectionId: $0.section_id, name: $0.name, video: $0.video)
        }

        let section = Section(id: alphabetsSection.id, title: alphabetsSection.title, exercises: exercises)
        let journey = Journey(id: UUID(), section: [section])
        guestJourney = journey

        return journey
    }
}
