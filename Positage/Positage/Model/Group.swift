//
//  Group.swift
//  Positage
//
//  Created by Ethan Cannelongo on 4/26/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import Foundation
import Firebase

class Group : Creatable{
    private(set) public var adminUsername: String
    private(set) public var adminUserId: String
    
    private(set) public var joinedUsers: [String]
    private(set) public var invitedUsers: [String]
    
    private(set) public var isPrivate: Bool

    private(set) public var numEntries: Int

    private(set) public var description: String
    private(set) public var stampsToJoin: Int
    
    
    init(adminUsername: String, adminUserId: String, joinedUsers: [String], invitedUsers: [String], isPrivate: Bool, numEntries: Int, title: String,  description: String, stampsToPost: Int, timestamp: Date, documentId: String) {
        self.adminUsername = adminUsername
        self.adminUserId = adminUserId
        
        self.joinedUsers = joinedUsers
        self.invitedUsers = invitedUsers
        
        self.isPrivate = isPrivate
        
        self.numEntries = numEntries

        self.description = description
        self.stampsToJoin = stampsToPost
                
        super.init(title: title, timestamp: timestamp, documentId: documentId)
    }
    
    func toDictionary() -> [String: Any]{
        let groupDictionaryData: [String: Any] = [
            ADMIN_USERID: adminUserId,
            ADMIN_USERNAME: adminUsername,
            
            JOINED_USERS: joinedUsers,
            INVITED_USERS: invitedUsers,
            
            IS_PRIVATE: isPrivate,

            NUM_ENTRIES: numEntries,
            
            TITLE: title,
            GROUP_DESC: description,
            
            STAMPS_TO_JOIN: stampsToJoin,
                
            TIMESTAMP: timestamp
        ]
        return groupDictionaryData
    }
    
    
    class func set(from snapshot: QuerySnapshot?) -> [Group] {
        var groups = [Group]()
        guard let snap = snapshot else { return groups }
        for document in snap.documents{
            let adminUsername = document.data()[ADMIN_USERNAME] as? String ?? "Unknown"
            let adminUserId = document.data()[ADMIN_USERID] as? String ?? "null"
            
            let joinedUsers = document.data()[JOINED_USERS] as? [String] ?? []
            let invitedUsers = document.data()[INVITED_USERS] as? [String] ?? []
            
            let isPrivate = document.data()[IS_PRIVATE] as? Bool ?? false
            
            let numEntries = document.data()[NUM_ENTRIES] as? Int ?? 0
            
            let description = document.data()[GROUP_DESC] as? String ?? "null"
            let title = document.data()[TITLE] as? String ?? "Unnamed Group"
            
            let stampsToPost = document.data()[STAMPS_TO_JOIN] as? Int ?? 0
            
            let documentId = document.documentID
            
            let timestamp = document.data()[TIMESTAMP] as? Date ?? Date()

            
            let newGroup = Group(adminUsername: adminUsername, adminUserId: adminUserId, joinedUsers: joinedUsers, invitedUsers: invitedUsers, isPrivate: isPrivate, numEntries: numEntries, title: title, description: description, stampsToPost: stampsToPost, timestamp: timestamp, documentId: documentId)
            groups.append(newGroup)
        }
        return groups
    }
}
