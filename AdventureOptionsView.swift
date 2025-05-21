import SwiftUI
import CoreData

struct AdventureOptionsView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext  // Accessing the managed object context
    @State private var showGenreSelection = false  // This keeps track of whether to show the genre picker
    
    var body: some View {
        NavigationView {
            VStack(spacing: 50) {
                
                // Button to read stories
                Button("Read") {
                    // Action to perform when 'Read' is tapped
                    // You would add what happens when this is tapped, like opening a story reader
                }
                .styledButton()

                // Button to choose your own adventure
                Button("Create") {
                    showGenreSelection = true  // This will show the genre selection when tapped
                }
                .sheet(isPresented: $showGenreSelection) {
                    ChooseGenreView(storyGenerator: StoryGenerator(context: managedObjectContext))  // Initializing StoryGenerator with managedObjectContext
                }
                .styledButton()

                // Button to listen to stories
                Button("Listen") {
                    // Action to perform when 'Listen' is tapped
                    // You would add what happens when this is tapped, like starting an audio story
                }
                .styledButton()
            }
            .background(Color(UIColor.systemBackground))  // Makes the background match the theme (light or dark)
            .navigationBarHidden(true)  // Hides the navigation bar to make it look cleaner
        }
    }
}

// Extension to style buttons consistently
extension View {
    func styledButton() -> some View {
        self
        .font(.largeTitle) // Using a large dynamic type
        .foregroundColor(.white)
        .padding(40)
        .background(Color.black)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple, Color.red]), startPoint: .leading, endPoint: .trailing), lineWidth: 10)
        )
        .padding()
    }
}
