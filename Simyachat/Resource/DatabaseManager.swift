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
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    public func InsertUser(with user: SimyachatUser, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue([
            "nick_name": user.userName
            ], withCompletionBlock: { error, _ in
                guard error == nil else {
                    print("Database yazım hatası.")
                    completion(false)
                    return
                }
            completion(true)
        })
    }
}

struct SimyachatUser {
    let userName: String
    let email: String
    
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName: String {
        return "\(safeEmail)_PP.png"
    }
}
