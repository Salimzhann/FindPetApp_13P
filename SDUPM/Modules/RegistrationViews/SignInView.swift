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
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    let surnameLabel: UILabel = {
        let label = UILabel()
        label.text = "Surname"
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
    let nameTextField: UITextField = {
        let name = UITextField()
        name.placeholder = "Your Name"
        name.borderStyle = .roundedRect
        return name
    }()
    let surnameTextField: UITextField = {
        let name = UITextField()
        name.placeholder = "Your Surname"
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
    private let signUpSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        spinner.color = .white
        return spinner
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
        
        hideKeyboardWhenTappedAround()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        [nameLabel, surnameLabel, passwordLabel, passwordTextField,
         emailLabel, phoneLabel, haveAccountButton,
         loginButton, signUpButton, signUpText, nameTextField, surnameTextField,
         emailTextField, numberTextfield].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        })
        
        signUpButton.addSubview(signUpSpinner)
        signUpSpinner.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signUpText.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),
            signUpText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            nameLabel.topAnchor.constraint(equalTo: signUpText.bottomAnchor, constant: 40),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 56),
            
            surnameLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 5),
            surnameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            surnameTextField.topAnchor.constraint(equalTo: surnameLabel.bottomAnchor, constant: 5),
            surnameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            surnameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            surnameTextField.heightAnchor.constraint(equalToConstant: 56),
            
            emailLabel.topAnchor.constraint(equalTo: surnameTextField.bottomAnchor, constant: 10),
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
            loginButton.leadingAnchor.constraint(equalTo: haveAccountButton.trailingAnchor, constant: 10),
            
            signUpSpinner.centerXAnchor.constraint(equalTo: signUpButton.centerXAnchor),
            signUpSpinner.centerYAnchor.constraint(equalTo: signUpButton.centerYAnchor)
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
    
    func showLoadingOnButton() {
        signUpButton.setTitle(nil, for: .normal)
        signUpSpinner.startAnimating()
        signUpButton.isUserInteractionEnabled = false
    }

    func hideLoadingOnButton() {
        signUpSpinner.stopAnimating()
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.isUserInteractionEnabled = true
    }
    
    func setupTextfields() {
        nameTextField.delegate = self
        surnameTextField.delegate = self
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
        
        guard let name = nameTextField.text, name.isEmpty == false else { return }
        guard let surname = surnameTextField.text, surname.isEmpty == false else { return }
        guard let email = emailTextField.text , email.isEmpty == false else { return }
        guard let password = passwordTextField.text , password.isEmpty == false else { return }
        guard let phoneNumber = numberTextfield.text , phoneNumber.isEmpty == false else { return }
        self.showLoadingOnButton()
        apiSender.sendUserData(name: name, surname: surname, email: email, password: password, phoneNumber: phoneNumber) { responseString in
            DispatchQueue.main.async {
                guard let response = responseString else { return }
                if response == "Success" {
                    let confirmVC = ConfirmEmailViewController(email: email)
                        confirmVC.modalPresentationStyle = .pageSheet

                        if let sheet = confirmVC.sheetPresentationController {
                            sheet.detents = [.custom { _ in
                                return UIScreen.main.bounds.height * 0.20
                            }]
                            sheet.prefersGrabberVisible = true
                            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                            sheet.preferredCornerRadius = 24
                        }
                        self.present(confirmVC, animated: true, completion: nil)
                    self.hideLoadingOnButton()
                }
            }
        }
    }
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false // Чтобы не блокировать нажатия на кнопки
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
