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
    private(set) public var numSupportsRemaining: Int
    private(set) public var numStampsToSend: Int
    private(set) public var timestamp: Date
    
    
    init(username: String, userId: String, numStamps: Int, numSupportsRemaining: Int, numStampsToSend: Int, timestamp: Date) {
        self.username = username
        self.userId = userId
        self.numStamps = numStamps
        self.numSupportsRemaining = numSupportsRemaining
        self.numStampsToSend = numStampsToSend
        self.timestamp = timestamp
    }
    
    
    func toDictionary() -> [String: Any]{
        let postDictionaryData: [String: Any] = [
            USERNAME: username,
            
            NUM_STAMPS: numStamps,
            NUM_SUPPORTS_REMAINING: numSupportsRemaining,
            NUM_STAMPS_TO_SEND: numStampsToSend,
            
            TIMESTAMP: timestamp
        ]
        return postDictionaryData
    }
    
    class func set(from snapshot: QuerySnapshot?) -> [User] {
        var users = [User]()
        guard let snap = snapshot else { return users }
        for document in snap.documents{
            let username = document.data()[USER_USERNAME] as? String ?? "Unknown"
            let userId = document.documentID
            let numStamps = document.data()[NUM_STAMPS] as? Int ?? 0
            let numSupportsRemaining = document.data()[NUM_SUPPORTS_REMAINING] as? Int ?? 10
            let numStampsToSend = document.data()[NUM_STAMPS_TO_SEND] as? Int ?? 10
            let timestamp = document.data()[TIMESTAMP] as? Timestamp ?? Timestamp()
            
            let dateTimestamp = timestamp.dateValue()

            let newUser = User(username: username, userId: userId, numStamps: numStamps, numSupportsRemaining: numSupportsRemaining, numStampsToSend: numStampsToSend, timestamp: dateTimestamp)
            users.append(newUser)
        }
        return users
    }
    
    class func set(from snapshot: DocumentSnapshot?) -> User? {
        if let data = snapshot?.data() {
            let username = data[USER_USERNAME] as? String ?? "Unknown"
            let userId = snapshot?.documentID ?? "Unknown"
            let numStamps = data[NUM_STAMPS] as? Int ?? 0
            let numSupportsRemaining = data[NUM_SUPPORTS_REMAINING] as? Int ?? 10
            let numStampsToSend = data[NUM_STAMPS_TO_SEND] as? Int ?? 10
            let timestamp = data[TIMESTAMP] as? Timestamp ?? Timestamp()
            
            let dateTimestamp = timestamp.dateValue()

            let newUser = User(username: username, userId: userId, numStamps: numStamps, numSupportsRemaining: numSupportsRemaining, numStampsToSend: numStampsToSend, timestamp: dateTimestamp)
            
            return newUser
        }
        return nil
    }

    
}
