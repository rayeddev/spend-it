//
//  Item.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
