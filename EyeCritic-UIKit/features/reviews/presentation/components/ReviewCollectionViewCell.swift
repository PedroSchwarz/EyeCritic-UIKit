//
//  ReviewCollectionViewCell.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 21/08/21.
//

import UIKit
import RxSwift

class ReviewCollectionViewCell: UICollectionViewCell {
    let viewModel = AppModules.container.resolve(ReviewCellViewModel.self)!
    var review: Review!
    
    private let disposeBag = DisposeBag()

    @IBOutlet weak var reviewCard: UIView!
    @IBOutlet weak var reviewThumb: UIImageView!
    @IBOutlet weak var reviewTitle: UILabel!
    @IBOutlet weak var reviewSummary: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.reviewCard.layer.cornerRadius = 20
        self.reviewCard.clipsToBounds = true
        self.reviewCard.layer.add(ViewAnimations.buildPopUpReviewCardAnimation(), forKey: nil)
    }
    
    func build() {
        self.viewModel.loadThumb(imageUrl: self.review.imageUrl)
        self.reviewTitle.text = self.review.displayTitle
        self.reviewSummary.text = self.review.summary
        
        self.viewModel.state.subscribe(onNext: { state in
            switch state {
                case .initial:
                    break
                case .success(let value):
                    self.reviewThumb.image = UIImage(data: value)
                    break
                case .failure(let error):
                    print(error)
                    break
            }
        })
        .disposed(by: self.disposeBag)
    }
}
