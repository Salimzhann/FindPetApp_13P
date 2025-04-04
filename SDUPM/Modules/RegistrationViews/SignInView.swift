//
//  ViewController.swift
//  SDUCanteenApp
//
//  Created by Manas Salimzhan on 11.09.2024.
//
import UIKit
import SnapKit

class SignInView: UIViewController, UITextFieldDelegate{
    let signUpText: UILabel = {
        let label = UILabel()
        label.text = "Create account"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    let fullnameLabel: UILabel = {
        let label = UILabel()
        label.text = "Fullname"
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
    let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    let phoneLabel: UILabel = {
        let label = UILabel()
        label.text = "Phone number"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    let fullNameTextfield: UITextField = {
        let name = UITextField()
        name.placeholder = "Your Name and Surname"
        name.borderStyle = .roundedRect
        return name
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
        id.placeholder = "Your email"
        id.borderStyle = .roundedRect
        return id
    }()
    let numberTextfield: UITextField = {
        let phone = UITextField()
        phone.placeholder = "Your Phone number"
        phone.text = "+7"
        phone.borderStyle = .roundedRect
        return phone
    }()
    let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.tintColor = .white
        return button
    }()
    let haveAccountButton: UILabel = {
        let label = UILabel()
        label.text = "Already have an account?"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    let loginButton: UIButton = {
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
        buttonSetups()
        setupTextfields()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        [fullnameLabel, passwordLabel, passwordTextField,
         emailLabel, phoneLabel, haveAccountButton,
         loginButton, signUpButton, signUpText, fullNameTextfield,
         emailTextField, numberTextfield].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        })
        
        NSLayoutConstraint.activate([
            signUpText.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),
            signUpText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            fullnameLabel.topAnchor.constraint(equalTo: signUpText.bottomAnchor, constant: 40),
            fullnameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            fullNameTextfield.topAnchor.constraint(equalTo: fullnameLabel.bottomAnchor, constant: 5),
            fullNameTextfield.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fullNameTextfield.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            fullNameTextfield.heightAnchor.constraint(equalToConstant: 56),
            
            emailLabel.topAnchor.constraint(equalTo: fullNameTextfield.bottomAnchor, constant: 10),
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
            
            phoneLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10),
            phoneLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            numberTextfield.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 5),
            numberTextfield.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            numberTextfield.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            numberTextfield.heightAnchor.constraint(equalToConstant: 56),
            
            signUpButton.topAnchor.constraint(equalTo: numberTextfield.bottomAnchor, constant: 20),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpButton.heightAnchor.constraint(equalToConstant: 55),
            
            haveAccountButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 20),
            haveAccountButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: -120),
            
            loginButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 10),
            loginButton.leadingAnchor.constraint(equalTo: haveAccountButton.trailingAnchor, constant: 10)
        ])
    }
    
    func shake(_ view: UITextField) {
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))

        view.layer.add(animation, forKey: "position")
    }
    
    func setupTextfields() {
        fullNameTextfield.delegate = self
        numberTextfield.delegate = self
        numberTextfield.keyboardType = .phonePad
        passwordTextField.delegate = self
        emailTextField.delegate = self
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func buttonSetups() {
        loginButton.addTarget(self, action: #selector(logInButtonIsTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(SignUpButtonTapped), for: .touchUpInside)
    }
    
    @objc func logInButtonIsTapped() {
        navigationController?.pushViewController(LoginView(), animated: true)
    }
    
    @objc func SignUpButtonTapped() {
        let apiSender = SignInViewModel()
        
        guard let fullname = fullNameTextfield.text , fullname.isEmpty == false else { return }
        guard let email = emailTextField.text , email.isEmpty == false else { return }
        guard let password = passwordTextField.text , password.isEmpty == false else { return }
        guard let phoneNumber = numberTextfield.text , phoneNumber.isEmpty == false else { return }
        
        apiSender.sendUserData(fullname: fullname, email: email, password: password, phoneNumber: phoneNumber) { responseString in
            DispatchQueue.main.async {
                guard let response = responseString else { return }
                if response == "Success" { self.navigationController?.pushViewController(LoginView(), animated: true) }
                if response.contains("fullname") {
                    self.fullNameTextfield.text = ""
                    self.shake(self.fullNameTextfield)
                } else if response.contains("password") {
                    self.passwordTextField.text = ""
                    self.shake(self.passwordTextField)
                } else if response.contains("email") {
                    self.emailTextField.text = ""
                    self.shake(self.emailTextField)
                } else if response.contains("phoneNumber") {
                    self.numberTextfield.text = ""
                    self.shake(self.numberTextfield)
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == numberTextfield {
            // Logic specific to the phone number text field
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            // Ensure "+7" is the prefix and can't be deleted
            if newText.count < 2 {
                return false // Prevent deleting the prefix
            }
            
            // Ensure the first characters are always "+7"
            if !newText.hasPrefix("+7") {
                textField.text = "+7"
                return false
            }

            return true
        }
        
        // For other text fields, allow normal behavior
        return true
    }

}
