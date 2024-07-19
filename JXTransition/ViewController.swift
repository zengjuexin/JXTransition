//
//  ViewController.swift
//  JXTransition
//
//  Created by 火山传媒 on 2024/7/19.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        self.jx_pushDelegate = self
        
        //设置为全屏滑动
        self.jx_popGestureType = .fullScreen
    }
}

extension ViewController: JXViewControllerPushDelegate {
    
    func pushToNextViewController() {
        let vc = UIViewController()
        vc.view.backgroundColor = .yellow
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

