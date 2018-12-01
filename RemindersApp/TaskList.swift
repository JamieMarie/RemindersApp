//
//  TaskList.swift
//  RemindersApp
//
//  Created by Kaylin Zaroukian on 11/14/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import Foundation

struct TaskList {
    var active: Bool
    var description: String
    var fullCompletion: Bool
    var name: String
    var userEmail: String
    var tasks: Array<Task>
    var numTasks: Int
    
    init(active: Bool, description: String, fullCompletion: Bool, name: String, userEmail: String, tasks: Array<Task>, numTasks: Int) {
        self.active = active
        self.description = description
        self.fullCompletion = fullCompletion
        self.name = name
        self.userEmail = userEmail
        self.tasks = tasks
        self.numTasks = numTasks
    }
}
