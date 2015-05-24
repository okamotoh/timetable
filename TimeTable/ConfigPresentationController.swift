//
//  ConfigPresentationController.swift
//  TimeTable
//
//  Created by 岡本 浩揮 on 2015/04/20.
//  Copyright (c) 2015年 Q太郎. All rights reserved.
//

import UIKit

class ConfigPresentationController: UIPresentationController {
    var overlayView: UIView!
    
    override init(presentedViewController: UIViewController!, presentingViewController: UIViewController!) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
    }
    
    func overlayViewTapped(tapRecognizer: UITapGestureRecognizer) {
        presentedViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func presentationTransitionWillBegin() {
        let containerView = self.containerView
        let presentedViewController = self.presentedViewController
        
        overlayView = UIView(frame: containerView.bounds)
        overlayView.gestureRecognizers = [UITapGestureRecognizer(target: self, action: "overlayViewTapped:")]
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.alpha = 0.0
        
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView.frame = overlayView.bounds
        visualEffectView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        
        containerView.insertSubview(overlayView, atIndex: 0)
        
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({
            (coordinatorContext) -> Void in
                self.overlayView.alpha = 0.5
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition( {
            (coordinatorContext) -> Void in
                self.overlayView.alpha = 0.0
        }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        if completed {
            self.overlayView.removeFromSuperview()
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        overlayView.frame = containerView.bounds
        presentedView().frame = frameOfPresentedViewInContainerView()
    }
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSizeMake(parentSize.width / 2.0, parentSize.height)
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        var presentedViewFrame = CGRectZero
        let containerBounds = containerView.bounds
        presentedViewFrame.size = sizeForChildContentContainer(presentedViewController, withParentContainerSize: containerBounds.size)
        presentedViewFrame.origin.x = (containerBounds.size.width - presentedViewFrame.size.width) / 2.0
        presentedViewFrame.origin.y = containerBounds.size.height - presentedViewFrame.size.height
        
        return presentedViewFrame
    }
}
