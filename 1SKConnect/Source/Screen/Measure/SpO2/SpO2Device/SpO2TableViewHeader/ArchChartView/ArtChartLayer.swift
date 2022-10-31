//
//  ArtChartLayer.swift
//  1SKConnect
//
//  Created by Be More on 1/10/2021.
//

import UIKit

open class ArtChartLayer: CAShapeLayer {
    internal var disableSpringAnimation: Bool = true
    open override func action(forKey event: String) -> CAAction? {
        return nil
        if event == "transform" && !disableSpringAnimation {
            let springAnimation = CASpringAnimation(keyPath: event)
            springAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            springAnimation.initialVelocity = 0.1
            springAnimation.damping = 0
            return springAnimation
        }
        return super.action(forKey: event)
    }
}
