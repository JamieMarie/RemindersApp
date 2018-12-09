//
//  Quote.swift
//  RemindersApp
//
//  Created by Kaylin Zaroukian on 12/9/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import Foundation
struct Quote {
    var author : String
    var quote : String
    
    init(author: String, quote: String) {
        self.author = author
        self.quote = quote
    }
}

protocol quoteService {
    func getQuoteOfTheDay( completion: @escaping (Quote?) -> Void)
}
