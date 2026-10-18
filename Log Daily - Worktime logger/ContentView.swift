import SwiftUI
import SwiftData
import CoreLocation
import UniformTypeIdentifiers

extension Item {
    static func csv(from items: [Item]) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"

        var rows = ["Timestamp,Leave Time,Duration"]
        for item in items {
            let leave = item.leavetime.map { df.string(from: $0) } ?? ""
            rows.append("\(df.string(from: item.timestamp)),\(leave),\(item.totalWorkTime ?? "")")
        }
        return rows.joined(separator: "\n")
    }
}

struct ExportButton: View {
    let items: [Item]

    var body: some View {
        ShareLink(item: exportURL) {
            Label("Export CSV", systemImage: "square.and.arrow.up")
        }
    }

    var exportURL: URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("WorkTimes.csv")
        try? Item.csv(from: items).write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}

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
    @Query private var incompleteItems: [Item]
    
    
 // location
    @State private var locationManager = LocationManager()
    

    init() {
        _incompleteItems = Query(filter: #Predicate<Item> { $0.leavetime == nil })
    }

    var body: some View {
        NavigationView {
            
            ZStack() {
                Color.black
                    .ignoresSafeArea(.all)
                VStack(alignment: .center) {
                    if let item = currentItem {
                        WorkingView(currentItem: item)
                    } else {
                        Button(action: {
                            withAnimation {
                                let newItem = Item(timestamp: Date())
                                modelContext.insert(newItem)
                                currentItem = newItem
                            }
                        }) {
                            Text("Start Work")
                                .padding(110)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.white)
                                .background(Color.green)
                                .font(.system(size: 28))
                                .clipShape(.circle)
                                .padding(.top, 10)
                        }
                        .buttonStyle(WeightedButtonStyle())
                    }
                    
                    
                    //                Button("Find My Location") {
                    //                    locationManager.requestLocation()
                    //                }
                    
                }
                .frame(maxWidth: .infinity)
            }
            
        }
        .onAppear {
            locationManager.requestLocation()
            if let existingItem = incompleteItems.first {
                currentItem = existingItem
            }
        }
    }
}

struct WorkingView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var currentItem: Item
    @State private var timer: Timer?
    
    @State private var rotationDegrees = 0.0
    private var animation: Animation {
           .linear
           .speed(0.1)
           .repeatForever(autoreverses: false)
       }

    var body: some View {
        NavigationView {
            ZStack() {
                Color.black
                    .ignoresSafeArea(.all)
                VStack(spacing: 40) {
                    Text("You are working")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .padding()
                    
                    Text("Started at: \(currentItem.timestamp.formatted(.dateTime.hour().minute()))")
                        .font(.title2)
                        .foregroundStyle(Color.white)
                    
                    
                    
                    
                    
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
                    .buttonStyle(WeightedButtonStyle())
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            endWork()
                        }
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                try? modelContext.save()
            }
        }
        
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    private func endWork() {
        withAnimation {
            currentItem.leavetime = Date()
            try? modelContext.save()
        }
    }
}

struct LogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var items: [Item]

    @State private var multiSelection = Set<UUID>()
    var body: some View {
        NavigationView {
            ZStack() {
                Color.black
                    .ignoresSafeArea(.all)
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
                                            .foregroundStyle(Color.green)
                                        Text(item.totalWorkTime ?? "0 hours: 0 minutes")
                                            .font(.subheadline)
                                        
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            // cell backgrouind color
                            .listRowBackground(Color(red: 240, green: 230, blue: 235))
                            .foregroundColor(.gray)
                            
                        }
                        .listStyle(.insetGrouped)
                        .environment(\.defaultMinListRowHeight, 70)
                        .scrollContentBackground(.hidden)
                        .background(Color.black.edgesIgnoringSafeArea(.all))
                        
                        
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                ExportButton(items: items)
                            }
                            
                            ToolbarItem(placement: .topBarTrailing) {
                                Button(action:{
                                    
                                }) {
                                    Label("", systemImage: "gear")
                                      .padding()
                                      .foregroundColor(.white)
                                      .background(Color.blue)
                                      .cornerRadius(10)
                                  }
                            }
                        }
                       
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
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
