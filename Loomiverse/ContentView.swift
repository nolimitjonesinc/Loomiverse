import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @State private var story = ""
    @State private var isShowingShareSheet = false
    @State private var databaseURL: URL?
    @State private var showStoryTypeSelection = false

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                List {
                    Section(header: Text("Create New Story")) {
                        Button("Start New Story") {
                            showStoryTypeSelection = true
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                        .sheet(isPresented: $showStoryTypeSelection) {
                            StoryTypeSelectionView()
                        }
                    }
                    // Additional sections...
                }
                .navigationTitle("Loomiverse")
                .background(Image("Title").resizable().scaledToFill().ignoresSafeArea())
            }
            .frame(maxWidth: geometry.size.width > 600 ? .infinity : nil)
            .sheet(isPresented: $isShowingShareSheet) {
                if let url = databaseURL {
                    ActivityView(activityItems: [url], applicationActivities: nil)
                }
            }
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Handle the error here
                    print("An error occurred while sharing: \(error.localizedDescription)")
                }
            }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
