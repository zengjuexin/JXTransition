//
//  UIViewController+JXTransition.swift
//  Test
//
//  Created by 曾觉新 on 2022/10/10.
//

import UIKit

// 左滑push代理
@objc public protocol JXViewControllerPushDelegate: NSObjectProtocol {
    /// 左滑push，在这里创建将要push的控制器
    @objc optional func pushToNextViewController()
    
    /// push手势滑动开始
    @objc optional func viewControllerPushScrollBegan()
    
    /// push手势滑动进度更新
    /// - Parameter progress: 进度（0-1）
    @objc optional func viewControllerPushScrollUpdate(progress: CGFloat)
    
    /// push手势滑动结束
    /// - Parameter finished: 是否完成push操作（true：push成功 false：push取消）
    @objc optional func viewControllerPushScrollEnded(finished: Bool)
}

// 右滑pop代理
@objc public protocol JXViewControllerPopDelegate: NSObjectProtocol {
    
    @objc optional func viewControllerPopShouldScrollBegan() -> Bool
    
    /// pop手势滑动开始
    @objc optional func viewControllerPopScrollBegan()
    
    /// pop手势滑动进度更新
    /// - Parameter progress: 进度（0-1）
    @objc optional func viewControllerPopScrollUpdate(progress: CGFloat)
    
    /// pop手势滑动结束
    /// - Parameter finished: 是否完成pop操作（true：pop成功 false：pop取消）
    @objc optional func viewControllerPopScrollEnded(finished: Bool)
}


extension UIViewController {
    enum GestureTransitionType: Int {
        ///全屏手势
        case fullScreen
        ///边缘手势
        case edge
        ///禁用手势
        case disabled
        
    }
    
    fileprivate struct AssociatedKeys {
        static var jxDelegateBridge: Int?
        static var jx_gestureType: Int?
    }
    
    /**
     手势类型
     */
    var jx_popGestureType: GestureTransitionType {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.jx_gestureType) as? GestureTransitionType else { return .fullScreen }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.jx_gestureType, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    /**
     代理桥接
     */
    fileprivate var jx_delegateBridge: JXTransitionDelegateBridge {
        get {
            var bridge = objc_getAssociatedObject(self, &AssociatedKeys.jxDelegateBridge) as? JXTransitionDelegateBridge
            if bridge == nil {
                bridge = JXTransitionDelegateBridge()
                objc_setAssociatedObject(self, &AssociatedKeys.jxDelegateBridge, bridge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return bridge!
        }
    }
    
    var jx_pushDelegate: JXViewControllerPushDelegate? {
        get {
            return jx_delegateBridge.jx_pushDelegate
        }
        set {
            jx_delegateBridge.jx_pushDelegate = newValue
        }
    }
    
    var jx_popDelegate: JXViewControllerPopDelegate? {
        get {
            return jx_delegateBridge.jx_popDelegate
        }
        set {
            jx_delegateBridge.jx_popDelegate = newValue
        }
    }
    
}



