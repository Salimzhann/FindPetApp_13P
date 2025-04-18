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
                    self.view?.setChats(chats)
                    print("Успешно получено \(chats.count) чатов")
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
