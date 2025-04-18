//
//  ChatViewController.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 18.04.2025.
//

import UIKit
import SnapKit

class ChatViewController: UIViewController {
    
    private let chat: Chat
    private var messages: [ChatMessage] = []
    private var currentUserId: Int = 1 // Значение будет получено из UserDefaults
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(OutgoingMessageCell.self, forCellReuseIdentifier: "OutgoingMessageCell")
        tableView.register(IncomingMessageCell.self, forCellReuseIdentifier: "IncomingMessageCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    
    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.layer.cornerRadius = 18
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        return textView
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        button.tintColor = .systemGreen
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    
    private let typingIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private let typingLabel: UILabel = {
        let label = UILabel()
        label.text = "typing..."
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .systemGreen
        return indicator
    }()
    
    // MARK: - Initialization
    
    init(chat: Chat) {
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
        setupKeyboardObservers()
        
        // Получаем текущий ID пользователя из UserDefaults
        if let userId = UserDefaults.standard.object(forKey: "current_user_id") as? Int {
            currentUserId = userId
        }
        
        title = chat.otherUserName
        
        // Загружаем тестовые сообщения
        loadMockMessages()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(inputContainerView)
        view.addSubview(activityIndicator)
        
        inputContainerView.addSubview(messageTextView)
        inputContainerView.addSubview(sendButton)
        
        view.addSubview(typingIndicatorView)
        typingIndicatorView.addSubview(typingLabel)
        
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputContainerView.snp.top)
        }
        
        inputContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.greaterThanOrEqualTo(60)
        }
        
        messageTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.trailing.equalTo(sendButton.snp.leading).offset(-10)
            make.height.greaterThanOrEqualTo(36).priority(.high)
        }
        
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        typingIndicatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalTo(inputContainerView.snp.top).offset(-8)
            make.height.equalTo(24)
        }
        
        typingLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        // Инвертируем таблицу, чтобы последнее сообщение было внизу
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    private func setupActions() {
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tableView.addGestureRecognizer(tapGesture)
        
        // Настраиваем делегата для text view, чтобы отслеживать высоту
        messageTextView.delegate = self
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func loadMockMessages() {
        // Показываем индикатор загрузки
        activityIndicator.startAnimating()
        
        // Моковые сообщения для тестирования
        if let lastMessage = chat.last_message {
            messages = [lastMessage]
        }
        
        // Добавим еще несколько сообщений
        messages.append(ChatMessage(
            id: messages.count + 1,
            content: "Hello! I saw your post about the pet.",
            chat_id: chat.id,
            sender_id: currentUserId,
            is_read: true,
            created_at: "2025-04-18T12:05:00.000000"
        ))
        
        messages.append(ChatMessage(
            id: messages.count + 1,
            content: "Can you share more details about where you found it?",
            chat_id: chat.id,
            sender_id: chat.user2_id,
            is_read: true,
            created_at: "2025-04-18T12:07:00.000000"
        ))
        
        messages.append(ChatMessage(
            id: messages.count + 1,
            content: "I found it near the park on Main Street.",
            chat_id: chat.id,
            sender_id: currentUserId,
            is_read: true,
            created_at: "2025-04-18T12:10:00.000000"
        ))
        
        // Инвертируем сообщения для отображения в обратном порядке
        messages = messages.reversed()
        
        // Имитируем задержку загрузки
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Скрываем индикатор загрузки
            self.activityIndicator.stopAnimating()
            
            // Обновляем таблицу
            self.tableView.reloadData()
            
            // Прокручиваем к самому последнему сообщению
            if !self.messages.isEmpty {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func sendButtonTapped() {
        guard let messageText = messageTextView.text, !messageText.isEmpty else { return }
        
        // Создаем новое сообщение
        let newMessage = ChatMessage(
            id: messages.count + 1,
            content: messageText,
            chat_id: chat.id,
            sender_id: currentUserId,
            is_read: false,
            created_at: ISO8601DateFormatter().string(from: Date())
        )
        
        // Добавляем сообщение в массив (вставляем в начало из-за инвертирования)
        messages.insert(newMessage, at: 0)
        
        // Обновляем таблицу
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
        tableView.endUpdates()
        
        // Прокручиваем к новому сообщению
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
        
        // Очищаем поле ввода
        messageTextView.text = ""
        updateTextViewHeight()
        
        // Имитация "typing..." у собеседника
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showTypingIndicator(true)
            
            // Скрываем индикатор через 2 секунды
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.showTypingIndicator(false)
            }
        }
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let bottomInset = keyboardSize.height - view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: 0.3) {
            self.inputContainerView.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-bottomInset)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.inputContainerView.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateTextViewHeight() {
        let fixedWidth = messageTextView.frame.size.width
        let newSize = messageTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let newHeight = min(max(newSize.height, 36), 100)
        
        messageTextView.snp.updateConstraints { make in
            make.height.greaterThanOrEqualTo(newHeight).priority(.high)
        }
        
        // Обновляем высоту всего контейнера
        let containerHeight = newHeight + 20 // 10 сверху и 10 снизу
        
        inputContainerView.snp.updateConstraints { make in
            make.height.greaterThanOrEqualTo(containerHeight)
        }
        
        view.layoutIfNeeded()
    }
    
    func showTypingIndicator(_ isTyping: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.typingIndicatorView.isHidden = !isTyping
            }
        }
    }
}

// MARK: - UITableView DataSource & Delegate

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        if message.sender_id == currentUserId {
            // Исходящие сообщения
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingMessageCell", for: indexPath) as! OutgoingMessageCell
            cell.transform = CGAffineTransform(scaleX: 1, y: -1) // Инвертируем ячейку обратно
            cell.configure(with: message)
            return cell
        } else {
            // Входящие сообщения
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingMessageCell", for: indexPath) as! IncomingMessageCell
            cell.transform = CGAffineTransform(scaleX: 1, y: -1) // Инвертируем ячейку обратно
            cell.configure(with: message)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - UITextViewDelegate

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateTextViewHeight()
    }
}

// MARK: - Message Cells

class BaseMessageCell: UITableViewCell {
    
    let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .systemGray
        return label
    }()
    
    let readStatusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with message: ChatMessage) {
        messageLabel.text = message.content
        timeLabel.text = message.formattedTime
        
        if message.is_read {
            readStatusImageView.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            readStatusImageView.image = UIImage(systemName: "checkmark.circle")
        }
    }
}

class OutgoingMessageCell: BaseMessageCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        bubbleView.backgroundColor = .systemGreen.withAlphaComponent(0.8)
        messageLabel.textColor = .white
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(timeLabel)
        contentView.addSubview(readStatusImageView)
        
        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.trailing.equalToSuperview().offset(-16)
            make.width.lessThanOrEqualTo(250)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-6)
            make.top.equalTo(messageLabel.snp.bottom).offset(4)
        }
        
        readStatusImageView.snp.makeConstraints { make in
            make.leading.equalTo(bubbleView.snp.leading).offset(-16)
            make.bottom.equalTo(bubbleView)
            make.width.height.equalTo(12)
        }
    }
}

class IncomingMessageCell: BaseMessageCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        bubbleView.backgroundColor = .systemGray5
        messageLabel.textColor = .label
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(timeLabel)
        
        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.leading.equalToSuperview().offset(16)
            make.width.lessThanOrEqualTo(250)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-6)
            make.top.equalTo(messageLabel.snp.bottom).offset(4)
        }
    }
    
    override func configure(with message: ChatMessage) {
        super.configure(with: message)
        readStatusImageView.isHidden = true
    }
}
