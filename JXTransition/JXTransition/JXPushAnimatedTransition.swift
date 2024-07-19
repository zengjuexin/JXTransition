//
//  JXPushAnimatedTransition.swift
//  Test
//
//  Created by 曾觉新 on 2022/10/10.
//

import UIKit

class JXPushAnimatedTransition: JXBaseAnimatedTransition {

    
    override func animateTransition() {
        guard let toView = self.toViewController?.view else { return }
        
        var fromView = self.fromViewController?.view
        
        let size = self.containerView?.bounds.size ?? .zero
        
        // 解决UITabBarController左滑push时的显示问题
        self.isHideTabBar = (self.fromViewController?.tabBarController != nil) && (self.toViewController?.hidesBottomBarWhenPushed == true)
        
        
        if self.isHideTabBar {
            // 获取fromViewController的截图
            let view: UIView?
            if self.fromViewController?.view.window != nil {
                view = self.fromViewController?.view.window
            }else {
                view = self.fromViewController?.view
            }
            
            if view != nil {
                let captureImage = self.getCapture(with: view!)
                let captureView = UIImageView(image: captureImage)
                captureView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                containerView?.addSubview(captureView)
                fromView = captureView
                self.fromViewController?.jx_captureImage = captureImage
                self.fromViewController?.view.isHidden = true
                self.fromViewController?.tabBarController?.tabBar.isHidden = true
            }
        }
        self.contentView = fromView
        
        
        self.containerView?.addSubview(toView)
        
        
        toView.frame = CGRect(x: size.width, y: 0, width: size.width, height: size.height)
        
        toView.layer.shadowColor = UIColor.black.cgColor
        toView.layer.shadowOpacity = 0.15
        toView.layer.shadowRadius = 3.0
        
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut) {
            
            fromView?.frame = CGRect(x: -(0.3 * size.width), y: 0, width: size.width, height: size.height)
            toView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
        } completion: { finish in
            if self.isHideTabBar {
                if self.contentView != nil {
                    self.contentView!.removeFromSuperview()
                    self.contentView = nil
                }
                self.fromViewController?.view.isHidden = false
                
                if self.fromViewController?.navigationController?.children.count == 1 {
                    self.fromViewController?.tabBarController?.tabBar.isHidden = false
                }
            }
            
            
            self.completeTransition()
        }
    }
}
