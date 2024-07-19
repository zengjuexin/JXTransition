//
//  JXTransitionDelegateBridge.swift
//  Test
//
//  Created by 曾觉新 on 2022/10/10.
//

import UIKit

class JXTransitionDelegateBridge: NSObject {
    
    weak var jx_pushDelegate: JXViewControllerPushDelegate?
    
    weak var jx_popDelegate: JXViewControllerPopDelegate?
    
}
