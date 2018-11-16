//
//  User.swift
//  RemindersApp
//
//  Created by Jamie Penzien on 11/5/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import Foundation

public var userData : [String: Any] = [
    "email" : "",
    "firstName" : "",
    "id" : "",
    "lastName" : "",
    "taskList" : []
]

struct User {
    var email: String
    var firstName: String
    var lastName: String
    var id: String
    var taskLists: Array<TaskList>
    init(email:String, firstName:String, lastName:String, id:String, taskLists: Array<TaskList>) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        self.taskLists = taskLists
    }
}




