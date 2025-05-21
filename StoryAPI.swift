import Foundation

class StoryAPI {
    private let apiKey =  apiKey goes here
    private let apiUrl = "https://api.openai.com/v1/chat/completions"
    
    func generateContinuations(for previousStorySegment: String, completion: @escaping ([String]) -> Void) {
        var results: [String] = [] // Array to store results

        for i in 1...3 {
            let prompt = previousStorySegment + " (Continuation \(i))"
            complete(prompt: prompt, maxTokens: 100) { result, error in
                if let result = result {
                    results.append(result) // Add each result to the array
                    
                    if results.count == 3 { // If we have all three results
                        completion(results) // Pass the complete array
                    }
                } else {
                    // Handle the error case (consider breaking out of the loop or passing an error)
                }
            }
        }
    }
    
    func complete(prompt: String, maxTokens: Int, completion: @escaping (String?, Error?) -> Void) {
        
        // Build messages array
        let messages: [[String: Any]] = [
            ["role": "system", "content": "You are a helpful assistant."],
            ["role": "user", "content": prompt]
        ]
        
        // Build request body
        var requestBody: [String: Any] = [:]
        requestBody["messages"] = messages
        requestBody["max_tokens"] = maxTokens
        requestBody["model"] = "gpt-4"
        
        let url = URL(string: apiUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("Data: \(String(describing: data))") // Debug print
            print("Response: \(String(describing: response))") // Debug print
            print("Error: \(String(describing: error))") // Debug print
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 400, let data = data {
                    let json = try? JSONSerialization.jsonObject(with: data, options: [])
                    print("OpenAI Error: \(String(describing: json))")
                }
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("Received JSON: \(json)") // Debug print
                        if let choices = json["choices"] as? [[String: Any]],
                           let firstChoice = choices.first,
                           let message = firstChoice["message"] as? [String: Any],
                           let text = message["content"] as? String {
                            print("Received text: \(text)") // Debug print
                            DispatchQueue.main.async {
                                completion(text, nil)
                            }
                        } else {
                            // Handle unexpected JSON structure here
                            print("Unexpected JSON structure") // Debug print
                        }
                    } else {
                        print("Unexpected JSON structure")
                    }
                } catch {
                    // Handle JSON parsing error here
                    print("JSON parsing error: \(error)") // Debug print
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        
        task.resume()
    }
}
