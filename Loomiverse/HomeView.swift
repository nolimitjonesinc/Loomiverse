// HomeView.swift
import SwiftUI

struct HomeView: View {
    // This part is like saying, "I'm using the data from our storage!"
    @Environment(\.managedObjectContext) var managedObjectContext

    // Here we make a list of books to read. Each one gets a picture and a title.
    let readBooks: [BookModel] = [
        BookModel(coverName: "Mage Book Cover", title: "Mage's Journey"),
        BookModel(coverName: "Red Book Cover", title: "Red Dawn Adventures"),
        BookModel(coverName: "32_large", title: "The Great Adventure")
    ]

    // Here's another list, this time for books we can listen to.
    let listenBooks: [BookModel] = [
        BookModel(coverName: "Mystery Thriller Book Cover", title: "Mystery Thriller"),
        BookModel(coverName: "32_small", title: "Small Mysteries"),
        BookModel(coverName: "35_large", title: "Large Tales")
    ]

    // This is how we decide what our screen looks like.
    var body: some View {
        NavigationView {
            VStack {
                // Top part with the app logo and a magnifying glass icon.
                HStack {
                    Image("Loomiverse Logo")
                    Spacer()
                    Text("Loomiverse")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                    }
                }
                .padding()

                // Now the main part where we show our books in a scrolling view.
                ScrollView {
                    VStack(alignment: .leading) {
                        // A section for reading books.
                        Text("Read")
                            .font(.headline)
                            .padding(.vertical)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(readBooks) { book in
                                NavigationLink(destination: Text("Details for \(book.title)")) {
                                    Image(book.coverName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 150)
                                }
                            }
                        }

                        // And here's a section for audiobooks.
                        Text("Listen")
                            .font(.headline)
                            .padding(.vertical)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(listenBooks) { book in
                                NavigationLink(destination: Text("Details for \(book.title)")) {
                                    Image(book.coverName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 150)
                                }
                            }
                        }
                    }
                }
                .padding()

                // This is just to push everything up.
                Spacer()
            }
            // We don't want to show the navigation bar on this screen.
            .navigationBarHidden(true)
        }
    }
}
