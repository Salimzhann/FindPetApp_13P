import UIKit
import SnapKit

class SignInView: UIViewController, UITextFieldDelegate {
    
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
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let password = UITextField()
        password.placeholder = "Your Password"
        password.borderStyle = .roundedRect
        password.isSecureTextEntry = true
        return password
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    private let phoneTextField: UITextField = {
        let phone = UITextField()
        phone.placeholder = "Your Phone number"
        phone.text = "+7"
        phone.borderStyle = .roundedRect
        phone.keyboardType = .phonePad
        return phone
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupTextFields()
        hideKeyboardWhenTappedAround()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        [signUpText, fullNameLabel, passwordLabel, passwordTextField,
         emailLabel, phoneLabel, haveAccountLabel, loginButton, signUpButton,
         fullNameTextField, emailTextField, phoneTextField].forEach {
            view.addSubview($0)
        }
        
        signUpButton.addSubview(signUpSpinner)
        
        // Title
        signUpText.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        // Full Name
        fullNameLabel.snp.makeConstraints { make in
            make.top.equalTo(signUpText.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
        }
        
        fullNameTextField.snp.makeConstraints { make in
            make.top.equalTo(fullNameLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        // Email
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(fullNameTextField.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(20)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        // Password
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        // Phone
        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(20)
        }
        
        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        // Sign Up Button
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        signUpSpinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // Login Link
        haveAccountLabel.snp.makeConstraints { make in
            make.top.equalTo(signUpButton.snp.bottom).offset(20)
            make.leading.equalTo(view.snp.centerX).offset(-100)
        }
        
        loginButton.snp.makeConstraints { make in
            make.centerY.equalTo(haveAccountLabel)
            make.leading.equalTo(haveAccountLabel.snp.trailing).offset(10)
        }
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
    }
    
    private func setupTextFields() {
        fullNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        phoneTextField.delegate = self
    }
    
    private func shake(_ view: UITextField) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))
        view.layer.add(animation, forKey: "position")
    }
    
    private func showLoadingOnButton() {
        signUpButton.setTitle(nil, for: .normal)
        signUpSpinner.startAnimating()
        signUpButton.isUserInteractionEnabled = false
    }
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    private func hideLoadingOnButton() {
        signUpSpinner.stopAnimating()
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.isUserInteractionEnabled = true
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Actions
    
    @objc private func loginButtonTapped() {
        navigationController?.pushViewController(LoginView(), animated: true)
    }
    
    @objc private func signUpButtonTapped() {
        guard let fullName = fullNameTextField.text, !fullName.isEmpty else {
            shake(fullNameTextField)
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            shake(emailTextField)
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            shake(passwordTextField)
            return
        }
        
        guard let phone = phoneTextField.text, !phone.isEmpty else {
            shake(phoneTextField)
            return
        }
        
        showLoadingOnButton()
        
        let apiSender = SignInViewModel()
        apiSender.sendUserData(fullName: fullName, email: email, password: password, phoneNumber: phone) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoadingOnButton()
                
                switch result {
                case .success(let message):
                    if message == "Success" {
                        let confirmVC = ConfirmEmailViewController(email: email)
                        confirmVC.modalPresentationStyle = .pageSheet
                        
                        if let sheet = confirmVC.sheetPresentationController {
                            sheet.detents = [.medium()]
                            sheet.prefersGrabberVisible = true
                            sheet.preferredCornerRadius = 24
                        }
                        
                        self.present(confirmVC, animated: true)
                    } else {
                        self.showAlert(title: "Registration Failed", message: message)
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
