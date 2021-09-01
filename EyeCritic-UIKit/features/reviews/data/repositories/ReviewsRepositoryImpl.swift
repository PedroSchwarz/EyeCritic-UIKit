//
//  ReviewsRepositoryImpl.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 21/08/21.
//

import Foundation
import Combine
import Network

struct ReviewsRepositoryImpl: ReviewsRepository {
    var network: NetworkInfo
    var remote: ReviewsRemoteDataSource
    var local: ReviewsLocalDataSource

    func getLatestReviews() -> AnyPublisher<[Review], Failure> {
        if network.isConnected() {
            return remote.getLatestReviews()
                .handleEvents(receiveOutput: { result in
                    local.cacheReviews(reviews: result.results)
                })
                .map({ result in
                    result.results.map { $0.toReview() }
                })
                .eraseToAnyPublisher()
        } else {
            return local.getCachedReview()
                .map({ result in
                    result.map { ReviewModel.fromCacheReview(data: $0).toReview() }
                })
                .eraseToAnyPublisher()
        }
    }
    
    func searchReviews(title: String) -> AnyPublisher<[Review], Failure> {
        if network.isConnected() {
            return remote.searchReviews(title: title)
                .map({ result in
                    result.results.map { $0.toReview() }
                })
                .eraseToAnyPublisher()
        } else {
            return local.searchCachedReviews(title: title)
                .map({ result in
                    result.map { $0.toReview() }
                })
                .eraseToAnyPublisher()
        }
    }
    
    func toggleReviewFavorite(review: Review) -> AnyPublisher<Void, Failure> {
        return local.insertOrUpdateReview(review: review)
            .eraseToAnyPublisher()
    }
    
    func getFavoriteReviews() -> AnyPublisher<[Review], Failure> {
        return local.getFavoriteReviews()
            .eraseToAnyPublisher()
    }
    
    func getReviewFavoriteStatus(review: Review) -> AnyPublisher<Bool, Failure> {
        return local.getReviewFavoriteStatus(review: review)
            .eraseToAnyPublisher()
    }
}
