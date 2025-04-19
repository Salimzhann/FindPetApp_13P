import UIKit
import SnapKit

protocol CreateChatDelegate: AnyObject {
    func didCreateChat(_ chat: Chat)
}

protocol CreateChatViewProtocol: AnyObject {
    func chatCreated(_ chat: Chat)
    func showError(message: String)
}

class CreateChatViewController: UIViewController, CreateChatViewProtocol {
    
    weak var delegate: CreateChatDelegate?
    private let presenter = CreateChatPresenter()
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создать новый чат"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let petIdTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "ID питомца"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let userIdTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "ID пользователя"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Введите ID питомца и ID пользователя, с которым хотите начать чат."
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать чат", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        hideKeyboardWhenTappedAround()
        setupPresenter()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Новый чат"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        view.addSubview(titleLabel)
        view.addSubview(infoLabel)
        view.addSubview(petIdTextField)
        view.addSubview(userIdTextField)
        view.addSubview(createButton)
        
        createButton.addSubview(activityIndicator)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        petIdTextField.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        
        userIdTextField.snp.makeConstraints { make in
            make.top.equalTo(petIdTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        
        createButton.snp.makeConstraints { make in
            make.top.equalTo(userIdTextField.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupActions() {
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    private func setupPresenter() {
        presenter.view = self
    }
    
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    func setupWithPet(petId: Int, userId: Int) {
        petIdTextField.text = String(petId)
        userIdTextField.text = String(userId)
    }
    
    @objc private func createButtonTapped() {
        guard let petIdText = petIdTextField.text, !petIdText.isEmpty,
              let userIdText = userIdTextField.text, !userIdText.isEmpty,
              let petId = Int(petIdText),
              let userId = Int(userIdText) else {
            showAlert(title: "Ошибка", message: "Пожалуйста, введите корректные ID питомца и пользователя")
            return
        }
        
        showLoading()
        presenter.createChat(petId: petId, userId: userId)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showLoading() {
        createButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        createButton.isEnabled = false
    }
    
    private func hideLoading() {
        activityIndicator.stopAnimating()
        createButton.setTitle("Создать чат", for: .normal)
        createButton.isEnabled = true
    }
    
    // MARK: - CreateChatViewProtocol
    
    func chatCreated(_ chat: Chat) {
        delegate?.didCreateChat(chat)
        dismiss(animated: true)
    }
    
    func showError(message: String) {
        hideLoading()
        showAlert(title: "Ошибка", message: message)
    }
}
