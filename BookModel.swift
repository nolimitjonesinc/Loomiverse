// BookModel.swift
import Foundation

struct BookModel: Identifiable {
    let id: UUID
    var coverName: String
    var title: String
    
    // When we make a new BookModel, it automatically gets a new ID.
    init(coverName: String, title: String) {
        self.id = UUID()
        self.coverName = coverName
        self.title = title
    }
}
