import UIKit
import SnapKit

// Renamed to avoid conflict with existing class
class LostPetDetailViewController: UIViewController {
    
    // MARK: - Properties
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
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(LostPetPhotoCell.self, forCellWithReuseIdentifier: "LostPetPhotoCell")
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .systemBackground
        return cv
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
        label.textColor = .label
        return label
    }()
    
    private let statusView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        return stackView
    }()
    
    private let contactButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Contact Owner", for: .normal)
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
    
    // MARK: - Initializers
    
    // Renamed parameter to clearly distinguish this initializer
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
        
        // Contact Button
        contentView.addSubview(contactButton)
        contactButton.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(30)
        }
        
        contactButton.addTarget(self, action: #selector(contactButtonTapped), for: .touchUpInside)
        
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
        configureStatus(for: pet.status)
        loadPetImages(from: pet.photos)
        
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        addInfoItems(for: pet)
        
        pageControl.numberOfPages = pet.photos.count > 0 ? pet.photos.count : 1
        pageControl.currentPage = 0
    }
    
    private func configureStatus(for status: String) {
        statusLabel.text = status.uppercased()
        
        switch status.lowercased() {
        case "lost":
            statusView.backgroundColor = .systemRed
            contactButton.backgroundColor = .systemRed
        case "found":
            statusView.backgroundColor = .systemBlue
            contactButton.backgroundColor = .systemBlue
        case "home":
            statusView.backgroundColor = .systemGreen
            contactButton.backgroundColor = .systemGreen
        default:
            statusView.backgroundColor = .systemGray
            contactButton.backgroundColor = .systemGray
        }
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
        
        let alertController = UIAlertController(
            title: "Contact Owner",
            message: "Would you like to contact the owner of \(pet.name)?",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Start Chat", style: .default, handler: { [weak self] _ in
            self?.startChat(with: pet)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    private func startChat(with pet: Pet) {
        let chatCreator = CreateChatViewController()
        chatCreator.delegate = self
        chatCreator.setupWithPet(petId: pet.id, userId: pet.owner_id)
        
        let navController = UINavigationController(rootViewController: chatCreator)
        present(navController, animated: true)
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

// MARK: - Create Chat Delegate

extension LostPetDetailViewController: CreateChatDelegate {
    func didCreateChat(_ chat: Chat) {
        dismiss(animated: true) {
            let chatVC = ChatViewController(chat: chat)
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
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
