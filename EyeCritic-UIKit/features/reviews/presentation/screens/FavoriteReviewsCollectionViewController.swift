//
//  FavoriteReviewsCollectionViewController.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 29/08/21.
//

import UIKit
import RxSwift

private let reuseIdentifier = "FavoriteReviewCell"
private let detailsSegue = "goToDetails"

class FavoriteReviewsCollectionViewController: UICollectionViewController {
    // View Data Properties
    var viewModel = AppModules.container.resolve(FavoriteReviewsViewModel.self)!
    var reviews: [Review] = []
    private let disposeBag = DisposeBag()
    // UI Properties
    let refreshControl = UIRefreshControl()
    lazy var progress: UIActivityIndicatorView = { return UIActivityIndicatorView(style: .large) }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.getFavoriteReviews()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Favorite Reviews"
        
        self.collectionView!.register(UINib(nibName: "ReviewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.handleUIState()
        self.applyViewCode()
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.viewModel.getFavoriteReviews()
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reviews.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ReviewCollectionViewCell
        
        let review = self.reviews[indexPath.row]
        
        cell.review = review
        cell.build()
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: detailsSegue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailsSegue {
            let destination = segue.destination as! ReviewDetailsViewController
            let index = (self.collectionView.indexPathsForSelectedItems?.first)?.row
            destination.review = self.reviews[index!]
        }
    }
    
    func handleUIState() {
        self.viewModel.state.subscribe(onNext: { state in
            switch state {
                case .initial:
                    break
                case .loading:
                    if !self.refreshControl.isRefreshing {
                        self.progress.startAnimating()
                        self.progress.layer.add(ViewAnimations.buildPopUpAnimation(), forKey: nil)
                    }
                case .success(let value):
                    self.reviews = value
                    self.collectionView.reloadData()
                    
                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                    } else {
                        self.progress.stopAnimating()
                    }
                case .failure:
                    self.progress.stopAnimating()
            }
          })
        .disposed(by: self.disposeBag)
    }
}

// MARK: - Collection View Flow Layout Delegate
extension FavoriteReviewsCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let paddingSpace = GridLayout.sectionInsets.left * (GridLayout.itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / GridLayout.itemsPerRow
    
    return CGSize(width: widthPerItem, height: GridLayout.itemHeight)
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    return GridLayout.sectionInsets
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int
  ) -> CGFloat {
    return GridLayout.sectionInsets.left
  }
}

//MARK: - ViewCode
extension FavoriteReviewsCollectionViewController: ViewCode {
    func buildHierarchy() {
        self.view.addSubview(self.progress)
    }
    
    func setupConstraints() {
        self.progress.snp.makeConstraints { make in
            make.center.equalTo(self.view.snp.center)
        }
    }
    
    func configureViews() {
        self.progress.color = Theme.Colors.accentColor
    }
}
