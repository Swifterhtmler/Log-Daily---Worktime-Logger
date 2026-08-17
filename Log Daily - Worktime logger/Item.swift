//
//  Item.swift
//  Log Daily - Worktime logger
//
//  Created by Riku Kuisma on 10.8.2026.
//

import Foundation
import SwiftData

@Model
final class Item: Identifiable {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}


