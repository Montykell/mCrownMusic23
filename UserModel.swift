//
//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var username: String
    var email: String
    var name: String
    var photoURL: String?
    var phoneNumber: String
    var userImageURL: String?
    
    init(id: String, username: String, email: String, name: String, photoURL: String?, phoneNumber: String, userImageURL: String?) {
        self.id = id
        self.username = username
        self.email = email
        self.name = name
        self.photoURL = photoURL
        self.phoneNumber = phoneNumber
        self.userImageURL = userImageURL
    }
    
    init?(dictionary: [String: Any], userId: String) {
        guard let username = dictionary["username"] as? String,
              let email = dictionary["email"] as? String,
              let name = dictionary["name"] as? String,
              let phoneNumber = dictionary["phoneNumber"] as? String else {
            return nil
        }
        self.id = userId
        self.username = username
        self.email = email
        self.name = name
        self.photoURL = dictionary["photoURL"] as? String
        self.phoneNumber = phoneNumber
        self.userImageURL = dictionary["userImageURL"] as? String
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "username": username,
            "email": email,
            "name": name,
            "photoURL": photoURL ?? "",
            "phoneNumber": phoneNumber,
            "userImageURL": userImageURL ?? ""
        ]
    }
}
