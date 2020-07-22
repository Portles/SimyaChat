//
//  ConversationModels.swift
//  Simyachat
//
//  Created by Nizamet Özkan on 22.07.2020.
//  Copyright © 2020 Nizamet Özkan. All rights reserved.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

struct SearchResult {
    let email: String
    let name: String
}
