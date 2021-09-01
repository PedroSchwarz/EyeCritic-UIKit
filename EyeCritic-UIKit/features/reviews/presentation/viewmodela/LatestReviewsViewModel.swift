//
//  LatestReviewsViewModel.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 23/08/21.
//

import Foundation
import RxSwift
import Combine

enum LatestReviewsState {
    case initial
    case loading
    case success(value: [Review])
    case failure(error: String)
}

class LatestReviewsViewModel {
    var usecase: GetLatestReviews
    private(set) var state: BehaviorSubject<LatestReviewsState> = BehaviorSubject(value: .initial)
    
    private var cancellables = Set<AnyCancellable>()
    
    init(usecase: GetLatestReviews) {
        self.usecase = usecase
    }
    
    func getLatestReviews() {
        self.state.onNext(.loading)
        usecase.execute()
            .sink { completion in
                switch completion {
                    case .failure(let error):
                        self.state.onNext(.failure(error: error.localizedDescription))
                        break
                    case .finished:
                        break
                }
            } receiveValue: { result in
                self.state.onNext(.success(value: result))
            }
            .store(in: &cancellables)
    }
}
