// Путь: SDUPM/Modules/Chat/ChatPresenter.swift

import Foundation

protocol ChatViewProtocol: AnyObject {
    func setMessages(_ messages: [ChatMessage])
    func addMessage(_ message: ChatMessage)
    func showTypingIndicator(_ isTyping: Bool)
    func updateUserStatus(_ userId: Int, isOnline: Bool, lastActiveAt: Date?)
    func markMessageAsRead(_ messageId: Int)
    func updateChatInfo(_ chat: Chat)
    func showLoading()
    func hideLoading()
    func showError(message: String)
}

class ChatPresenter {
    
    weak var view: ChatViewProtocol?
    private let provider = NetworkServiceProvider()
    private let chatId: Int
    private var webSocketTask: URLSessionWebSocketTask?
    private var isConnected = false
    private var isConnecting = false
    private var reconnectTimer: Timer?
    private let reconnectInterval: TimeInterval = 5.0
    
    init(chatId: Int) {
        self.chatId = chatId
    }
    
    deinit {
        disconnectFromWebSocket()
        reconnectTimer?.invalidate()
    }
    
    func fetchChatDetails() {
        view?.showLoading()
        
        provider.getChat(chatId: chatId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.view?.hideLoading()
                
                switch result {
                case .success(let chat):
                    self.view?.updateChatInfo(chat)
                case .failure(let error):
                    self.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    func fetchMessages() {
        view?.showLoading()
        
        provider.getChatMessages(chatId: chatId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.view?.hideLoading()
                
                switch result {
                case .success(let messages):
                    self.view?.setMessages(messages)
                case .failure(let error):
                    self.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    func sendMessage(content: String) {
        let messageData: [String: Any] = [
            "message_type": "text",
            "content": content
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: messageData),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        
        sendWebSocketMessage(jsonString)
    }
    
    // MARK: - WebSocket
    
    func connectToWebSocket() {
        // Предотвращаем повторные попытки подключения
        guard !isConnected && !isConnecting else { return }
        
        isConnecting = true
        let apiUrl = NetworkService.api
        
        guard let token = UserDefaults.standard.string(forKey: LoginViewModel.tokenIdentifier) else {
            DispatchQueue.main.async {
                self.isConnecting = false
                self.view?.showError(message: "Authentication required. Please log in again.")
            }
            return
        }
        
        let wsBaseUrl: String
        if apiUrl.hasPrefix("https://") {
            wsBaseUrl = "wss://" + apiUrl.dropFirst("https://".count)
        } else if apiUrl.hasPrefix("http://") {
            wsBaseUrl = "ws://" + apiUrl.dropFirst("http://".count)
        } else {
            wsBaseUrl = apiUrl
        }
        
        let websocketEndpoint = "/api/v1/ws/\(chatId)?token=\(token)"
        
        guard let url = URL(string: "\(wsBaseUrl)\(websocketEndpoint)") else {
            DispatchQueue.main.async {
                self.isConnecting = false
                self.view?.showError(message: "Invalid WebSocket URL")
            }
            return
        }
        
        print("Connecting to WebSocket URL: \(url.absoluteString)")
        
        // Создаем сессию с расширенными настройками
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        
        webSocketTask?.resume()
        
        isConnected = true
        isConnecting = false
        
        receiveMessage()
    }
    
    func disconnectFromWebSocket() {
        guard isConnected, let task = webSocketTask else { return }
        
        task.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        isConnected = false
        
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
    
    private func scheduleReconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: reconnectInterval, repeats: false) { [weak self] _ in
            self?.connectToWebSocket()
        }
    }
    
    private func receiveMessage() {
        guard isConnected, let task = webSocketTask else { return }
        
        task.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received WebSocket message: \(text)")
                    self.handleWebSocketMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        print("Received WebSocket data message: \(text)")
                        self.handleWebSocketMessage(text)
                    }
                @unknown default:
                    break
                }
                
                // Продолжаем получать сообщения
                self.receiveMessage()
                
            case .failure(let error):
                print("WebSocket error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    // Avoid multiple notifications about the same error
                    if self.isConnected {
                        self.isConnected = false
                        
                        // Only notify the user in case of a critical error
                        if (error as NSError).code != URLError.cancelled.rawValue {
                            self.view?.showError(message: "Connection to chat interrupted. Reconnecting...")
                            self.scheduleReconnect()
                        }
                    }
                }
            }
        }
    }
    
    private func handleWebSocketMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                // Check if this is a chat message
                if let content = json["content"] as? String,
                   let messageId = (json["message_id"] as? Int) ?? (json["id"] as? Int),
                   let chatId = json["chat_id"] as? Int,
                   let senderId = json["sender_id"] as? Int,
                   let isRead = json["is_read"] as? Bool,
                   let createdAt = json["created_at"] as? String {
                    
                    let id = messageId is Int ? messageId : (json["id"] as? Int ?? 0)
                    
                    let message = ChatMessage(
                        id: id,
                        content: content,
                        chat_id: chatId,
                        sender_id: senderId,
                        is_read: isRead,
                        created_at: createdAt
                    )
                    
                    DispatchQueue.main.async {
                        self.view?.addMessage(message)
                    }
                    return
                }
                
                // Handle typing status
                if let statusType = json["status_type"] as? String,
                   let userId = json["user_id"] as? Int {
                    
                    switch statusType {
                    case "typing_started":
                        DispatchQueue.main.async {
                            self.view?.showTypingIndicator(true)
                        }
                    case "typing_ended":
                        DispatchQueue.main.async {
                            self.view?.showTypingIndicator(false)
                        }
                    case "message_read":
                        if let messageId = json["message_id"] as? Int {
                            DispatchQueue.main.async {
                                self.view?.markMessageAsRead(messageId)
                            }
                        }
                    case "user_online":
                        let lastActiveStr = json["last_active_at"] as? String
                        let lastActive: Date?
                        if let lastActiveStr = lastActiveStr {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                            lastActive = dateFormatter.date(from: lastActiveStr)
                        } else {
                            lastActive = nil
                        }
                        DispatchQueue.main.async {
                            self.view?.updateUserStatus(userId, isOnline: true, lastActiveAt: lastActive)
                        }
                    case "user_offline":
                        let lastActiveStr = json["last_active_at"] as? String
                        let lastActive: Date?
                        if let lastActiveStr = lastActiveStr {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                            lastActive = dateFormatter.date(from: lastActiveStr)
                        } else {
                            lastActive = nil
                        }
                        DispatchQueue.main.async {
                            self.view?.updateUserStatus(userId, isOnline: false, lastActiveAt: lastActive)
                        }
                    default:
                        break
                    }
                    return
                }
                
                // System message
                if let message = json["message"] as? String,
                   let type = json["type"] as? String,
                   type == "system" {
                    print("System message: \(message)")
                    return
                }
            }
        } catch {
            print("Failed to parse WebSocket message: \(error)")
        }
    }
    
    private func sendWebSocketMessage(_ text: String) {
        guard isConnected, let task = webSocketTask else {
            // Try to reconnect if disconnected
            if !isConnecting {
                connectToWebSocket()
            }
            return
        }
        
        let message = URLSessionWebSocketTask.Message.string(text)
        task.send(message) { [weak self] error in
            if let error = error {
                print("Failed to send WebSocket message: \(error)")
                DispatchQueue.main.async {
                    if let self = self, self.isConnected {
                        self.isConnected = false
                        self.scheduleReconnect()
                    }
                }
            }
        }
    }
    
    func sendTypingEvent(isTyping: Bool) {
        let messageType = isTyping ? "typing_started" : "typing_ended"
        let messageDict = ["message_type": messageType]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: messageDict),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        
        sendWebSocketMessage(jsonString)
    }
    
    func markMessageAsRead(messageId: Int) {
        let messageDict: [String: Any] = [
            "message_type": "message_read",
            "message_id": messageId
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: messageDict),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        
        sendWebSocketMessage(jsonString)
    }
}
