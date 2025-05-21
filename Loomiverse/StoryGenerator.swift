import Foundation
import CoreData
import CloudKit


struct StoryNode {
    let content: String
    let choices: [String]
    var children: [StoryNode]
}

struct StoryFormula {
    var sections: [String]
    var prompts: [String]
    var chapterCounts: [Int]
}

struct Author: Codable {
    let name: String
    let description: String?
}


struct AuthorStyle: Codable {
    let style: String
    let authors: [Author]
}

struct OpenAIResult: Codable {
    var id: String
    var object: String
    var created: Int
    var model: String
    var usage: Usage
    var choices: [Choice]
    
    struct Usage: Codable {
        var prompt_tokens: Int
        var completion_tokens: Int
        var total_tokens: Int
    }
    
    struct Choice: Codable {
        var message: Message
        var finish_reason: String
        var index: Int
    }
    
    struct Message: Codable {
        var role: String
        var content: String
    }
}

class StoryGenerator: ObservableObject {
    var context: NSManagedObjectContext
    private let apiKey = API_UNAVAILABLE
    private let apiUrl = "https://api.openai.com/v1/chat/completions"
    var protagonistName: String = ""
    var currentAllies: [String] = []
    var currentLocation: String = ""
    var chapterSummaries: [String] = []
    private var condensedSummary: String = ""
    private var storyOutline: [String] = [] // Keep it private
    private var currentChapterIndex: Int = 1
    private var AuthorStyles: [AuthorStyle] = []
    private var chosenStyle: String?
    private var currentOutlinePointIndex: Int = 1
    
    
    private func getSectionNumber(for chapterNumber: Int) -> Int {
        return chapterNumber - 1 // Assuming chapters start with an index of 1
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context // Initialize context with the passed argument
        if let url = Bundle.main.url(forResource: "AuthorStyles", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                self.AuthorStyles = try decoder.decode([AuthorStyle].self, from: data)
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func getStoryOutline() -> [String] {
        return storyOutline
    }
    let HeroJourneyFormula = StoryFormula(
        sections: [
            "Ordinary World",
            "Inciting Incident",
            "Reaction to the Inciting Incident",
            "Introduction to the New Situation",
            "Exploration of the New Situation",
            "First Challenge",
            "Making Allies",
            "Intensifying Mystery or Conflict",
            "A Test of Skills",
            "Introduction of Subplot",
            "Character Development",
            "Evolution of Relationships",
            "Rising Tension",
            "Climax of Conflicts",
            "Crisis Point",
            "Preparing for Climax",
            "Climax",
            "Aftermath of Climax",
            "Resolution of Subplots",
            "Return to Ordinary World and Setup for Next Adventure"
        ],
        prompts: [
            "1. Start with an opening that captivates the reader, perhaps a question or intriguing scenario. Introduce the protagonist's daily life, traits, and desires. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits. Provide insights into their internal and external motivations. End with a subtle hint or question that teases their deeper yearnings, enticing the reader.",
            "2. Introduce an unexpected event that shakes the protagonist's regular life. This incident must intrigue the reader and hint at the main conflict. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits.Conclude with the uncertainty or excitement this event triggers, maintaining momentum.",
            "3. Detail the protagonist's initial response to the incident, showcasing their character and intentions. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits. Highlight their thoughts, feelings, and decisions. End with a choice that promises more to come, propelling the reader forward.",
            "4. Transition the protagonist to a new environment or situation. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits. Describe their reactions, be it awe, confusion, or curiosity, connecting the reader to their experience. Conclude with a discovery or upcoming adventure, keeping the narrative engaging.",
            "5. Allow the protagonist to explore the new setting or situation. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits. Use vivid descriptions to immerse the reader, ensuring details reflect the protagonist's perception. End with a realization or twist that leads to the next chapter.",
            "6. Present the protagonist's first significant challenge. Detail their struggles, failures, and successes, revealing their depth and creating intrigue. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits.Conclude with the implications of this test, leaving a question or problem that draws the reader onward.",
            "7. Describe the formation of friendships or alliances, with each supporting character uniquely motivated. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits. Enhance the story's richness through these relationships. Conclude with a bonding moment or shared secret, enticing further exploration.",
            "8. Deepen the central conflict or mystery, adding layers to the plot through clues or obstacles.Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits.  Ensure every twist is character-driven. End with a significant revelation that heightens suspense, compelling continuation.",
            "9. Craft a situation that tests the protagonist's abilities, generating excitement. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits. Tie the outcome to personal growth or relationships, having substantial consequences. Conclude with success or failure that poses a new question or challenge.",
            "10. Introduce a subplot that intertwines with the main plot. Unfold character-driven connections to the central conflict. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits. End with a tantalizing link or turn that enriches the narrative.",
            "11. Emphasize the protagonist's transformation. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits. Showcase their evolution in thought and action, making them engaging. Conclude with a personal insight or directional change that leads the reader deeper.",
            "12. Focus on the dynamics of the protagonist's relationships. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits. Explore the changes and emotions, adding authenticity to the story. Conclude with an emotional turning point that pulls the reader into the stakes.",
            "13. Increase tension through character-driven conflicts.Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits. Illustrate the protagonist's struggles, building anticipation. Conclude with a complication or crisis, urging the reader towards the climax.",
            "14. Resolve major conflicts, leading to a critical juncture.Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits. Detail the protagonist's confrontation, escalating drama. Conclude with a dramatic decision or situation that leaves the reader on edge.",
            "15. Bring the protagonist to a crisis, facing significant consequences. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits.Their reaction must be deeply character-driven. A cliffhanger here sets the stage for what's to come.",
            "16. Prepare the protagonist for the final confrontation. Detail their planning, doubts, and anticipation, building suspense. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits. End with a final barrier or determination leading to the climax.",
            "17. Stage the climax, a character-driven confrontation resolving the main conflict. Provide a dramatic payoff. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits. Conclude with questions or the immediate aftermath, enticing the reader to the resolution.",
            "18. Depict the immediate aftermath, focusing on the protagonist's reaction. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits. Show their transformation, resonating with the story's theme. End with reflections or realization, keeping engagement.",
            "19. Resolve remaining subplots, maintaining thematic consistency. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits. Provide closure and satisfaction. Conclude with an insight or connection, hinting at future possibilities.",
            "20. Return the protagonist to ordinary life, reflecting their transformation. Emphasize dialog-rich, action-oriented prose and vivid scenes or intimate moments between characters with a focus on impactful dialogue with exchanges that reveal personality creating realistic back-and-forth conversations and inner monologues. Use metaphors and sensory details to create unique character traits. Detail their character-driven experiences. End with a hint of their future or a tease for the next adventure, leaving the reader yearning for more."
        ],
        chapterCounts: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    )
    
    
    func generateTitleAndLogline(for genre: String, completion: @escaping (String, Error?) -> Void) {
        // Find the style for the given genre
        guard let style = AuthorStyles.first(where: { $0.style == genre }) else {
            print("Genre not supported.")
            completion("", nil)
            return
        }
        
        // Randomly select an author from the style's authors
        guard let author = style.authors.randomElement() else {
            print("No authors available for this genre.")
            completion("", nil)
            return
        }
        
        // Use the author's description if available, otherwise use the author's name
        self.chosenStyle = author.description ?? author.name
        
        // Print the chosen style
        print("Chosen style: \(self.chosenStyle!)")
        
        let prompt = "Generate a title and a logline for a \(genre)."
        
        complete(prompt: prompt, maxTokens: 100) { result in
            switch result {
            case .success(let response):
                let titleAndLogline = response.choices[0].message.content.trimmingCharacters(in: .whitespacesAndNewlines)
                print("Generated title and logline: \(titleAndLogline)")
                // Reset the chapter summaries and condensed summary
                self.chapterSummaries = []
                self.condensedSummary = ""
                // Generate the story outline
                self.generateOutline(for: titleAndLogline) { outline, error in
                    if let error = error {
                        print("Error generating story outline: \(error)")
                    } else {
                        self.storyOutline = outline
                        completion(titleAndLogline, nil)
                    }
                }
            case .failure(let error):
                print("Error generating title and logline: \(error)")
                completion("", error)
            }
        }
    }
    
    func generateOutline(for titleAndLogline: String, completion: @escaping ([String], Error?) -> Void) {
        print("Starting to generate an outline...") // Logging the start of the outline generation
        let prompt = "Generate an outline based on the title and logline \"\(titleAndLogline)\"."
        print("Using prompt: \(prompt)") // Logging the prompt being used
        complete(prompt: prompt, maxTokens: 500) { result in
            switch result {
            case .success(let response):
                let outline = response.choices[0].message.content.trimmingCharacters(in: .whitespacesAndNewlines)
                let outlinePoints = outline.components(separatedBy: "\n")
                print("Outline generated successfully.") // Logging success
                print("Outline points: \(outlinePoints)") // Logging the specific outline points
                self.storyOutline = outlinePoints  // Saving the generated outline
                completion(outlinePoints, nil)
            case .failure(let error):
                print("Error generating outline: \(error)") // Logging an error
                completion([], error)
            }
        }
    }
    
    func generateMysteriousTitle(chapterNumber: Int, section: String) -> String {
        let title = "Chapter \(chapterNumber): The Mystery of \(section)"
        print("Generated mysterious title: \(title)") // Logging the generated title
        return title
    }
    
    func startStory(completion: @escaping (String) -> Void) {
        print("Starting the story...") // Logging the start of the story
        let genre = "Your selected genre here" // Replace with your selected genre
        print("Selected genre: \(genre)") // Added print statement to log the selected genre
        generateTitleAndLogline(for: genre) { titleAndLogline, error in
            if let error = error {
                print("Error in generating title and logline: \(error)") // Added print statement for error handling
                return
            }
            print("Title and logline generated.") // Logging title and logline generation
            self.generateOutline(for: titleAndLogline) { outline, error in
                if let error = error {
                    print("Error in generating outline: \(error)") // Added print statement for error handling
                    return
                }
                print("Outline generated.") // Logging outline generation
                self.generateOpeningChapter(for: titleAndLogline, outline: outline) { chapter, error in
                    if let error = error {
                        print("Error in generating opening chapter: \(error)") // Added print statement for error handling
                        return
                    }
                    print("Opening chapter generated.") // Logging opening chapter generation
                    print("Opening chapter content: \(chapter)") // Added print statement to log the opening chapter content
                    // Call the completion handler with the chapter content
                    completion(chapter)
                }
            }
        }
    }
    
    func nextChapter() {
        print("Generating the next chapter...") // Logging the start of the next chapter generation
        generateNextChapter { chapter, _ in
            print("Next chapter generated.") // Logging next chapter generation
            // Display the next chapter in your UI
            // You'll need to update a UI component (e.g., a TextView) to show the next chapter
        }
    }
    
    
    // Adjusted to dynamically set the chapter title during the save operation
    // Corrected version without extra trailing closure and duplicate function declaration
    func generateOpeningChapter(for titleAndLogline: String, outline: [String], completion: @escaping (String, Error?) -> Void) {
        print("Starting to generate the opening chapter...")
        let chapterNumber = 1
        let section = HeroJourneyFormula.sections[chapterNumber - 1]
        let title = generateMysteriousTitle(chapterNumber: chapterNumber, section: section)
        let outlinePrompt = outline[currentOutlinePointIndex]
        let prompt = "\(title) Based on the title and logline \"\(titleAndLogline)\", the outline point \"\(outlinePrompt)\", and written in the style of \(self.chosenStyle!), write the opening chapter."
        print("Using prompt: \(prompt)")
        complete(prompt: prompt, maxTokens: 3000) { result in
            switch result {
            case .success(let response):
                let chapterContent = response.choices[0].message.content.trimmingCharacters(in: .whitespacesAndNewlines)
                print("Opening chapter generated successfully.")
                if self.saveChapter(chapterNumber: chapterNumber, title: title, content: chapterContent, context: self.context) {
                    print("Chapter saved successfully.")
                    self.createSummary(for: chapterContent) { summary, error in
                        DispatchQueue.main.async {
                            self.chapterSummaries.append(summary)
                            print("Summary for opening chapter added.")
                        }
                        completion(chapterContent, nil)
                    }
                } else {
                    print("Error saving chapter.")
                }
            case .failure(let error):
                print("Error generating opening chapter: \(error)")
                completion("", error)
            }
        }
    }
    
    func generateChapter(for titleAndLogline: String, chapterNumber: Int, completion: @escaping (Chapter?, Error?) -> Void) {
        if chapterNumber < 1 || chapterNumber > storyOutline.count {
            completion(nil, NSError(domain: "Loomiverse", code: 999, userInfo: [NSLocalizedDescriptionKey: "Chapter number is wrong."]))
            return
        }
        if chapterNumber - 1 > chapterSummaries.count {
            completion(nil, NSError(domain: "Loomiverse", code: 998, userInfo: [NSLocalizedDescriptionKey: "Not enough chapter summaries."]))
            return
        }
        currentChapterIndex = chapterNumber
        let outlinePoint = storyOutline[chapterNumber - 1]
        let sectionNumber = getSectionNumber(for: currentChapterIndex)
        let section = HeroJourneyFormula.sections[sectionNumber]
        let title = generateMysteriousTitle(chapterNumber: chapterNumber, section: section)
        let previousChapterSummaries = chapterSummaries.prefix(upTo: chapterNumber - 1).joined(separator: " ")
        let prompt = "\(title) \(outlinePoint) \(previousChapterSummaries) Please write in the following style: \(chosenStyle!)."
        complete(prompt: prompt, maxTokens: 3000) { result in
            // Adjusted handling for OpenAIResult type
        }
    }
    
    func saveChapter(chapterNumber: Int, title: String, content: String, context: NSManagedObjectContext) -> Bool {
        let newChapter = StoryChapters(context: context)
        newChapter.chapterNumber = Int32(chapterNumber)
        newChapter.title = title
        newChapter.content = content
        
        do {
            try context.save()
            print("Chapter saved to CoreData")
            
            // Assuming CloudKit setup is correct and CKRecord.ID, CKRecord.Reference are available
            let recordID = CKRecord.ID(recordName: newChapter.recordName ?? UUID().uuidString)
            let chapterRecord = CKRecord(recordType: "StoryChapters", recordID: recordID)
            chapterRecord["chapterNumber"] = chapterNumber
            chapterRecord["title"] = title
            chapterRecord["content"] = content
            
            if let story = newChapter.story, let storyRecordName = story.recordName {
                chapterRecord["story"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: storyRecordName), action: .none)
            }
    
            CKContainer.default().publicCloudDatabase.save(chapterRecord) { record, error in
                if let error = error {
                    print("Error saving chapter to CloudKit: \(error)")
                } else {
                    print("Chapter saved to CloudKit")
                }
            }
            return true
        } catch {
            print("Error saving chapter: \(error)")
            return false
        }
    }
    
    
    
    func generateNextChapter(completion: @escaping (String, Error?) -> Void) {
        currentChapterIndex += 1
        let sectionNumber = getSectionNumber(for: self.currentChapterIndex)
        let section = HeroJourneyFormula.sections[sectionNumber]
        let title = generateMysteriousTitle(chapterNumber: self.currentChapterIndex, section: section)
        let originalPrompt = HeroJourneyFormula.prompts[sectionNumber]
        let outlinePrompt = storyOutline[currentOutlinePointIndex]
        let adjustedPrompt = generateAdjustedPrompt(prompt: originalPrompt)
        let fullPrompt = "\(title) \(adjustedPrompt) \(outlinePrompt) \(self.condensedSummary) Please write in the style of \(chosenStyle!)."
        complete(prompt: fullPrompt, maxTokens: 3000) { result in
            // Adjusted handling for OpenAIResult type
        }
    }
    
    
    private func generateAdjustedPrompt(prompt: String) -> String {
        print("Starting to generate adjusted prompt...") // Logging the start
        let unwantedPhrases = ["Ordinary World",
                               "Inciting Incident",
                               "Reaction to the Inciting Incident",
                               "Introduction to the New Situation",
                               "Exploration of the New Situation",
                               "First Challenge",
                               "Making Allies",
                               "Intensifying Mystery or Conflict",
                               "A Test of Skills",
                               "Introduction of Subplot",
                               "Character Development",
                               "Evolution of Relationships",
                               "Rising Tension",
                               "Climax of Conflicts",
                               "Crisis Point",
                               "Preparing for Climax",
                               "Climax",
                               "Aftermath of Climax",
                               "Resolution of Subplots",
                               "Return to Ordinary World and Setup for Next Adventure"]
        var adjustedPrompt = prompt
        for phrase in unwantedPhrases {
            adjustedPrompt = adjustedPrompt.replacingOccurrences(of: phrase, with: "")
        }
        print("Adjusted prompt generated: \(adjustedPrompt)") // Logging the result
        return adjustedPrompt
    }
    
    
    func createSummary(for chapter: String, completion: @escaping (String, Error?) -> Void) {
        print("Starting to create summary for chapter...") // Logging the start
        let prompt = "Summarize the following text: \(chapter)"
        complete(prompt: prompt, maxTokens: 1000) { result in
            switch result {
            case .success(let response):
                let summary = response.choices[0].message.content.trimmingCharacters(in: .whitespacesAndNewlines)
                print("Summary created successfully: \(summary)") // Logging success
                completion(summary, nil)
            case .failure(let error):
                print("Error generating summary: \(error)")
                completion("", error)
            }
        }
    }
    private func generateCondensedSummary(completion: @escaping (String, Error?) -> Void) {
        // Create a prompt from the chapter summaries
        let prompt = "Summarize the following chapter summaries into a short paragraph: " + chapterSummaries.joined(separator: "\n")
        // Call the complete function with the new prompt
        complete(prompt: prompt, maxTokens: 1000) { result in
            switch result {
            case .success(let response):
                let condensedSummary = response.choices[0].message.content.trimmingCharacters(in: .whitespacesAndNewlines)
                completion(condensedSummary, nil)
            case .failure(let error):
                print("Error generating condensed summary: \(error)")
                completion("", error)
            }
        }
    }
    private func complete(prompt: String, maxTokens: Int, completion: @escaping (Result<OpenAIResult, Error>) -> Void) {
        // Assuming apiUrl and apiKey are correctly set
        guard let url = URL(string: apiUrl) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "You are an award-winning novelist known for your ability to craft complex characters, engaging dialogues, and thrilling opening chapter hooks. Your characters act with consistency and depth, their dialogues filled with subtext that reveals personality and propels the plot forward. You masterfully weave intricate plots and subplots, emphasizing emotional, action-driven storytelling. Your writing style aligns with popular authors from the last 25 years, and you can adapt to the style and genre specified by the user. Your goal is to compel readers to keep turning the page, eager to discover what happens next. "],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": maxTokens
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Create a custom URLSession configuration with a 30-second timeout
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 90.0 // 90 seconds
        let session = URLSession(configuration: configuration)
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in API request: \(error)")
                completion(.failure(error))
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(OpenAIResult.self, from: data)
                    print("API response body: \(result)")
                    completion(.success(result))
                } catch {
                    print("Error decoding API response: \(error)")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
