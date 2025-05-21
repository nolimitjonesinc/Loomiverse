import SwiftUI

struct BookContentView: View {
    var book: BookModel

    var body: some View {
        VStack {
            Image(book.coverName)
                .resizable()
                .scaledToFit()
            Text(book.title)
        }
        .navigationBarTitle("Book Details", displayMode: .inline)
    }
}
