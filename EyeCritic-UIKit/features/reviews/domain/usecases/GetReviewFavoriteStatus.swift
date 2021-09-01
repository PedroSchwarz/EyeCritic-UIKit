//
//  GetReviewFavoriteStatus.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 27/08/21.
//

import Foundation
import Combine

struct GetReviewFavoriteStatus {
    var repository: ReviewsRepository
       
   func execute(review: Review) -> AnyPublisher<Bool, Failure> {
       return repository.getReviewFavoriteStatus(review: review)
   }
}
