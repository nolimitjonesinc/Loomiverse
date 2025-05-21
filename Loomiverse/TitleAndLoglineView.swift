import SwiftUI

struct TitleAndLoglineView: View {
    @ObservedObject var storyGenerator: StoryGenerator
    let genre: String
    @State private var titleAndLogline = "" {
        didSet {
            print("Title and logline: \(titleAndLogline)") // Print title and logline
        }
    }
    @State private var isPresentingStoryView = false

    var body: some View {
        VStack {
            Text(titleAndLogline)
            Button("Create Story") {
                isPresentingStoryView = true
            }
            .sheet(isPresented: $isPresentingStoryView) {
                StoryView(storyGenerator: storyGenerator, titleAndLogline: titleAndLogline, chapterNumber: 1)
            }
        }
        .onAppear {
            print("Generating title and logline for genre: \(genre)") // Print statement for genre

            storyGenerator.generateTitleAndLogline(for: genre) { (titleAndLogline, error) in
                if let error = error {
                    print("Error generating title and logline: \(error)") // Print error
                } else {
                    self.titleAndLogline = titleAndLogline
                }
            }
        }
    }
}
