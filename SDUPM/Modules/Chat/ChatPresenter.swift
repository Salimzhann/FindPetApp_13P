// Путь: SDUPM/Modules/Chat/ChatPresenter.swift

import Foundation

protocol ChatViewProtocol: AnyObject {
    func setMessages(_ messages: [ChatMessage])
    func addMessage(_ message: ChatMessage)
    func showTypingIndicator(_ isTyping: Bool)
    func showUserInfo(_ userInfo: UserProfile)
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
    
    init(chatId: Int) {
        self.chatId = chatId
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
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    self?.view?.addMessage(message)
                case .failure(let error):
                    self?.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - WebSocket
    
    func connectToWebSocket() {
        guard var urlComponents = URLComponents(string: "\(NetworkService.api)/ws/\(chatId)") else {
            DispatchQueue.main.async {
                self.view?.showError(message: "Invalid WebSocket URL")
            }
            return
        }
        
        if let token = UserDefaults.standard.string(forKey: LoginInViewModel.tokenIdentifier) {
            urlComponents.queryItems = [URLQueryItem(name: "token", value: token)]
        }
        
        guard let url = urlComponents.url else {
            DispatchQueue.main.async {
                self.view?.showError(message: "Failed to create WebSocket URL")
            }
            return
        }
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        
        webSocketTask?.resume()
        isConnected = true
        
        receiveMessage()
    }
    
    func disconnectFromWebSocket() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        isConnected = false
    }
    
    private func receiveMessage() {
        guard isConnected else { return }
        
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleWebSocketMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.handleWebSocketMessage(text)
                    }
                @unknown default:
                    break
                }
                
                self.receiveMessage()
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view?.showError(message: "WebSocket error: \(error.localizedDescription)")
                    self.isConnected = false
                }
            }
        }
    }
    
    private func handleWebSocketMessage(_ text: String) {
        do {
            if let data = text.data(using: .utf8) {
                let message = try JSONDecoder().decode(ChatMessage.self, from: data)
                DispatchQueue.main.async {
                    self.view?.addMessage(message)
                }
            }
        } catch {
            print("Failed to parse WebSocket message: \(error)")
        }
    }
    
    func sendTypingEvent() {
        guard isConnected else { return }
        
        let messageDict = ["message": ""] // Пустое сообщение для события typing
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: messageDict)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let message = URLSessionWebSocketTask.Message.string(jsonString)
                webSocketTask?.send(message) { error in
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
