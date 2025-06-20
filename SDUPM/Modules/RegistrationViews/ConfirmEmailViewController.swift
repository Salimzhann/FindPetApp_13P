import UIKit
import SnapKit

class ConfirmEmailViewController: UIViewController {
    
    private let email: String
    private let presenter = SignInViewModel()
    
    private let containerView = UIView()
    
    private let emailTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirm your email"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let emailDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter the 6-digit verification code sent to your email"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let verificationCodeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "000000"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        return textField
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("Confirm Email", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 12
        button.tintColor = .white
        return button
    }()
    
    private let resendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Didn't receive code? Resend", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
    private let resendActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        return indicator
    }()
    
    private var resendTimer: Timer?
    private var resendCooldown = 60
    
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        setupDismissKeyboardGesture()
        updateEmailDescription()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resendTimer?.invalidate()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview().offset(-70)
        }
        
        [emailTitleLabel, emailDescriptionLabel, verificationCodeTextField,
         errorLabel, confirmButton, resendButton].forEach {
            containerView.addSubview($0)
        }
        
        confirmButton.addSubview(activityIndicator)
        resendButton.addSubview(resendActivityIndicator)
        
        emailTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        emailDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTitleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        verificationCodeTextField.snp.makeConstraints { make in
            make.top.equalTo(emailDescriptionLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(60)
            make.height.equalTo(50)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(verificationCodeTextField.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        resendButton.snp.makeConstraints { make in
            make.top.equalTo(confirmButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        resendActivityIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(resendButton.titleLabel!.snp.leading).offset(-8)
        }
    }
    
    private func updateEmailDescription() {
        let maskedEmail = maskEmail(email)
        emailDescriptionLabel.text = "Please enter the 6-digit verification code sent to \(maskedEmail)"
    }
    
    private func maskEmail(_ email: String) -> String {
        let components = email.split(separator: "@")
        guard components.count == 2 else { return email }
        
        let username = String(components[0])
        let domain = String(components[1])
        
        if username.count <= 3 {
            return email
        }
        
        let firstTwo = username.prefix(2)
        let lastOne = username.suffix(1)
        let masked = firstTwo + String(repeating: "*", count: username.count - 3) + String(lastOne)
        
        return "\(masked)@\(domain)"
    }
    
    private func setupActions() {
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        resendButton.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)
        verificationCodeTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        errorLabel.isHidden = true
        
        // Limit to 6 digits
        if let text = textField.text, text.count > 6 {
            textField.text = String(text.prefix(6))
        }
        
        // Auto-submit when 6 digits are entered
        if let text = textField.text, text.count == 6 {
            confirmButtonTapped()
        }
    }
    
    @objc private func confirmButtonTapped() {
        guard let code = verificationCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            showError("Please enter the verification code")
            return
        }
        
        // Validate code format
        if code.count != 6 || !code.allSatisfy({ $0.isNumber }) {
            showError("Please enter a valid 6-digit code")
            return
        }
        
        showLoadingOnButton(true)
        errorLabel.isHidden = true
        
        presenter.verifyEmail(email: email, code: code) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.showLoadingOnButton(false)
                
                switch result {
                case .success(_):
                    self.showSuccessAndDismiss()
                case .failure(let error):
                    self.handleVerificationError(error)
                }
            }
        }
    }
    
    @objc private func resendButtonTapped() {
        resendButton.isEnabled = false
        resendActivityIndicator.startAnimating()
        resendButton.setTitle("", for: .normal)
        errorLabel.isHidden = true
        
        // Call API to resend code
        // For now, we'll simulate the resend
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.resendActivityIndicator.stopAnimating()
            self?.startResendCooldown()
            self?.showSuccess("Verification code sent successfully")
        }
    }
    
    private func startResendCooldown() {
        resendCooldown = 60
        updateResendButtonTitle()
        
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.resendCooldown -= 1
            
            if self.resendCooldown <= 0 {
                self.resendTimer?.invalidate()
                self.resendButton.isEnabled = true
                self.resendButton.setTitle("Didn't receive code? Resend", for: .normal)
            } else {
                self.updateResendButtonTitle()
            }
        }
    }
    
    private func updateResendButtonTitle() {
        resendButton.setTitle("Resend code in \(resendCooldown)s", for: .normal)
    }
    
    private func showLoadingOnButton(_ isLoading: Bool) {
        if isLoading {
            confirmButton.setTitle(nil, for: .normal)
            activityIndicator.startAnimating()
            confirmButton.isUserInteractionEnabled = false
            verificationCodeTextField.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            confirmButton.setTitle("Confirm Email", for: .normal)
            confirmButton.isUserInteractionEnabled = true
            verificationCodeTextField.isEnabled = true
        }
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        
        // Shake animation for text field
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: verificationCodeTextField.center.x - 10, y: verificationCodeTextField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: verificationCodeTextField.center.x + 10, y: verificationCodeTextField.center.y))
        verificationCodeTextField.layer.add(animation, forKey: "position")
    }
    
    private func showSuccess(_ message: String) {
        errorLabel.text = message
        errorLabel.textColor = .systemGreen
        errorLabel.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.errorLabel.isHidden = true
            self?.errorLabel.textColor = .systemRed
        }
    }
    
    private func handleVerificationError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .requestFailed(let statusCode):
                if statusCode == 400 {
                    showError("Invalid or expired verification code. Please check and try again.")
                } else if statusCode == 404 {
                    showError("Email not found. Please check your email address.")
                } else {
                    showError("Verification failed. Please try again.")
                }
            case .networkUnavailable:
                showError("No internet connection. Please check your network.")
            default:
                showError("An error occurred. Please try again.")
            }
        } else {
            showError(error.localizedDescription)
        }
    }
    
    private func showSuccessAndDismiss() {
        // Create success view
        let successView = UIView()
        successView.backgroundColor = .systemGreen
        successView.layer.cornerRadius = 12
        successView.alpha = 0
        
        let checkmarkImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkmarkImageView.tintColor = .white
        checkmarkImageView.contentMode = .scaleAspectFit
        
        let successLabel = UILabel()
        successLabel.text = "Email Verified Successfully!"
        successLabel.textColor = .white
        successLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        successLabel.textAlignment = .center
        
        successView.addSubview(checkmarkImageView)
        successView.addSubview(successLabel)
        
        view.addSubview(successView)
        
        successView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(250)
            make.height.equalTo(150)
        }
        
        checkmarkImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.width.height.equalTo(50)
        }
        
        successLabel.snp.makeConstraints { make in
            make.top.equalTo(checkmarkImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Animate success view
        UIView.animate(withDuration: 0.3, animations: {
            successView.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.dismiss(animated: true) {
                    // Navigate to login screen if in navigation stack
                    if let navigationController = self.presentingViewController as? UINavigationController {
                        navigationController.pushViewController(LoginView(), animated: true)
                    }
                }
            }
        }
    }
}
