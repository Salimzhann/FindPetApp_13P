// Путь: SDUPM/Modules/Chat/ChatListViewController.swift

import UIKit
import SnapKit

protocol ChatListViewProtocol: AnyObject {
    func setChats(_ chats: [Chat])
    func showLoading()
    func hideLoading()
    func showError(message: String)
}

class ChatListViewController: UIViewController, ChatListViewProtocol {
    
    private let presenter = ChatListPresenter()
    private var chats: [Chat] = []
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChatListCell.self, forCellReuseIdentifier: "ChatListCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .systemGreen
        return indicator
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "У вас пока нет активных чатов"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bubble.left.and.bubble.right")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupNavigation()
        setupRefreshControl()
        
        presenter.view = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchChats()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Чаты"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyStateView)
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        emptyStateImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyStateImageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(createChatTapped)
        )
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Обновление...")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Actions
    
    @objc private func createChatTapped() {
        let createChatVC = CreateChatViewController()
        createChatVC.delegate = self
        let navController = UINavigationController(rootViewController: createChatVC)
        present(navController, animated: true)
    }
    
    @objc private func refreshData() {
        fetchChats()
    }
    
    private func fetchChats() {
        presenter.fetchChats()
    }
    
    private func updateEmptyState() {
        emptyStateView.isHidden = !chats.isEmpty
        tableView.isHidden = chats.isEmpty
    }
    
    // MARK: - ChatListViewProtocol
    
    func setChats(_ chats: [Chat]) {
        self.chats = chats
        tableView.reloadData()
        updateEmptyState()
        refreshControl.endRefreshing()
    }
    
    func showLoading() {
        if !refreshControl.isRefreshing {
            activityIndicator.startAnimating()
            tableView.isHidden = true
            emptyStateView.isHidden = true
        }
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
        updateEmptyState()
        refreshControl.endRefreshing()
    }
    
    func showError(message: String) {
        refreshControl.endRefreshing()
        
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableView DataSource & Delegate

extension ChatListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
        cell.configure(with: chats[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chatVC = ChatViewController(chat: chats[indexPath.row])
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - CreateChatDelegate

extension ChatListViewController: CreateChatDelegate {
    func didCreateChat(_ chat: Chat) {
        presenter.fetchChats() // Refresh chat list to include the new chat
    }
}

// MARK: - Chat List Cell

class ChatListCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 25
        imageView.image = UIImage(systemName: "pawprint.circle.fill")
        imageView.tintColor = .systemGray3
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let petNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
        return label
    }()
    
    private let unreadBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 10
        view.isHidden = true
        return view
    }()
    
    private let unreadCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(containerView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(userNameLabel)
        containerView.addSubview(petNameLabel)
        containerView.addSubview(lastMessageLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(unreadBadge)
        unreadBadge.addSubview(unreadCountLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.equalTo(timeLabel.snp.leading).offset(-8)
        }
        
        petNameLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(2)
            make.leading.equalTo(userNameLabel)
            make.trailing.equalTo(userNameLabel)
        }
        
        lastMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(petNameLabel.snp.bottom).offset(4)
            make.leading.equalTo(userNameLabel)
            make.trailing.equalTo(unreadBadge.snp.leading).offset(-8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel)
            make.trailing.equalToSuperview()
            make.width.equalTo(60)
        }
        
        unreadBadge.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(lastMessageLabel)
            make.width.height.equalTo(20)
        }
        
        unreadCountLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with chat: Chat) {
        userNameLabel.text = chat.otherUserName
        petNameLabel.text = "Питомец: \(chat.petName)"
        
        if let lastMessage = chat.last_message {
            lastMessageLabel.text = lastMessage.content
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            if let date = dateFormatter.date(from: lastMessage.created_at) {
                // Проверяем, сегодня ли это было
                let calendar = Calendar.current
                if calendar.isDateInToday(date) {
                    dateFormatter.dateFormat = "HH:mm"
                } else {
                    dateFormatter.dateFormat = "dd.MM"
                }
                timeLabel.text = dateFormatter.string(from: date)
            } else {
                timeLabel.text = ""
            }
        } else {
            lastMessageLabel.text = "Нет сообщений"
            timeLabel.text = ""
        }
        
        if chat.unread_count > 0 {
            unreadBadge.isHidden = false
            unreadCountLabel.text = chat.unread_count > 99 ? "99+" : "\(chat.unread_count)"
        } else {
            unreadBadge.isHidden = true
        }
        
        // Добавим разные иконки в зависимости от типа питомца - это можно улучшить при наличии API
        if chat.petName.lowercased().contains("кот") || chat.petName.lowercased().contains("кош") {
            avatarImageView.image = UIImage(systemName: "cat.fill")
        } else if chat.petName.lowercased().contains("соба") {
            avatarImageView.image = UIImage(systemName: "dog.fill")
        } else {
            avatarImageView.image = UIImage(systemName: "pawprint.circle.fill")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userNameLabel.text = nil
        petNameLabel.text = nil
        lastMessageLabel.text = nil
        timeLabel.text = nil
        unreadBadge.isHidden = true
        unreadCountLabel.text = nil
    }
}
