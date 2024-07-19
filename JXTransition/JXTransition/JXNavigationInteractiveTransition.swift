//
//  JXNavigationInteractiveTransition.swift
//  Test
//
//  Created by 曾觉新 on 2022/10/10.
//

import UIKit

class JXNavigationInteractiveTransition: NSObject {
    
    
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    var isGesturePush = false
    
    weak var navigationController: UINavigationController!
    weak var visibleVC: UIViewController?
    
}

extension JXNavigationInteractiveTransition {
    
    @objc func panGestureRecognizerAction(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view else { return }
        
        
        var progress = sender.translation(in: view).x / UIScreen.main.bounds.width
        let velocity = sender.velocity(in: sender.view)


        // 在手势开始的时候判断是push操作还是pop操作
        if sender.state == .began {
            isGesturePush = velocity.x < 0 ? true : false
            visibleVC = self.navigationController.visibleViewController
        }

        if isGesturePush {
            progress = -progress
        }

        progress = min(1, max(0, progress))

        switch sender.state {
        case .began:
            if self.isGesturePush {
                if let visibleVC = self.visibleVC {
                    if visibleVC.jx_pushDelegate != nil {
                        self.interactionController = UIPercentDrivenInteractiveTransition()
                        visibleVC.jx_pushDelegate?.pushToNextViewController?()
                        self.pushScrollBegan()
                    }
                }
            } else {
                self.interactionController = UIPercentDrivenInteractiveTransition()
                self.navigationController.popViewController(animated: true)
                self.popScrollBegan()
            }

        case .changed:
            self.interactionController?.update(progress)
            
            if self.isGesturePush {
                self.pushScrollUpdate(progress: progress)
            } else {
                self.popScrollUpdate(progress: progress)
            }

        default:
            
            var pushFinished: Bool = false
            
            var finishProgress = 0.5
            if self.isGesturePush {
                finishProgress = 0.3
            }            
            
            if progress > finishProgress {
                pushFinished = true
                self.interactionController?.finish()
            } else {
                pushFinished = false
                self.interactionController?.cancel()
            }
            
            if self.isGesturePush {
                pushScrollEnded(finished: pushFinished)
            } else {
                popScrollEnded(finished: pushFinished)
            }
            
            self.interactionController = nil
        }
        
    }
    
    func pushScrollBegan() {
        if let visibleVC = self.visibleVC {
            visibleVC.jx_pushDelegate?.viewControllerPushScrollBegan?()
        }
    }
    
    func pushScrollUpdate(progress: CGFloat) {
        if let visibleVC = self.visibleVC {
            visibleVC.jx_pushDelegate?.viewControllerPushScrollUpdate?(progress: progress)
        }
    }
    
    func pushScrollEnded(finished: Bool) {
        if let visibleVC = self.visibleVC {
            visibleVC.jx_pushDelegate?.viewControllerPushScrollEnded?(finished: finished)
        }
    }
    
    func popScrollBegan() {
        if let visibleVC = self.visibleVC {
            visibleVC.jx_popDelegate?.viewControllerPopScrollBegan?()
        }
    }
    
    func popScrollUpdate(progress: CGFloat) {
        if let visibleVC = self.visibleVC {
            visibleVC.jx_popDelegate?.viewControllerPopScrollUpdate?(progress: progress)
        }
    }
    
    func popScrollEnded(finished: Bool) {
        if let visibleVC = self.visibleVC {
            visibleVC.jx_popDelegate?.viewControllerPopScrollEnded?(finished: finished)
        }
    }
    
}

extension JXNavigationInteractiveTransition: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        ydLog(message: "滑动========\(gestureRecognizer.jxTag ?? "")")
        guard let jxTag = gestureRecognizer.jxTag else { return true }
        
        // 忽略导航控制器正在做转场动画
        if self.navigationController.jx_isTransitioning == true { return false }
        
        // 如果没有visibleViewController，不作处理
        guard let visibleVC = self.navigationController.visibleViewController else { return true }
        
        //页面禁止了手势
        if visibleVC.jx_popGestureType == .disabled { return false }
        
        if let _ = gestureRecognizer as? UIScreenEdgePanGestureRecognizer {
            if visibleVC.jx_popGestureType == .fullScreen { return false } //当前是全屏手势直接返回
            // 修复边缘侧滑返回失效的bug
            if self.navigationController.viewControllers.count <= 1 { return false }
//            ydLog(message: "滑动========这里是边缘手势返回")
            return true
            
        } else if let panGesture = gestureRecognizer as? UIPanGestureRecognizer { //全屏滑动手势处理
            // 根据transition判断是左滑还是右滑
            let transition = panGesture.translation(in: gestureRecognizer.view)
            if transition.x == 0 { return false }
            
            if jxTag == "pop" {
                if visibleVC.jx_popGestureType == .edge { return false }
                if transition.x <= 0 { return false } //左滑直接返回
                if self.navigationController.viewControllers.count <= 1 { return false }
//                ydLog(message: "滑动========这里是pop滑动")
                return true
            } else if jxTag == "push" {
                if transition.x >= 0 { return false } //右滑直接返回
                if visibleVC.jx_pushDelegate == nil { return false }
//                ydLog(message: "滑动========这里是push滑动")
                return true
            }
        }
        
        return true
    }
}

extension JXNavigationInteractiveTransition: UINavigationControllerDelegate {
    
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if interactionController != nil, operation == .pop {
            return JXPopAnimatedTransition()
        } else if interactionController != nil, operation == .push {
            return JXPushAnimatedTransition()
        }
        return nil
    }

    ///处理交互式转场
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if animationController.isKind(of: JXBaseAnimatedTransition.self) {
            return interactionController
        }
        return nil
    }
}
