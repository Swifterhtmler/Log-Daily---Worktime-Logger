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
    var leavetime: Date?

    var totalWorkTime: String? {
        guard let leavetime = leavetime else { return nil }
        let interval = leavetime.timeIntervalSince(timestamp)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return "\(hours) hours: \(minutes) minutes"
    }

    init(timestamp: Date, leavetime: Date? = nil) {
        self.timestamp = timestamp
        self.leavetime = leavetime
    }
}
