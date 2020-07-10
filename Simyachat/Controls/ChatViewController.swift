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

struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let frmttr = DateFormatter()
        frmttr.dateStyle = .medium
        frmttr.timeStyle = .long
        frmttr.locale = .current
        return frmttr
    }()
    
    public let otherUserMail: String
    private let conversationId: String?
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
        messageInputBar.delegate = self
        
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self]result in
            switch result {
            case .success(let message):
                guard !message.isEmpty else {
                    return
                }
                
                self?.messages = message
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
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
                } else {
                    print("Mesaj gönderilemedi")
                }
            })
        } else {
            guard let conversationId = conversationId, let name = self.title else {
                return
            }
            DatabaseManager.shared.sendMessage(to: conversationId, name: name, otherUserEmail: otherUserMail, newMessage: meessage, completion: { success in
                if success {
                    
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
    
    
}
