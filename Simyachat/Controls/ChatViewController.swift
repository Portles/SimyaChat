//
//  ChatViewController.swift
//  Simyachat
//
//  Created by Nizamet Özkan on 27.06.2020.
//  Copyright © 2020 Nizamet Özkan. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVKit
import AVFoundation
import CoreLocation

final class ChatViewController: MessagesViewController {
    
    private var sendPhotoURL: URL?
    private var otherUserPhotoURL: URL?
    
    public static let dateFormatter: DateFormatter = {
        let frmttr = DateFormatter()
        frmttr.dateStyle = .medium
        frmttr.timeStyle = .long
        frmttr.locale = .current
        return frmttr
    }()
    
    public let otherUserMail: String
    private var conversationId: String?
    public var isNewConversation = false
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAdress: email)
        
        return Sender(photoURL: "", senderId: safeEmail, displayName: "Ben")
    }
    
    init(with email: String, id: String?) {
        self.conversationId = id
        self.otherUserMail = email
        super.init(nibName: nil ,bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setInputButton()
    }
    
    private func setInputButton() {
        let bttn = InputBarButtonItem()
        bttn.setSize(CGSize(width: 35, height: 35), animated: false)
        bttn.setImage(UIImage(systemName: "paperclip"), for: .normal)
        bttn.onTouchUpInside{ [weak self]_ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([bttn], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Medya Gönder", message: "Göndermek istediğiniz medya türünü seçiniz", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Fotoğraf", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Ses", style: .default, handler: {  _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Konum", style: .default, handler: { [weak self] _ in
            self?.presentLocationPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Vazgeç", style: .default, handler: nil ))
        
        present(actionSheet, animated: true)
    }
    
    private func presentLocationPicker() {
        let vc = LocationPickerViewController(cordinates: nil)
        vc.title = "Konum Seçiniz"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { [weak self] selectedCordinates in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let messageId = strongSelf.createMessageId(),
                let conversationId = strongSelf.conversationId,
                let name = strongSelf.title,
                let selfSender = strongSelf.selfSender else {
                    return
            }
            
            let longitude: Double = selectedCordinates.longitude
            let latitude: Double = selectedCordinates.latitude
            
            print("Enlem = \(longitude),Boylam = \(latitude)")
            
            let loc = Location(location: CLLocation(latitude: latitude, longitude: longitude), size: .zero)
            let meessage = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .location(loc))
            
            DatabaseManager.shared.sendMessage(to: conversationId, name: name, otherUserEmail: strongSelf.otherUserMail, newMessage: meessage, completion: { succes in
                if succes {
                    print("Konum mesaj gönderildi.")
                } else {
                    print("Konum mesaj gönderilemedi.")
                }
            })
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentPhotoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Fotoğraf Gönder", message: "Gönderme türünü seçiniz", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Kamera", style: .default, handler: { [weak self] _ in
            let img = UIImagePickerController()
            img.sourceType = .camera
            img.delegate = self
            img.allowsEditing = true
            self?.present(img, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Fotoğraflarım", style: .default, handler: { [weak self] _ in
            let img = UIImagePickerController()
            img.sourceType = .photoLibrary
            img.delegate = self
            img.allowsEditing = true
            self?.present(img, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Vazgeç", style: .default, handler: nil ))
        
        present(actionSheet, animated: true)
    }
    
    private func presentVideoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Video Gönder", message: "Gönderme türünü seçiniz", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Kamera", style: .default, handler: { [weak self] _ in
            let img = UIImagePickerController()
            img.sourceType = .camera
            img.delegate = self
            img.mediaTypes = ["public.movie"]
            img.videoQuality = .typeMedium
            img.allowsEditing = true
            self?.present(img, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Videolarım", style: .default, handler: { [weak self] _ in
            let img = UIImagePickerController()
            img.sourceType = .photoLibrary
            img.delegate = self
            img.mediaTypes = ["public.movie"]
            img.videoQuality = .typeMedium
            img.allowsEditing = true
            self?.present(img, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Vazgeç", style: .default, handler: nil ))
        
        present(actionSheet, animated: true)
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self]result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
            case .failure(let error):
                print("Mesajlar yüklenemedi. \(error)")
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let convesationId = conversationId {
            listenForMessages(id: convesationId, shouldScrollToBottom: true)
        }
    }
    
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let messageId = createMessageId(),
            let conversationId = conversationId,
            let name = self.title,
            let selfSender = selfSender else {
                return
        }
        
        if let image = info[.editedImage] as? UIImage, let imgData = image.pngData() {
            let fileName = "message_photo"+messageId.replacingOccurrences(of: " ", with: "-")+".png"
            
            StorageManager.shared.uploadMessagePhoto(with: imgData, fileName: fileName, completion: { [weak self]result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let urlString):
                    print("Mesaj fotoğrafı upload edildi: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                        let placeholder = UIImage(systemName: "plus") else {
                            return
                    }
                    
                    let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                    let meessage = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .photo(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, name: name, otherUserEmail: strongSelf.otherUserMail, newMessage: meessage, completion: { succes in
                        if succes {
                            print("Foto mesaj gönderildi.")
                        } else {
                            print("Foto mesaj gönderilemedi.")
                        }
                    })
                case .failure(let error):
                    print("Fotoğraf upload error: \(error)")
                }
            })
        } else if let videoUrl = info[.mediaURL] as? URL {
            let fileName = "message_video"+messageId.replacingOccurrences(of: " ", with: "-")+".mov"
            
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName, completion: { [weak self]result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let urlString):
                    print("Mesaj videosu upload edildi: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                        let placeholder = UIImage(systemName: "plus") else {
                            return
                    }
                    
                    let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                    let meessage = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .video(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, name: name, otherUserEmail: strongSelf.otherUserMail, newMessage: meessage, completion: { succes in
                        if succes {
                            print("Video mesaj gönderildi.")
                        } else {
                            print("Video mesaj gönderilemedi.")
                        }
                    })
                case .failure(let error):
                    print("Video upload error: \(error)")
                }
            })
        }
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = self.selfSender,
            let messageId = createMessageId() else {
                return
        }
        
        print("Gönderiliyor: \(text)")
        let meessage = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        let seyfmeil = DatabaseManager.safeEmail(emailAdress: otherUserMail)
        if isNewConversation {
            DatabaseManager.shared.createNewConversation(with: seyfmeil, name: self.title ?? "User", firstMessage: meessage, completion: {      [weak self] success in
                if success {
                    print("Mesaj gönderildi.")
                    self?.isNewConversation = false
                    let newConversationId = "conversation_\(meessage.messageId)"
                    self?.conversationId = newConversationId
                    self?.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
                    self?.messageInputBar.inputTextView.text = nil
                } else {
                    print("Mesaj gönderilemedi")
                }
            })
        } else {
            guard let conversationId = conversationId, let name = self.title else {
                return
            }
            DatabaseManager.shared.sendMessage(to: conversationId, name: name, otherUserEmail: otherUserMail, newMessage: meessage, completion: { [weak self]success in
                if success {
                    self?.messageInputBar.inputTextView.text = nil
                    print("Mesaj gönderildi.")
                } else {
                    print("Mesaj gönderilemedi.")
                }
            })
        }
    }
    private func createMessageId() -> String? {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAdress: currentUserEmail)
        let safeOtherUserEmail = DatabaseManager.safeEmail(emailAdress: otherUserMail)
        
        let dateString = ChatViewController.self.dateFormatter.string(from: Date())
        let newIdentifier = "\(safeOtherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        print("Mesaj oluşturuldu ID: \(newIdentifier)")
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Gönderici void dönüyor, emaili kontrol et.")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imgUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imgUrl, completed: nil)
        default:
            break
        }
    }
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            
            return.link
        }
        return.secondarySystemBackground
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        
        if sender.senderId == selfSender?.senderId {
            if let currentUserImage = self.sendPhotoURL {
                avatarView.sd_setImage(with: currentUserImage, completed: nil)
            }else{
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                    return
                }
                
                let safeEmail = DatabaseManager.safeEmail(emailAdress: email)
                let path = "img/\(safeEmail)_PP.png"
                
                StorageManager.shared.downloadURL(for: path, completion: { [weak self]result in
                    switch result {
                    case .success(let url):
                        self?.sendPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("\(error)")
                    }
                })
            }
        }else{
            if let otherUserImage = self.otherUserPhotoURL {
                avatarView.sd_setImage(with: otherUserImage, completed: nil)
            }else{
                let email = self.otherUserMail
                
                let safeEmail = DatabaseManager.safeEmail(emailAdress: email)
                let path = "img/\(safeEmail)_PP.png"
                
                StorageManager.shared.downloadURL(for: path, completion: { [weak self]result in
                    switch result {
                    case .success(let url):
                        self?.otherUserPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("\(error)")
                    }
                })
            }
        }
    }
}

extension ChatViewController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .location(let locaionData):
            let cordinates = locaionData.location.coordinate
            let vc = LocationPickerViewController(cordinates: cordinates)
            vc.title = "Konum"
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imgUrl = media.url else {
                return
            }
            let vc = PhotoViewViewController(with: imgUrl)
            navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else {
                return
            }
            
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true)
        default:
            break
        }
    }
}
