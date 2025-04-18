import Foundation

protocol CreateChatViewProtocol: AnyObject {
    func chatCreated(_ chat: Chat)
    func showError(message: String)
}

class CreateChatPresenter {
    
    weak var view: CreateChatViewProtocol?
    private let provider = NetworkServiceProvider()
    
    func createChat(petId: Int, userId: Int) {
        provider.createChat(petId: petId, userId: userId) { [weak self] result in
            switch result {
            case .success(let chat):
                self?.view?.chatCreated(chat)
            case .failure(let error):
                self?.view?.showError(message: error.localizedDescription)
            }
        }
    }
}
