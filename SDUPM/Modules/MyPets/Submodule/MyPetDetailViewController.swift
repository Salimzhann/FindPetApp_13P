import SnapKit
import UIKit


class MyPetDetailViewController: UIViewController {
    
    private let presenter = MyPetDetailPresenter()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PetDetailCell.self, forCellWithReuseIdentifier: PetDetailCell.identifier)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.pageIndicatorTintColor = .lightGray
        pc.currentPageIndicatorTintColor = .systemGreen
        return pc
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    private let ageLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    private let breedLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    private let genderLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [makeSeparator(),
                                                       ageLabel,
                                                       makeSeparator(),
                                                       breedLabel,
                                                       makeSeparator(),
                                                       genderLabel,
                                                       makeSeparator(),
                                                       descriptionLabel]
        )
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    private let model: MyPetModel
    private var images: [UIImage] = []
    
    var detailInfo: MyPetModel? = nil {
        didSet {
            images = detailInfo?.images ?? []
            nameLabel.text = detailInfo?.name
            ageLabel.text = "Возраст: \(detailInfo?.age ?? "0") лет"
            breedLabel.text = "Порода: \(detailInfo?.breed ?? "Не указана")"
            genderLabel.text = "Пол: \(detailInfo?.gender ?? "Не указан")"
            descriptionLabel.text = detailInfo?.description
            
            pageControl.numberOfPages = images.count
        }
    }
    
    init(model: MyPetModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        detailInfo = model
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.view = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .systemGreen
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(140)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(250)
        }
        
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(20)
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
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
}


extension MyPetDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PetDetailCell.identifier, for: indexPath) as! PetDetailCell
        cell.configure(image: images[indexPath.row])
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        if pageIndex.isFinite {
            pageControl.currentPage = Int(pageIndex)
        } else {
            pageControl.currentPage = 0 // или ничего не делай
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}
