import Foundation

enum LoginError: Error, LocalizedError {
    case invalidCredentials
    case networkError(Error)
    case invalidResponse
    case unexpectedError
    case emailNotVerified
    case accountInactive

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
        case .emailNotVerified:
            return "Please verify your email before logging in."
        case .accountInactive:
            return "Your account has been deactivated. Please contact support."
        }
    }
}

class LoginViewModel {
    
    static let tokenIdentifier: String = "TokenIdentifier"
    static let userIdIdentifier: String = "UserIdIdentifier"
    
    private let networkProvider = NetworkServiceProvider()
    
    func login(email: String, password: String, completion: @escaping (Result<Void, LoginError>) -> Void) {
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        networkProvider.login(email: normalizedEmail, password: password) { result in
            switch result {
            case .success(let tokenJSON):
                if let data = tokenJSON.data(using: .utf8),
                   let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                    
                    UserDefaults.standard.set(loginResponse.accessToken, forKey: LoginViewModel.tokenIdentifier)
                    UserDefaults.standard.set(loginResponse.userId, forKey: LoginViewModel.userIdIdentifier)
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
                    case .requestFailed(statusCode: 403):
                        completion(.failure(.emailNotVerified))
                    default:
                        completion(.failure(.networkError(error)))
                    }
                } else {
                    completion(.failure(.networkError(error)))
                }
            }
        }
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 8
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: trimmedEmail)
    }
}
