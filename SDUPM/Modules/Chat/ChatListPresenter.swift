// Путь: SDUPM/Modules/Chat/ChatListPresenter.swift

import Foundation

class ChatListPresenter {
    
    weak var view: ChatListViewProtocol?
    private let provider = NetworkServiceProvider()
    
    func fetchChats() {
        view?.showLoading()
        
        provider.fetchChats { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.view?.hideLoading()
                
                switch result {
                case .success(let chats):
                    self.view?.setChats(chats)
                case .failure(let error):
                    self.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
}
