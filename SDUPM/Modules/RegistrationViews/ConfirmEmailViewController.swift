//
//  ConfirmEmailViewController.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 10.04.2025.
//

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
    private let emailTextField: UITextField = {
        let id = UITextField()
        id.placeholder = "Enter password from email"
        id.borderStyle = .roundedRect
        return id
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
        
        view.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
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
        confirmButton.setTitle("Sign Up", for: .normal)
        confirmButton.isUserInteractionEnabled = true
    }
    
    @objc private func didTap() {
        guard let text = emailTextField.text, !text.isEmpty else { return }
        
        showLoadingOnButton()
        presenter.verifyEmail(verificationCode: text, newEmail: email) { _ in
            DispatchQueue.main.async {
                self.hideLoadingOnButton()
                self.dismiss(animated: true)
            }
        }
    }
}
