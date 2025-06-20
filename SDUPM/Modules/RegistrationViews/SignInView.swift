import UIKit
import SnapKit

class SignInView: UIViewController, UITextFieldDelegate {
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let signUpText: UILabel = {
        let label = UILabel()
        label.text = "Create account"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Full Name"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let passwordRequirementsLabel: UILabel = {
        let label = UILabel()
        label.text = "Must be at least 8 characters with 1 uppercase, 1 lowercase, and 1 number"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.text = "Phone number"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let fullNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your Full Name"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        return textField
    }()
    
    private let fullNameErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let password = UITextField()
        password.placeholder = "Your Password"
        password.borderStyle = .roundedRect
        password.isSecureTextEntry = true
        password.textContentType = .newPassword
        return password
    }()
    
    private let passwordErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your email"
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
    
    private let phoneTextField: UITextField = {
        let phone = UITextField()
        phone.placeholder = "Your Phone number"
        phone.text = "+7"
        phone.borderStyle = .roundedRect
        phone.keyboardType = .phonePad
        phone.textContentType = .telephoneNumber
        return phone
    }()
    
    private let phoneErrorLabel: UILabel = {
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
            label.tag = 100
            return label
        }()
        
        view.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        return view
    }()
    
    private let signUpSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        spinner.color = .white
        return spinner
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.tintColor = .white
        return button
    }()
    
    private let haveAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "Already have an account?"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        let title = "Log in"
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.black
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    private let viewModel = SignInViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupTextFields()
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
        
        // Add all subviews to content view
        [signUpText, errorAlertView, fullNameLabel, fullNameTextField, fullNameErrorLabel,
         emailLabel, emailTextField, emailErrorLabel,
         passwordLabel, passwordTextField, passwordErrorLabel, passwordRequirementsLabel,
         phoneLabel, phoneTextField, phoneErrorLabel,
         signUpButton, haveAccountLabel, loginButton].forEach {
            contentView.addSubview($0)
        }
        
        signUpButton.addSubview(signUpSpinner)
        
        // ScrollView constraints
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // Title
        signUpText.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        // Error alert
        errorAlertView.snp.makeConstraints { make in
            make.top.equalTo(signUpText.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Full Name
        fullNameLabel.snp.makeConstraints { make in
            make.top.equalTo(errorAlertView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        fullNameTextField.snp.makeConstraints { make in
            make.top.equalTo(fullNameLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        fullNameErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(fullNameTextField.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Email
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(fullNameErrorLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        emailErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Password
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailErrorLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        passwordRequirementsLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        passwordErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordRequirementsLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Phone
        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordErrorLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
        }
        
        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        phoneErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Sign Up Button
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(phoneErrorLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        signUpSpinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // Login Link
        haveAccountLabel.snp.makeConstraints { make in
            make.top.equalTo(signUpButton.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.centerX).offset(-100)
        }
        
        loginButton.snp.makeConstraints { make in
            make.centerY.equalTo(haveAccountLabel)
            make.leading.equalTo(haveAccountLabel.snp.trailing).offset(10)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        fullNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        phoneTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupTextFields() {
        fullNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        phoneTextField.delegate = self
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
    
    // MARK: - Actions
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // Clear error when user starts typing
        switch textField {
        case fullNameTextField:
            fullNameErrorLabel.isHidden = true
            clearFieldError(textField: fullNameTextField)
        case emailTextField:
            emailErrorLabel.isHidden = true
            clearFieldError(textField: emailTextField)
        case passwordTextField:
            passwordErrorLabel.isHidden = true
            clearFieldError(textField: passwordTextField)
            validatePasswordRealTime()
        case phoneTextField:
            phoneErrorLabel.isHidden = true
            clearFieldError(textField: phoneTextField)
        default:
            break
        }
        errorAlertView.isHidden = true
    }
    
    private func validatePasswordRealTime() {
        guard let password = passwordTextField.text else { return }
        
        var isValid = true
        var requirements: [String] = []
        
        if password.count < 8 {
            requirements.append("• At least 8 characters")
            isValid = false
        }
        
        if !password.contains(where: { $0.isUppercase }) {
            requirements.append("• One uppercase letter")
            isValid = false
        }
        
        if !password.contains(where: { $0.isLowercase }) {
            requirements.append("• One lowercase letter")
            isValid = false
        }
        
        if !password.contains(where: { $0.isNumber }) {
            requirements.append("• One number")
            isValid = false
        }
        
        if isValid {
            passwordRequirementsLabel.textColor = .systemGreen
            passwordRequirementsLabel.text = "✓ Password meets all requirements"
        } else {
            passwordRequirementsLabel.textColor = .darkGray
            passwordRequirementsLabel.text = "Requirements: " + requirements.joined(separator: ", ")
        }
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
    
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Validation Methods
    
    private func validateFullName(_ name: String) -> (isValid: Bool, error: String?) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            return (false, "Full name is required")
        }
        
        if trimmedName.count < 2 {
            return (false, "Full name must be at least 2 characters")
        }
        
        let nameRegex = "^[a-zA-Z\\s\\-']+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        if !namePredicate.evaluate(with: trimmedName) {
            return (false, "Full name can only contain letters, spaces, hyphens and apostrophes")
        }
        
        return (true, nil)
    }
    
    private func validateEmail(_ email: String) -> (isValid: Bool, error: String?) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedEmail.isEmpty {
            return (false, "Email is required")
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if !emailPred.evaluate(with: trimmedEmail) {
            return (false, "Please enter a valid email address")
        }
        
        return (true, nil)
    }
    
    private func validatePassword(_ password: String) -> (isValid: Bool, error: String?) {
        if password.isEmpty {
            return (false, "Password is required")
        }
        
        if password.count < 8 {
            return (false, "Password must be at least 8 characters long")
        }
        
        if !password.contains(where: { $0.isUppercase }) {
            return (false, "Password must contain at least one uppercase letter")
        }
        
        if !password.contains(where: { $0.isLowercase }) {
            return (false, "Password must contain at least one lowercase letter")
        }
        
        if !password.contains(where: { $0.isNumber }) {
            return (false, "Password must contain at least one number")
        }
        
        return (true, nil)
    }
    
    private func validatePhone(_ phone: String) -> (isValid: Bool, error: String?) {
        let cleanedPhone = phone.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        
        if cleanedPhone.isEmpty || cleanedPhone == "+" {
            return (false, "Phone number is required")
        }
        
        let phoneRegex = "^\\+?\\d{10,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        if !phonePredicate.evaluate(with: cleanedPhone) {
            return (false, "Please enter a valid phone number (10-15 digits)")
        }
        
        return (true, nil)
    }
    
    // MARK: - UI Helper Methods
    
    private func showFieldError(textField: UITextField, errorLabel: UILabel, message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        textField.layer.borderColor = UIColor.systemRed.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
    }
    
    private func clearFieldError(textField: UITextField) {
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.layer.borderWidth = 0
    }
    
    private func hideAllErrors() {
        errorAlertView.isHidden = true
        
        fullNameErrorLabel.isHidden = true
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        phoneErrorLabel.isHidden = true
        
        clearFieldError(textField: fullNameTextField)
        clearFieldError(textField: emailTextField)
        clearFieldError(textField: passwordTextField)
        clearFieldError(textField: phoneTextField)
    }
    
    private func showError(message: String) {
        if let errorLabel = errorAlertView.viewWithTag(100) as? UILabel {
            errorLabel.text = message
        }
        errorAlertView.isHidden = false
    }
    
    private func showLoadingOnButton() {
        signUpButton.setTitle(nil, for: .normal)
        signUpSpinner.startAnimating()
        signUpButton.isUserInteractionEnabled = false
    }
    
    private func hideLoadingOnButton() {
        signUpSpinner.stopAnimating()
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.isUserInteractionEnabled = true
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case fullNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            phoneTextField.becomeFirstResponder()
        case phoneTextField:
            textField.resignFirstResponder()
            signUpButtonTapped()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - Actions
    
    @objc private func loginButtonTapped() {
        navigationController?.pushViewController(LoginView(), animated: true)
    }
    
    @objc private func signUpButtonTapped() {
        hideAllErrors()
        
        // Get values
        let fullName = fullNameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let phone = phoneTextField.text ?? ""
        
        // Validate all fields
        var hasError = false
        
        let nameValidation = validateFullName(fullName)
        if !nameValidation.isValid {
            showFieldError(textField: fullNameTextField, errorLabel: fullNameErrorLabel, message: nameValidation.error!)
            hasError = true
        }
        
        let emailValidation = validateEmail(email)
        if !emailValidation.isValid {
            showFieldError(textField: emailTextField, errorLabel: emailErrorLabel, message: emailValidation.error!)
            hasError = true
        }
        
        let passwordValidation = validatePassword(password)
        if !passwordValidation.isValid {
            showFieldError(textField: passwordTextField, errorLabel: passwordErrorLabel, message: passwordValidation.error!)
            hasError = true
        }
        
        let phoneValidation = validatePhone(phone)
        if !phoneValidation.isValid {
            showFieldError(textField: phoneTextField, errorLabel: phoneErrorLabel, message: phoneValidation.error!)
            hasError = true
        }
        
        if hasError {
            return
        }
        
        showLoadingOnButton()
        
        viewModel.sendUserData(
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            phoneNumber: phone
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoadingOnButton()
                
                switch result {
                case .success(_):
                    // Show verification screen
                    let confirmVC = ConfirmEmailViewController(email: email)
                    confirmVC.modalPresentationStyle = .pageSheet
                    
                    if let sheet = confirmVC.sheetPresentationController {
                        sheet.detents = [.medium()]
                        sheet.prefersGrabberVisible = true
                        sheet.preferredCornerRadius = 24
                    }
                    
                    self.present(confirmVC, animated: true) {
                        // Clear fields after presenting
                        self.fullNameTextField.text = ""
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        self.phoneTextField.text = "+7"
                        self.passwordRequirementsLabel.textColor = .darkGray
                        self.passwordRequirementsLabel.text = "Must be at least 8 characters with 1 uppercase, 1 lowercase, and 1 number"
                    }
                    
                case .failure(let error):
                    self.handleRegistrationError(error)
                }
            }
        }
    }
    
    private func handleRegistrationError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .requestFailed(let statusCode):
                if statusCode == 400 {
                    showError(message: "An account with this email already exists. Please use a different email or log in.")
                } else if statusCode == 422 {
                    showError(message: "Invalid data provided. Please check your information and try again.")
                } else {
                    showError(message: "Registration failed. Please try again.")
                }
            case .networkUnavailable:
                showError(message: "No internet connection. Please check your network and try again.")
            default:
                showError(message: "An error occurred during registration. Please try again.")
            }
        } else {
            showError(message: error.localizedDescription)
        }
    }
}
