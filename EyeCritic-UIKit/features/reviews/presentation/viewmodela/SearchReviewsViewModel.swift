//
//  SearchReviewsViewModel.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 27/08/21.
//

import Foundation
import RxSwift
import Combine

enum SearchReviewsState {
    case initial
    case loading
    case success(value: [Review])
    case failure(error: String)
}

class SearchReviewsViewModel {
    var usecase: SearchReviews
    private(set) var state: BehaviorSubject<SearchReviewsState> = BehaviorSubject(value: .initial)
    
    private var cancellables = Set<AnyCancellable>()
    
    init(usecase: SearchReviews) {
        self.usecase = usecase
    }
    
    func searchReviews(title: String) {
        self.state.onNext(.loading)
        usecase.execute(for: title)
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
