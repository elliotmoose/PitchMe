//
//  Extensions.swift
//  Prog
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 3/9/17.
//  Copyright © 2017 Kohbroco. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    @IBInspectable var imageColor: UIColor! {
        set {
            super.tintColor = newValue
        }
        get {
            return super.tintColor
        }
    }
}
