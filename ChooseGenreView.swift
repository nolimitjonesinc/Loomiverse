import SwiftUI
import CoreData

struct ChooseGenreView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @StateObject var storyGenerator: StoryGenerator
    @State private var selectedGenre: String? = nil
    @State private var isPresentingDetailsView = false

    private let genres: [String] = [
        "Fantasy", "Romance", "Sci-Fi", "Mystery", "Thriller", "Young Adult",
        "Crime", "Horror", "Historical Fiction", "Adventure", "Dystopian", "Paranormal",
        "Cyberpunk Tale", "Dark Fantasy Story", "Romantic Comedy", "Graphic Novel",
        "Action", "Literary Fiction", "Magic Realism", "Biography/Autobiography",
        "70s Sci-Fi", "Gothic", "Noir Crime Thriller", "Western", "Satire",
        "Stand Up Comedy (in first person pov and style of Nate Bargatze)"
    ]

    private var columns: [GridItem] {
        Array(repeating: .init(.flexible(), spacing: 20), count: UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(genres, id: \.self) { genre in
                        Button(genre) {
                            selectedGenre = genre
                            isPresentingDetailsView = true
                        }
                        .buttonStyle(GenreButtonStyle())
                        // Using closure directly to ensure it triggers correctly.
                        .sheet(isPresented: $isPresentingDetailsView, onDismiss: {
                            isPresentingDetailsView = false // Reset the state when sheet is dismissed
                        }) {
                            // Only present if selectedGenre is not nil
                            if let genre = selectedGenre {
                                StoryDetailsView(genre: genre, storyGenerator: storyGenerator)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Choose Your Genre")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Custom Button Style
struct GenreButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(size: 25)) // Font size for better fit in grid
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50) // Ensure each button has the same size
            .foregroundColor(.white) // Text color
            .padding() // Space inside the button around the text
            .background(Color.black) // Button background color
            .cornerRadius(10) // Rounded corners
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: 5) // Simple white stroke around the button
            )
    }
}

