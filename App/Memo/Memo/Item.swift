//
//  Item.swift
//  Memo
//
//  Created by Philip Rehker on 11/18/26.
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
