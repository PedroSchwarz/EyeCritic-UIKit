//
//  ViewAnimations.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 24/08/21.
//

import Foundation
import UIKit

struct ViewAnimations {
    static func buildPopUpAnimation() -> CASpringAnimation {
        let popUp = CASpringAnimation(keyPath: "transform.scale")
        popUp.damping = 2
        popUp.initialVelocity = 2
        popUp.mass = 2
        popUp.stiffness = 5
        popUp.fromValue = 0
        popUp.toValue = 1
        popUp.duration = popUp.settlingDuration
        popUp.beginTime = CACurrentMediaTime()
        return popUp
    }
    
    static func buildPopUpReviewCardAnimation() -> CASpringAnimation {
        let popUp = CASpringAnimation(keyPath: "transform.scale")
        popUp.damping = 10
        popUp.initialVelocity = 1.5
        popUp.mass = 2
        popUp.stiffness = 2
        popUp.fromValue = 0
        popUp.toValue = 1
        popUp.duration = popUp.settlingDuration
        popUp.beginTime = CACurrentMediaTime() + 0.3
        return popUp
    }
    
    static func buildFadeOutAnimation() -> CABasicAnimation {
        let fadeOut = CABasicAnimation(keyPath: "transform.scale")
        fadeOut.fromValue = 1
        fadeOut.toValue = 0
        fadeOut.timingFunction = CAMediaTimingFunction(name: .easeOut)
        fadeOut.duration = 2
        fadeOut.beginTime = CACurrentMediaTime() + 0.3
        fadeOut.fillMode = .forwards
        return fadeOut
    }
    
    static func buildOpacityAnimation() -> CABasicAnimation {
        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.fromValue = 0
        opacity.toValue = 1
        opacity.fillMode = .forwards
        opacity.timingFunction = CAMediaTimingFunction(name: .easeOut)
        opacity.duration = 2
        opacity.beginTime = CACurrentMediaTime() + 0.3
        return opacity
    }
    
    static func buildSlideUpAnimation() -> CABasicAnimation {
        let slideUp = CABasicAnimation(keyPath: "position.y")
        slideUp.fromValue = UIScreen.main.bounds.height + 100
        slideUp.toValue = UIScreen.main.bounds.height - 175
        slideUp.timingFunction = CAMediaTimingFunction(name: .easeOut)
        slideUp.duration = 2
        return slideUp
    }
}
