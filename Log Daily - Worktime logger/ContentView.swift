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
    @Query var items: [Item]
    @State private var scale = 1.0
    
    // start of contentview: view
    var body: some View {
        
        
        NavigationView {
            
            VStack(alignment: .leading) {
                VStack(alignment: .center) {
                    NavigationLink(destination: LogView().navigationBarBackButtonHidden(true), label: {
                        // note for future: when tapped by default navigationlink "absorbs" the touch not letting addItem to fire but using .simultaneousGesture lets bith navigate and fire the function below
                        
                        Text("Saavuin")
                            .padding(50)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.black)
                            .background(Color.gray)
                            .cornerRadius(15)
                            .clipShape(.circle)
                            .scaleEffect(scale)
                            .animation(.linear(duration: 1), value: scale)
                            .padding(.top,10)
                    })
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            addItem()
                        }
                    )
                    
                }.frame(maxWidth: .infinity)
            
            }
            
        }
        
        
        
        // the view ends here
        }
    
    
    private func addItem() {
        withAnimation {
               let newItem = Item(timestamp: Date())
                modelContext.insert(newItem)
        }
    }
    
    
}

    
    struct LogView: View {
        @Environment(\.modelContext) private var modelContext
        @Query var items: [Item]
        var body: some View {
         //  Text("this is log view navigated to");
            
                       
            VStack(alignment: .leading) {
                VStack(alignment: .center) {
                    NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true), label: {
                        // note for future: when tapped by default navigationlink "absorbs" the touch not letting addItem to fire but using .simultaneousGesture lets bith navigate and fire the function below
                        
                        Text("Lähdin")
                            .padding(50)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.black)
                            .background(Color.gray)
                            .cornerRadius(15)
                            .clipShape(.circle)
                            .padding(.top,10)
                    })
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            AddLeaveTime()
                        }
                    )
                    
                }.frame(maxWidth: .infinity)
            }
            
                            List {
                                ForEach(items) { item in
                                    Text(item.timestamp.description)
                             .font(.caption)
                            .fontWeight(.heavy)
                         }
                    }
        }
        
        
         
        private func AddLeaveTime() {
            withAnimation {
                   let newItem = Item(timestamp: Date())
                    modelContext.insert(newItem)
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
        .modelContainer(for: Item.self, inMemory: true)
    }

