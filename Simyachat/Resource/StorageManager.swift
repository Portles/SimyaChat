//
//  StorageManager.swift
//  Simyachat
//
//  Created by Nizamet Özkan on 28.06.2020.
//  Copyright © 2020 Nizamet Özkan. All rights reserved.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    
    public typealias uploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadPP(with data: Data, fileName: String, completion: @escaping uploadPictureCompletion) {
        storage.child("img/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                print("Fotoğraf Firebase'e upload edilemedi.")
                completion(.failure(StorageError.failedUplod))
                return
            }
            self.storage.child("img/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("İndirme url'si bulunamadı.")
                    completion(.failure(StorageError.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("İndirme URL'si: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    public enum StorageError: Error {
        case failedUplod
        case failedToGetDownloadUrl
    }
}
