//
//  DatabaseManager.swift
//  Simyachat
//
//  Created by Nizamet Özkan on 25.06.2020.
//  Copyright © 2020 Nizamet Özkan. All rights reserved.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
}

extension DatabaseManager {
    
    public func UserExist(with email: String,
                          completion: @escaping ((Bool)->Void)){
        database.child(email).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    public func InsertUser(with user: SimyachatUser){
        database.child(user.email).setValue([
            "nick_name": user.userName
        ])
    }
}

struct SimyachatUser {
    let userName: String
    let email: String
    let pass: String
}
