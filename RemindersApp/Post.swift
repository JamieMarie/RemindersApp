//
//  Post.swift
//  RemindersApp
//
//  Created by Kaylin Zaroukian on 12/8/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import Foundation
struct Post {
    var content : String
    var userEmail : String
    var datePosted : Date
    var postType : String
    var taskListName : String
    var taskName : String
    
    init(content: String, userEmail: String, datePosted: Date, postType: String, taskListName: String, taskName: String) {
        self.content = content
        self.userEmail = userEmail
        self.datePosted = datePosted
        self.postType = postType
        self.taskName = taskName
        self.taskListName = taskListName
    }
    
}
