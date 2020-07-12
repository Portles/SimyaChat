//
//  NewConversationViewCell.swift
//  Simyachat
//
//  Created by Nizamet Özkan on 12.07.2020.
//  Copyright © 2020 Nizamet Özkan. All rights reserved.
//

import Foundation
import SDWebImage

class NewConversationCell: UITableViewCell {

    static let identifier = "NewConversationCell"
    
    private let UserImageView: UIImageView = {
        let imgv = UIImageView()
        imgv.contentMode = .scaleAspectFill
        imgv.layer.cornerRadius = 35
        imgv.layer.masksToBounds = true
        return imgv
    }()
    
    private let userNameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(UserImageView)
        contentView.addSubview(userNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        UserImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 70,
                                     height: 70)
        
        userNameLabel.frame = CGRect(x: UserImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - 20 - UserImageView.width,
                                     height: 50)

    }
    
    public func configure(with model: SearchResult) {
        self.userNameLabel.text = model.name
        
        let seyfmeyil = DatabaseManager.safeEmail(emailAdress: model.email)
        
        let path = "img/\(seyfmeyil)_PP.png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self]result in
            switch result {
            case .success(let url):
                
                DispatchQueue.main.async {
                    self?.UserImageView.sd_setImage(with: url, completed: nil)
                }
                
            case .failure(let error):
                print("PP indirme linki alınamadı. \(error)")
            }
        })
    }
    
}
