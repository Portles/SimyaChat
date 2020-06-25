//
//  RegisterViewController.swift
//  Simyachat
//
//  Created by Nizamet Özkan on 23.06.2020.
//  Copyright © 2020 Nizamet Özkan. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    private let scrollView: UIScrollView = {
           let scrollView = UIScrollView()
            scrollView.clipsToBounds = true
            return scrollView
        }()
        
        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "person.circle")
            imageView.tintColor = .gray
            imageView.contentMode = .scaleAspectFit
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 3
            imageView.layer.borderColor = UIColor.lightGray.cgColor
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
    
        private let userNameField: UITextField = {
            let field = UITextField()
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.returnKeyType = .continue
            field.layer.cornerRadius = 12
            field.layer.borderWidth = 1
            field.layer.borderColor = UIColor.lightGray.cgColor
            field.placeholder = "Kullanıcı adı"
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
            field.placeholder = "Şifre"
            field.leftView = UIView(frame: CGRect(x: 0,y: 0, width: 5,height:0))
            field.leftViewMode = .always
            field.backgroundColor = .white
            field.isSecureTextEntry = true
            return field
        }()
        
        private let regButton: UIButton = {
            let button = UIButton()
            button.setTitle("Kayıt ol", for: .normal)
            button.backgroundColor = .systemGreen
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            button.layer.masksToBounds = true
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
            return button
        }()

        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Kayıt ol"
            view.backgroundColor = .white
            
            // Do any additional setup after loading the view.
            regButton.addTarget(self, action: #selector(regButtontap), for: .touchUpInside)
            
            emailField.delegate = self
            passField.delegate = self
            
            view.addSubview(scrollView)
            scrollView.addSubview(imageView)
            scrollView.addSubview(emailField)
            scrollView.addSubview(userNameField)
            scrollView.addSubview(passField)
            scrollView.addSubview(regButton)
            
            imageView.isUserInteractionEnabled = true
            scrollView.isUserInteractionEnabled = true
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
            imageView.addGestureRecognizer(gesture)
        }
    
    @objc func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            scrollView.frame = view.bounds
            let size = view.width/3
            imageView.frame = CGRect(x: (scrollView.width/3),y: 20,width: size,height: size)
            imageView.layer.cornerRadius = imageView.width/2.0
            userNameField.frame = CGRect(x: 30,y: imageView.bottom+10,width: scrollView.width-60,height: 52)
            emailField.frame = CGRect(x: 30,y: userNameField.bottom+10,width: scrollView.width-60,height: 52)
            passField.frame = CGRect(x: 30,y: emailField.bottom+10,width: scrollView.width-60,height: 52)
            regButton.frame = CGRect(x: 30,y: passField.bottom+10,width: scrollView.width-60,height: 52)

        }
        
        @objc private func regButtontap() {
            
            emailField.resignFirstResponder()
            userNameField.resignFirstResponder()
            passField.resignFirstResponder()
            
            guard let userName = userNameField.text, let email = emailField.text, let pass = passField.text,
                !email.isEmpty, !userName.isEmpty, !pass.isEmpty, pass.count >= 6 else {
                alertLogError()
                return
            }
            
            DatabaseManager.shared.UserExist(with: email, completion: { [weak self]exist in
                guard let strongSelf = self else {
                    return
                }
                guard !exist else{
                    strongSelf.alertLogError(message: "Bu email zaten kullanılmaktadır.")
                    return
                }
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: pass, completion: { authResult, error in
                    
                    guard authResult != nil, error == nil else{
                    print("Hesap oluşturulamadı.")
                    return
                    }
                    DatabaseManager.shared.InsertUser(with: SimyachatUser(userName: userName, email: email, pass: pass))
                    strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                })
            })
        }
        
    func alertLogError(message: String = "Kutucukları doğru doldurudğunuzdan emin olun.") {
            let alert = UIAlertController(title: "OH", message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Boşver", style: .cancel, handler: nil))
            
            present(alert, animated: true)
        }
        
        @objc private func didTapReg() {
            let vc = RegisterViewController()
            vc.title = "Hesap oluştur"
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    extension RegisterViewController: UITextFieldDelegate {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            
            if textField == emailField {
                passField.becomeFirstResponder()
            } else if textField == passField{
                regButtontap()
            }
            return true
        }
    }

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profil fotoğrafı seç", message: "Fotoğraf nerden alınsın?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Fotoğraf Çek", style: .default, handler: {[weak self]_ in
            self?.presentCamera()
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Fotoğraf Seç", style: .default, handler: {[weak self]_ in
            self?.presentPhotoLib()
        }))
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoLib() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
