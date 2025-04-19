import Foundation

class ChatListPresenter {
    
    weak var view: ChatListViewProtocol?
    private let provider = NetworkServiceProvider()
    
    func fetchChats() {
        view?.showLoading()
        
        provider.fetchChats { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.view?.hideLoading()
                
                switch result {
                case .success(let chats):
                    // Дополним информацию для каждого чата
                    var enhancedChats = chats
                    
                    let currentUserId = UserDefaults.standard.integer(forKey: "current_user_id")
                    
                    for i in 0..<enhancedChats.count {
                        // Определяем, какой пользователь является "другим" для текущего
                        let otherUserId = enhancedChats[i].user1_id == currentUserId ?
                                         enhancedChats[i].user2_id : enhancedChats[i].user1_id
                                         
                        // Устанавливаем имя другого пользователя и питомца
                        enhancedChats[i].otherUserName = "Пользователь \(otherUserId)"
                        enhancedChats[i].petName = "Питомец \(enhancedChats[i].pet_id)"
                    }
                    
                    // Сортируем по дате последнего сообщения (если есть)
                    enhancedChats.sort { (chat1, chat2) -> Bool in
                        // Если у обоих чатов есть последние сообщения
                        if let lastMessage1 = chat1.last_message, let lastMessage2 = chat2.last_message {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                            
                            if let date1 = dateFormatter.date(from: lastMessage1.created_at),
                               let date2 = dateFormatter.date(from: lastMessage2.created_at) {
                                return date1 > date2
                            }
                        }
                        
                        // Если у одного чата есть последнее сообщение, а у другого нет
                        if chat1.last_message != nil && chat2.last_message == nil {
                            return true
                        }
                        
                        if chat1.last_message == nil && chat2.last_message != nil {
                            return false
                        }
                        
                        // Если у обоих чатов нет последних сообщений, сортируем по дате создания
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                        
                        if let date1 = dateFormatter.date(from: chat1.updated_at),
                           let date2 = dateFormatter.date(from: chat2.updated_at) {
                            return date1 > date2
                        }
                        
                        // По умолчанию возвращаем false
                        return false
                    }
                    
                    self.view?.setChats(enhancedChats)
                    print("Успешно получено \(enhancedChats.count) чатов")
                    
                case .failure(let error):
                    self.view?.showError(message: "Ошибка загрузки чатов: \(error.localizedDescription)")
                    print("Ошибка загрузки чатов: \(error)")
                }
            }
        }
    }
    
    func createChat(petId: Int, userId: Int, completion: @escaping (Result<Chat, Error>) -> Void) {
        provider.createChat(petId: petId, userId: userId, completion: completion)
    }
}
