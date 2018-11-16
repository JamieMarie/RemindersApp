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
    var tasks: Array<Task>
    
    init(active: Bool, description: String, fullCompletion: Bool, name: String, tasks: Array<Task>) {
        self.active = active
        self.description = description
        self.fullCompletion = fullCompletion
        self.name = name
        self.tasks = tasks
    }
}
