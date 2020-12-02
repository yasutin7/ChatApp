//
//  ChatRoom.swift
//  ChatApp
//
//  Created by 藤原康就 on 2020/12/02.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatRoom {
    
    let latestMessageId: String
    let members: [String]
    let createdAt: Timestamp
    var documentId: String?
    var partnerUser: User?
    
    init(dic:[String: Any]) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.members = dic["members"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}
