import Foundation
import CoreData
import CloudKit

// Import StoryChapterModel from StoryChapters.swift instead of redefining it


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
    // IMPORTANT: Replace "YOUR_OPENAI_API_KEY_HERE" with your actual OpenAI API key.
    // Never hardcode API keys in production apps. Use environment variables or secure methods.
    private let apiKey = "YOUR_OPENAI_API_KEY_HERE"
    private let apiUrl = "https://api.openai.com/v1/chat/completions"
    var protagonistName: String = ""
    var currentAllies: [String] = []
    var currentLocation: String = ""
    var chapterSummaries: [String] = []
    private var generatedChapters: [String] = [] // Store actual chapter content
    private var condensedSummary: String = ""
    private var storyOutline: [String] = [] // Keep it private
    private var currentChapterIndex: Int = 1
    private var AuthorStyles: [AuthorStyle] = []
    private var chosenStyle: String?
    private var currentOutlinePointIndex: Int = 0 // Changed to 0-indexed for array access
    
    
    private func getSectionNumber(for chapterNumber: Int) -> Int {
        return chapterNumber - 1 // Assuming chapters start with an index of 1
    }
    
    func generateOpeningChapter(for titleAndLogline: String, outline: [String], completion: @escaping (StoryChapterModel?, Error?) -> Void) {
        // Generate opening chapter using OpenAI
        let prompt = """
        Create an engaging opening chapter for a story titled "\(titleAndLogline)".
        The story outline is as follows: \(outline.joined(separator: "\n"))
        
        IMPORTANT: You must format your response EXACTLY as follows:
        
        TITLE: [Create a compelling title for this opening chapter that sets the tone]
        
        [Start writing the opening chapter immediately. Begin with an engaging hook that draws readers into the story. Introduce the main character and establish the story's world and premise.]
        
        The chapter title should be creative and compelling (like "An Unexpected Discovery" or "The Call to Adventure" or "A New Beginning").
        """
        
        generateChapterContent(prompt: prompt) { result, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let fullResponse = result {
                // Parse the title and content from the response
                let components = fullResponse.components(separatedBy: "\n")
                var chapterTitle = "The Journey Begins"
                var chapterContent = fullResponse
                
                // Look for the TITLE: line (case insensitive)
                if let titleLine = components.first(where: { 
                    $0.uppercased().hasPrefix("TITLE:") || $0.hasPrefix("TITLE:") 
                }) {
                    // Extract title after "TITLE:" (handle both upper and lower case)
                    let titleText = titleLine.replacingOccurrences(of: "TITLE:", with: "")
                                            .replacingOccurrences(of: "title:", with: "")
                                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if !titleText.isEmpty {
                        chapterTitle = titleText
                        
                        // Find where the actual content starts (after the title line and any empty lines)
                        if let titleIndex = components.firstIndex(of: titleLine) {
                            let contentComponents = Array(components.dropFirst(titleIndex + 1))
                            // Skip empty lines at the beginning
                            let contentStartIndex = contentComponents.firstIndex { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } ?? 0
                            chapterContent = Array(contentComponents.dropFirst(contentStartIndex)).joined(separator: "\n")
                        }
                    }
                }
                
                // Store the opening chapter content for future chapters to reference
                self.generatedChapters.append(chapterContent)
                
                let chapter = StoryChapterModel(story: chapterContent, number: 1, summary: "", title: chapterTitle)
                completion(chapter, nil)
            } else {
                completion(nil as StoryChapterModel?, NSError(domain: "Loomiverse", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Failed to generate opening chapter"]))
            }
        }
    }
    
    func createSummary(for chapter: String, completion: @escaping (String?, Error?) -> Void) {
        let prompt = """
        Create a concise summary of the following chapter:
        \(chapter)
        The summary should be 2-3 sentences long and capture the main events and themes.
        """
        
        generateChapterContent(prompt: prompt) { result, error in
            if let error = error {
                completion(nil as String?, error)
                return
            }
            
            completion(result, nil)
        }
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
        
        // Set up genre-specific formulas
        setupGenreFormulas()
    }
    
    func getStoryOutline() -> [String] {
        return storyOutline
    }
    
    // This function is already defined above
    // Removed duplicate function
    
    private func generateChapterContent(prompt: String, completion: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: apiUrl) else {
            completion(nil, NSError(domain: "Loomiverse", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"]))
            return
        }
        
        // Get a random author style to use
        let selectedStyle = getRandomAuthorStyle()
        let enhancedPrompt = selectedStyle.isEmpty ? prompt : "\(prompt)\n\nWriting Style: \(selectedStyle)"
        
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": enhancedPrompt]],
            "max_tokens": 3000,  // Increased for longer chapters
            "temperature": 0.7
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let data = data else {
                    completion(nil, NSError(domain: "Loomiverse", code: 1002, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(OpenAIResult.self, from: data)
                    if let content = result.choices.first?.message.content {
                        completion(content, nil)
                    } else {
                        completion(nil, NSError(domain: "Loomiverse", code: 1003, userInfo: [NSLocalizedDescriptionKey: "No content in response"]))
                    }
                } catch {
                    completion(nil, error)
                }
            }
            task.resume()
        } catch {
            completion(nil as String?, error)
        }
    }
    
    private func getRandomAuthorStyle() -> String {
        guard !AuthorStyles.isEmpty else { return "" }
        
        let randomStyle = AuthorStyles.randomElement()
        if let randomAuthor = randomStyle?.authors.randomElement(),
           let description = randomAuthor.description {
            return "Write in the style of \(randomAuthor.name): \(description)"
        }
        return ""
    }
    
    let HeroJourneyFormula = StoryFormula(
        sections: [
            // Core beats that must be present
            "Ordinary World",
            "Inciting Incident",
            "Call to Adventure",
            "Crossing the Threshold",
            "Tests, Allies, and Enemies",
            "Approach to the Inmost Cave",
            "Climax",
            "Return with the Elixir",
            
            // Genre-specific beats (filled in by genre-specific formulas)
            "Genre_Beat_1",
            "Genre_Beat_2",
            "Genre_Beat_3",
            "Genre_Beat_4",
            "Genre_Beat_5"
        ],
        prompts: [
            "Describe the protagonist's ordinary world and establish their desires and fears.",
            "What event disrupts the protagonist's normal life?",
            "How does the protagonist initially react to the call to adventure?",
            "What challenges must the protagonist overcome to fully commit to the journey?",
            "Who are the key allies and enemies the protagonist encounters?",
            "How does the protagonist prepare for the final challenge?",
            "What is the ultimate confrontation and how does it resolve?",
            "How has the protagonist changed and what have they learned?",
            "What unique elements does this genre bring to each beat?",
            "9. Genre_Specific_Beat_1",
            "10. Genre_Specific_Beat_2",
            "11. Genre_Specific_Beat_3",
            "12. Optional_Beat_1",
            "13. Optional_Beat_2",
            "14. Optional_Beat_3"
        ],
        chapterCounts: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    )

    // Add genre-specific formulas
    private var genreFormulas: [String: StoryFormula] = [:]

    func getGenreFormula(for genre: String) -> StoryFormula {
        // Return genre-specific formula if available, otherwise use default
        return genreFormulas[genre] ?? HeroJourneyFormula
    }

    // Add genre-specific beats and prompts
    func setupGenreFormulas() {
        // Fantasy-specific formula
        let fantasyFormula = StoryFormula(
            sections: [
                "World-Building",
                "Magic System Introduction",
                "Quest Setup",
                "Dungeon Crawl",
                "Magical Artifact Discovery"
            ],
            prompts: [
                "1. Create a rich fantasy world with unique geography and culture.",
                "2. Introduce the magic system and its rules.",
                "3. Set up the main quest with clear objectives.",
                "4. Create a challenging dungeon with puzzles and traps.",
                "5. Design a magical artifact with significant story implications."
            ],
            chapterCounts: [1, 1, 1, 1, 1]
        )
        genreFormulas["Fantasy"] = fantasyFormula

        // Mystery-specific formula
        let mysteryFormula = StoryFormula(
            sections: [
                "Crime Scene",
                "Detective Introduction",
                "Clue Discovery",
                "Red Herring",
                "Revelation"
            ],
            prompts: [
                "1. Create a compelling crime scene with multiple clues.",
                "2. Introduce a unique detective with a distinct methodology.",
                "3. Plant subtle clues that lead to the solution.",
                "4. Include a convincing red herring to mislead the reader.",
                "5. Reveal the solution in a satisfying way."
            ],
            chapterCounts: [1, 1, 1, 1, 1]
        )
        genreFormulas["Mystery"] = mysteryFormula

        // Romance-specific formula
        let romanceFormula = StoryFormula(
            sections: [
                "Meet Cute",
                "Initial Attraction",
                "Conflict",
                "Resolution",
                "Happily Ever After"
            ],
            prompts: [
                "1. Create a memorable meet-cute scenario.",
                "2. Build initial attraction through dialogue and shared experiences.",
                "3. Introduce a conflict that keeps them apart.",
                "4. Show how they overcome their differences.",
                "5. Create a satisfying romantic resolution."
            ],
            chapterCounts: [1, 1, 1, 1, 1]
        )
        genreFormulas["Romance"] = romanceFormula
    }
    
    
    func generateTitleAndLogline(for genre: String, completion: @escaping (String, Error?) -> Void) {
        // Create a prompt that uses the author's style
        let prompt = "Generate a compelling title and logline for a \(genre) story."
        
        completeRequest(prompt: prompt, maxTokens: 1000) { result in
            switch result {
            case .success(let response):
                guard let content = response.choices.first?.message.content else {
                    completion("", nil)
                    return
                }
                
                // Extract title and logline from the response
                let components = content.components(separatedBy: ":")
                guard components.count >= 2 else {
                    completion("", nil)
                    return
                }
                
                let title = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let logline = components[1...].joined(separator: ":").trimmingCharacters(in: .whitespacesAndNewlines)
                
                completion("\(title): \(logline)", nil)
            case .failure(let error):
                completion("", error)
            }
        }
    }
    
    func generateOutline(for titleAndLogline: String, genre: String, completion: @escaping ([String], Error?) -> Void) {
        print("Starting to generate an outline for genre: \(genre)...") // Logging the start of the outline generation
        
        // Get genre-specific formula
        let formula = getGenreFormula(for: genre)
        let genreStructure = formula.sections.joined(separator: ", ")
        
        let prompt = """
        Generate a detailed story outline for a \(genre) story with the title and logline: "\(titleAndLogline)".
        
        Structure the story using these genre-appropriate beats: \(genreStructure)
        
        Create \(formula.sections.count) chapter summaries that form a complete \(genre) story arc with:
        - Compelling beginning that hooks readers
        - Engaging middle with rising tension and character development  
        - Satisfying conclusion that resolves all plot threads
        
        Each chapter should be substantial (aim for 2000-3000 words when expanded).
        Format as numbered chapters with clear, detailed summaries.
        """
        print("Using prompt: \(prompt)") // Logging the prompt being used
        
        completeRequest(prompt: prompt, maxTokens: 1500) { result in
            switch result {
            case .success(let response):
                guard let content = response.choices.first?.message.content else {
                    completion([], NSError(domain: "Loomiverse", code: 1003, userInfo: [NSLocalizedDescriptionKey: "No content in response"]))
                    return
                }
                
                let outline = content.trimmingCharacters(in: .whitespacesAndNewlines)
                let outlinePoints = outline.components(separatedBy: "\n").filter { !$0.isEmpty }
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
    
    func generateChapter(for titleAndLogline: String, chapterNumber: Int, completion: @escaping (StoryChapterModel?, Error?) -> Void) {
        // Validate chapter number
        if chapterNumber < 1 || chapterNumber > storyOutline.count {
            completion(nil as StoryChapterModel?, NSError(domain: "Loomiverse", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Chapter number out of range"]))
            return
        }
        
        // Get the outline point for this chapter
        let outlinePoint = storyOutline[chapterNumber - 1]
        
        // Create a prompt that requests both title and content
        let prompt = """
        Write chapter \(chapterNumber) based on this outline: \(outlinePoint).
        
        Previous chapters: \(generatedChapters.joined(separator: "\n\n--- END OF CHAPTER ---\n\n"))
        
        Title and logline: \(titleAndLogline)
        
        IMPORTANT: You must format your response EXACTLY as follows:
        
        TITLE: [Create a compelling, specific chapter title that reflects the main events or themes in this chapter]
        
        [Start writing the actual chapter story content here immediately. Begin with engaging narrative that draws the reader into the action. Do not include any prefacing text or explanations - jump straight into the story.]
        
        The chapter title should be creative and specific (like "The Dark Forest" or "A Mysterious Stranger" or "The Final Confrontation"), not generic like "Chapter \(chapterNumber)".
        """
        
        completeRequest(prompt: prompt, maxTokens: 6000) { result in
            switch result {
            case .success(let response):
                guard let fullResponse = response.choices.first?.message.content else {
                    completion(nil as StoryChapterModel?, NSError(domain: "Loomiverse", code: 1003, userInfo: [NSLocalizedDescriptionKey: "No content in response"]))
                    return
                }
                
                // Parse the title and content from the response
                print("Raw AI Response: \(fullResponse)")  // Debug log
                
                let components = fullResponse.components(separatedBy: "\n")
                var chapterTitle = "Chapter \(chapterNumber)"
                var chapterContent = fullResponse
                
                // Look for the TITLE: line (case insensitive)
                if let titleLine = components.first(where: { 
                    $0.uppercased().hasPrefix("TITLE:") || $0.hasPrefix("TITLE:") 
                }) {
                    // Extract title after "TITLE:" (handle both upper and lower case)
                    let titleText = titleLine.replacingOccurrences(of: "TITLE:", with: "")
                                            .replacingOccurrences(of: "title:", with: "")
                                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if !titleText.isEmpty {
                        chapterTitle = titleText
                        print("Extracted chapter title: \(chapterTitle)")  // Debug log
                        
                        // Find where the actual content starts (after the title line and any empty lines)
                        if let titleIndex = components.firstIndex(of: titleLine) {
                            let contentComponents = Array(components.dropFirst(titleIndex + 1))
                            // Skip empty lines at the beginning
                            let contentStartIndex = contentComponents.firstIndex { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } ?? 0
                            chapterContent = Array(contentComponents.dropFirst(contentStartIndex)).joined(separator: "\n")
                            print("Extracted chapter content length: \(chapterContent.count) characters")  // Debug log
                        }
                    }
                } else {
                    print("No TITLE: line found in response")  // Debug log
                }
                
                // Create a Core Data StoryChapters entity
                let chapter = NSEntityDescription.insertNewObject(forEntityName: "StoryChapters", into: self.context) as! NSManagedObject
                
                // Set values using key-value coding
                chapter.setValue(chapterContent, forKey: "content")
                chapter.setValue(Int32(chapterNumber), forKey: "chapterNumber")
                chapter.setValue(chapterTitle, forKey: "title")
                chapter.setValue(UUID(), forKey: "id")
                
                // Store the generated chapter content for future chapters to reference
                self.generatedChapters.append(chapterContent)
                
                // Create a model object to return
                let storyChapter = StoryChapterModel(story: chapterContent, number: chapterNumber, summary: outlinePoint, title: chapterTitle)
                completion(storyChapter, nil)
            case .failure(let error):
                completion(nil as StoryChapterModel?, error)
            }
        }
    }
    
    // Helper function for API requests
    private func completeRequest(prompt: String, maxTokens: Int, completion: @escaping (Result<OpenAIResult, Error>) -> Void) {
        guard let url = URL(string: apiUrl) else {
            completion(.failure(NSError(domain: "Loomiverse", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"])))
            return
        }
        
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": maxTokens,
            "temperature": 0.7
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NSError(domain: "Loomiverse", code: 1004, userInfo: [NSLocalizedDescriptionKey: "Failed to create JSON request body"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Loomiverse", code: 1006, userInfo: [NSLocalizedDescriptionKey: "No data received from API"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(OpenAIResult.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(NSError(domain: "Loomiverse", code: 1007, userInfo: [NSLocalizedDescriptionKey: "Failed to parse API response"])))
            }
        }
        task.resume()
    }
}
