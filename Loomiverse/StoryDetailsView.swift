import SwiftUI

struct StoryDetailsView: View {
    var genre: String
    let storyGenerator: StoryGenerator
    @State private var titleAndLogline: String? = nil
    @State private var error: Error?
    @State private var isPresentingStoryView = false
    @State private var isLoading = false
    @State private var loadingMessage = ""
    private let loadingMessages = [
        "Creating Title and Teaser",
        "Crafting a Title and Preview",
        "Dreaming up a Catchy Name and Sneak Peek",
        "Orchestrating a Compelling Title and Prelude",
        "Composing a Fascinating Title and Sneak Peek",
        "Designing a Snazzy Title and Prelude"
    ]

    var body: some View {
        VStack {
            Text(genre)
                .font(.title3) // Use a dynamic system style that adjusts automatically
            if let titleAndLogline = titleAndLogline {
                Text(titleAndLogline)
                    .padding()
                    .font(.body) // Use a common dynamic type size for body text
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5, anchor: .center)
                    } else {
                        Button("New Story") {
                            generateTitleAndLogline()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.clear)
                        .border(Color.white, width: 5)
                        .cornerRadius(10)
                    }
                    Button("Chapter One") {
                        isPresentingStoryView = true
                    }
                    .disabled(titleAndLogline == nil)
                    .sheet(isPresented: $isPresentingStoryView) {
                        StoryView(storyGenerator: storyGenerator, titleAndLogline: titleAndLogline, chapterNumber: 1)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.clear)
                    .border(Color.white, width: 5)
                    .cornerRadius(5)
                }
            } else {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5, anchor: .center)
                    Text(loadingMessage)
                        .padding()
                        .font(.body) // Use dynamic type for loading message as well
                }
            }
        }
        .onAppear {
            loadingMessage = loadingMessages.randomElement() ?? "Generating title and logline..."
            isLoading = true
            generateTitleAndLogline()
        }
    }
    
    private func generateTitleAndLogline() {
        isLoading = true
        print("Selected Genre: \(genre)")
        storyGenerator.generateTitleAndLogline(for: genre) { generatedTitleAndLogline, error in
            if let error = error {
                print("Error generating title and logline: \(error)")
                self.error = error
            } else {
                self.titleAndLogline = generatedTitleAndLogline
                self.isLoading = false
            }
        }
    }
}
