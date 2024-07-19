//
//  JXBaseAnimatedTransition.swift
//  Test
//
//  Created by 曾觉新 on 2022/10/10.
//

import UIKit

class JXBaseAnimatedTransition: NSObject {

    open var isHideTabBar = false
    
    open var transitionContext: UIViewControllerContextTransitioning?
    open weak var containerView: UIView?
    open weak var fromViewController: UIViewController?
    open weak var toViewController: UIViewController?
    
    open var contentView: UIView?
    
//    open var isScale = false
//    open var shadowView: UIView!
//    open var isHideTabBar = false
//    open var contentView: UIView?
    
    
    open func getCapture(with view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension JXBaseAnimatedTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(UINavigationController.hideShowBarDuration)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        
        self.containerView = containerView
        self.fromViewController = fromVC
        self.toViewController = toVC
        self.transitionContext = transitionContext
        
        animateTransition()
    }
    
    
    @objc open func animateTransition() {
        // SubClass Implementation
    }
    
    public func completeTransition() {
        guard let transitionContext = self.transitionContext else { return }
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
    
    public func animationDuration() -> TimeInterval {
        return self.transitionDuration(using: self.transitionContext)
    }
    
}


extension UIViewController {
    fileprivate struct AssociatedKeys {
        static var defCaptureImage: Int?
    }
    
    public var jx_captureImage: UIImage? {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.defCaptureImage) else { return nil }
            return obj as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.defCaptureImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
