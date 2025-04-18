//
//  ChatModels.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 18.04.2025.
//

import Foundation
struct Chat: Codable {
    let id: Int
    let pet_id: Int
    let user1_id: Int
    let user2_id: Int
    let created_at: String
    let updated_at: String
    var last_message: ChatMessage?
    var unread_count: Int
    
    // Для отображения в списке чатов - не декодируются из JSON
    var otherUserName: String = "User"
    var petName: String = "Pet"
    
    // Определение кодируемых ключей для исключения UI-свойств
    enum CodingKeys: String, CodingKey {
        case id
        case pet_id
        case user1_id
        case user2_id
        case created_at
        case updated_at
        case last_message
        case unread_count
    }
}

struct ChatMessage: Codable {
    let id: Int
    let content: String
    let chat_id: Int
    let sender_id: Int
    let is_read: Bool
    let created_at: String
    
    // Вычисляемое свойство для форматирования времени
    var formattedTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        if let date = dateFormatter.date(from: created_at) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        }
        return ""
    }
}

struct ChatResponse: Codable {
    let chats: [Chat]
    let total: Int
}

struct CreateChatRequest: Codable {
    let pet_id: Int
    let user2_id: Int
}

struct SendMessageRequest: Codable {
    let content: String
}
