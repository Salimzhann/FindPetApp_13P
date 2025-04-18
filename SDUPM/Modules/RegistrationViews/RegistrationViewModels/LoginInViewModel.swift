// File path: SDUPM/Modules/RegistrationViews/RegistrationViewModels/LoginInViewModel.swift

import UIKit

class LoginInViewModel {
    
    static let tokenIdentifier: String = "TokenIdentifier"
    
    func sendUserData(email: String, password: String, completion: @escaping (String?) -> Void) {
        let networkService = NetworkServiceProvider()
        
        networkService.login(email: email, password: password) { result in
            switch result {
            case .success(let token):
                completion("Success")
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
}
