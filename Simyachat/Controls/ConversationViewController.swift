//
//  ViewController.swift
//  Simyachat
//
//  Created by Nizamet Özkan on 23.06.2020.
//  Copyright © 2020 Nizamet Özkan. All rights reserved.
//

import UIKit
import FirebaseAuth

class ConversationViewController: UIViewController {
    
    private let tableView: UITableView {
        let table = UITableView()
        table.register(UITableView, forCellReuseIdentifier: <#T##String#>)
        return table
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
}

