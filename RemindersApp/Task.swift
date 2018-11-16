//
//  Task.swift
//  RemindersApp
//
//  Created by Kaylin Zaroukian on 11/14/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import Foundation

struct Task {
    var completed: Bool
    var description: String
    var priority: String
    var title: String
    var timestamp: Date
    var ownedBy: User
    
    init(completed: Bool, description: String, priority: String, title:String, timestamp:Date, ownedBy:User) {
        self.completed = completed
        self.description = description
        self.priority = priority
        self.title = title
        self.timestamp  = timestamp
        self.ownedBy = ownedBy
    }
}
