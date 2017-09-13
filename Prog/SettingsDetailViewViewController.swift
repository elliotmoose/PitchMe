//
//  SettingsDetailViewViewController.swift
//  Prog
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 10/9/17.
//  Copyright © 2017 Kohbroco. All rights reserved.
//

import UIKit
import StoreKit

class SettingsDetailViewViewController: UIViewController {

    public static let singleton = SettingsDetailViewViewController(nibName: "", bundle: Bundle.main)
    
    private var buttonAnimating = false
    
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var upKeyButton: UIButton!
    @IBOutlet weak var downKeyButton: UIButton!
    @IBOutlet weak var unlockAllFeaturesButton: SpringButton!
    @IBOutlet weak var vibrationSwitch: UISwitch!

    @IBOutlet weak var unlockIcon: UIImageView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "SettingsDetailViewViewController", bundle: Bundle.main)
        
        Bundle.main.loadNibNamed("SettingsDetailViewViewController", owner: self, options: nil)
        
        
        unlockAllFeaturesButton.clipsToBounds = true
        unlockAllFeaturesButton.layer.cornerRadius = 5
        unlockAllFeaturesButton.layer.shadowOpacity = 0.4
        unlockAllFeaturesButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        unlockAllFeaturesButton.layer.masksToBounds = false
        unlockAllFeaturesButton.layer.shadowRadius = 2
        
        upKeyButton.clipsToBounds = true
        upKeyButton.layer.cornerRadius = 5
        downKeyButton.clipsToBounds = true
        downKeyButton.layer.cornerRadius = 5
        
        unlockIcon.image = unlockIcon.image?.withRenderingMode(.alwaysTemplate)
        unlockIcon.tintColor = ColorManager.themeGray
        
        IAPManager.productIdentifiers = NSSet(array: ["unlockAll","com.kohbroco.PitchMe.unlockAll"])

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        buttonAnimating = true
        LoadSettingsUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        buttonAnimating = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AnimateButton()
        LoadSettingsUI()
    }
    
    
    func LoadSettingsUI()
    {
        vibrationSwitch.isOn = SettingsManager.vibrationOn
        RefreshKeyLabel()
    }
    
    @IBAction func instrumentsSegContChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            ProgressionManager.instrument.SetInstrument(instrument: .piano)
        case 1:
            ProgressionManager.instrument.SetInstrument(instrument: .strings)
        case 2:
            ProgressionManager.instrument.SetInstrument(instrument: .bass)
        default:
            ProgressionManager.instrument.SetInstrument(instrument: .piano)
        }
    }
    
    @IBAction func UnlockAllFeaturesButtonPressed(_ sender: UIButton) {
        IAPManager.singleton.BuyProductWithID("com.kohbroco.PitchMe.unlockAll")
    }
    
    func AnimateButton()
    {
        unlockAllFeaturesButton.animation = "pop"
        unlockAllFeaturesButton.force = 0.5
        unlockAllFeaturesButton.animate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4 , execute: {
            if self.buttonAnimating
            {
                self.AnimateButton()
            }
        })
        
    }
    @IBAction func DownKeyButtonPressed(_ sender: UIButton) {
        SettingsManager.OffsetKey(value: -1)
        RefreshKeyLabel()
    }
    
    @IBAction func UpKeyButtonPressed(_ sender: UIButton) {
        SettingsManager.OffsetKey(value: 1)
        RefreshKeyLabel()
    }
    @IBAction func vibrationSwitchChanged(_ sender: UISwitch) {
        SettingsManager.vibrationOn = sender.isOn
    }
    
    func RefreshKeyLabel()
    {
        let notes = ["A","A#","B","C","C#","D","D#","E","F","F#","G","G#"]
        keyLabel.text = "Key: \(notes[SettingsManager.key])"
    }
    
}
