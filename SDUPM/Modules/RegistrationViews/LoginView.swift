//
//  LoginPage.swift
//  SDUCanteenApp
//
//  Created by Manas Salimzhan on 12.09.2024.
//

import UIKit

class LoginView: UIViewController {
    
    static let isActive = "AccountIsActive"

    let loginText: UILabel = {
        let label = UILabel()
        label.text = "Log in"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    let passwordTextField: UITextField = {
        let password = UITextField()
        password.placeholder = "Your Password"
        password.borderStyle = .roundedRect
        password.isSecureTextEntry = true
        return password
    }()
    let emailTextField: UITextField = {
        let id = UITextField()
        id.placeholder = "Your Email"
        id.borderStyle = .roundedRect
        return id
    }()
    let LogInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log in", for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.tintColor = .white
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupButtons()
    }
    
    func setupUI() {
        
        view.backgroundColor = .white
        
        [passwordLabel, passwordTextField, emailLabel, LogInButton, loginText, emailTextField].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        })
        
        NSLayoutConstraint.activate([
            loginText.topAnchor.constraint(equalTo: view.topAnchor, constant: 95),
            loginText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            emailLabel.topAnchor.constraint(equalTo: loginText.bottomAnchor, constant: 50),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 5),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 56),
            
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 5),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 56),
    
            LogInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            LogInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            LogInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            LogInButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    func start() {
        UserDefaults.standard.set(true, forKey: LoginView.isActive)
        view.window?.rootViewController = UINavigationController(rootViewController: NavigationViewModel())
        view.window?.makeKeyAndVisible()
    }
    
    func setupButtons() {
        LogInButton.addTarget(self, action: #selector(logInButtonTapped), for: .touchUpInside)
    }
    
    @objc func logInButtonTapped() {
        let loginAPI = LoginInViewModel()
        loginAPI.sendUserData(email: emailTextField.text!, password: passwordTextField.text!) { responseString in
            DispatchQueue.main.async {
                guard let response = responseString else { return }
                if response == "Success" {
                    self.start()
                }
                self.showAlert(title: "Something went wrong!", message: response)
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
