//
//  AppDelegate.swift
//  Simyachat
//
//  Created by Nizamet Özkan on 23.06.2020.
//  Copyright © 2020 Nizamet Özkan. All rights reserved.
//


//  AppDelegate.swift


//  AppDelegate.swift

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
        
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FirebaseApp.configure()
          
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self

        return true
    }
          
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return GIDSignIn.sharedInstance().handle(url)
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error{
            print("Google servisleri ile giriş başarısız! \(error)")
            }
            
            return
        }
        
        guard let user = user else {
            return
        }
        
        print("Google ile giriş yapıldı mı?: \(user)")
        
        guard let email = user.profile.email,
        let fullName = user.profile.name else {
            return
        }
        
        DatabaseManager.shared.UserExist(with: email, completion: { exist in
            if !exist {
                let charUser = SimyachatUser(userName: fullName, email: email)
                DatabaseManager.shared.InsertUser(with: charUser, completion: { succes in
                    if succes {
                        
                        if user.profile.hasImage {
                            guard let url = user.profile.imageURL(withDimension: 200) else {
                                return
                            }
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                guard let data = data else {
                                    return
                                }
                                let fileName = charUser.profilePictureFileName
                                StorageManager.shared.uploadPP(with: data, fileName: fileName, completion: { result in
                                    switch result {
                                    case .success(let downloadURL):
                                        UserDefaults.standard.set(downloadURL, forKey: "pp_url")
                                        print(downloadURL)
                                    case .failure(let error):
                                        print("Data yönetimi hatası. \(error)")
                                    }
                                })
                            }).resume()
                        }
                    }
                })
            }
        })
        
          guard let authentication = user.authentication else {
            print("Google kullanıcı objesine erişilemedi.")
            return
        }
          let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                            accessToken: authentication.accessToken)
        FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
            guard authResult != nil, error == nil else {
                print("Google hesabı ile giriş başarısız.")
                return
            }
            print("Google hesabı ile giriş başarılı. \(user)")
            NotificationCenter.default.post(name: .didLogInNotification, object: nil)
        })
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google kullanıcısı çıkış yaptı.")
    }
}

    
