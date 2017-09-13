//
//  TransparentScrollView.swift
//  Prog
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 3/9/17.
//  Copyright © 2017 Kohbroco. All rights reserved.
//

import UIKit

class TransparentScrollView: UIScrollView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
}
