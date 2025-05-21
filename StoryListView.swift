import SwiftUI
import CoreData
import CloudKit

struct StoryListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: Story.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Story.title, ascending: true)]
    ) var stories: FetchedResults<Story>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(stories, id: \.id) { story in
                    NavigationLink(destination: ChapterListView(story: story)) {
                        Text(story.title ?? "Untitled")
                            .foregroundColor(Color.primary) // Ensures text color is set to default primary color
                    }
                }
                .onDelete(perform: deleteAndArchiveStory)
            }
            .navigationBarTitle("Stories")
            .navigationBarItems(trailing: EditButton())
        }
    }
    
    private func deleteAndArchiveStory(at offsets: IndexSet) {
        for index in offsets {
            let story = stories[index]
            managedObjectContext.delete(story)
            archiveStoryInCloudKit(storyID: story.id) // Pass UUID directly
        }
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
    
    
    private func archiveStoryInCloudKit(storyID: UUID?) {
        guard let storyID = storyID?.uuidString else { return } // Convert UUID to String
        let recordID = CKRecord.ID(recordName: storyID)
        let database = CKContainer.default().publicCloudDatabase
        
        database.fetch(withRecordID: recordID) { record, error in
            if let record = record, error == nil {
                record["status"] = "archived"
                database.save(record) { _, saveError in
                    if let saveError = saveError {
                        print("Error archiving story in CloudKit: \(saveError)")
                    } else {
                        print("Story successfully archived in CloudKit")
                    }
                }
            } else if let error = error {
                print("Error fetching story for archiving in CloudKit: \(error)")
            }
        }
    }
    
    
    // ChapterListView struct
    struct ChapterListView: View {
        let story: Story
        @FetchRequest var storyChapters: FetchedResults<StoryChapters> // Changed here
        
        init(story: Story) {
            self.story = story
            self._storyChapters = FetchRequest<StoryChapters>(
                entity: StoryChapters.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \StoryChapters.chapterNumber, ascending: true)],
                predicate: NSPredicate(format: "story == %@", story) // Pass 'story' as an argument directly
            )
        }

        
        var body: some View {
            NavigationView {
                List {
                    ForEach(storyChapters, id: \.self) { chapter in
                        NavigationLink(destination: ChapterDetailView(chapter: chapter)) {
                            Text("Chapter \(chapter.chapterNumber): \(chapter.title ?? "Untitled")")
                                .foregroundColor(Color.primary) // Ensures text color is set to default primary color
                        }
                    }
                }
                .navigationBarTitle(Text(story.title ?? "Untitled"), displayMode: .inline)
            }
        }
    }
    
    // ChapterDetailView struct
    struct ChapterDetailView: View {
        let chapter: StoryChapters
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Chapter \(chapter.chapterNumber): \(chapter.title ?? "Untitled")")
                        .font(.headline)
                        .foregroundColor(Color.primary) // Ensures text color is set to default primary color
                    Text(chapter.content ?? "")
                        .foregroundColor(Color.primary) // Ensures text color is set to default primary color
                }
                .padding()
            }
            .navigationBarTitle(Text("Chapter Details"), displayMode: .inline)
        }
    }
}
