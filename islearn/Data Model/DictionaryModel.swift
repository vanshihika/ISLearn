import UIKit
import PostgREST
import Foundation

struct Word: Codable, Identifiable, Hashable {
    let id: UUID
    let wordName: String
    let wordDefinition: String
    let videoURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case wordName = "word_name"
        case wordDefinition = "word_definition"
        case videoURL = "video_url"
    }
}

struct Bookmark: Codable {
    let id: UUID
    let user_id: UUID
    let word_id: UUID
}

class WordDataModel {
    static let sharedInstance = WordDataModel()

    private var words: [Word] = []
    private let supabaseClient = SupabaseManager.shared.client

    private init() {}

    func fetchAllWords() -> [Word] {
        return words
    }

    func giveWord(_ byName: String) -> Word? {
        words.first { $0.wordName.lowercased() == byName.lowercased() }
    }

    func giveMatching(_ compareString: String) -> [Word] {
        words.filter { $0.wordName.localizedCaseInsensitiveContains(compareString) }
    }

    func fetchWordsFromBackend(completion: @escaping (Result<[Word], Error>) -> Void) {
        Task {
            do {
                let response: [Word] = try await supabaseClient
                    .from("words")
                    .select()
                    .execute()
                    .value

                self.words = response
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deleteData() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("words_list").appendingPathExtension("plist")
        try? FileManager.default.removeItem(at: archiveURL)
    }
}

class WordOfTheDay {
    private var words: [Word: Date] = [
        Word(
            id: UUID(),
            wordName: "Independence",
            wordDefinition: "Freedom from being governed or ruled by another country",
            videoURL: "IndependenceDay"
        ): Date()
    ]
    
    

    static let sharedInstance = WordOfTheDay()

    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURl = documentsDirectory.appendingPathComponent("wotd_list").appendingPathExtension("plist")

        let propertyDecoder = PropertyListDecoder()
        if let retrievedData = try? Data(contentsOf: archiveURl),
           let decodedWOTD = try? propertyDecoder.decode([Word: Date].self, from: retrievedData) {
            words = decodedWOTD
        }
    }

    func getWordOfTheDay() -> Word? {
        let today = Calendar.current.startOfDay(for: Date())
        return words.first { Calendar.current.startOfDay(for: $0.value) == today }?.key
    }


    func deleteData() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURl = documentsDirectory.appendingPathComponent("wotd_list").appendingPathExtension("plist")
        try? FileManager.default.removeItem(at: archiveURl)
    }
}

class BookMarkedWords {
    static let sharedInstance = BookMarkedWords()
    private let supabaseClient = SupabaseManager.shared.client
    private var bookmarkedWords: [Word] = []

    private init() {}

    func fetchBookmarksFromSupabase(for userId: UUID) async {
        do {
            let fetchedWords = await fetchBookmarks(for: userId)
            self.bookmarkedWords = fetchedWords
        } catch {
            // Optionally handle/log error
        }
    }

    func getBookmarkedWords() -> [Word] {
        return self.bookmarkedWords
    }

    private func fetchBookmarks(for userId: UUID) async -> [Word] {
        do {
            let bookmarks: [Bookmark] = try await supabaseClient
                .from("bookmarks")
                .select("id, user_id, word_id")
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value

            let wordIds = bookmarks.map { $0.word_id }
            guard !wordIds.isEmpty else { return [] }

            let words: [Word] = try await supabaseClient
                .from("words")
                .select("*")
                .in("id", value: wordIds)
                .execute()
                .value

            return words
        } catch {
            return []
        }
    }
    

    func toggleBookmarkedWords(_ word: Word, for userId: UUID) async {
        let isBookmarked = bookmarkedWords.contains { $0.id == word.id }

        if isBookmarked {
            await removeBookmark(word, for: userId)
        } else {
            await addBookmark(word, for: userId)
        }
    }

    private func addBookmark(_ word: Word, for userId: UUID) async {
        do {
            let formattedDate = ISO8601DateFormatter().string(from: Date())

            _ = try await supabaseClient
                .from("bookmarks")
                .insert([
                    "user_id": userId.uuidString,
                    "word_id": word.id.uuidString,
                    "created_at": formattedDate
                ])
                .execute()

            bookmarkedWords.append(word)
        } catch {
            // Optionally handle/log error
        }
    }

    private func removeBookmark(_ word: Word, for userId: UUID) async {
        do {
            _ = try await supabaseClient
                .from("bookmarks")
                .delete()
                .eq("user_id", value: userId.uuidString)
                .eq("word_id", value: word.id.uuidString)
                .execute()

            bookmarkedWords.removeAll { $0.id == word.id }
        } catch {
            // Optionally handle/log error
        }
    }
    
    func deleteData(for userId: UUID) {
        UserDefaults.standard.removeObject(forKey: "bookmarks_\(userId)")
    }
}

//class WordOfTheDay {
//    static let sharedInstance = WordOfTheDay()
//
//    private var words: [Word] = []
//    private var cachedWordOfTheDay: Word?
//    private var cachedDate: Date?
//
//    private init() {
//        // You could load cached word/day from disk here if you want persistence
//    }
//
//    /// Fetch words from backend and update the local list.
//    /// Call this early, e.g. in app launch or viewDidLoad.
//    func fetchWordsFromBackend(completion: @escaping (Result<Void, Error>) -> Void) {
//        WordDataModel.sharedInstance.fetchWordsFromBackend { [weak self] result in
//            switch result {
//            case .success(let words):
//                self?.words = words
//                self?.cachedWordOfTheDay = nil // Reset cache on new data
//                completion(.success(()))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
//    /// Get the word of the day based on the current date.
//    /// Returns nil if words list is empty.
//    func getWordOfTheDay() -> Word? {
//        let today = Calendar.current.startOfDay(for: Date())
//        
//        // If cached and date matches, return cached word
//        if let cachedDate = cachedDate, cachedDate == today, let cachedWord = cachedWordOfTheDay {
//            return cachedWord
//        }
//        
//        guard !words.isEmpty else { return nil }
//        
//        // Use a deterministic method to pick the word for today, for example:
//        // Hash the date and mod by words.count to pick an index.
//        
//        let dayNumber = Calendar.current.ordinality(of: .day, in: .year, for: today) ?? 0
//        let index = dayNumber % words.count
//        let wordForToday = words[index]
//        
//        // Cache the selected word and date
//        cachedWordOfTheDay = wordForToday
//        cachedDate = today
//        
//        return wordForToday
//    }
//    
//    /// Optional: Clear cache if needed
//    func clearCache() {
//        cachedWordOfTheDay = nil
//        cachedDate = nil
//    }
//}
//
