import Foundation

class ChatListPresenter {
    
    weak var view: ChatListViewProtocol?
    private let provider = NetworkServiceProvider()
    
    func fetchChats() {
        view?.showLoading()
        
        // Для тестирования можем использовать моковые данные
        let mockChats = [
            Chat(id: 1, pet_id: 101, user1_id: 1, user2_id: 2, created_at: "2025-04-18T12:00:00.000000",
                 updated_at: "2025-04-18T12:00:00.000000", last_message: ChatMessage(id: 1, content: "Hello!",
                 chat_id: 1, sender_id: 2, is_read: true, created_at: "2025-04-18T12:00:00.000000"),
                 unread_count: 0, otherUserName: "John", petName: "Rex"),
            
            Chat(id: 2, pet_id: 102, user1_id: 1, user2_id: 3, created_at: "2025-04-17T14:30:00.000000",
                 updated_at: "2025-04-17T14:30:00.000000", last_message: ChatMessage(id: 2, content: "How is your pet?",
                 chat_id: 2, sender_id: 1, is_read: false, created_at: "2025-04-17T14:30:00.000000"),
                 unread_count: 2, otherUserName: "Alice", petName: "Luna")
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.view?.hideLoading()
            self?.view?.setChats(mockChats)
        }
        
        // В реальном приложении будет использоваться API
        /*
        provider.fetchChats { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoading()
                
                switch result {
                case .success(let chats):
                    self?.view?.setChats(chats)
                case .failure(let error):
                    self?.view?.showError(message: error.localizedDescription)
                }
            }
        }
        */
    }
}
