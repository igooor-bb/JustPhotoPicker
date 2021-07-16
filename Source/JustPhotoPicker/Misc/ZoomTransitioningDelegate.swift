//
//  ZoomTransitionDelegate.swift
//  PhotoPicker
//
//  Created by Igor Belov on 13.07.2021.
//

import UIKit

protocol ZoomingViewController {
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView?
}

enum TransitionState {
    case initial
    case final
}

class ZoomTransitioningDelegate: NSObject {
    var transitionDuration: TimeInterval = 0.65
    var operation: UINavigationController.Operation = .none
    
    private let zoomScale: CGFloat = 15
    private let backgroundScale: CGFloat = 0.75
    
    private func configureViews(
        for state: TransitionState,
        containerView: UIView,
        backgroundViewController: UIViewController,
        imageViewInBackground: UIView,
        imageViewInForeground: UIView,
        snapshotImageView: UIView) {
        
        switch state {
        case .initial:
            // Set the initial appearance of the backgroundView and its image view.
            backgroundViewController.view.transform = CGAffineTransform.identity
            backgroundViewController.view.alpha = 1
            
            snapshotImageView.frame = containerView.convert(
                imageViewInBackground.frame,
                from: imageViewInBackground.superview)
            
        case .final:
            // Set the final scaled state of backgroundView.
            backgroundViewController.view.transform = CGAffineTransform(
                scaleX: backgroundScale,
                y: backgroundScale)
            
            backgroundViewController.view.alpha = 0
            
            snapshotImageView.frame = containerView.convert(
                imageViewInForeground.frame,
                from: imageViewInForeground.superview)
        }
    }
}

extension ZoomTransitioningDelegate: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        // Make sure that both view controllers conform ZoomingViewController protocol.
        if fromVC is ZoomingViewController && toVC is ZoomingViewController {
            self.operation = operation
            return self
        } else {
            return nil
        }
    }
}

extension ZoomTransitioningDelegate: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        let containerView = transitionContext.containerView
        
        var backgroundViewController = fromViewController
        var foregroundViewController = toViewController
        
        if operation == .pop {
            backgroundViewController = toViewController
            foregroundViewController = fromViewController
        }
        
        // Get the imageview to animate.
        let possibleBackgroundImageView =
            (backgroundViewController as? ZoomingViewController)?.zoomingImageView(for: self)
        let possibleForegroundImageView =
            (foregroundViewController as? ZoomingViewController)?.zoomingImageView(for: self)
        
        assert(possibleBackgroundImageView != nil, "Cannot find image view in backgroundVC in ZoomingTransitioningDelegate")
        assert(possibleForegroundImageView != nil, "Cannot find image view in foregroundVC in ZoomingTransitioningDelegate")
        
        let backgroundImageView = possibleBackgroundImageView!
        let foregroundImageView = possibleForegroundImageView!
        
        let imageViewSnapshot = UIImageView(image: backgroundImageView.image)
        imageViewSnapshot.contentMode = .scaleAspectFill
        imageViewSnapshot.layer.masksToBounds = true
        
        // Prepare container view for animation.
        backgroundImageView.isHidden = true
        foregroundImageView.isHidden = true
        
        let foregroundViewBackgroundColor = foregroundViewController.view.backgroundColor
        foregroundViewController.view.backgroundColor = UIColor.clear
        
        containerView.backgroundColor = UIColor.systemBackground
        containerView.addSubview(backgroundViewController.view)
        containerView.addSubview(foregroundViewController.view)
        containerView.addSubview(imageViewSnapshot)
        
        // Configure direction of transition.
        let firstTransitionState: TransitionState = operation == .pop ? .final : .initial
        let secondTransitionState: TransitionState = operation == .pop ? .initial : .final
        
        // Set the initial state of the transition.
        configureViews(
            for: firstTransitionState,
            containerView: containerView,
            backgroundViewController: backgroundViewController,
            imageViewInBackground: backgroundImageView,
            imageViewInForeground: foregroundImageView,
            snapshotImageView: imageViewSnapshot)
        
        // In case the device was rotated before the animation.
        foregroundViewController.view.layoutIfNeeded()
        
        // Animate from the initial state to the final state.
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            // Set the final state of the transition.
            self.configureViews(
                for: secondTransitionState,
                containerView: containerView,
                backgroundViewController: backgroundViewController,
                imageViewInBackground: backgroundImageView,
                imageViewInForeground: foregroundImageView,
                snapshotImageView: imageViewSnapshot)
        }) { _ in
            backgroundViewController.view.transform = CGAffineTransform.identity
            imageViewSnapshot.removeFromSuperview()
            backgroundImageView.isHidden = false
            foregroundImageView.isHidden = false
            foregroundViewController.view.backgroundColor = foregroundViewBackgroundColor
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
