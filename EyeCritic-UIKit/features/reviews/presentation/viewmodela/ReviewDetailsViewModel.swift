//
//  ReviewDetailsViewModel.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 30/08/21.
//

import Foundation
import Combine
import RxSwift

class ReviewDetailsViewModel {
    var toggleUseCase: ToggleReviewFavorite
    var favoriteStatusUseCase: GetReviewFavoriteStatus
    
    private(set) var favorite: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    private(set) var image: BehaviorSubject<Data?> = BehaviorSubject(value: nil)
    
    private var cancellables = Set<AnyCancellable>()
    
    init(toggleUseCase: ToggleReviewFavorite, favoriteStatusUseCase: GetReviewFavoriteStatus) {
        self.toggleUseCase = toggleUseCase
        self.favoriteStatusUseCase = favoriteStatusUseCase
    }
    
    func loadImage(imageUrl: String) {
        if let url = URL(string: imageUrl) {
            do {
                let data = try Data(contentsOf: url)
                self.image.onNext(data)
            } catch {
                self.image.onNext(nil)
            }
        } else {
            self.image.onNext(nil)
        }
    }
    
    func toggleReviewFavorite(review: Review) {
        self.toggleUseCase.execute(for: review)
            .sink { completion in
                switch completion {
                case .failure(_):
                        break
                    case .finished:
                        break
                }
            } receiveValue: { _ in
                do {
                    let current = try self.favorite.value()
                    self.favorite.onNext(!current)
                } catch { }
            }
            .store(in: &cancellables)
    }
        
    func getReviewFavoriteStatus(review: Review) {
        self.favoriteStatusUseCase.execute(review: review)
            .sink { completion in
                switch completion {
                case .failure(_):
                        break
                    case .finished:
                        break
                }
            } receiveValue: { value in
                self.favorite.onNext(value)
            }
            .store(in: &cancellables)
    }
}
