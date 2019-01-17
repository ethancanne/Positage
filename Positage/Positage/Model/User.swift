//
//  User.swift
//  Positage
//
//  Created by Ethan Cannelongo on 1/8/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import Foundation
import Firebase

class User {
    private(set) public var username: String
    private(set) public var userId: String
    private(set) public var numStamps: Int
    private(set) public var timestamp: Timestamp
    
    init(username: String, userId: String, numStamps: Int, timestamp: Timestamp) {
        self.username = username
        self.userId = userId
        self.numStamps = numStamps
        self.timestamp = timestamp
    }
    
    class func setUser(from snapshot: QuerySnapshot?) -> [User] {
        var users = [User]()
        guard let snap = snapshot else { return users }
        for document in snap.documents{
            let username = document.data()[USER_USERNAME] as? String ?? "Unknown"
            let userId = document.documentID
            let numStamps = document.data()[NUM_STAMPS] as? Int ?? 0
            let timestamp = document.data()[TIMESTAMP] as? Timestamp ?? Timestamp()
            
            let newUser = User(username: username, userId: userId, numStamps: numStamps, timestamp: timestamp)
            users.append(newUser)
        }
        return users
    }
    
}
