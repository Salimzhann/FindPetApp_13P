// Путь: SDUPM/Modules/Chat/ChatPresenter.swift

import Foundation

protocol ChatViewProtocol: AnyObject {
    func setMessages(_ messages: [ChatMessage])
    func addMessage(_ message: ChatMessage)
    func showTypingIndicator(_ isTyping: Bool)
    func showUserInfo(_ userInfo: UserProfile)
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
    
    init(chatId: Int) {
        self.chatId = chatId
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
        provider.sendMessage(chatId: chatId, content: content) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    self.view?.addMessage(message)
                case .failure(let error):
                    self.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - WebSocket
    
    func connectToWebSocket() {
        // Предотвращаем повторные попытки подключения
        guard !isConnected && !isConnecting else { return }
        
        isConnecting = true
        let apiUrl = NetworkService.api
        
        // Обратите внимание, что в зависимости от серверной инфраструктуры
        // WebSocket URL может отличаться от REST API URL
        let websocketEndpoint = "/api/v1/ws/chat/\(chatId)"
        
        let wsBaseUrl: String
        if apiUrl.hasPrefix("https://") {
            wsBaseUrl = "wss://" + apiUrl.dropFirst("https://".count)
        } else if apiUrl.hasPrefix("http://") {
            wsBaseUrl = "ws://" + apiUrl.dropFirst("http://".count)
        } else {
            DispatchQueue.main.async {
                self.isConnecting = false
                self.view?.showError(message: "Invalid API URL format")
            }
            return
        }
        
        guard var urlComponents = URLComponents(string: "\(wsBaseUrl)\(websocketEndpoint)") else {
            DispatchQueue.main.async {
                self.isConnecting = false
                self.view?.showError(message: "Invalid WebSocket URL")
            }
            return
        }
        
        if let token = UserDefaults.standard.string(forKey: LoginViewModel.tokenIdentifier) {
            urlComponents.queryItems = [URLQueryItem(name: "token", value: token)]
        }
        
        guard let url = urlComponents.url else {
            DispatchQueue.main.async {
                self.isConnecting = false
                self.view?.showError(message: "Failed to create WebSocket URL")
            }
            return
        }
        
        print("Connecting to WebSocket URL: \(url.absoluteString)")
        
        // Создаем сессию с расширенными настройками для отладки
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30 // Увеличиваем таймаут для отладки
        let session = URLSession(configuration: config)
        
        webSocketTask = session.webSocketTask(with: url)
        
        // Добавляем обработчик завершения соединения
        webSocketTask?.resume()
        
        // Устанавливаем обработчик ошибок
        webSocketTask?.maximumMessageSize = 1024 * 1024 // 1 MB
        
        isConnected = true
        isConnecting = false
        
        receiveMessage()
    }
    
    func disconnectFromWebSocket() {
        guard isConnected else { return }
        
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        isConnected = false
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
                    // Избегаем многократных уведомлений о той же ошибке
                    if self.isConnected {
                        self.isConnected = false
                        // Уведомляем пользователя только в случае критической ошибки,
                        // незначительные ошибки лучше обрабатывать молча
                        if (error as NSError).code != URLError.cancelled.rawValue {
                            self.view?.showError(message: "Соединение с чатом прервано")
                        }
                    }
                }
            }
        }
    }
    
    private func handleWebSocketMessage(_ text: String) {
        // Более гибкая обработка различных форматов сообщений
        do {
            // Сначала пробуем декодировать как простое сообщение чата
            if let data = text.data(using: .utf8) {
                do {
                    let message = try JSONDecoder().decode(ChatMessage.self, from: data)
                    DispatchQueue.main.async {
                        self.view?.addMessage(message)
                    }
                    return
                } catch {
                    print("Failed to decode as ChatMessage: \(error)")
                    // Если не удалось декодировать как ChatMessage, продолжаем
                }
                
                // Пробуем декодировать как обертку сообщения
                do {
                    let messageWrapper = try JSONDecoder().decode(MessageWrapper.self, from: data)
                    if let message = messageWrapper.message {
                        // Если сообщение содержит текст, обрабатываем его как ChatMessage
                        let messageData = message.data(using: .utf8)
                        let chatMessage = try JSONDecoder().decode(ChatMessage.self, from: messageData!)
                        DispatchQueue.main.async {
                            self.view?.addMessage(chatMessage)
                        }
                    } else if messageWrapper.typing == true {
                        // Сообщение о наборе текста
                        DispatchQueue.main.async {
                            self.view?.showTypingIndicator(true)
                        }
                        
                        // Скрываем индикатор набора через 3 секунды
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.view?.showTypingIndicator(false)
                        }
                    }
                    return
                } catch {
                    print("Failed to decode as MessageWrapper: \(error)")
                }
                
                // Если все вышеперечисленные методы не сработали, просто логируем сообщение
                print("Received unhandled WebSocket message: \(text)")
            }
        } catch {
            print("Failed to parse WebSocket message: \(error)")
        }
    }
    
    func sendTypingEvent() {
        guard isConnected, let task = webSocketTask else { return }
        
        let messageDict = ["typing": true]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: messageDict)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let message = URLSessionWebSocketTask.Message.string(jsonString)
                task.send(message) { error in
                    if let error = error {
                        print("Failed to send typing event: \(error)")
                    }
                }
            }
        } catch {
            print("Failed to encode typing event: \(error)")
        }
    }
}

// Структура для декодирования разных форматов сообщений
struct MessageWrapper: Codable {
    let message: String?
    let typing: Bool?
}
