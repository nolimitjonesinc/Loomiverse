import SwiftUI

struct Chapter {
    var story: String
    var number: Int
}

// Add this structure to conform to Identifiable
struct IdentifiableError: Identifiable {
    var id = UUID()
    var message: String
}

struct StoryView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
        @State private var currentChapter: Chapter? // Ensure Chapter is a Core Data entity
        // Add other existing states here
    @State private var story: String? = nil
    @State private var retryTitle = "Retry"
    @State private var isLoading = false
    @State private var identifiableError: IdentifiableError? = nil
    @Environment(\.presentationMode) var presentationMode
    let storyGenerator: StoryGenerator
    let titleAndLogline: String
    @State var chapterNumber: Int
    let verbs = ["Creating", "Producing", "Crafting", "Forming", "Making", "Generating", "Fabricating", "Constructing", "Inventing", "Designing"]
    @State private var currentVerb = "Creating"
    @State private var storyQueue: [Chapter] = []
    let maxChapterNumber = 30
    
    var body: some View {
        NavigationView {
            Group {
                if let storyText = story {
                    VStack {
                        ScrollView {
                            Text(storyText)
                                .padding()
                        }
                        HStack {
                            Button(retryTitle) {
                                retryTitle = verbs.randomElement() ?? "Retry"
                                generateChapter()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .border(Color.white, width: 3)
                            Button("Next Chapter") {
                                chapterNumber += 1
                                generateChapter()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .border(Color.white, width: 3)
                            .disabled(chapterNumber >= maxChapterNumber)
                        }
                        .padding()
                        if isLoading {
                            ProgressView()
                                .scaleEffect(1.5, anchor: .center)
                                .padding()
                        }
                    }
                } else {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5, anchor: .center)
                        Text("\(currentVerb) your story...")
                            .padding()
                    }
                }
            }
            .navigationBarItems(leading: Button("Back") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                generateChapter() // Generate the opening chapter on appear
            }
            .alert(item: $identifiableError) { error in
                Alert(title: Text("Oops!"), message: Text(error.message), dismissButton: .default(Text("Got it")))
            }
        }
    }
   
    private func generateChapter() {
            print("Generating chapter number: \(chapterNumber)") // Add this log
            isLoading = true
            currentVerb = verbs.randomElement() ?? "Creating"
            print("Generating chapter with verb: \(currentVerb)") // Logging the current verb

            if chapterNumber == 1 {
                storyGenerator.generateOpeningChapter(for: titleAndLogline, outline: storyGenerator.getStoryOutline()) { (chapter, error) in
                    handleChapterGenerationResult(chapter: chapter, error: error)
                }
            } else if !storyQueue.isEmpty {
                story = storyQueue.removeFirst().story
                print("Generating chapter from pre-fetched queue") // Logging pre-fetching
                preFetchNextChapter()
                isLoading = false
            } else {
                storyGenerator.generateChapter(for: titleAndLogline, chapterNumber: chapterNumber) { (chapter, error) in
                    handleChapterGenerationResult(chapter: chapter?.story, error: error)
                }
            }
        }

    func handleChapterGenerationResult(chapter: String?, error: Error?) {
        isLoading = false
        if let error = error {
            print("Error generating chapter: \(error)")
            identifiableError = IdentifiableError(message: "Gremlins! Try again!")
        } else if let chapter = chapter {
            print("Chapter generated successfully.")
            self.story = chapter
            // Create summary for the current chapter
            storyGenerator.createSummary(for: chapter) { (summary, error) in
                if let error = error {
                    print("Error generating chapter summary: \(error.localizedDescription)")
                } else {
                    storyGenerator.chapterSummaries.append(summary) // Accessing from storyGenerator
                    print("Chapter summary created successfully.")
                    preFetchNextChapter() // Pre-fetch the next chapter
                }
            }
        }
    }



        private func preFetchNextChapter() {
            print("Starting pre-fetching next chapter...") // Logging the start of pre-fetching
            let numberOfChaptersToPrefetch = storyQueue.count == 1 ? 2 : 1
            for _ in 0..<numberOfChaptersToPrefetch {
                if chapterNumber < maxChapterNumber && storyQueue.count < 3 { // Limit to 3 chapters in the queue
                    storyGenerator.generateChapter(for: titleAndLogline, chapterNumber: chapterNumber + storyQueue.count + 1) { (chapter, error) in
                        if let chapter = chapter {
                            print("Pre-fetched chapter: \(chapter.number)") // Logging pre-fetched chapter
                            storyQueue.append(chapter)
                        }
                        
                    }
                }
            }
        }
    }
