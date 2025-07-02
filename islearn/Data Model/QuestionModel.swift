import Foundation

struct Question: Codable {
    var id: UUID
    var questionTitle: QuestionTitle
    var questionStatement: String
    var gestureWord: String?
    var answer: Int? 
    var options: [String]?
    var questionType: QuestionType
    var questionXP: Int
    
    init(id: UUID = UUID(), questionTitle: QuestionTitle, questionStatement: String, gestureWord: String? = nil, answer: Int? = nil, options: [String]? = nil, questionType: QuestionType, questionXP: Int) {
        self.id = id
        self.questionTitle = questionTitle
        self.questionStatement = questionStatement
        self.gestureWord = gestureWord
        self.answer = answer
        self.options = options
        self.questionType = questionType
        self.questionXP = questionXP
    }
}

enum QuestionTitle: String, Codable {
    case practice, test
    
    var description: String {
        switch self {
        case .practice:
            return "Practice"
        case .test:
            return "Test"
        }
    }
}

enum QuestionType: Codable {
    case mcqA, mcqB, wordGesture, spellGesture
}
