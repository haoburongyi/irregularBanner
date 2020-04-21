//
//  ViewController.swift
//  demo
//
//  Created by zhanghao on 2020/4/21.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let banner = ZHHomeRecommendBanner.init(frame: .init(x: 0, y: 100, width: view.bounds.width, height: 200))
        banner.models = ["test1", "test2", "test3"]
        view.addSubview(banner)
    }


}

