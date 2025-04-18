// Путь: SDUPM/Modules/Chat/CreateChatPresenter.swift

import Foundation



class CreateChatPresenter {
    
    weak var view: CreateChatViewProtocol?
    private let provider = NetworkServiceProvider()
    
    func createChat(petId: Int, userId: Int) {
        provider.createChat(petId: petId, userId: userId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let chat):
                    self.view?.chatCreated(chat)
                case .failure(let error):
                    self.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
}
