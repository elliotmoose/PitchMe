//
//  QuizButton.swift
//  Prog
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 2/9/17.
//  Copyright © 2017 Kohbroco. All rights reserved.
//

import UIKit

class QuizButton: UIButton {

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func SetCorrect()
    {
        self.backgroundColor = ColorManager.themeGreen
    }
    
    public func SetIncorrect()
    {
        self.backgroundColor = ColorManager.themeRed
    }
    
    public func SetNormal()
    {
        if isEnabled
        {
            self.backgroundColor = ColorManager.themeLight
        }
        else
        {
            self.backgroundColor = ColorManager.themeBlueDisabled
        }
    }
    
    public func SetAnswer()
    {
        self.backgroundColor = ColorManager.themeOrange
    }
}
