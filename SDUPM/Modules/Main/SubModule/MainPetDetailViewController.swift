import UIKit
import SnapKit

class LostPetDetailViewController: UIViewController {
    
    private let petId: Int
    private let provider = NetworkServiceProvider()
    private var pet: Pet?
    private var petImages: [UIImage] = []
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    private let contentView = UIView()
    private let photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(LostPetPhotoCell.self, forCellWithReuseIdentifier: "LostPetPhotoCell")
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.pageIndicatorTintColor = .systemGray3
        pc.currentPageIndicatorTintColor = .systemGreen
        return pc
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let statusView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        return stackView
    }()
    private let phoneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Call", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        return button
    }()
    
    private let contactButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Chat", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        return button
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .systemGreen
        return indicator
    }()
    
    private var phoneNumber: String?
    
    // MARK: - Initializers
    
    init(withPetId id: Int) {
        self.petId = id
        super.init(nibName: nil, bundle: nil)
    }
    
    init(withPet pet: Pet) {
        self.petId = pet.id
        self.pet = pet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureCollectionView()
        
        if pet != nil {
            populateUI()
        } else {
            loadPetData()
        }
    }
    
    // MARK: - UI Setup
    
    private func setupView() {
        title = "Pet Details"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .systemGreen
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }
        
        // Photo Collection View
        contentView.addSubview(photoCollectionView)
        photoCollectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(300)
        }
        
        // Page Control
        contentView.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(photoCollectionView.snp.bottom).offset(8)
        }
        
        // Name and Status
        let headerView = UIView()
        contentView.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        headerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }
        
        headerView.addSubview(statusView)
        statusView.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.trailing.equalToSuperview()
            make.height.equalTo(24)
            make.width.greaterThanOrEqualTo(60)
        }
        
        statusView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        // Info Stack View
        contentView.addSubview(infoStackView)
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(phoneButton)
        phoneButton.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(30)
            make.trailing.equalToSuperview().inset(20)
            make.leading.equalTo(contentView.snp.centerX).offset(5)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(30)
        }
        
        // Contact Button
        contentView.addSubview(contactButton)
        contactButton.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalTo(contentView.snp.centerX).offset(-5)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(30)
        }
        
        contactButton.addTarget(self, action: #selector(contactButtonTapped), for: .touchUpInside)
        phoneButton.addTarget(self, action: #selector(phoneButtonTapped), for: .touchUpInside)
        
        // Activity Indicator
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func configureCollectionView() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
    }
    
    // MARK: - Data Loading
    
    private func loadPetData() {
        activityIndicator.startAnimating()
        
        provider.getPetDetails(petId: petId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let pet):
                    self.pet = pet
                    self.populateUI()
                case .failure(let error):
                    self.showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func populateUI() {
        guard let pet = self.pet else { return }
        
        nameLabel.text = pet.name
        loadPetImages(from: pet.photos)
        
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        addInfoItems(for: pet)
        
        pageControl.numberOfPages = pet.photos.count > 0 ? pet.photos.count : 1
        pageControl.currentPage = 0
    }
    
    private func loadPetImages(from photos: [PetPhoto]) {
        petImages.removeAll()
        
        if photos.isEmpty {
            if let placeholderImage = UIImage(systemName: "pawprint.fill") {
                petImages = [placeholderImage]
                DispatchQueue.main.async {
                    self.photoCollectionView.reloadData()
                }
            }
            return
        }
        
        let group = DispatchGroup()
        
        for photo in photos {
            group.enter()
            loadImage(from: photo.photo_url) { [weak self] image in
                if let image = image {
                    self?.petImages.append(image)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            if self.petImages.isEmpty, let placeholderImage = UIImage(systemName: "pawprint.fill") {
                self.petImages = [placeholderImage]
            }
            self.photoCollectionView.reloadData()
        }
    }
    
    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(UIImage(systemName: "pawprint.fill"))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(UIImage(systemName: "pawprint.fill"))
            }
        }.resume()
    }
    
    private func addInfoItems(for pet: Pet) {
        var details: [(title: String, value: String)] = []
        
        details.append(("SPECIES", pet.species.capitalized))
        
        if let breed = pet.breed, !breed.isEmpty {
            details.append(("BREED", breed))
        }
        
        if let age = pet.age {
            let yearWord = age == 1 ? "year" : "years"
            details.append(("AGE", "\(age) \(yearWord)"))
        }
        
        if !pet.color.isEmpty {
            details.append(("COLOR", pet.color))
        }
        
        if let gender = pet.gender, !gender.isEmpty {
            details.append(("GENDER", gender.capitalized))
        }
        
        if let features = pet.distinctive_features, !features.isEmpty {
            details.append(("DISTINCTIVE FEATURES", features))
        }
        
        if let location = pet.last_seen_location, !location.isEmpty {
            details.append(("LAST SEEN LOCATION", location))
        }
        
        self.phoneNumber = pet.owner_phone
        
        if let lostDate = pet.lost_date, !lostDate.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = dateFormatter.date(from: lostDate) {
                dateFormatter.dateFormat = "MMM d, yyyy"
                let formattedDate = dateFormatter.string(from: date)
                details.append(("LOST DATE", formattedDate))
            }
        }
        
        for (index, detail) in details.enumerated() {
            if index > 0 {
                infoStackView.addArrangedSubview(makeSeparator())
            }
            
            infoStackView.addArrangedSubview(createInfoView(title: detail.title, detail: detail.value))
        }
    }
    
    private func createInfoView(title: String, detail: String) -> UIView {
        let containerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        
        let detailLabel = UILabel()
        detailLabel.text = detail
        detailLabel.font = .systemFont(ofSize: 16, weight: .regular)
        detailLabel.textColor = .label
        detailLabel.numberOfLines = 0
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(detailLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        return containerView
    }
    
    private func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        return view
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func contactButtonTapped() {
        guard let pet = self.pet else { return }
        
        // Показываем индикатор загрузки
        activityIndicator.startAnimating()
        contactButton.setTitle("", for: .normal)
        contactButton.isEnabled = false
        
        // Создаем реальный чат с владельцем питомца
        let provider = NetworkServiceProvider()
        provider.createChat(petId: pet.id, userId: pet.owner_id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Скрываем индикатор загрузки
                self.activityIndicator.stopAnimating()
                self.contactButton.setTitle("Chat", for: .normal)
                self.contactButton.isEnabled = true
                
                switch result {
                case .success(let chat):
                    // Переходим к просмотру чата, не показываем инфо о питомце,
                    // так как мы перешли из экрана деталей питомца
                    let chatVC = ChatViewController(chat: chat, showPetInfo: false)
                    self.navigationController?.pushViewController(chatVC, animated: true)
                    
                case .failure(let error):
                    // Показываем ошибку
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to create chat: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc private func phoneButtonTapped() {
        guard let phoneNumber = phoneNumber?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let phoneURL = URL(string: "tel://\(phoneNumber)"),
              UIApplication.shared.canOpenURL(phoneURL) else {
            return
        }

        UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
    }

    
    private func showMessageInput(for pet: Pet) {
        let alertController = UIAlertController(
            title: "Send Message",
            message: "Enter your message to the owner of \(pet.name)",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Your message"
        }
        
        alertController.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak self] _ in
            guard let message = alertController.textFields?.first?.text, !message.isEmpty else {
                let errorAlert = UIAlertController(title: "Error", message: "Please enter a message", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(errorAlert, animated: true)
                return
            }
            
            self?.sendFirstMessage(to: pet, message: message)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }

    private func sendFirstMessage(to pet: Pet, message: String) {
        let provider = NetworkServiceProvider()
        
        // Show loading indicator
        let loadingAlert = UIAlertController(title: nil, message: "Sending message...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true)
        
        provider.createChatWithFirstMessage(petId: pet.id, message: message) { [weak self] result in
            DispatchQueue.main.async {
                self?.dismiss(animated: true) {
                    switch result {
                    case .success(let chat):
                        // Navigate to chat view with the new chat
                        let chatVC = ChatViewController(chat: chat)
                        self?.navigationController?.pushViewController(chatVC, animated: true)
                    case .failure(let error):
                        let errorAlert = UIAlertController(title: "Error", message: "Failed to send message: \(error.localizedDescription)", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(errorAlert, animated: true)
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension LostPetDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(1, petImages.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LostPetPhotoCell", for: indexPath) as! LostPetPhotoCell
        
        if petImages.count > indexPath.row {
            cell.configure(with: petImages[indexPath.row])
        } else {
            cell.configure(with: UIImage(systemName: "pawprint.fill")!)
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == photoCollectionView {
            let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
            if pageIndex.isFinite {
                pageControl.currentPage = Int(pageIndex)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

// MARK: - Pet Photo Cell
// Renamed to avoid conflict

class LostPetPhotoCell: UICollectionViewCell {
    static let identifier = "LostPetPhotoCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with image: UIImage) {
        activityIndicator.stopAnimating()
        imageView.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        activityIndicator.startAnimating()
    }
}
