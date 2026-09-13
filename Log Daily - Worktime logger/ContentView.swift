import SwiftUI
import SwiftData


struct WeightedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.91 : 1.0)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .shadow(
                color: .black.opacity(configuration.isPressed ? 0.08 : 0.25),
                radius: configuration.isPressed ? 4 : 18,
                y: configuration.isPressed ? 2 : 10
            )
            .animation(
                .spring(
                    response: 0.35,
                    dampingFraction: 0.38
                ),
                value: configuration.isPressed
            )
    }
}


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentItem: Item?
    
    @State private var buttonPulse = false

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                if let item = currentItem {
                    WorkingView(currentItem: item)
                } else {
                    // Changed to Button
                    Button(action: {
                        withAnimation {
                            let newItem = Item(timestamp: Date())
                            modelContext.insert(newItem)
                            currentItem = newItem
                        }
                        
                        
                        
                    }) {
                        Text("Start Work")
                            .padding(80)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                            .background(Color.green)
                            .font(.system(size: 28))
                            .clipShape(.circle)
                            .padding(.top, 10)
                    }
                    .buttonStyle(WeightedButtonStyle())
                    
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
                        .font(.system(size: 25))
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
                .buttonStyle(WeightedButtonStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
           
        }
    }

    private func endWork() {
        withAnimation {
            currentItem.leavetime = Date()
            try? modelContext.save() // Ensure changes are saved
        }
    }
    
    
}


// login view

struct LogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var items: [Item]

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text("Work Sessions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                VStack(alignment: .center) {
                    List {
                        let reversedItems = items.reversed()
                        ForEach(reversedItems) { item in
                            VStack(alignment: .leading) {
                            

                                if let endTime = item.leavetime {
                                    
                                    Text(endTime.formatted(.dateTime.day(.defaultDigits).month(.defaultDigits).year(.defaultDigits)))
                                                .font(.headline)
                                    
                                    Text(item.totalWorkTime ?? "0 hours: 0 minutes")
                                        .font(.subheadline)
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
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .background(Color.blue)
                        .font(.system(size: 25))
                        .clipShape(.circle)
                }
                .buttonStyle(WeightedButtonStyle())
                
            }
            .frame(maxWidth: .infinity, alignment: .center)
          //  .ignoresSafeArea(.all)
        }
        Spacer()
    }
}








#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
