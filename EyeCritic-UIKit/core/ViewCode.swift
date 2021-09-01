//
//  ViewCode.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 27/08/21.
//

import Foundation
import SnapKit

protocol ViewCode {
    func buildHierarchy()
    func setupConstraints()
    func configureViews()
}

extension ViewCode {
    func applyViewCode() {
        buildHierarchy()
        setupConstraints()
        configureViews()
    }
}
