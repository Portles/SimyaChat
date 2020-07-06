//
//  ProfileViewController.swift
//  Simyachat
//
//  Created by Nizamet Özkan on 23.06.2020.
//  Copyright © 2020 Nizamet Özkan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let data = ["Çıkış Yap"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAdress: email)
        let filename = safeEmail + "_PP.png"
        
        let path = "img/" + filename
        
        let hedirview = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        
        hedirview.backgroundColor = .link
        
        let imageView = UIImageView(frame: CGRect(x: (hedirview.width-150)/2, y: 75, width: 150, height: 150))
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = imageView.width/2
        imageView.layer.masksToBounds = true
        hedirview.addSubview(imageView)
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self]result in
            switch result {
            case .success(let url):
                self?.downloadimg(imageView: imageView, url: url)
            case .failure(let error):
                print("Indirme başarısız URL: \(error)")
            }
        })
        
        return hedirview
    }
    func downloadimg(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
            }).resume()
    }
}
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: "Çıkış Yap", message: "Çıkış yapmak istediğinize emin misiniz?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Onayla", style: .destructive, handler: { [weak self]_ in
            
            guard let strongSelf = self else {
                return
            }
            
            FBSDKLoginKit.LoginManager().logOut()
            
            GIDSignIn.sharedInstance()?.signOut()
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            }
            catch {
                print("Failed to log out")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
        
        
    }
}
