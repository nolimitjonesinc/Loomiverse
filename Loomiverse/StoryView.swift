import SwiftUI
import CoreData

struct Chapter {
    var story: String
    var number: Int
    var title: String?  // Add title to Chapter struct
}

// Add this structure to conform to Identifiable
struct IdentifiableError: Identifiable {
    var id = UUID()
    var message: String
}

struct StoryView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var currentChapter: Chapter? // Ensure Chapter is a Core Data entity
    @State private var story: String? = nil
    @State private var chapterTitle: String? = nil  // Add chapter title state
    @State private var retryTitle = "Retry"
    @State private var isLoading = false
    @State private var identifiableError: IdentifiableError? = nil
    @State private var timeoutOccurred = false
    @State private var apiAttempts = 0
    @State private var showRetryButton = false
    @Environment(\.presentationMode) var presentationMode
    let storyGenerator: StoryGenerator
    let titleAndLogline: String
    let genre: String
    @State var chapterNumber: Int
    let verbs = ["Creating", "Producing", "Crafting", "Forming", "Making", "Generating", "Fabricating", "Constructing", "Inventing", "Designing"]
    @State private var currentVerb = "Creating"
    @State private var storyQueue: [Chapter] = []
    let maxChapterNumber = 30
    let maxApiAttempts = 3
    
    var body: some View {
        NavigationView {
            Group {
                if let storyText = story {
                    // Story has been successfully loaded
                    VStack {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                // Chapter title header (like a real book)
                                if let title = chapterTitle {
                                    VStack(alignment: .center, spacing: 10) {
                                        Text("Chapter \(chapterNumber)")
                                            .font(.title2)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                        
                                        Text(title)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(.bottom, 30)
                                } else {
                                    Text("Chapter \(chapterNumber)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.bottom, 20)
                                }
                                
                                // Chapter content
                                Text(storyText)
                                    .foregroundColor(.white)
                                    .lineSpacing(8)
                            }
                            .padding()
                        }
                        HStack {
                            Button(retryTitle) {
                                retryTitle = verbs.randomElement() ?? "Retry"
                                apiAttempts = 0
                                generateChapter()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.clear)
                            .border(Color.white, width: 3)
                            
                            Button("Next Chapter") {
                                chapterNumber += 1
                                apiAttempts = 0
                                // Clear current chapter data when moving to next
                                story = nil
                                chapterTitle = nil
                                generateChapter()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.clear)
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
                } else if showRetryButton {
                    // Error occurred, show retry option
                    VStack(spacing: 20) {
                        Text("We couldn't generate your story")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("This might be due to a network timeout or server issue.")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Try Again") {
                            showRetryButton = false
                            apiAttempts = 0
                            generateChapter()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.clear)
                        .border(Color.white, width: 3)
                        .cornerRadius(5)
                    }
                    .padding()
                } else {
                    // Initial loading state
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5, anchor: .center)
                        Text("\(currentVerb) your story...")
                            .foregroundColor(.white)
                            .padding()
                        
                        if isLoading && timeoutOccurred {
                            Text("This is taking longer than usual...")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.top, 5)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                generateChapter() // Generate the opening chapter on appear
            }
            .alert(item: $identifiableError) { error in
                Alert(
                    title: Text("Oops!"),
                    message: Text(error.message),
                    primaryButton: .default(Text("Try Again")) {
                        apiAttempts = 0
                        generateChapter()
                    },
                    secondaryButton: .cancel(Text("Cancel")) {
                        showRetryButton = true
                    }
                )
            }
        }
    }
   
    // Create fallback chapter content when API fails
    private func createFallbackChapter(chapterNumber: Int) -> String {
        let fallbackContents = [
            "The journey began with uncertainty but also determination. Our protagonist took their first steps into a world of mystery, guided by an ancient map and the whispers of destiny. The path ahead was shrouded in mist, but they were resolved to discover the truth about their heritage and the strange powers that had begun to manifest.\n\nAs they ventured deeper into unknown territory, our protagonist encountered their first real challenge. The landscape had transformed—trees grew taller, shadows deeper, and the very air seemed charged with magic. This was no ordinary place, and they were no ordinary traveler.",
            "New allies appeared when least expected. Some offered wisdom, others protection, but all would play a crucial role in the unfolding story. Trust didn't come easily to our protagonist, but in this strange new world, they were learning that some journeys cannot be undertaken alone.\n\nA revelation changed everything. What seemed like random events now revealed themselves as part of a greater pattern. Our protagonist began to understand their place in this ancient tale, and with understanding came both power and responsibility.",
            "Facing their greatest fear, our protagonist discovered strength they never knew they possessed. The confrontation was inevitable, but its outcome was not predetermined. With courage and newfound abilities, they stood their ground against forces that had intimidated them for too long.\n\nVictory brought not just relief but transformation. The world looked different now, filled with possibilities that had been invisible before. This was just the beginning of a much larger adventure.",
            "The return journey was not the same as the outward path. Our protagonist carried new knowledge, new abilities, and a changed perspective. What once seemed ordinary now revealed hidden depths and connections to the greater mysteries they had uncovered.\n\nAs they shared their experiences with those who had stayed behind, our protagonist realized that the true journey was just beginning. The adventure had changed them in ways they were only starting to understand.",
            "Reflections on the journey revealed patterns and purposes that had been invisible during the adventure itself. Our protagonist now understood that each challenge, each ally, each discovery had been preparing them for something greater still.\n\nWith renewed purpose and clarity, they began to prepare for the next chapter of their story, knowing that the path ahead would be both challenging and rewarding in ways they could not yet imagine."
        ]
        
        // Use modulo to cycle through fallback contents if chapter number exceeds array size
        let index = (chapterNumber - 1) % fallbackContents.count
        return fallbackContents[index]
    }
    
    private func generateChapter() {
        // Check if we've exceeded the maximum number of attempts
        if apiAttempts >= maxApiAttempts {
            print("Exceeded maximum API attempts (\(maxApiAttempts))")
            DispatchQueue.main.async {
                // Instead of showing retry button, use fallback content
                let fallbackChapter = self.createFallbackChapter(chapterNumber: self.chapterNumber)
                self.story = fallbackChapter
                self.isLoading = false
                self.apiAttempts = 0
            }
            return
        }
        
        // Increment attempt counter
        apiAttempts += 1
        print("API attempt \(apiAttempts) of \(maxApiAttempts) for chapter \(chapterNumber)")
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.timeoutOccurred = false
            
            // After 15 seconds, show the "taking longer than usual" message
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                if self.isLoading {
                    self.timeoutOccurred = true
                }
            }
        }
        
        print("Generating chapter number: \(chapterNumber)")
        if chapterNumber == 1 {
            currentVerb = "Planning"  // Different verb for outline generation
        } else {
            currentVerb = verbs.randomElement() ?? "Creating"
        }
        print("Generating chapter with verb: \(currentVerb)")

        if chapterNumber == 1 {
            // First generate the story outline, then the opening chapter
            print("Generating story outline first...")
            storyGenerator.generateOutline(for: titleAndLogline, genre: genre) { (outline, error) in
                if let error = error {
                    print("Error generating outline: \(error)")
                    // Continue with fallback outline
                }
                
                print("Generating opening chapter with outline")
                self.storyGenerator.generateOpeningChapter(for: self.titleAndLogline, outline: self.storyGenerator.getStoryOutline()) { (chapter, error) in
                    print("Opening chapter generation completed")
                    if let chapter = chapter {
                        self.handleChapterGenerationResult(chapter: chapter.story, chapterTitle: "The Journey Begins", error: error)
                    } else {
                        self.handleChapterGenerationResult(chapter: nil, chapterTitle: nil, error: error)
                    }
                }
            }
        } else if !storyQueue.isEmpty {
            print("Using pre-fetched chapter from queue")
            DispatchQueue.main.async {
                let nextChapter = self.storyQueue.removeFirst()
                self.story = nextChapter.story
                self.chapterTitle = nextChapter.title
                print("Chapter loaded from pre-fetched queue")
                self.preFetchNextChapter()
                self.isLoading = false
                self.apiAttempts = 0 // Reset attempt counter on success
            }
        } else {
            print("Generating chapter \(chapterNumber) directly")
            storyGenerator.generateChapter(for: titleAndLogline, chapterNumber: chapterNumber) { (chapter, error) in
                print("Chapter \(chapterNumber) generation completed")
                if let chapter = chapter {
                    print("Chapter received: \(chapter.number)")
                    // Extract title from the Core Data entity if available
                    let chapterTitle = chapter.title ?? "Chapter \(chapterNumber)"
                    self.handleChapterGenerationResult(chapter: chapter.story, chapterTitle: chapterTitle, error: error)
                } else {
                    print("No chapter received from generator")
                    let customError = NSError(
                        domain: "Loomiverse", 
                        code: 1001, 
                        userInfo: [NSLocalizedDescriptionKey: "We couldn't generate your story. Please try again."]
                    )
                    self.handleChapterGenerationResult(chapter: nil, chapterTitle: nil, error: error ?? customError)
                }
            }
        }
    }

    func handleChapterGenerationResult(chapter: String?, chapterTitle: String?, error: Error?) {
        DispatchQueue.main.async {
            self.isLoading = false
            
            // Handle errors
            if let error = error {
                print("Error generating chapter: \(error)")
                
                // Provide fallback content instead of showing error
                let fallbackChapter = self.createFallbackChapter(chapterNumber: self.chapterNumber)
                print("Using fallback chapter due to error")
                self.story = fallbackChapter
                self.chapterTitle = "Chapter \(self.chapterNumber)"  // Set fallback title
                self.apiAttempts = 0
                
                // Still create a summary for the fallback chapter
                self.storyGenerator.createSummary(for: fallbackChapter) { (summary, _) in
                    DispatchQueue.main.async {
                        if let summaryText = summary, !summaryText.isEmpty {
                            self.storyGenerator.chapterSummaries.append(summaryText)
                        }
                        self.preFetchNextChapter()
                    }
                }
                return
            }
            
            // Handle missing content with fallback
            guard let chapter = chapter, !chapter.isEmpty else {
                print("No chapter content received or empty content")
                let fallbackChapter = self.createFallbackChapter(chapterNumber: self.chapterNumber)
                print("Using fallback chapter due to empty content")
                self.story = fallbackChapter
                self.chapterTitle = "Chapter \(self.chapterNumber)"  // Set fallback title
                self.apiAttempts = 0
                
                // Create a summary for the fallback chapter
                self.storyGenerator.createSummary(for: fallbackChapter) { (summary, _) in
                    DispatchQueue.main.async {
                        if let summaryText = summary, !summaryText.isEmpty {
                            self.storyGenerator.chapterSummaries.append(summaryText)
                        }
                        self.preFetchNextChapter()
                    }
                }
                return
            }
            
            // Success path
            print("Chapter generated successfully with length: \(chapter.count) characters")
            self.story = chapter
            self.chapterTitle = chapterTitle  // Set the chapter title
            self.apiAttempts = 0 // Reset attempt counter on success
            
            // Create summary for the current chapter
            self.storyGenerator.createSummary(for: chapter) { (summary, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error generating chapter summary: \(error.localizedDescription)")
                        // We can still continue even if summary generation fails
                    } else if let summaryText = summary, !summaryText.isEmpty {
                        self.storyGenerator.chapterSummaries.append(summaryText)
                        print("Chapter summary created successfully with length: \(summaryText.count) characters")
                    } else {
                        print("Empty summary received")
                    }
                    
                    // Pre-fetch the next chapter regardless of summary success
                    self.preFetchNextChapter()
                }
            }
        }
    }



        private func preFetchNextChapter() {
            print("Starting pre-fetching next chapter...")
            
            // Don't try to prefetch if we're at the max chapter number
            guard chapterNumber < maxChapterNumber else {
                print("Reached maximum chapter number (\(maxChapterNumber)), not pre-fetching")
                return
            }
            
            // Don't prefetch more if we already have enough in the queue
            guard storyQueue.count < 3 else { // Limit to 3 chapters in the queue
                print("Queue already has \(storyQueue.count) chapters, not pre-fetching more")
                return
            }
            
            // Determine how many chapters to prefetch
            let numberOfChaptersToPrefetch = storyQueue.count == 1 ? 2 : 1
            print("Pre-fetching \(numberOfChaptersToPrefetch) chapters")
            
            for i in 0..<numberOfChaptersToPrefetch {
                let nextChapterNumber = chapterNumber + storyQueue.count + 1 + i
                
                // Make sure we don't exceed max chapter number
                if nextChapterNumber <= maxChapterNumber {
                    print("Pre-fetching chapter \(nextChapterNumber)")
                    
                    storyGenerator.generateChapter(for: titleAndLogline, chapterNumber: nextChapterNumber) { (chapter, error) in
                        if let error = error {
                            print("Error pre-fetching chapter \(nextChapterNumber): \(error)")
                            // We don't show errors for prefetching to the user
                        } else if let chapter = chapter {
                            print("Successfully pre-fetched chapter \(chapter.number) with \(chapter.story.count) characters")
                            DispatchQueue.main.async {
                                let chapterTitle = chapter.title ?? "Chapter \(chapter.number)"
                                let convertedChapter = Chapter(story: chapter.story, number: chapter.number, title: chapterTitle)
                                self.storyQueue.append(convertedChapter)
                                print("Added pre-fetched chapter to queue. Queue size: \(self.storyQueue.count)")
                            }
                        } else {
                            print("No chapter returned when pre-fetching chapter \(nextChapterNumber)")
                        }
                    }
                }
            }
        }
    }
