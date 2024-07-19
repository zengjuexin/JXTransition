//
//  JXTransitionDefine.swift
//  Test
//
//  Created by 曾觉新 on 2022/10/11.
//

import UIKit

public func jx_swizzled_instanceMethod(_ prefix: String, oldClass: Swift.AnyClass!, oldSelector: String, newClass: Swift.AnyClass) {
    let newSelector = prefix + "_" + oldSelector;
    
    let originalSelector = NSSelectorFromString(oldSelector)
    let swizzledSelector = NSSelectorFromString(newSelector)
    
    let originalMethod = class_getInstanceMethod(oldClass, originalSelector)
    let swizzledMethod = class_getInstanceMethod(newClass, swizzledSelector)
    
    let isAdd = class_addMethod(oldClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
    
    if isAdd {
        class_replaceMethod(newClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
    }else {
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}


// MARK: - Swizzling会改变全局状态，所以用DispatchQueue.once来确保无论多少线程都只会被执行一次
extension DispatchQueue {
    private static var onceTracker = [String]()
    // Executes a block of code, associated with a unique token, only once.  The code is thread safe and will only execute the code once even in the presence of multithreaded calls.
    public class func once(token: String, block: () -> Void) {
        // 保证被 objc_sync_enter 和 objc_sync_exit 包裹的代码可以有序同步地执行
        objc_sync_enter(self)
        defer { // 作用域结束后执行defer中的代码
            objc_sync_exit(self)
        }
        
        if onceTracker.contains(token) {
            return
        }
        
        onceTracker.append(token)
        block()
    }
}
