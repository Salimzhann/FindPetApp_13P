// File path: SDUPM/Modules/RegistrationViews/ConfirmEmailViewController.swift

import UIKit
import SnapKit

class ConfirmEmailViewController: UIViewController {
    
    private let email: String
    private let presenter = SignInViewModel()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirm your email"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter the verification code sent to your email"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter verification code"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("Confirm Email", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 16
        button.tintColor = .white
        return button
    }()
    
    private let signUpSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        spinner.color = .white
        return spinner
    }()
    
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
        
        confirmButton.addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        hideKeyboardWhenTappedAround()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(emailLabel)
        emailLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(instructionLabel)
        instructionLabel.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(instructionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(46)
        }
        
        view.addSubview(signUpSpinner)
        signUpSpinner.snp.makeConstraints { make in
            make.center.equalTo(confirmButton)
        }
    }
    
    func showLoadingOnButton() {
        confirmButton.setTitle(nil, for: .normal)
        signUpSpinner.startAnimating()
        confirmButton.isUserInteractionEnabled = false
    }

    func hideLoadingOnButton() {
        signUpSpinner.stopAnimating()
        confirmButton.setTitle("Confirm Email", for: .normal)
        confirmButton.isUserInteractionEnabled = true
    }
    
    @objc private func didTap() {
        guard let code = emailTextField.text, !code.isEmpty else {
            showAlert(title: "Error", message: "Please enter verification code")
            return
        }
        
        showLoadingOnButton()
        presenter.verifyEmail(verificationCode: code, newEmail: email) { result in
            DispatchQueue.main.async {
                self.hideLoadingOnButton()
                
                if let result = result, result == "Success" {
                    self.showAlert(title: "Success", message: "Email verified successfully", completion: {
                        self.dismiss(animated: true) {
                            if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                                let loginView = LoginView()
                                navigationController.pushViewController(loginView, animated: true)
                            }
                        }
                    })
                } else {
                    self.showAlert(title: "Error", message: result ?? "Verification failed")
                }
            }
        }
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
