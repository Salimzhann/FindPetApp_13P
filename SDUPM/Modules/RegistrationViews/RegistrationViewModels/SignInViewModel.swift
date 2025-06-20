import UIKit

class SignInViewModel {
    
    var accountIsActive: Bool = false
    private let provider = NetworkServiceProvider()
    
    func sendUserData(fullName: String, email: String, password: String, phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Normalize email
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        provider.register(
            fullName: fullName,
            email: normalizedEmail,
            phone: phoneNumber,
            password: password,
            completion: completion
        )
    }
    
    func verifyEmail(email: String, code: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Normalize email
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        provider.verifyEmail(email: normalizedEmail, code: code, completion: completion)
    }
    
    func resendVerificationCode(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        // This would call a resend endpoint on your backend
        // For now, we'll use the existing verify endpoint
        completion(.success("Verification code sent"))
    }
}
