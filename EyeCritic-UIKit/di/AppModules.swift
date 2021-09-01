//
//  AppModules.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 24/08/21.
//

import Foundation
import Network
import Swinject
import CoreData
import UIKit

struct AppModules {
    // Container
    static let container = Container()
    // Declare Modules
    static func declareModules() {
        // Network monitoring
        let monitor = NWPathMonitor()
        monitor.start(queue: DispatchQueue(label: "Network monitor"))
        // Utils
        container.register(NWPathMonitor.self) { _ in  monitor }
        container.register(NetworkInfo.self) { r in NetworkInfoImpl(monitor: r.resolve(NWPathMonitor.self)!) }
        container.register(NSManagedObjectContext.self) { _ in (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext }
        // Data Sources
        container.register(ReviewsRemoteDataSource.self) { _ in ReviewsRemoteDataSourceImpl(service: ReviewsService()) }
        container.register(ReviewsLocalDataSource.self) { r in ReviewsLocalDataSourceImpl(context: r.resolve(NSManagedObjectContext.self)!) }
        
        // Repositories
        container.register(ReviewsRepository.self) { r in
            ReviewsRepositoryImpl(
                network: r.resolve(NetworkInfo.self)!,
                remote: r.resolve(ReviewsRemoteDataSource.self)!,
                local: r.resolve(ReviewsLocalDataSource.self)!
            )
        }
        
        // Use Cases
        container.register(GetLatestReviews.self) { r in GetLatestReviews(repository: r.resolve(ReviewsRepository.self)!) }
        container.register(SearchReviews.self) { r in SearchReviews(repository: r.resolve(ReviewsRepository.self)!) }
        container.register(GetFavoriteReviews.self) { r in GetFavoriteReviews(repository: r.resolve(ReviewsRepository.self)!) }
        container.register(ToggleReviewFavorite.self) { r in ToggleReviewFavorite(repository: r.resolve(ReviewsRepository.self)!) }
        container.register(GetReviewFavoriteStatus.self) { r in GetReviewFavoriteStatus(repository: r.resolve(ReviewsRepository.self)!) }
        
        // View Models
        container.register(LatestReviewsViewModel.self) { r in LatestReviewsViewModel(usecase: r.resolve(GetLatestReviews.self)!) }
        container.register(ReviewCellViewModel.self) { r in ReviewCellViewModel() }
        container.register(SearchReviewsViewModel.self) { r in SearchReviewsViewModel(usecase: r.resolve(SearchReviews.self)!) }
        container.register(FavoriteReviewsViewModel.self) { r in FavoriteReviewsViewModel(usecase: r.resolve(GetFavoriteReviews.self)!) }
        container.register(ReviewDetailsViewModel.self) { r in ReviewDetailsViewModel(toggleUseCase: r.resolve(ToggleReviewFavorite.self)!, favoriteStatusUseCase: r.resolve(GetReviewFavoriteStatus.self)!) }
    }
}
