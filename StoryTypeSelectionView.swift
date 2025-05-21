import SwiftUI

struct StoryTypeSelectionView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext // Assuming you need it here
    @State private var navigateToGenreSelection = false
    @State private var selectedStoryType: String?
    @StateObject var storyGenerator = StoryGenerator(context: PersistenceController.shared.viewContext) // Assuming context initialization

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button("Classic") {
                    selectedStoryType = "Classic"
                    navigateToGenreSelection = true
                }
                .buttonStyle(StoryTypeButtonStyle())

                Button("Choose Your Own Adventure") {
                    selectedStoryType = "Choose Your Own Adventure"
                    navigateToGenreSelection = true
                }
                .buttonStyle(StoryTypeButtonStyle())
                
                NavigationLink(destination: ChooseGenreView(storyGenerator: storyGenerator), isActive: $navigateToGenreSelection) {
                    EmptyView()
                }
            }
            .navigationTitle("Select Story Type")
        }
    }
}

// Custom button style for the story type selection
struct StoryTypeButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 10)
    }
}
