//
//  SearchReviewsViewController.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 27/08/21.
//

import UIKit
import RxSwift

private let reuseIdentifier = "SearchReviewCell"
private let detailsSegue = "goToDetails"

class SearchReviewsViewController: UIViewController {
    // View Data Properties
    var viewModel = AppModules.container.resolve(SearchReviewsViewModel.self)!
    var reviews: [Review] = []
    private let disposeBag = DisposeBag()
    // UI Properties
    lazy var searchButton: UIButton = { return UIButton(frame: .zero) }()
    lazy var searchField: UITextField = { return UITextField(frame: .zero) }()
    lazy var progress: UIActivityIndicatorView = { return UIActivityIndicatorView(style: .large) }()
    lazy var reviewsGrid: UICollectionView = { return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()) }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search Reviews"
        
        self.applyViewCode()
        self.handleUIState()
    }
    
    func handleUIState() {
        self.viewModel.state.subscribe(onNext: { state in
            switch state {
                case .initial:
                    break
                case .loading:
                    self.progress.startAnimating()
                    self.reviewsGrid.layer.opacity = 0
                    break
                case .success(let value):
                    self.progress.stopAnimating()
                    self.reviewsGrid.layer.opacity = 1
                    self.reviews = value
                    self.reviewsGrid.reloadData()
                case .failure(let error):
                    print(error)
                   break
            }
          })
        .disposed(by: self.disposeBag)
    }
    
    @objc func searchReviews() {
        if let title = self.searchField.text {
            self.viewModel.searchReviews(title: title)
            self.view.endEditing(true)
        }
    }
}

//MARK: - UICollectionViewDataSource
extension SearchReviewsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ReviewCollectionViewCell
        
        let review = self.reviews[indexPath.row]
        
        cell.review = review
        cell.build()
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: detailsSegue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailsSegue {
            let destination = segue.destination as! ReviewDetailsViewController
            let index = self.reviewsGrid.indexPathsForSelectedItems?.first?.row
            destination.review = self.reviews[index!]
        }
    }
}

//MARK: - ViewCode
extension SearchReviewsViewController: ViewCode {
    func buildHierarchy() {
        self.view.addSubview(self.searchButton)
        self.view.addSubview(self.searchField)
        self.view.addSubview(self.progress)
        self.view.addSubview(self.reviewsGrid)
    }
    
    func setupConstraints() {
        var topPadding: CGFloat
        
        let window = UIApplication.shared.keyWindow
        topPadding = (window?.safeAreaInsets.top)!
        
        self.searchButton.snp.makeConstraints { make in
            make.height.equalTo(54)
            make.width.equalTo(54)
            make.top.equalTo(self.view.snp.top).offset(topPadding + 130)
            make.leading.equalToSuperview().offset(16)
        }
        
        self.searchField.snp.makeConstraints { make in
            make.height.equalTo(54)
            make.top.equalTo(self.view.snp.top).offset(topPadding + 130)
            make.leading.equalTo(self.searchButton.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
        
        self.progress.snp.makeConstraints { make in
            make.top.equalTo(self.searchButton.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.reviewsGrid.snp.makeConstraints { make in
            make.top.equalTo(self.searchButton.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func configureViews() {
        self.searchButton.backgroundColor = Theme.Colors.accentColor
        self.searchButton.layer.cornerRadius = 27
        self.searchButton.layer.shadowColor = Theme.Colors.accentColor.cgColor
        self.searchButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.searchButton.layer.shadowRadius = 10
        self.searchButton.layer.shadowOpacity = 1
        if let image = UIImage(systemName: "magnifyingglass") {
            self.searchButton.setImage(image.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        }
        self.searchButton.addTarget(self, action: #selector(self.searchReviews), for: .touchUpInside)
        
        self.searchField.backgroundColor = Theme.Colors.appReviewCard
        self.searchField.layer.shadowColor = Theme.Colors.appReviewCard.cgColor
        self.searchField.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.searchField.layer.shadowRadius = 5
        self.searchField.layer.shadowOpacity = 1
        self.searchField.textColor = .black
        self.searchField.borderStyle = .roundedRect
        self.searchField.placeholder = "Search by title..."
        self.searchField.returnKeyType = .send
        self.searchField.addTarget(self, action: #selector(self.searchReviews), for: .primaryActionTriggered)
        
        self.progress.color = Theme.Colors.accentColor
        
        self.reviewsGrid.dataSource = self
        self.reviewsGrid.delegate = self
        self.reviewsGrid.register(UINib(nibName: "ReviewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let paddingSpace = GridLayout.sectionInsets.left * (GridLayout.itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / GridLayout.itemsPerRow
        layout.sectionInset = GridLayout.sectionInsets
        layout.minimumLineSpacing = GridLayout.sectionInsets.left
        layout.itemSize = CGSize(width: widthPerItem, height: GridLayout.itemHeight)
        self.reviewsGrid.setCollectionViewLayout(layout, animated: true)
        self.reviewsGrid.backgroundColor = .systemBackground
    }
}
