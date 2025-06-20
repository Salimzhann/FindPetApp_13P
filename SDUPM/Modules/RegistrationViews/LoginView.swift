import UIKit
import SnapKit

class LoginView: UIViewController {
    
    static let isActive = "AccountIsActive"
    private let viewModel = LoginViewModel()
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
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
        textField.textContentType = .emailAddress
        return textField
    }()
    
    private let emailErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.isHidden = true
        return label
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
        textField.textContentType = .password
        return textField
    }()
    
    private let passwordErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private let errorAlertView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.isHidden = true
        view.layer.cornerRadius = 8
        
        let errorLabel: UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.textAlignment = .left
            label.font = UIFont.systemFont(ofSize: 14)
            label.numberOfLines = 0
            label.tag = 100 // Tag to identify the label
            return label
        }()
        
        view.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        return view
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
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
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add UI components to content view
        [titleLabel, emailLabel, emailTextField, emailErrorLabel,
         passwordLabel, passwordTextField, passwordErrorLabel,
         errorAlertView, loginButton, signUpLabel, signUpButton].forEach {
            contentView.addSubview($0)
        }
        
        // Add activity indicator to login button
        loginButton.addSubview(activityIndicator)
        
        // ScrollView constraints
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // Title
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalToSuperview().offset(20)
        }
        
        // Error alert
        errorAlertView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Email
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(errorAlertView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        emailErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Password
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailErrorLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        passwordErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Login button
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordErrorLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // Sign up
        signUpLabel.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(30)
            make.leading.equalTo(contentView.snp.centerX).offset(-80)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.centerY.equalTo(signUpLabel)
            make.leading.equalTo(signUpLabel.snp.trailing).offset(8)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // Clear error when user starts typing
        if textField == emailTextField {
            emailErrorLabel.isHidden = true
            emailTextField.layer.borderColor = UIColor.clear.cgColor
            emailTextField.layer.borderWidth = 0
        } else if textField == passwordTextField {
            passwordErrorLabel.isHidden = true
            passwordTextField.layer.borderColor = UIColor.clear.cgColor
            passwordTextField.layer.borderWidth = 0
        }
        errorAlertView.isHidden = true
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func loginButtonTapped() {
        // Clear all previous errors
        hideAllErrors()
        
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordTextField.text else {
            showError(message: "Please fill in all fields")
            return
        }
        
        // Validate email format
        if !viewModel.isValidEmail(email) {
            showFieldError(textField: emailTextField, errorLabel: emailErrorLabel, message: "Please enter a valid email address")
            return
        }
        
        // Validate password is not empty
        if password.isEmpty {
            showFieldError(textField: passwordTextField, errorLabel: passwordErrorLabel, message: "Password is required")
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
                    self?.handleLoginError(error)
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
            emailTextField.isEnabled = false
            passwordTextField.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            loginButton.setTitle("Log in", for: .normal)
            loginButton.isEnabled = true
            emailTextField.isEnabled = true
            passwordTextField.isEnabled = true
        }
    }
    
    private func hideAllErrors() {
        errorAlertView.isHidden = true
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        emailTextField.layer.borderColor = UIColor.clear.cgColor
        emailTextField.layer.borderWidth = 0
        passwordTextField.layer.borderColor = UIColor.clear.cgColor
        passwordTextField.layer.borderWidth = 0
    }
    
    private func showFieldError(textField: UITextField, errorLabel: UILabel, message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        textField.layer.borderColor = UIColor.systemRed.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
    }
    
    private func showError(message: String) {
        if let errorLabel = errorAlertView.viewWithTag(100) as? UILabel {
            errorLabel.text = message
        }
        errorAlertView.isHidden = false
    }
    
    private func handleLoginError(_ error: LoginError) {
        switch error {
        case .invalidCredentials:
            showError(message: "Invalid email or password. Please check your credentials and try again.")
        case .networkError(let networkError):
            if let networkErr = networkError as? NetworkError {
                switch networkErr {
                case .authenticationRequired:
                    showError(message: "Authentication failed. Please check your credentials.")
                case .networkUnavailable:
                    showError(message: "No internet connection. Please check your network and try again.")
                default:
                    showError(message: "Network error occurred. Please try again.")
                }
            } else {
                showError(message: "Network error: \(networkError.localizedDescription)")
            }
        case .invalidResponse:
            showError(message: "Invalid response from server. Please try again.")
        case .unexpectedError:
            showError(message: "An unexpected error occurred. Please try again.")
        case .emailNotVerified:
            showError(message: "email Not Verified")
        case .accountInactive:
            showError(message: "account Inactive")
        }
    }
    
    private func navigateToMainScreen() {
        guard let window = UIApplication.shared.windows.first else { return }
        
        let mainViewController = NavigationViewModel()
        let navigationController = UINavigationController(rootViewController: mainViewController)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
    }
}
