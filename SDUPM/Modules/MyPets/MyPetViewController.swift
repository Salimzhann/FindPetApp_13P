import UIKit
import SnapKit

protocol IMyPetViewController: AnyObject {
    var myPetsArray: [MyPetModel] { get set }
    
    func showLoading()
    func hideLoading()
    func showError(message: String)
}

class MyPetViewController: UIViewController, IMyPetViewController {
    
    private let presenter: IMyPetPresenter = MyPetPresenter()
    private let editPresenter = EditPetViewPresenter()
    
    var myPetsArray: [MyPetModel] = [] {
        didSet {
            // Убедимся, что обновляем UI в основном потоке
            if Thread.isMainThread {
                filterPetsAndUpdateUI()
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.filterPetsAndUpdateUI()
                }
            }
        }
    }
    
    // Фильтрованный массив питомцев для отображения
    private var filteredPets: [MyPetModel] = []
    
    // Текущий режим отображения
    private enum DisplayMode {
        case myPets
        case foundPets
    }
    
    private var currentDisplayMode: DisplayMode = .myPets
    
    // MARK: - UI Components
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["My Pets", "Found Pets"])
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .systemGreen
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        return control
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "pawprint.circle"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray3
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No pets found"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }()
    
    private let emptyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Add your first pet by tapping the button below"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Pet", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return button
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .systemBackground
        cv.register(MyPetCell.self, forCellWithReuseIdentifier: MyPetCell.identifier)
        return cv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .systemGreen
        return indicator
    }()
    
    private let errorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        view.isHidden = true
        return view
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Try Again", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return button
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        
        (presenter as? MyPetPresenter)?.view = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        fetchData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        title = "My Pets"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        // Добавляем сегментированный контрол
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        
        // Add empty state view
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyImageView)
        emptyStateView.addSubview(emptyLabel)
        emptyStateView.addSubview(emptyDescriptionLabel)
        
        emptyStateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        emptyImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyImageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        emptyDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        // Add collection view
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(80)
        }
        
        // Add activity indicator
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // Add error view
        view.addSubview(errorView)
        errorView.addSubview(errorLabel)
        errorView.addSubview(refreshButton)
        
        errorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }
        
        refreshButton.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
        }
        
        // Add button
        view.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addPetTapped), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    // Метод для фильтрации питомцев в зависимости от выбранного режима
    private func filterPetsAndUpdateUI() {
        switch currentDisplayMode {
        case .myPets:
            // Отображаем все питомцы, кроме тех, у которых статус "found"
            filteredPets = myPetsArray.filter { $0.status != "found" }
            emptyDescriptionLabel.text = "Add your first pet by tapping the button below"
            addButton.isHidden = false
        case .foundPets:
            // Отображаем только питомцы со статусом "found"
            filteredPets = myPetsArray.filter { $0.status == "found" }
            emptyDescriptionLabel.text = "No found pets to display"
            addButton.isHidden = true
        }
        
        updateEmptyState()
        collectionView.reloadData()
    }
    
    private func updateEmptyState() {
        // Thread-safe check for UI updates
        if Thread.isMainThread {
            emptyStateView.isHidden = !filteredPets.isEmpty
            collectionView.isHidden = filteredPets.isEmpty
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.emptyStateView.isHidden = !self.filteredPets.isEmpty
                self.collectionView.isHidden = self.filteredPets.isEmpty
            }
        }
    }
    
    // MARK: - Data Loading
    
    private func fetchData() {
        presenter.fetchUserPets()
    }
    
    // MARK: - IMyPetViewController Methods (Thread-Safe Implementations)
    
    func showLoading() {
        if Thread.isMainThread {
            activityIndicator.startAnimating()
            errorView.isHidden = true
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.startAnimating()
                self?.errorView.isHidden = true
            }
        }
    }
    
    func hideLoading() {
        if Thread.isMainThread {
            activityIndicator.stopAnimating()
            updateEmptyState()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.updateEmptyState()
            }
        }
    }
    
    func showError(message: String) {
        if Thread.isMainThread {
            errorLabel.text = message
            errorView.isHidden = false
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.errorLabel.text = message
                self?.errorView.isHidden = false
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func addPetTapped() {
        presenter.createPet(from: self)
    }
    
    @objc private func refreshTapped() {
        if Thread.isMainThread {
            errorView.isHidden = true
            fetchData()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.errorView.isHidden = true
                self?.fetchData()
            }
        }
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        currentDisplayMode = sender.selectedSegmentIndex == 0 ? .myPets : .foundPets
        filterPetsAndUpdateUI()
    }
    
    // MARK: - Show Edit View
    
    private func showEditPetView(for pet: MyPetModel) {
        let editVC = EditPetViewController(pet: pet)
        editVC.delegate = self
        
        // Если питомец имеет статус "found", блокируем возможность редактирования
        if pet.status == "found" {
            editVC.disableEditing = true
        }
        
        present(editVC, animated: true)
    }
    
    // MARK: - Confirm and Delete Pet
    
    private func confirmAndDeletePet(_ pet: MyPetModel) {
        let alert = UIAlertController(
            title: "Delete Pet",
            message: "Are you sure you want to delete \(pet.name)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            self.showLoading()
            self.editPresenter.deletePet(petId: pet.id) { result in
                DispatchQueue.main.async {
                    self.hideLoading()
                    
                    switch result {
                    case .success:
                        // Удаляем питомца из массива
                        if let index = self.myPetsArray.firstIndex(where: { $0.id == pet.id }) {
                            self.myPetsArray.remove(at: index)
                            // Показываем уведомление об успешном удалении
                            self.showSuccessToast(message: "Pet successfully deleted")
                        }
                    case .failure(let error):
                        self.showError(message: "Failed to delete pet: \(error.localizedDescription)")
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Status Update Action
    
    private func showStatusUpdateOptions(for pet: MyPetModel) {
        let alertController = UIAlertController(
            title: "Update Status",
            message: "Select new status for \(pet.name)",
            preferredStyle: .actionSheet
        )
        
        let statusOptions: [(title: String, value: String)] = [
            ("At Home", "home"),
            ("Lost", "lost"),
            ("Found", "found")
        ]
        
        for option in statusOptions {
            // Не показываем текущий статус
            if option.value != pet.status {
                alertController.addAction(UIAlertAction(title: option.title, style: .default) { [weak self] _ in
                    self?.updatePetStatus(pet: pet, newStatus: option.value)
                })
            }
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    private func updatePetStatus(pet: MyPetModel, newStatus: String) {
        // Показываем индикатор загрузки
        showLoading()
        
        editPresenter.updatePetStatus(id: pet.id, status: newStatus) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoading()
                
                switch result {
                case .success(let updatedPet):
                    // Обновляем питомца в массиве
                    if let index = self.myPetsArray.firstIndex(where: { $0.id == pet.id }) {
                        self.myPetsArray[index] = updatedPet
                        // После обновления, фильтрация будет применена автоматически через didSet
                    }
                    
                case .failure(let error):
                    self.showError(message: "Failed to update status: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension MyPetViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPetCell.identifier, for: indexPath) as! MyPetCell
        let pet = filteredPets[indexPath.row]
        cell.configure(with: pet)
        
        // Настраиваем действия для кнопок в зависимости от статуса
        if pet.status == "found" {
            // Для найденных питомцев показываем кнопку удаления
            cell.showEditButton(false)
            cell.showDeleteButton(true)
            cell.onDeleteTapped = { [weak self] in
                self?.confirmAndDeletePet(pet)
            }
        } else {
            // Для обычных питомцев показываем кнопку редактирования
            cell.showEditButton(true)
            cell.showDeleteButton(false)
            cell.onEditTapped = { [weak self] in
                self?.showEditPetView(for: pet)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Открываем детальный просмотр для ЛЮБОГО питомца
        let pet = filteredPets[indexPath.row]
        let vc = MyPetDetailViewController(model: pet)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Метод для контекстного меню (долгое нажатие)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let pet = filteredPets[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            var actions: [UIAction] = []
            
            // Для Found питомцев только удаление
            if pet.status == "found" {
                let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                    self?.confirmAndDeletePet(pet)
                }
                actions.append(deleteAction)
            } else {
                // Для обычных питомцев редактирование и удаление
                let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] _ in
                    self?.showEditPetView(for: pet)
                }
                
                let statusAction = UIAction(title: "Change Status", image: UIImage(systemName: "arrow.triangle.2.circlepath")) { [weak self] _ in
                    self?.showStatusUpdateOptions(for: pet)
                }
                
                let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                    self?.confirmAndDeletePet(pet)
                }
                
                actions.append(contentsOf: [editAction, statusAction, deleteAction])
            }
            
            return UIMenu(title: "", children: actions)
        }
    }
}

// MARK: - EditPetViewControllerDelegate
extension MyPetViewController: EditPetViewControllerDelegate {
    func petUpdated(pet: MyPetModel) {
        // После обновления питомца просто перезагружаем все данные
        presenter.fetchUserPets()
    }
    
    func petDeleted(petId: Int) {
        // Самый простой подход - просто запросить данные заново
        presenter.fetchUserPets()
        
        // Показываем уведомление об успешном удалении
        showSuccessToast(message: "Pet successfully deleted")
    }
    
    // Helper методы
    private func showSuccessToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = .systemFont(ofSize: 16, weight: .medium)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        
        view.addSubview(toastLabel)
        
        toastLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(100)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.greaterThanOrEqualTo(50)
        }
        
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Protocol для делегата EditPetViewController
protocol EditPetViewControllerDelegate: AnyObject {
    func petUpdated(pet: MyPetModel)
    func petDeleted(petId: Int)
}
