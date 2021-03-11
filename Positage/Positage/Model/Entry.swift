//
//  CommunityPost.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/4/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import Foundation
import Firebase

class Entry : Creatable{
    
    
    
    private(set) public var message: String
    private(set) public var sorting: String
    
    private(set) public var numSupports: Int

    private(set) public var usersSupported: [String]
    private(set) public var usersInvested: [String : [Int]]
    
    private(set) public var investmentThankYouMsg: String
    
    private(set) public var investmentCharge: Int
    
    private(set) public var username: String
    private(set) public var userId: String
        
    
    init(title: String, message: String, sorting: String, numSupports: Int, usersSupported: [String], usersInvested: [String : [Int]], investmentThankYouMsg: String, investmentCharge: Int, username: String, userId: String, timestamp: Date, documentId: String) {
        self.message = message
        self.sorting = sorting
        self.numSupports = numSupports
        self.usersSupported = usersSupported
        self.usersInvested = usersInvested
        self.investmentThankYouMsg = investmentThankYouMsg
        self.investmentCharge = investmentCharge
        self.username = username
        self.userId = userId
        
        super.init(title: title, timestamp: timestamp, documentId: documentId)
    }
    
    func toDictionary() -> [String: Any]{
        let postDictionaryData: [String: Any] = [
            TITLE: title,
            MESSAGE: message,
            SORTING: sorting,

            NUM_SUPPORTS: numSupports,
            USERS_SUPPORTED: usersSupported,
            USERS_INVESTED: usersInvested,

            
            INVESTMENT_CHARGE: investmentCharge,
            INVESTMENT_THANK_YOU_MSG: investmentThankYouMsg,

            USERNAME: username,
            USERID: userId,
            TIMESTAMP: timestamp,
        ]
        return postDictionaryData
    }
    
    
    class func set(from snapshot: QuerySnapshot?) -> [Entry] {
        var entries = [Entry]()
        guard let snap = snapshot else { return entries }
        for document in snap.documents{
            let data = document.data()
            
            let title = data[TITLE] as? String ?? "Unnamed"
            let message = data[MESSAGE] as? String ?? "Unknown"
            let sorting = data[SORTING] as? String ?? ""
            
            let usersInvested = data[USERS_INVESTED] as? [String : [Int]] ?? [String : [Int]]()
            
            let numSupports = data[NUM_SUPPORTS] as? Int ?? 0
            
            let usersSuppored = data[USERS_SUPPORTED] as? [String] ?? [String]()
            
            let investmentThankYouMsg = data[INVESTMENT_THANK_YOU_MSG] as? String ?? "Thank you"
            
            let investmentCharge = data[INVESTMENT_CHARGE] as? Int ?? 0
            
            let username = data[USERNAME] as? String ?? "Anonymous"
            let userId = data[USERID] as? String ?? ""
            
            let timestamp = data[TIMESTAMP] as? Timestamp ?? Timestamp()
            let documentId = document.documentID
            
            let dateTimestamp = timestamp.dateValue()
            let newEntry = Entry(title: title, message: message, sorting: sorting, numSupports: numSupports, usersSupported: usersSuppored, usersInvested: usersInvested, investmentThankYouMsg: investmentThankYouMsg, investmentCharge: investmentCharge, username: username, userId: userId, timestamp: dateTimestamp, documentId: documentId)
            
            entries.append(newEntry)
            
        }
        return entries
    }
}
