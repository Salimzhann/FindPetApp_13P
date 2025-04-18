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
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create a new chat"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let petIdTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Pet ID"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let userIdTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "User ID"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Chat", for: .normal)
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
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "New Chat"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        view.addSubview(titleLabel)
        view.addSubview(petIdTextField)
        view.addSubview(userIdTextField)
        view.addSubview(createButton)
        
        createButton.addSubview(activityIndicator)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        petIdTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
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
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let petIdText = petIdTextField.text, !petIdText.isEmpty,
              let userIdText = userIdTextField.text, !userIdText.isEmpty,
              let petId = Int(petIdText),
              let userId = Int(userIdText) else {
            showAlert(title: "Error", message: "Please enter valid Pet ID and User ID")
            return
        }
        
        showLoading()
        
        // Для демонстрации создаем моковый чат
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.hideLoading()
            
            // Создаем моковый чат
            let mockChat = Chat(
                id: Int.random(in: 100...999),
                pet_id: petId,
                user1_id: 1,  // Текущий пользователь
                user2_id: userId,
                created_at: ISO8601DateFormatter().string(from: Date()),
                updated_at: ISO8601DateFormatter().string(from: Date()),
                last_message: nil,
                unread_count: 0,
                otherUserName: "User \(userId)",
                petName: "Pet \(petId)"
            )
            
            self?.delegate?.didCreateChat(mockChat)
            self?.dismiss(animated: true)
        }
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
        createButton.setTitle("Create Chat", for: .normal)
        createButton.isEnabled = true
    }
    
    // MARK: - CreateChatViewProtocol
    
    func chatCreated(_ chat: Chat) {
        delegate?.didCreateChat(chat)
        dismiss(animated: true)
    }
    
    func showError(message: String) {
        hideLoading()
        showAlert(title: "Error", message: message)
    }
}
