//
//  ReviewDetailsViewController.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 29/08/21.
//

import UIKit
import RxSwift

class ReviewDetailsViewController: UIViewController {
    var review: Review!
    var viewModel: ReviewDetailsViewModel = AppModules.container.resolve(ReviewDetailsViewModel.self)!
    private var disposeBag = DisposeBag()
    // UI Properties
    lazy var scrollView: UIScrollView = { return UIScrollView(frame: .zero) }()
    lazy var reviewImage: UIImageView = { return UIImageView(frame: .zero) }()
    lazy var reviewHeadline: UILabel = { return UILabel(frame: .zero) }()
    lazy var reviewSummary: UILabel = { return UILabel(frame: .zero) }()
    lazy var reviewPublication: UILabel = { return UILabel(frame: .zero) }()
    lazy var reviewBy: UILabel = { return UILabel(frame: .zero) }()
    lazy var reviewLink: UIButton = { return UIButton(frame: .zero) }()
    lazy var reviewToggleFavorite: UIButton = { return UIButton(frame: .zero) }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        
        self.viewModel.getReviewFavoriteStatus(review: self.review)
        self.viewModel.loadImage(imageUrl: self.review.imageUrl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = self.review.displayTitle
        
        self.applyViewCode()
    }
    
    @objc func openLink() {
        if let link = URL(string: self.review.link) {
          UIApplication.shared.open(link)
        }
    }
    
    @objc func toggleFavorite() {
        self.viewModel.toggleReviewFavorite(review: self.review)
    }
}

//MARK: - ViewCode
extension ReviewDetailsViewController: ViewCode {
    func buildHierarchy() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(reviewImage)
        self.scrollView.addSubview(reviewHeadline)
        self.scrollView.addSubview(reviewSummary)
        self.scrollView.addSubview(reviewPublication)
        self.scrollView.addSubview(reviewBy)
        self.scrollView.addSubview(reviewLink)
        self.scrollView.addSubview(reviewToggleFavorite)
    }
    
    func setupConstraints() {
        self.scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.reviewImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 2)
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        
        self.reviewHeadline.snp.makeConstraints { make in
            make.top.equalTo(self.reviewImage.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        self.reviewSummary.snp.makeConstraints { make in
            make.top.equalTo(self.reviewHeadline.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        self.reviewPublication.snp.makeConstraints { make in
            make.top.equalTo(self.reviewSummary.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        self.reviewBy.snp.makeConstraints { make in
            make.top.equalTo(self.reviewSummary.snp.bottom).offset(20)
            make.leading.equalTo(self.reviewPublication.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(20)
        }
        
        self.reviewLink.snp.makeConstraints { make in
            make.top.equalTo(self.reviewBy.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        self.reviewToggleFavorite.snp.makeConstraints { make in
            make.bottom.equalTo(reviewImage).offset(28)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.width.equalTo(56)
        }
    }
    
    func configureViews() {
        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.scrollView.showsHorizontalScrollIndicator = false
        
        self.reviewImage.contentMode = .scaleAspectFill
        
        self.viewModel.image.subscribe(onNext: { data in
            if let image = data {
                self.reviewImage.image = UIImage(data: image)!
            }
        })
        .disposed(by: self.disposeBag)
        
        self.reviewHeadline.text = self.review.displayTitle
        self.reviewHeadline.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        self.reviewSummary.text = self.review.headline
        self.reviewSummary.font = UIFont.systemFont(ofSize: 20)
        self.reviewSummary.numberOfLines = 50
        
        self.reviewPublication.text = "Published on \(self.review.formattedDate)"
        
        self.reviewBy.text = "By \(self.review.byLine)"
        
        self.reviewLink.setTitle("Go to article", for: .normal)
        self.reviewLink.setTitleColor(Theme.Colors.accentColor, for: .normal)
        self.reviewLink.addTarget(self, action: #selector(self.openLink), for: .touchUpInside)
        
        self.reviewToggleFavorite.backgroundColor = Theme.Colors.appReviewCard
        self.reviewToggleFavorite.layer.cornerRadius = 28
        self.reviewToggleFavorite.layer.shadowColor = Theme.Colors.appReviewCard.cgColor
        self.reviewToggleFavorite.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.reviewToggleFavorite.layer.shadowRadius = 10
        
        self.viewModel.favorite.subscribe(onNext: { value in
            if let image = UIImage(systemName: value ? "heart.fill" : "heart") {
                self.reviewToggleFavorite.setImage(image.withTintColor(.red, renderingMode: .alwaysOriginal), for: .normal)
            }
        })
        .disposed(by: self.disposeBag)
        
        self.reviewToggleFavorite.addTarget(self, action: #selector(self.toggleFavorite), for: .touchUpInside)
    }
}
