import Foundation

// This model is used for temporary story chapter data, distinct from the Core Data entity
struct StoryChapterModel {
    let story: String
    let number: Int
    let summary: String?
    let title: String?  // Add title field to the model
}
