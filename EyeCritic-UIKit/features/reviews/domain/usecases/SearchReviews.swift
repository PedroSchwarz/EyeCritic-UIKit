//
//  SearchReviews.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 27/08/21.
//

import Foundation
import Combine

struct SearchReviews {
    var repository: ReviewsRepository
        
    func execute(for title: String) -> AnyPublisher<[Review], Failure> {
        return repository.searchReviews(title: title)
    }
}
