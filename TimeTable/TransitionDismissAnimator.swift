//
//  TransitionDismissAnimator.swift
//  TimeTable
//
//  Created by 岡本 浩揮 on 2015/04/20.
//  Copyright (c) 2015年 Q太郎. All rights reserved.
//

import Foundation
import UIKit

class TransitionDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()
        
        let animationDuration = self.transitionDuration(transitionContext)
        
        println("animatetransition: \(fromViewController.view.frame)")
        
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            fromViewController.view.alpha = 0.0
            fromViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1)
        }) { (finished) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}
