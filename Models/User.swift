//
//  User.swift
//  ChatApp
//
//  Created by 藤原康就 on 2020/12/01.
//

import Foundation
import Firebase
import FirebaseFirestore

class User {
    
    let email: String
    let username: String
    let createdAt: Timestamp
    let profile_image: String
    var uid: String?
    
    init(dic: [String: Any]) {
        
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.createdAt = dic["createAt"] as? Timestamp ?? Timestamp()
        self.profile_image = dic["profile_image"] as? String ?? ""
    }
}
