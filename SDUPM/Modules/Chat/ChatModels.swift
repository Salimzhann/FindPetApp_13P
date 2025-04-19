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
    
    // Свойства для отображения в UI - не декодируются из JSON
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
    var is_read: Bool
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
    
    // Вычисляемое свойство для определения даты
    var createdAtDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        return dateFormatter.date(from: created_at)
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

// Типы сообщений для WebSocket
enum MessageType: String, Codable {
    case TEXT = "text"
    case TYPING_STARTED = "typing_started"
    case TYPING_ENDED = "typing_ended"
    case MESSAGE_READ = "message_read"
    case USER_ONLINE = "user_online"
    case USER_OFFLINE = "user_offline"
    case SYSTEM = "system"
}

// Структура для WebSocket сообщений
struct WebSocketMessage: Codable {
    let message_type: MessageType
    let content: String?
    let message_id: Int?
    let user_id: Int?
}

// Структура для ответа о статусе WebSocket
struct WebSocketStatusResponse: Codable {
    let user_id: Int
    let status_type: MessageType
    let last_active_at: String?
    let message_id: Int?
}
