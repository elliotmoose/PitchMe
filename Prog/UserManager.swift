//
//  UserManager.swift
//  Prog
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 6/9/17.
//  Copyright © 2017 Kohbroco. All rights reserved.
//

import Foundation

protocol UserManagerDelegate : class
{
    func DidLevelUp()
}
public class UserManager
{
    public static var experience : Int = 0
    public static var maxExpForLevel = [500,1000,2000,3000,5000,10000]
    public static var currentLevel = 0    
    
    weak static var delegate : UserManagerDelegate?
    
    public static func AddExperience(_ value : Int)
    {
        let ud = UserDefaults.standard
        
        var expIncrement = 0
        var lvlIncrement = 0
        
        guard currentLevel < maxExpForLevel.count else {return}
        if experience + value >= maxExpForLevel[currentLevel] //if needs to lvl up
        {
            expIncrement = value - maxExpForLevel[currentLevel]
            lvlIncrement = 1
        }
        else
        {
            expIncrement = value
        }
        
        
        if let exp = ud.value(forKey: "experience") as? Int
        {
            if exp + expIncrement < 0 //if cant go any lower
            {
                experience = 0
            }
            else
            {                
                experience = exp + expIncrement
            }
            
            ud.set(experience, forKey: "experience")
        }
        else
        {
            //if has never been set
            ud.set(expIncrement, forKey: "experience")
        }
        
        if let lvl = ud.value(forKey: "level") as? Int
        {
            currentLevel = lvl + lvlIncrement
            ud.set(currentLevel, forKey: "level")
        }
        else
        {
            //if has never been set
            ud.set(lvlIncrement, forKey: "level")
        }
        
        
        if lvlIncrement != 0
        {
            delegate?.DidLevelUp()
        }
    }
    
    public static func LoadUserInfo()
    {
        let ud = UserDefaults.standard
        
        if let exp = ud.value(forKey: "experience") as? Int
        {
            experience = exp
        }
        else
        {
            experience = 0
        }
        
        if let lvl = ud.value(forKey: "level") as? Int
        {
            currentLevel = lvl
        }
        else
        {
            currentLevel = 0
        }
        
        if currentLevel >= maxExpForLevel.count
        {
            currentLevel = maxExpForLevel.count - 1
            ud.set(currentLevel, forKey: "level")
        }
    }
}
