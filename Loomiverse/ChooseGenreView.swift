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

    // Simple grid layout with 2 columns
    private var columns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }

    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(genres, id: \.self) { genre in
                            Button(genre) {
                                selectedGenre = genre
                                isPresentingDetailsView = true
                            }
                            .buttonStyle(GenreButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                .navigationTitle("Choose Your Genre")
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Choose Your Genre")
                    }
                }
            }
            
            // Overlay instead of sheet for better visibility
            if isPresentingDetailsView, let genre = selectedGenre {
                // Semi-transparent background
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        // Allow tapping outside to dismiss
                        isPresentingDetailsView = false
                    }
                
                // Content container
                VStack {
                    // Close button
                    HStack {
                        Spacer()
                        Button(action: {
                            isPresentingDetailsView = false
                        }) {
                            Text("X")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Story details view
                    StoryDetailsView(genre: genre, storyGenerator: storyGenerator)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .padding()
                }
            }
        }
        .onAppear {
            // Reset the genre selection when the view appears
            selectedGenre = nil
        }
    }
}

// Custom Button Style
struct GenreButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(size: 25)) // Font size for better fit in grid
            .frame(maxWidth: .infinity)
            .foregroundColor(.white) // Text color
            .padding() // Space inside the button around the text
            .background(Color.black) // Button background color
            .cornerRadius(10) // Rounded corners
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: 2) // Simple white stroke around the button
            )
    }
}
