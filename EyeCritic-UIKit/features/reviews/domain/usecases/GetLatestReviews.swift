//
//  GetLatestReviews.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 21/08/21.
//

import Foundation
import Combine

struct GetLatestReviews {
    var repository: ReviewsRepository
    
    func execute() -> AnyPublisher<[Review], Failure> {
        return repository.getLatestReviews()
    }
}
