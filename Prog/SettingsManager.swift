//
//  SettingsManager.swift
//  Prog
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 3/9/17.
//  Copyright © 2017 Kohbroco. All rights reserved.
//

import Foundation

public class SettingsManager
{    
    public static var inversions = false
    public static var bpm = 120
    public static var key = 3
    public static var selectedInstrument = 0
    public static var vibrationOn = true    
    
    public static func RandomizeKey()
    {
        key = Int(arc4random_uniform(11))
    }
    
    public static func OffsetKey(value : Int)
    {
        key += value
        
        if key == 12
        {
            key = 0
        }
        
        if key == -1
        {
            key = 11
        }
    }
}
