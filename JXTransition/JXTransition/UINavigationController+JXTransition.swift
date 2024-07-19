//
//  UINavigationController+JXTransition.swift
//  Test
//
//  Created by 曾觉新 on 2022/10/10.
//

import UIKit


extension UINavigationController {
    
    /**
     承载手势的视图
     */
    private var gestureView: UIView? {
        return self.interactivePopGestureRecognizer?.view
    }
    /**
     激活转场动画
     */
    func jx_transitionAwake() {
//        UIViewController.jxTransitionAwake()

        self.delegate = self.interactiveTransition
        self.interactivePopGestureRecognizer?.isEnabled = false
        
        self.gestureView?.addGestureRecognizer(pushGesture)
        self.gestureView?.addGestureRecognizer(popGesture)
        self.gestureView?.addGestureRecognizer(edgePopGesture)
    }
    
    
    
}


extension UINavigationController {
    fileprivate struct AssociatedKeys {
        static var screenPanGesture: Int?
        static var panGesture: Int?
        static var panPushGesture: Int?
        static var transition: Int?
    }
    
    var interactiveTransition: JXNavigationInteractiveTransition {
        get {
            var transition = objc_getAssociatedObject(self, &AssociatedKeys.transition) as? JXNavigationInteractiveTransition
            if transition == nil {
                transition = JXNavigationInteractiveTransition()
                transition?.navigationController = self
                
                objc_setAssociatedObject(self, &AssociatedKeys.transition, transition, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return transition!
        }
    }
    
    /**
     边缘滑动手势
     */
    var edgePopGesture: UIScreenEdgePanGestureRecognizer {
        get {
            var panGesture = objc_getAssociatedObject(self, &AssociatedKeys.screenPanGesture) as? UIScreenEdgePanGestureRecognizer
            if panGesture == nil {
                panGesture = UIScreenEdgePanGestureRecognizer(target: self.systemTarget, action: self.systemAction)
                panGesture?.jxTag = "edgePop"
                panGesture?.edges = .left
                panGesture?.delegate = self.interactiveTransition
                
                objc_setAssociatedObject(self, &AssociatedKeys.screenPanGesture, panGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return panGesture!
        }
    }
    
    /**
     全屏返回手势
     */
    var popGesture: UIPanGestureRecognizer {
        get {
            var panGesture = objc_getAssociatedObject(self, &AssociatedKeys.panGesture) as? UIPanGestureRecognizer
            if panGesture == nil {
                panGesture = UIPanGestureRecognizer(target: self.systemTarget, action: self.systemAction)
                panGesture?.jxTag = "pop"
                panGesture?.maximumNumberOfTouches = 1
                panGesture?.delegate = self.interactiveTransition
                objc_setAssociatedObject(self, &AssociatedKeys.panGesture, panGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return panGesture!
        }
    }
    
    /**
     全屏push手势
     */
    var pushGesture: UIPanGestureRecognizer {
        get {
            var panGesture = objc_getAssociatedObject(self, &AssociatedKeys.panPushGesture) as? UIPanGestureRecognizer
            if panGesture == nil {
                panGesture = UIPanGestureRecognizer(target: self.interactiveTransition, action: #selector(self.interactiveTransition.panGestureRecognizerAction(_:)))
                panGesture?.jxTag = "push"
                panGesture?.maximumNumberOfTouches = 1
                panGesture?.delegate = self.interactiveTransition
                objc_setAssociatedObject(self, &AssociatedKeys.panPushGesture, panGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return panGesture!
        }
    }
    
    
    
    var systemTarget: Any? {
        get {
            let internalTargets = self.interactivePopGestureRecognizer?.value(forKey: "targets") as? [AnyObject]
            let internamTarget = internalTargets?.first?.value(forKey: "target")
            return internamTarget
        }
    }
    var systemAction: Selector {
        return NSSelectorFromString("handleNavigationTransition:")
    }
    
    /**
     是否正在做转场动画
     */
    var jx_isTransitioning: Bool? {
        return value(forKey: "_isTransitioning") as? Bool
    }
}
