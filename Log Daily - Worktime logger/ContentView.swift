import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentItem: Item?

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                if let item = currentItem {
                    WorkingView(currentItem: item)
                } else {
                    // Start work button
                    NavigationLink(
                        destination: WorkingView(currentItem: Item(timestamp: Date())),
                        label: {
                            Text("Start Work")
                                .padding(60)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.black)
                                .background(Color.green)
                                .clipShape(.circle)
                                .padding(.top, 10)
                        }
                    )
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            withAnimation {
                                currentItem = Item(timestamp: Date())
                            }
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}


struct WorkingView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var currentItem: Item  // Use @Bindable to observe changes

    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Text("You are working")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Text("Started at: \(currentItem.timestamp.formatted(.dateTime.hour().minute()))")
                    .font(.title2)

                Spacer()

                NavigationLink(destination: LogView().navigationBarBackButtonHidden(true)) {
                    Text("End Day")
                        .padding(65)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .background(Color.red)
                        .clipShape(.circle)
                }
                .simultaneousGesture(
                    TapGesture().onEnded {
                        endWork()
                    }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func endWork() {
        withAnimation {
            currentItem.leavetime = Date()
        }
    }
}


struct LogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var items: [Item]

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Work Sessions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                VStack(alignment: .center) {
                    List {
                        ForEach(items) { item in
                            VStack(alignment: .leading) {
                                Text("Session")
                                    .font(.headline)
                                
                                if let endTime = item.leavetime {
                                    // Completed session
                                    Text("\(item.timestamp.formatted(.dateTime.hour().minute())) - \(endTime.formatted(.dateTime.hour().minute()))")
                                        .font(.subheadline)
                                } else {
                                    // Ongoing session
                                    Text("Started: \(item.timestamp.formatted(.dateTime.hour().minute())) - Still working")
                                        .font(.subheadline)
                                        .foregroundStyle(.orange)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.plain)
                }

                Spacer()

                NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true)) {
                    Text("Back to Start")
                        .padding(70)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .background(Color.blue)
                        .clipShape(.circle)
                        .padding(.bottom, 20)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}



#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
