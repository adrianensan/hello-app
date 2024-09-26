import Foundation

enum FeedbackType: String, Identifiable, CaseIterable, Sendable {
  case featureRequest
  case bugReport
  case feedback
  case question
  case other
  
  var id: String { rawValue }
  
  var name: String {
    switch self {
    case .featureRequest: "Feature Request"
    case .bugReport: "Bug Report"
    case .feedback: "Feedback"
    case .question: "Question"
    case .other: "Other"
    }
  }
  
  var code: String {
    switch self {
    case .featureRequest: "Feature Request"
    case .bugReport: "Bug"
    case .feedback: "Feedback"
    case .question: "Question"
    case .other: "Other"
    }
  }
}
