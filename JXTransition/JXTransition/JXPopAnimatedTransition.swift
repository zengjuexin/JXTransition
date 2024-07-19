//
//  JXPopAnimatedTransition.swift
//  Test
//
//  Created by 曾觉新 on 2022/10/10.
//

import UIKit

class JXPopAnimatedTransition: JXBaseAnimatedTransition {
    
    override func animateTransition() {
        guard let fromView = self.fromViewController?.view else { return }
        
        var toView = self.toViewController?.view
        
        if toView == nil { return }
        
        self.containerView?.insertSubview(toView!, belowSubview: fromView)
        
        let size = self.containerView?.bounds.size ?? .zero
        
        self.isHideTabBar = (self.toViewController?.tabBarController != nil) && (self.fromViewController?.hidesBottomBarWhenPushed == true) && (self.toViewController?.jx_captureImage != nil)
        
        if self.isHideTabBar {
            let captureView = UIImageView(image: self.toViewController?.jx_captureImage!)
            
            captureView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            self.containerView?.insertSubview(captureView, belowSubview: fromView)
            toView = captureView
            self.toViewController?.view.isHidden = true
            self.toViewController?.tabBarController?.tabBar.isHidden = true
        }
        self.contentView = toView
        
        
        fromView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        toView!.frame = CGRect(x: -(0.3 * size.width), y: 0, width: size.width, height: size.height)
        
        fromView.layer.shadowColor = UIColor.black.cgColor
        fromView.layer.shadowOpacity = 0.15
        fromView.layer.shadowRadius = 3.0
        
        UIView.animate(withDuration: animationDuration(), delay: 0, options: .curveEaseInOut) {
            
            fromView.frame = CGRect(x: size.width, y: 0, width: size.width, height: size.height)
            
            if #available(iOS 11.0, *) {
                toView!.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            }else {
                toView!.transform = .identity
            }
            
        } completion: { finish in
            
            if self.isHideTabBar {
                if self.contentView != nil {
                    self.contentView?.removeFromSuperview()
                    self.contentView = nil
                }
                self.toViewController?.view.isHidden = false
                if self.toViewController?.navigationController?.children.count == 1 {
                    self.toViewController?.tabBarController?.tabBar.isHidden = false
                }
            }
            
            self.completeTransition()
        }
    }
    
    
}
