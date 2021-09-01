//
//  ReviewsLocalDataSource.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 25/08/21.
//

import Foundation
import Combine
import CoreData

protocol ReviewsLocalDataSource {
    func getCachedReview() -> AnyPublisher<[ReviewData], Failure>
        
    func cacheReviews(reviews: [ReviewModel]) -> Void
    
    func searchCachedReviews(title: String) -> AnyPublisher<[ReviewModel], Failure>
    
    func getFavoriteReviews() -> AnyPublisher<[Review], Failure>
    
    func insertOrUpdateReview(review: Review) -> AnyPublisher<Void, Failure>
    
    func getReviewFavoriteStatus(review: Review) -> AnyPublisher<Bool, Failure>
}

struct ReviewsLocalDataSourceImpl: ReviewsLocalDataSource {
    var context: NSManagedObjectContext
    
    func getCachedReview() -> AnyPublisher<[ReviewData], Failure> {
        let request: NSFetchRequest<ReviewData> = ReviewData.fetchRequest()
        
        do {
            let result = try context.fetch(request)
            return Result.Publisher(result)
                .eraseToAnyPublisher()
        } catch {
            return Result.Publisher(Failure(type: .cache))
                .eraseToAnyPublisher()
        }
    }
    
    func cacheReviews(reviews: [ReviewModel]) {
        self.getCachedReview()
            .sink { completion in
                switch completion {
                    case .failure(let e):
                        print(e)
                        break
                    case .finished:
                        break
                }
            } receiveValue: { value in
                reviews.forEach { model in
                    if value.first(where: { el in
                        el.display_title == model.display_title
                    }) != nil {
                        return
                    } else {
                        let data = ReviewData(context: context)
                        data.display_title = model.display_title
                        data.byline = model.byline
                        data.favorite = false
                        data.headline = model.headline
                        data.imageUrl = model.multimedia?.src ?? ""
                        data.link = model.link.url
                        data.mpaa_rating = model.mpaa_rating
                        data.publication_date = model.publication_date
                        data.summary_short = model.summary_short
                        
                        do {
                            try context.save()
                        } catch {
                            let nsError = error as NSError
                            print("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                }
            }
            .cancel()
    }
    
    func searchCachedReviews(title: String) -> AnyPublisher<[ReviewModel], Failure> {
        let request: NSFetchRequest<ReviewData> = ReviewData.fetchRequest()
        let filterByTitle = NSPredicate(format: "display_title contains[cd] %@", title)
        request.predicate = filterByTitle
        
        do {
            let result = try context.fetch(request)
            let modelsList: [ReviewModel] = result.map { ReviewModel.fromCacheReview(data: $0) }
            return Result.Publisher(modelsList)
                .eraseToAnyPublisher()
        } catch {
            return Result.Publisher(Failure(type: .cache))
                .eraseToAnyPublisher()
        }
    }
    
    func getFavoriteReviews() -> AnyPublisher<[Review], Failure> {
        let request: NSFetchRequest<ReviewData> = ReviewData.fetchRequest()
        let filterByFavorite = NSPredicate(format: "favorite == YES")
        request.predicate = filterByFavorite
        
        do {
            let result = try context.fetch(request)
            let reviews: [Review] = result.map {
                Review(
                    displayTitle: $0.display_title!,
                    rating: $0.mpaa_rating!,
                    byLine: $0.byline!,
                    headline: $0.headline!,
                    summary: $0.summary_short!,
                    publicationDate: $0.publication_date!,
                    imageUrl: $0.imageUrl!,
                    link: $0.link!,
                    favorite: $0.favorite
                )
            }
            return Result.Publisher(reviews)
                .eraseToAnyPublisher()
        } catch {
            return Result.Publisher(Failure(type: .cache))
                .eraseToAnyPublisher()
        }
    }
    
    func insertOrUpdateReview(review: Review) -> AnyPublisher<Void, Failure> {
        self.getCachedReview()
            .tryMap({ data in
                if let cachedReview = data.first(where: { $0.display_title == review.displayTitle }) {
                    do {
                        cachedReview.favorite = !cachedReview.favorite
                        try self.context.save()
                        return
                    } catch {
                        throw Failure(type: .cache)
                    }
                } else {
                    let newReview = ReviewData(context: context)
                    newReview.display_title = review.displayTitle
                    newReview.byline = review.byLine
                    newReview.headline = review.headline
                    newReview.mpaa_rating = review.rating
                    newReview.publication_date = review.publicationDate
                    newReview.imageUrl = review.imageUrl
                    newReview.link = review.link
                    newReview.favorite = true
                    newReview.summary_short = review.summary
                    
                    do {
                        try self.context.save()
                        return
                    } catch {
                        throw Failure(type: .cache)
                    }
                }
            })
            .mapError({ error in
                return Failure(type: .cache)
            })
            .eraseToAnyPublisher()
    }
    
    func getReviewFavoriteStatus(review: Review) -> AnyPublisher<Bool, Failure> {
        self.getCachedReview()
            .map({ data in
                if let cachedReview = data.first(where: { $0.display_title == review.displayTitle }) {
                    return cachedReview.favorite
                } else {
                    return false
                }
            })
            .eraseToAnyPublisher()
    }
}
