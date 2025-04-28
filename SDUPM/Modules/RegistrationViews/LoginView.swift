import UIKit
import SnapKit

class LoginView: UIViewController {
    
    static let isActive = "AccountIsActive"
    private let viewModel = LoginViewModel()
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Log in"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
    private let signUpLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't have an account?"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        let title = "Sign Up"
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.systemGreen
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add UI components
        view.addSubview(titleLabel)
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(signUpLabel)
        view.addSubview(signUpButton)
        
        // Add activity indicator to login button
        loginButton.addSubview(activityIndicator)
        
        // Constraints
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.leading.equalToSuperview().offset(20)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(20)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        signUpLabel.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(30)
            make.leading.equalTo(view.snp.centerX).offset(-80)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.centerY.equalTo(signUpLabel)
            make.leading.equalTo(signUpLabel.snp.trailing).offset(8)
        }
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
    }
    
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Navigation
    
    private func navigateToMainScreen() {
        guard let window = UIApplication.shared.windows.first else { return }
        
        let mainViewController = NavigationViewModel()
        let navigationController = UINavigationController(rootViewController: mainViewController)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
    }
    
    // MARK: - Actions
    
    @objc private func loginButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Please enter your email")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter your password")
            return
        }
        
        showLoadingState(true)
        
        viewModel.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.showLoadingState(false)
                
                switch result {
                case .success:
                    self?.navigateToMainScreen()
                case .failure(let error):
                    self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func signUpButtonTapped() {
        let signUpVC = SignInView()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func showLoadingState(_ isLoading: Bool) {
        if isLoading {
            loginButton.setTitle("", for: .normal)
            activityIndicator.startAnimating()
            loginButton.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            loginButton.setTitle("Log in", for: .normal)
            loginButton.isEnabled = true
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
