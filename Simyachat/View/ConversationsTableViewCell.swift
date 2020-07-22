//
//  ConversationViewController.swift
//  Simyachat
//
//  Created by Nizamet Özkan on 5.07.2020.
//  Copyright © 2020 Nizamet Özkan. All rights reserved.
//

import UIKit
import SDWebImage

class ConversationsTableViewCell: UITableViewCell {

    static let identifier = "ConversationsTableViewCell"
    
    private let UserImageView: UIImageView = {
        let imgv = UIImageView()
        imgv.contentMode = .scaleAspectFill
        imgv.layer.cornerRadius = 50
        imgv.layer.masksToBounds = true
        return imgv
    }()
    
    private let userNameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(UserImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        UserImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 100,
                                     height: 100)
        
        userNameLabel.frame = CGRect(x: UserImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - 20 - UserImageView.width,
                                     height: (contentView.height-20)/2)
        
        userMessageLabel.frame = CGRect(x: UserImageView.right + 10,
                                        y: userNameLabel.bottom + 10,
                                        width: contentView.width - 20 - UserImageView.width,
                                        height: (contentView.height-20)/2)

    }
    
    public func configure(with model: Conversation) {
        userMessageLabel.text = model.latestMessage.text
        userNameLabel.text = model.name
        
        let path = "img/\(model.otherUserEmail)_PP.png"
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
