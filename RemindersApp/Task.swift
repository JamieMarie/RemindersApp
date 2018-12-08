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
    var deleted: Bool
    var description: String
    var priority: String
    var title: String
    var dateCreated: Date
    var expectedCompletion: Date
    var actualCompletion: Date
    var ownedBy: String
    var taskList: String
    
    init(completed: Bool, deleted: Bool, description: String, priority: String, title:String, dateCreated:Date, expectedCompletion: Date, actualCompletion: Date, ownedBy:String,taskList:String) {
        self.completed = completed
        self.deleted = deleted
        self.description = description
        self.priority = priority
        self.title = title
        self.dateCreated  = dateCreated
        self.expectedCompletion = expectedCompletion
        self.actualCompletion = actualCompletion
        self.ownedBy = ownedBy
        self.taskList = taskList
    }
}
