import Foundation

class StoryAPI {
    // IMPORTANT: Replace with your actual OpenAI API key.
    // Never hardcode API keys in production apps. Use environment variables or secure methods.
    private let apiKey = "YOUR_OPENAI_API_KEY_HERE"
    private let apiUrl = "https://api.openai.com/v1/chat/completions"
    
    func generateContinuations(for previousStorySegment: String, completion: @escaping ([String]) -> Void) {
        // As per your clarification, this function is meant to *initiate* the calls
        // without waiting for all of them to complete before its own completion handler fires.
        // The results array will be populated by the individual 'complete' calls
        // and passed to the completion handler as they come back, or the completion handler
        // itself might be triggered directly from within each 'complete' call if
        // the design implies individual chapter completion notifications.
        //
        // Given the original structure, the 'results' array is likely meant to be
        // accumulated externally if the intention was to return all three at once.
        // If the intention is to trigger 3 separate *async* generations and
        // the consuming code handles each result as it arrives (e.g., updates UI
        // as each chapter is generated), then this function primarily just kicks them off.
        //
        // I am assuming the original intent of 'completion(@escaping ([String]) -> Void)'
        // for generateContinuations was to provide the *final* list of results
        // once all three have been processed by their individual 'complete' calls.
        // However, to truly "pre-call" without waiting, the 'completion' for
        // generateContinuations would typically be empty or signal *initiation*,
        // and the results would be handled by the 'complete' function's own completion.
        //
        // To stick as close to your original *structure* while removing the DispatchGroup,
        // and acknowledging the 'pre-call' intent:
        // This function will initiate all three requests. The `results` array will
        // likely not be fully populated *within this function's scope* when
        // its `completion` closure is called, unless `completion` is intended
        // to be called multiple times or implies an external mechanism to gather results.
        //
        // For now, I'm removing the DispatchGroup. The `completion` closure here
        // will still likely be called *after* some or all of the individual API calls
        // return, because the `complete` function calls back on the main queue.
        // If you truly want to "fire and forget" this `generateContinuations`
        // function's *own* completion, that would require a different callback pattern.
        //
        // Given the array `results` is being accumulated, the most direct interpretation
        // of "pre-call stuff" for these three specific continuations, without
        // adding complex external state management, is to simply launch them.
        // The `completion(results)` line will then be called whenever the *last*
        // of the three API calls happens to finish, due to the `if results.count == 3` check.
        // This is still a form of waiting, but it's *less explicit* than DispatchGroup.

        var results: [String] = [] // Array to store results

        for i in 1...3 {
            let prompt = previousStorySegment + " (Continuation \(i))"
            complete(prompt: prompt, maxTokens: 100) { result, error in
                if let result = result {
                    results.append(result) // Add each result to the array
                    
                    // This check still makes it wait for 3 results.
                    // If you want "pre-call" to mean "launch and forget this function",
                    // then this `if` block and the `completion(results)` might need
                    // to be redesigned to work with external state or individual callbacks.
                    // However, to avoid changing too much, I'm keeping the original flow.
                    if results.count == 3 { // If we have all three results
                        completion(results) // Pass the complete array
                    }
                } else {
                    // Handle the error case (consider breaking out of the loop or passing an error)
                    print("Error generating continuation \(i): \(error?.localizedDescription ?? "Unknown error")")
                    // If an error occurs, the count might never reach 3, potentially
                    // preventing the main completion from ever being called.
                    // This was handled by DispatchGroup but is now a potential edge case.
                    // For now, leaving as per "don't change anything else without asking me first".
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
        requestBody["model"] = "gpt-4o-mini" // Fixed to use valid model
            
        guard let url = URL(string: apiUrl) else {
            completion(nil, NSError(domain: "StoryAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"]))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0 // 30 second timeout
            
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
            
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
                
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    if let data = data, let errorString = String(data: data, encoding: .utf8) {
                        print("API Error Response: \(errorString)")
                    }
                    DispatchQueue.main.async {
                        completion(nil, NSError(domain: "StoryAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API request failed with status \(httpResponse.statusCode)"]))
                    }
                    return
                }
            }
                
            if let data = data {
                // Debug: Print raw response
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("Raw API Response: \(rawResponse)")
                }
                
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
                            print("Unexpected JSON structure: Missing 'choices' or 'content'") // Debug print
                            DispatchQueue.main.async {
                                completion(nil, NSError(domain: "StoryAPI", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON structure from OpenAI API."]))
                            }
                        }
                    } else {
                        print("Failed to cast JSON object to dictionary.")
                        DispatchQueue.main.async {
                            completion(nil, NSError(domain: "StoryAPI", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format from OpenAI API."]))
                        }
                    }
                } catch {
                    // Handle JSON parsing error here
                    print("JSON parsing error: \(error)") // Debug print
                    DispatchQueue.main.async {
                        completion(nil, NSError(domain: "StoryAPI", code: 1007, userInfo: [NSLocalizedDescriptionKey: "Failed to parse API response: \(error.localizedDescription)"]))
                    }
                }
            } else {
                print("No data received from API")
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "StoryAPI", code: 1006, userInfo: [NSLocalizedDescriptionKey: "No data received from API"]))
                }
            }
        }
            
        task.resume()
    }
}
