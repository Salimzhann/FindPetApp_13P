// File path: SDUPM/Modules/RegistrationViews/RegistrationViewModels/SignInViewModel.swift

import UIKit

class SignInViewModel {
    
    var accountIsActive: Bool = false
    
    func sendUserData(name: String, surname: String, email: String, password: String, phoneNumber: String, completion: @escaping (String?) -> Void) {
        let networkService = NetworkServiceProvider()
        
        networkService.register(email: email, firstName: name, lastName: surname, phone: phoneNumber, password: password) { result in
            switch result {
            case .success(let message):
                completion("Success")
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    func verifyEmail(verificationCode: String, newEmail: String, completion: @escaping (String?) -> Void) {
        let networkService = NetworkServiceProvider()
        
        networkService.verifyEmail(email: newEmail, code: verificationCode) { result in
            switch result {
            case .success(let message):
                completion("Success")
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
}
