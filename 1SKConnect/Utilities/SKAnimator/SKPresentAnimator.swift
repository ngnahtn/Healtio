//
//  SKPresentAnimator.swift
//  1SKConnect
//
//  Created by Elcom Corp on 08/11/2021.
//

import UIKit

class SKPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    var buttonFrame: CGRect
    
    init(startFrame: CGRect) {
        self.buttonFrame = startFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)
        
        let destinationViewController = transitionContext.viewController(forKey: .to)

        let destinationView = (destinationViewController?.view)!

        transitionContext.containerView.addSubview((fromViewController?.view)!)
        transitionContext.containerView.addSubview(destinationView)

        let maskPath = UIBezierPath(ovalIn: self.buttonFrame)

        let maskLayer = CAShapeLayer()

        maskLayer.frame = destinationView.frame
        
        maskLayer.path = maskPath.cgPath

        destinationView.layer.mask = maskLayer

        let screenHeight = UIScreen.main.bounds.height

        let screenYHeight = screenHeight - buttonFrame.midX

        let buttonYHeight = buttonFrame.height / 2

        let scaleFactor = screenYHeight / buttonYHeight

        let endFrameWidth = scaleFactor * buttonFrame.width

        let endFrameHeight = endFrameWidth

        let endFrameXPos = destinationView.frame.midX - (endFrameWidth / 2)

        let endFrameYPos = CGFloat(0)

        let endFrame = CGRect(x: endFrameXPos, y: endFrameYPos, width: endFrameWidth, height: endFrameHeight)

        let bigCirclePath = UIBezierPath(ovalIn: endFrame)

        let pathAnimation = CABasicAnimation(keyPath: "path")

        pathAnimation.setValue(transitionContext, forKey: "context")

        pathAnimation.setValue(destinationViewController, forKey: "destination")

        pathAnimation.delegate = self

        pathAnimation.fromValue = maskPath.cgPath

        pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)

        pathAnimation.toValue = bigCirclePath.cgPath

        maskLayer.path = bigCirclePath.cgPath

        maskLayer.add(pathAnimation, forKey: nil)
    }
}

extension SKPresentAnimator: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let context = anim.value(forKey: "context") as? UIViewControllerContextTransitioning, let destinationVc = anim.value(forKey: "destination") as? UIViewController, flag else {
            return
        }
        context.completeTransition(!context.transitionWasCancelled)
        destinationVc.view.layer.mask?.removeFromSuperlayer()
    }
}
