//
//  ConfigViewController.swift
//  TimeTable
//
//  Created by 岡本 浩揮 on 2015/04/20.
//  Copyright (c) 2015年 Q太郎. All rights reserved.
//

import UIKit

class ConfigViewController : UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
    }
}
