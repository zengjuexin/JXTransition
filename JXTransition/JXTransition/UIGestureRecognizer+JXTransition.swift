//
//  UIGestureRecognizer+JXTransition.swift
//  YDLive
//
//  Created by 曾觉新 on 2022/11/29.
//

import UIKit

extension UIGestureRecognizer {
    
    fileprivate struct AssociatedKeys {
        static var jxTag: Int?
    }
    
    var jxTag: String? {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.jxTag) as? String else { return nil }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.jxTag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
