// Path: SDUPM/Modules/Chat/ChatModels.swift

import Foundation

struct Chat: Codable {
    let id: Int
    let pet_id: Int
    let user1_id: Int
    let user2_id: Int
    let created_at: String
    let updated_at: String
    var last_message: ChatMessage?
    var unread_count: Int = 0 // Теперь имеет значение по умолчанию
    var pet_photo_url: String?
    var pet_name: String?
    var pet_status: String?
    var other_user_name: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case pet_id
        case user1_id
        case user2_id
        case created_at
        case updated_at
        case last_message
        case unread_count
        case pet_photo_url
        case pet_name
        case pet_status
        case other_user_name
    }
    
    // Добавим свой инициализатор для декодера
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        pet_id = try container.decode(Int.self, forKey: .pet_id)
        user1_id = try container.decode(Int.self, forKey: .user1_id)
        user2_id = try container.decode(Int.self, forKey: .user2_id)
        created_at = try container.decode(String.self, forKey: .created_at)
        updated_at = try container.decode(String.self, forKey: .updated_at)
        
        // Опциональные поля с ручной обработкой неудач декодирования
        last_message = try? container.decode(ChatMessage?.self, forKey: .last_message)
        unread_count = (try? container.decode(Int.self, forKey: .unread_count)) ?? 0
        pet_photo_url = try? container.decode(String?.self, forKey: .pet_photo_url)
        pet_name = try? container.decode(String?.self, forKey: .pet_name)
        pet_status = try? container.decode(String?.self, forKey: .pet_status)
        other_user_name = try? container.decode(String?.self, forKey: .other_user_name)
    }
}

struct ChatMessage: Codable {
    let id: Int
    let content: String
    let chat_id: Int
    var sender_id: Int
    let whoid: Int?
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

