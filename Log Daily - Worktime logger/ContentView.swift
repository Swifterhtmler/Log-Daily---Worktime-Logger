//
//  ContentView.swift
//  Log Daily - Worktime logger
//
//  Created by Riku Kuisma on 10.8.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            VStack(alignment: .center) {
                Button(action: addItem) {
                    Label("Saavuin", systemImage: "plus")
                    .padding(.top,320)
                }
            }.frame(maxWidth: .infinity)
            
            List {
                ForEach(items) { item in
                    Text(item.timestamp.description)
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            //   let newItem = Item(timestamp: Date())
            //   modelContext.insert(newItem)
        }
    }
    //
    //    private func deleteItems(offsets: IndexSet) {
    //        withAnimation {
    //            for index in offsets {
    //                modelContext.delete(items[index])
    //            }
    //        }
    //    }
    //}
}
    
    #Preview {
        ContentView()
        //  .modelContainer(for: Item.self, inMemory: true)
    }

