//
//  SKDismissAnimator.swift
//  1SKConnect
//
//  Created by Elcom Corp on 08/11/2021.
//

import UIKit

class SKDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var buttonFrame: CGRect

    init(toFrame: CGRect) {
        self.buttonFrame = toFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)
        let destinationViewController = transitionContext.viewController(forKey: .to)
        let destinationView = (destinationViewController?.view)!
        let fromView = (fromViewController?.view)!

        transitionContext.containerView.addSubview(destinationView)
        transitionContext.containerView.addSubview((fromViewController?.view)!)

        let maskPath = UIBezierPath(rect: fromView.frame)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = fromView.frame
        maskLayer.path = maskPath.cgPath
        fromView.layer.mask = maskLayer

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
        let smallCirclePath = UIBezierPath(ovalIn: self.buttonFrame)
        let pathAnimation = CABasicAnimation(keyPath: "path")

        pathAnimation.setValue(transitionContext, forKey: "context")

        pathAnimation.setValue(fromViewController, forKey: "FromViewController")

        pathAnimation.delegate = self

        pathAnimation.fromValue = bigCirclePath.cgPath

        pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)

        pathAnimation.toValue = smallCirclePath.cgPath

        maskLayer.path = smallCirclePath.cgPath

        maskLayer.add(pathAnimation, forKey: nil)
    }
}

extension SKDismissAnimator: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let context = anim.value(forKey: "context") as? UIViewControllerContextTransitioning, let fromVc = anim.value(forKey: "FromViewController") as? UIViewController, flag else {
            return
        }
        context.completeTransition(!context.transitionWasCancelled)
        fromVc.view.layer.mask?.removeFromSuperlayer()
    }
}
