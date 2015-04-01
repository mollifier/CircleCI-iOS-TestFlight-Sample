//
//  ViewController.swift
//  CircleCI-Sample
//
//  Created by Takahiro Horikawa on 1/7/15.
//  Copyright (c) 2015 Poly's Factory. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let label1 = UILabel(frame: CGRectMake(20, 20, 200, 44))
        label1.text = "label1"
        self.view.addSubview(label1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }


}

