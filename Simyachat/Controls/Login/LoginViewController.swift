//
//  LoginViewController.swift
//  Simyachat
//
//  Created by Nizamet Özkan on 23.06.2020.
//  Copyright © 2020 Nizamet Özkan. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController{
    
    private let scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "messageBox")
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
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email adress"
        field.leftView = UIView(frame: CGRect(x: 0,y: 0, width: 5,height:0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        field.leftView = UIView(frame: CGRect(x: 0,y: 0, width: 5,height:0))
        field.leftViewMode = .always
        field.backgroundColor = .white
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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Giriş yap"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title : "Kayıt ol", style:  .done, target: self, action: #selector(didTapReg))
        // Do any additional setup after loading the view.
        
        logButton.addTarget(self, action: #selector(logButtontap), for: .touchDragInside)
        
        emailField.delegate = self
        passField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passField)
        scrollView.addSubview(logButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = view.width/3
        imageView.frame = CGRect(x: (scrollView.width/3),y: 20,width: size,height: size)
        emailField.frame = CGRect(x: 30,y: imageView.bottom+10,width: scrollView.width-60,height: 52)
        passField.frame = CGRect(x: 30,y: emailField.bottom+10,width: scrollView.width-60,height: 52)
        logButton.frame = CGRect(x: 30,y: passField.bottom+10,width: scrollView.width-60,height: 52)

    }
    
    @objc private func logButtontap() {
        
        emailField.resignFirstResponder()
        passField.resignFirstResponder()
        
        guard let email = emailField.text, let pass = passField.text,
        !email.isEmpty, !pass.isEmpty, pass.count >= 6 else {
            alertLogError()
            return
        }
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: pass, completion: {[weak self]authResult, error in
            guard let strongSelf = self else{
                return
            }
            guard let result = authResult, error == nil else {
                print("Hatalı giriş: \(email)")
                return
            }
            let user = result.user
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
