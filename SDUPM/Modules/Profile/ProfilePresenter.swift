import UIKit

protocol ProfilePresenterProtocol: AnyObject {
    func fetchProfile()
    func updateProfile(fullName: String, phone: String, password: String?)
    func deleteAccount()
    func logout()
}

class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewProtocol?
    
    private let provider = NetworkServiceProvider()
    
    func fetchProfile() {
        view?.showLoading()
        provider.fetchUserProfile { [weak self] model in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let model = model {
                    self.view?.configure(with: model)
                } else {
                    self.view?.showError(message: "Failed to load profile data")
                }
                
                self.view?.hideLoading()
            }
        }
    }
    
    func updateProfile(fullName: String, phone: String, password: String?) {
        view?.showLoading()
        
        provider.updateUserProfile(fullName: fullName, phone: phone, password: password) { [weak self] success, message in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.view?.hideLoading()
                
                if success {
                    self.view?.showSuccess(message: "Profile updated successfully")
                    // Refresh profile data
                    self.fetchProfile()
                } else {
                    self.view?.showError(message: message ?? "Failed to update profile")
                }
            }
        }
    }
    
    func deleteAccount() {
        view?.showLoading()
        
        provider.deleteUserAccount { [weak self] success, message in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.view?.hideLoading()
                
                if success {
                    self.logout()
                } else {
                    self.view?.showError(message: message ?? "Failed to delete account")
                }
            }
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: LoginView.isActive)
        UserDefaults.standard.removeObject(forKey: LoginViewModel.tokenIdentifier)
        
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first {
                let signInViewController = SignInView()
                let navigationController = UINavigationController(rootViewController: signInViewController)
                
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
                
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
            }
        }
    }
}
