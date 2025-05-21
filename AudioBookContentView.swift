import SwiftUI

struct AudioBookContentView: View {
    var book: BookModel

    var body: some View {
        VStack {
            Image(book.coverName)
                .resizable()
                .scaledToFit()
            Text(book.title)
        }
        .navigationBarTitle("Audio Book Details", displayMode: .inline)
    }
}
