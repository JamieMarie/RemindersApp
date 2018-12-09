//
//  FavQService.swift
//  RemindersApp
//
//  Created by Kaylin Zaroukian on 12/9/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import Foundation

let sharedFavQInstance = FavQService()
class FavQService : quoteService {
    var urlSession = URLSession.shared
    
    class func getInstance() -> FavQService {
        return sharedFavQInstance
    }
    
    func getQuoteOfTheDay( completion: @escaping (Quote?) -> Void) {
        let urlStr = "https://favqs.com/api/qotd"
        let url = URL(string: urlStr)
        let task = self.urlSession.dataTask(with: url!) {
            (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let _ = response {
                let parsedObj : Dictionary<String,AnyObject>!
                do {
                    parsedObj = try JSONSerialization.jsonObject(with: data!, options:
                        .allowFragments) as? Dictionary<String,AnyObject>
                    
                    guard let currently = parsedObj["quote"],
                        let text = currently["body"] as? String,
                        let author = currently["author"]  as? String
                    
                    
                        else {
                            completion(nil)
                            return
                    }
                    
                    let quote = Quote(author: author, quote: text)
                    completion(quote)
                    
                }  catch {
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
    }

