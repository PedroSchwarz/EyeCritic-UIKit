//
//  ReviewCellViewModel.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 24/08/21.
//

import Foundation
import RxSwift

enum ReviewCellState {
    case initial
    case success(value: Data)
    case failure(error: String)
}

class ReviewCellViewModel {
    var state: BehaviorSubject<ReviewCellState> = BehaviorSubject(value: .initial)
    
    func loadThumb(imageUrl: String) {
        if let url = URL(string: imageUrl) {
            do {
                let data = try Data(contentsOf: url)
                self.state.onNext(.success(value: data))
            } catch {
                self.state.onNext(.failure(error: error.localizedDescription))
            }
        } else {
            self.state.onNext(.failure(error: "Something went wrong"))
        }
    }
}
