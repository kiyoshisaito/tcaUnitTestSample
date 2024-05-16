//
//  Item.swift
//  TcaSample
//
//  Created by 斎藤基世志 on 2024/05/13.
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
