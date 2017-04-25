//
//  ViewController.swift
//  XLXContact
//
//  Created by charles on 2017/4/25.
//  Copyright © 2017年 charles. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        XLXContact().getContacts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

