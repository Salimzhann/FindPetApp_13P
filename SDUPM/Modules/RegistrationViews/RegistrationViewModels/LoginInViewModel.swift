import Foundation

enum LoginError: Error, LocalizedError {
    case invalidCredentials
    case networkError(Error)
    case invalidResponse
    case unexpectedError

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from the server. Please try again."
        case .unexpectedError:
            return "An unexpected error occurred. Please try again."
        }
    }
}

class LoginViewModel {
    
    // Сохраняем важный идентификатор для токена
    static let tokenIdentifier: String = "TokenIdentifier"
    
    private let networkProvider = NetworkServiceProvider()
    
    // MARK: - Login
    
    func login(email: String, password: String, completion: @escaping (Result<Void, LoginError>) -> Void) {
        networkProvider.login(email: email, password: password) { result in
            switch result {
            case .success(let tokenJSON):
                // Parse the token JSON
                if let data = tokenJSON.data(using: .utf8),
                   let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                    
                    // Save the token
                    UserDefaults.standard.set(loginResponse.accessToken, forKey: LoginViewModel.tokenIdentifier)
                    UserDefaults.standard.set(true, forKey: LoginView.isActive)
                    
                    completion(.success(()))
                } else {
                    completion(.failure(.invalidResponse))
                }
                
            case .failure(let error):
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .requestFailed(statusCode: 401):
                        completion(.failure(.invalidCredentials))
                    default:
                        completion(.failure(.networkError(error)))
                    }
                } else {
                    completion(.failure(.networkError(error)))
                }
            }
        }
    }
    
    // MARK: - Password Validation
    
    func isValidPassword(_ password: String) -> Bool {
        // Password should be at least 8 characters
        return password.count >= 8
    }
    
    // MARK: - Email Validation
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
