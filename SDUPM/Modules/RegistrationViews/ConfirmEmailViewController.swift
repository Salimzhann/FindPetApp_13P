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
        label.text = "Please enter the verification code sent to your email"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let verificationCodeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Verification code"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 18)
        return textField
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("Confirm Email", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 12
        button.tintColor = .white
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
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
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview().offset(-70)
        }
        
        [emailTitleLabel, emailDescriptionLabel, verificationCodeTextField, confirmButton].forEach {
            containerView.addSubview($0)
        }
        
        confirmButton.addSubview(activityIndicator)
        
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
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(verificationCodeTextField.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupActions() {
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }
    
    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func confirmButtonTapped() {
        guard let code = verificationCodeTextField.text, !code.isEmpty else {
            showAlert(title: "Error", message: "Please enter the verification code")
            return
        }
        
        showLoadingOnButton()
        
        presenter.verifyEmail(email: email, code: code) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoadingOnButton()
                
                switch result {
                case .success(let message):
                    self.dismiss(animated: true) {
                        self.showSuccessToast()
                    }
                case .failure(let error):
                    self.showAlert(title: "Verification Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showLoadingOnButton() {
        confirmButton.setTitle(nil, for: .normal)
        activityIndicator.startAnimating()
        confirmButton.isUserInteractionEnabled = false
    }
    
    private func hideLoadingOnButton() {
        activityIndicator.stopAnimating()
        confirmButton.setTitle("Confirm Email", for: .normal)
        confirmButton.isUserInteractionEnabled = true
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessToast() {
        guard let parentViewController = presentingViewController else { return }
        
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = .systemFont(ofSize: 16)
        toastLabel.text = "Email successfully verified! Please log in."
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        
        parentViewController.view.addSubview(toastLabel)
        
        toastLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(100)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.greaterThanOrEqualTo(50)
        }
        
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}
