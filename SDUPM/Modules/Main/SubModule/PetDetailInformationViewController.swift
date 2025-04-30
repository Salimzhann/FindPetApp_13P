// Путь: SDUPM/Modules/Main/SubModule/MainPetDetailViewController.swift

import UIKit
import SnapKit

class MainPetDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let petId: Int
    private let presenter = PetDetailPresenter()
    private var pet: Pet?
    private var petImages: [UIImage] = []
    
    // MARK: - UI Components
    
    // Коллекция для фотографий питомца
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(PetPhotoCell.self, forCellWithReuseIdentifier: PetPhotoCell.identifier)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .systemBackground
        return cv
    }()
    
    // Индикатор страниц
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.pageIndicatorTintColor = .lightGray
        pc.currentPageIndicatorTintColor = .systemGreen
        return pc
    }()
    
    // Основная информация
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    // Информация о питомце
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    // Кнопка связи
    private let contactButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Связаться с владельцем", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 12
        return button
    }()
    
    // Индикатор загрузки
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .systemGreen
        return indicator
    }()
    
    // MARK: - Initializers
    
    init(petId: Int) {
        self.petId = petId
        super.init(nibName: nil, bundle: nil)
    }
    
    init(pet: Pet) {
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
        setupUI()
        setupPresenter()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if pet != nil {
            populateUI()
        } else {
            loadPetData()
        }
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Информация о питомце"
        navigationController?.navigationBar.tintColor = .systemGreen
        
        // Добавляем индикатор загрузки
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // Настраиваем коллекцию изображений
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(250)
        }
        
        // Добавляем индикатор страниц
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        // Добавляем имя питомца
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(20)
        }
        
        // Добавляем статус
        view.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(20)
        }
        
        // Добавляем стек информации
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Добавляем кнопку
        view.addSubview(contactButton)
        contactButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        contactButton.addTarget(self, action: #selector(contactButtonTapped), for: .touchUpInside)
    }
    
    private func setupPresenter() {
        presenter.view = self
    }
    
    // MARK: - Data Loading
    
    private func loadPetData() {
        activityIndicator.startAnimating()
        collectionView.isHidden = true
        presenter.fetchPetDetails(id: petId)
    }
    
    private func populateUI() {
        guard let pet = self.pet else { return }
        
        // Основная информация
        nameLabel.text = pet.name
        
        // Статус (текстом)
        configureStatus(for: pet.status)
        
        // Загрузка фотографий
        loadPetImages(from: pet.photos)
        
        // Очистка существующих элементов
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Добавление информации в стек
        addInfoItems(for: pet)
        
        // Показываем контент
        activityIndicator.stopAnimating()
        collectionView.isHidden = false
    }
    
    private func configureStatus(for status: String) {
        switch status.lowercased() {
        case "lost":
            statusLabel.text = "Статус: Потерян"
            statusLabel.textColor = .systemRed
            contactButton.backgroundColor = .systemRed
        case "found":
            statusLabel.text = "Статус: Найден"
            statusLabel.textColor = .systemBlue
            contactButton.backgroundColor = .systemBlue
        case "home":
            statusLabel.text = "Статус: Дома"
            statusLabel.textColor = .systemGreen
            contactButton.backgroundColor = .systemGreen
        default:
            statusLabel.text = "Статус: \(status)"
            statusLabel.textColor = .systemGray
            contactButton.backgroundColor = .systemGray
        }
    }
    
    private func loadPetImages(from photos: [PetPhoto]) {
        petImages.removeAll()
        pageControl.numberOfPages = photos.count
        
        // Если нет фотографий, добавляем заглушку
        if photos.isEmpty {
            petImages.append(UIImage(systemName: "pawprint.fill")!)
            collectionView.reloadData()
            return
        }
        
        // Создаем группу для ожидания загрузки всех изображений
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
            self?.collectionView.reloadData()
        }
    }
    
    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(UIImage(systemName: "pawprint.fill"))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(UIImage(systemName: "pawprint.fill"))
                }
            }
        }.resume()
    }
    
    private func addInfoItems(for pet: Pet) {
        // Строим массив деталей для отображения
        var details: [(title: String, value: String)] = []
        
        // Добавляем вид
        details.append(("Вид", pet.species.capitalized))
        
        // Добавляем породу если доступна
        if let breed = pet.breed, !breed.isEmpty {
            details.append(("Порода", breed))
        }
        
        // Добавляем возраст если доступен
        if let age = pet.age {
            let yearWord = age == 1 ? "год" : (age < 5 ? "года" : "лет")
            details.append(("Возраст", "\(age) \(yearWord)"))
        }
        
        // Добавляем цвет если доступен
        if !pet.color.isEmpty {
            details.append(("Цвет", pet.color))
        }
        
        // Добавляем пол если доступен
        if let gender = pet.gender, !gender.isEmpty {
            let displayGender = gender.lowercased() == "male" ? "Мужской" :
                              (gender.lowercased() == "female" ? "Женский" : gender.capitalized)
            details.append(("Пол", displayGender))
        }
        
        // Добавляем отличительные особенности если доступны
        if let features = pet.distinctive_features, !features.isEmpty {
            details.append(("Особые приметы", features))
        }
        
        // Добавляем местоположение если доступно
        if let location = pet.last_seen_location, !location.isEmpty {
            details.append(("Последнее местоположение", location))
        }
        
        // Добавляем дату если доступна
        if let lostDate = pet.lost_date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            if let date = dateFormatter.date(from: lostDate) {
                dateFormatter.dateFormat = "dd MMMM yyyy"
                dateFormatter.locale = Locale(identifier: "ru_RU")
                let formattedDate = dateFormatter.string(from: date)
                details.append(("Дата пропажи", formattedDate))
            }
        }
        
        // Добавляем все элементы деталей в стек
        for (index, detail) in details.enumerated() {
            // Добавляем разделитель перед каждым элементом (кроме первого)
            if index > 0 {
                stackView.addArrangedSubview(makeSeparator())
            }
            
            // Добавляем метку с деталями
            let label = UILabel()
            label.text = "\(detail.title): \(detail.value)"
            label.font = .systemFont(ofSize: 16)
            label.numberOfLines = 0
            stackView.addArrangedSubview(label)
        }
        
        // Если есть описание, добавляем его
        if let description = pet.distinctive_features, !description.isEmpty {
            stackView.addArrangedSubview(makeSeparator())
            
            let descriptionLabel = UILabel()
            descriptionLabel.text = description
            descriptionLabel.font = .systemFont(ofSize: 16)
            descriptionLabel.textAlignment = .left
            descriptionLabel.numberOfLines = 0
            stackView.addArrangedSubview(descriptionLabel)
        }
    }
    
    private func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        return view
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
                    // Переходим к просмотру чата
                    let chatVC = ChatViewController(chat: chat)
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
    
    private func startChat(with pet: Pet) {
        let chatCreator = CreateChatViewController()
        chatCreator.delegate = self
        chatCreator.setupWithPet(petId: pet.id, userId: pet.owner_id)
        
        let navController = UINavigationController(rootViewController: chatCreator)
        present(navController, animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension MainPetDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(1, petImages.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PetPhotoCell.identifier, for: indexPath) as! PetPhotoCell
        
        if petImages.count > indexPath.row {
            cell.configure(with: petImages[indexPath.row])
        } else {
            cell.configure(with: UIImage(systemName: "pawprint.fill")!)
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        if pageIndex.isFinite {
            pageControl.currentPage = Int(pageIndex)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

// MARK: - PetPhotoCell

class PetPhotoCell: UICollectionViewCell {
    static let identifier = "PetPhotoCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with image: UIImage) {
        imageView.image = image
    }
}

// MARK: - PetDetailView Protocol
protocol PetDetailViewProtocol: AnyObject {
    func displayPetDetails(_ pet: Pet)
    func showError(_ message: String)
}

extension MainPetDetailViewController: PetDetailViewProtocol {
    func displayPetDetails(_ pet: Pet) {
        self.pet = pet
        DispatchQueue.main.async { [weak self] in
            self?.populateUI()
        }
    }
    
    func showError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            
            // Показываем ошибку пользователю
            let alertController = UIAlertController(
                title: "Ошибка",
                message: message,
                preferredStyle: .alert
            )
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }))
            
            self?.present(alertController, animated: true)
        }
    }
}

// MARK: - Create Chat Delegate
extension MainPetDetailViewController: CreateChatDelegate {
    func didCreateChat(_ chat: Chat) {
        dismiss(animated: true) {
            let chatVC = ChatViewController(chat: chat)
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}
