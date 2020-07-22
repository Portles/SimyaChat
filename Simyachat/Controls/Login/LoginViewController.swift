//
//  LoginViewController.swift
//  Simyachat
//
//  Created by Nizamet Özkan on 23.06.2020.
//  Copyright © 2020 Nizamet Özkan. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn
import JGProgressHUD

final class LoginViewController: UIViewController{
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logoo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.black.cgColor
        field.placeholder = "Email adress"
        field.leftView = UIView(frame: CGRect(x: 0,y: 0, width: 5,height:0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        return field
    }()
    
    private let passField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.black.cgColor
        field.placeholder = "Password"
        field.leftView = UIView(frame: CGRect(x: 0,y: 0, width: 5,height:0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        field.isSecureTextEntry = true
        return field
    }()
    
    private let logButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    private let loginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email,public_profile"]
        return button
    }()
    
    private let GGloginButton = GIDSignInButton()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        title = "Giriş yap"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title : "Kayıt ol", style:  .done, target: self, action: #selector(didTapReg))
        
        logButton.addTarget(self, action: #selector(logButtontap), for: .touchUpInside)
        
        emailField.delegate = self
        passField.delegate = self
        
        loginButton.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passField)
        scrollView.addSubview(logButton)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(GGloginButton)
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = view.width/3
        imageView.frame = CGRect(x: (scrollView.width/3),y: 20,width: size,height: size)
        emailField.frame = CGRect(x: 30,y: imageView.bottom+10,width: scrollView.width-60,height: 52)
        passField.frame = CGRect(x: 30,y: emailField.bottom+10,width: scrollView.width-60,height: 52)
        logButton.frame = CGRect(x: 30,y: passField.bottom+10,width: scrollView.width-60,height: 52)
        loginButton.frame = CGRect(x: 30,y: logButton.bottom+10,width: scrollView.width-60,height: 52)
        loginButton.frame.origin.y = logButton.bottom+60
        GGloginButton.frame = CGRect(x: 30,y: loginButton.bottom+10,width: scrollView.width-60,height: 52)

    }
    
    @objc private func logButtontap() {
        
        emailField.resignFirstResponder()
        passField.resignFirstResponder()
        
        guard let email = emailField.text, let pass = passField.text,
        !email.isEmpty, !pass.isEmpty, pass.count >= 6 else {
            alertLogError()
            return
        }
        
        spinner.show(in: view)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: pass, completion: {[weak self]authResult, error in
            guard let strongSelf = self else{
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                print("Hatalı giriş: \(email)")
                return
            }
            let user = result.user
            
            let safmeail = DatabaseManager.safeEmail(emailAdress: email)
            DatabaseManager.shared.getDataFor(path: safmeail, comletion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                        let name = userData["name"] as? String else {
                        return
                    }
                    UserDefaults.standard.set("\(name)", forKey: "name")
                case .failure(let error):
                    print("Data okunamadı: \(error)")
                }
            })
            
            UserDefaults.standard.set(email, forKey: "email")
            
            print("Giriş başarılı. \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func alertLogError() {
        let alert = UIAlertController(title: "OH", message: "Lütfen email ile şifrenizin doğruluğunu kontrol edin.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Boşver", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    @objc private func didTapReg() {
        let vc = RegisterViewController()
        vc.title = "Hesap oluştur"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passField.becomeFirstResponder()
        } else if textField == passField{
            logButtontap()
        }
        
        
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("Facebook ile giriş başarısız.")
            return
        }
        
        let faceRQ = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields" : "email, name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        
        faceRQ.start(completionHandler: { _, result, error in
            guard let result = result as? [String: Any],
                error == nil else {
                print("Facebook graph hatası.")
                return
            }
            print("\(result)")
            guard let userName = result["name"] as? String,
                let email = result["email"] as? String,
                let picture = result["picture"] as? [String: Any],
                let data = picture["data"] as? [String: Any],
                let pictureURL = data["url"] as? String else {
                    print("Id şifre alınamadı.")
                    return
            }
            
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(userName, forKey: "name")

            DatabaseManager.shared.UserExist(with: email, completion: { exists in
                if !exists {
                    let chatUser = SimyachatUser(userName: userName, email: email)
                    DatabaseManager.shared.InsertUser(with: chatUser, completion: { succes in
                        if succes {
                            
                            guard let url = URL(string: pictureURL) else {
                                return
                            }
                            
                            print("Facebooktan fotoğraf indiriliyor")
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                guard let data = data else {
                                    print("Facebooktan data alınamadı.")
                                    return
                                }
                                print("İndirilen fotoğraf upload ediliyor.")
                                let fileName = chatUser.profilePictureFileName
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
                    })
                }
            })
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                
                guard let strongSelf = self else {
                    return
                }
                
                guard authResult != nil, error == nil else {
                    print("Facebook girişi başarısız. Hesapta çift doğrulama aktif olmayabilir.")
                    return
                }
                print("Giriş başarılı.")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
}
