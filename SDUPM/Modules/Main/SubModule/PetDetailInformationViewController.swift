// Путь: SDUPM/Modules/Main/SubModule/MainPetDetailViewController.swift

import UIKit
import SnapKit

class MainPetDetailViewController: UIViewController {
    
    private let petId: Int
    private let presenter = PetDetailPresenter()
    private var pet: Pet?
    
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
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .systemGreen
        pageControl.pageIndicatorTintColor = .systemGray3
        return pageControl
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let statusView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.text = "LOST"
        return label
    }()
    
    private let infoStackView: UIStackView = {
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
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initializer
    
    init(petId: Int) {
        self.petId = petId
        print("MainPetDetailViewController: Initialized with petId \(petId)")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MainPetDetailViewController: viewDidLoad()")
        setupView()
        configureCollectionView()
        setupPresenter()
        loadPetData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("MainPetDetailViewController: viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("MainPetDetailViewController: viewDidAppear")
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        title = "Pet Details"
        view.backgroundColor = .systemBackground
        
        // Add activity indicator
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // Main layout
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
    }
    
    private func configureCollectionView() {
        photoCollectionView.register(MainPhotoViewCell.self, forCellWithReuseIdentifier: "MainPhotoViewCell")
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
    }
    
    private func setupPresenter() {
        presenter.view = self
        print("MainPetDetailViewController: Set self as presenter.view")
    }
    
    private func loadPetData() {
        print("MainPetDetailViewController: loadPetData() with id \(petId)")
        activityIndicator.startAnimating()
        scrollView.isHidden = true
        presenter.fetchPetDetails(id: petId)
    }
    
    private func populateData() {
        guard let pet = self.pet else {
            print("MainPetDetailViewController: populateData() - pet is nil!")
            return
        }
        
        print("MainPetDetailViewController: populateData() with pet \(pet.name), id \(pet.id)")
        
        nameLabel.text = pet.name
        
        // Set status
        statusLabel.text = pet.status.uppercased()
        switch pet.status.lowercased() {
        case "lost":
            statusView.backgroundColor = .systemRed
        case "found":
            statusView.backgroundColor = .systemBlue
        default:
            statusView.backgroundColor = .systemGreen
        }
        
        // Clear existing info views
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add all info views
        var infoViews = [UIView]()
        
        infoViews.append(createInfoView(title: "SPECIES", detail: pet.species.capitalized))
        
        if let breed = pet.breed, !breed.isEmpty {
            infoViews.append(createInfoView(title: "BREED", detail: breed))
        }
        
        if let age = pet.age {
            infoViews.append(createInfoView(title: "AGE", detail: "\(age) year\(age > 1 ? "s" : "")"))
        }
        
        if !pet.color.isEmpty {
            infoViews.append(createInfoView(title: "COLOR", detail: pet.color))
        }
        
        if let gender = pet.gender, !gender.isEmpty {
            infoViews.append(createInfoView(title: "GENDER", detail: gender.capitalized))
        }
        
        if let features = pet.distinctive_features, !features.isEmpty {
            infoViews.append(createInfoView(title: "DISTINCTIVE FEATURES", detail: features))
        }
        
        // Add location if available
        if let location = pet.last_seen_location, !location.isEmpty {
            infoViews.append(createInfoView(title: "LAST SEEN", detail: location))
        }
        
        // Add date if available
        if let lostDate = pet.lost_date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            if let date = dateFormatter.date(from: lostDate) {
                dateFormatter.dateFormat = "MMM d, yyyy"
                let formattedDate = dateFormatter.string(from: date)
                infoViews.append(createInfoView(title: "LOST DATE", detail: formattedDate))
            }
        }
        
        // Add all info views to stack
        infoViews.forEach { infoStackView.addArrangedSubview($0) }
        
        // Configure page control
        pageControl.numberOfPages = pet.photos.count
        pageControl.currentPage = 0
        
        // Reload collection view
        photoCollectionView.reloadData()
        
        print("MainPetDetailViewController: Content prepared, showing UI")
        
        // Show the content
        activityIndicator.stopAnimating()
        scrollView.isHidden = false
    }
    
    private func createInfoView(title: String, detail: String) -> UIView {
        let containerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .systemGray
        
        let detailLabel = UILabel()
        detailLabel.text = detail
        detailLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
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
        // Create a chat with the pet owner
        let chatCreator = CreateChatViewController()
        chatCreator.delegate = self
        
        // Pre-fill the fields with the pet and owner information
        chatCreator.setupWithPet(petId: pet.id, userId: pet.owner_id)
        
        let navController = UINavigationController(rootViewController: chatCreator)
        present(navController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension MainPetDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pet?.photos.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainPhotoViewCell", for: indexPath) as! MainPhotoViewCell
        if let pet = self.pet, indexPath.item < pet.photos.count {
            let photo = pet.photos[indexPath.item]
            cell.configure(with: photo.photo_url)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == photoCollectionView {
            let pageWidth = scrollView.frame.width
            let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
            pageControl.currentPage = currentPage
        }
    }
}

// MARK: - Photo View Cell
class MainPhotoViewCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func configure(with urlString: String) {
        activityIndicator.startAnimating()
        
        guard let url = URL(string: urlString) else {
            activityIndicator.stopAnimating()
            imageView.image = UIImage(systemName: "pawprint.fill")
            imageView.tintColor = .systemGray3
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                if let data = data, let image = UIImage(data: data) {
                    self?.imageView.image = image
                } else {
                    self?.imageView.image = UIImage(systemName: "pawprint.fill")
                    self?.imageView.tintColor = .systemGray3
                }
            }
        }.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}

// MARK: - PetDetailView Protocol
protocol PetDetailViewProtocol: AnyObject {
    func displayPetDetails(_ pet: Pet)
    func showError(_ message: String)
}

extension MainPetDetailViewController: PetDetailViewProtocol {
    func displayPetDetails(_ pet: Pet) {
        print("MainPetDetailViewController: displayPetDetails called with pet \(pet.name), id \(pet.id)")
        self.pet = pet
        DispatchQueue.main.async { [weak self] in
            self?.populateData()
        }
    }
    
    func showError(_ message: String) {
        print("MainPetDetailViewController: showError called with message: \(message)")
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
}

// MARK: - Create Chat Delegate
extension MainPetDetailViewController: CreateChatDelegate {
    func didCreateChat(_ chat: Chat) {
        dismiss(animated: true) {
            // Navigate to the chat
            let chatVC = ChatViewController(chat: chat)
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}
