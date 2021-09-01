//
//  GetFavoriteReviews.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 27/08/21.
//

import Foundation
import Combine

struct GetFavoriteReviews {
    var repository: ReviewsRepository
       
   func execute() -> AnyPublisher<[Review], Failure> {
       return repository.getFavoriteReviews()
   }
}
