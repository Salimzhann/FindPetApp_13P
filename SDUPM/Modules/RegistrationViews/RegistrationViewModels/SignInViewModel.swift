import UIKit

class SignInViewModel {
    
    var accountIsActive: Bool = false
    private let provider = NetworkServiceProvider()
    
    func sendUserData(fullName: String, email: String, password: String, phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        provider.register(fullName: fullName, email: email, phone: phoneNumber, password: password, completion: completion)
    }
    
    func verifyEmail(email: String, code: String, completion: @escaping (Result<String, Error>) -> Void) {
        provider.verifyEmail(email: email, code: code, completion: completion)
    }
    
    // Для обратной совместимости
    func verifyEmail(verificationCode: String, newEmail: String, completion: @escaping (String?) -> Void) {
        verifyEmail(email: newEmail, code: verificationCode) { result in
            switch result {
            case .success(let message):
                completion("Success")
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
}
