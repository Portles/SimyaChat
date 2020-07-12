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
    
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping uploadPictureCompletion) {
        storage.child("message_img/\(fileName)").putData(data, metadata: nil, completion: { [weak self]metadata, error in
            guard error == nil else {
                print("Fotoğraf Firebase'e upload edilemedi.")
                completion(.failure(StorageError.failedUplod))
                return
            }
            self?.storage.child("message_img/\(fileName)").downloadURL(completion: { url, error in
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
    
    public func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping uploadPictureCompletion) {
        storage.child("message_vid/\(fileName)").putFile(from: fileUrl, metadata: nil, completion: { [weak self]metadata, error in
            guard error == nil else {
                print("Video Firebase'e upload edilemedi.")
                completion(.failure(StorageError.failedUplod))
                return
            }
            self?.storage.child("message_vid/\(fileName)").downloadURL(completion: { url, error in
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
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let referance = storage.child(path)
        
        referance.downloadURL(completion: {url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageError.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        })
    }
}
