//
//  ViewController.swift
//  Prog
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 2/9/17.
//  Copyright © 2017 Kohbroco. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController,UIScrollViewDelegate,ProgressionManagerDelegate,UserManagerDelegate {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var settingsView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var messageSubLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet var quizButtons: [QuizButton]!
    
    @IBOutlet weak var beginQuizButton: UIButton!
    
    @IBOutlet weak var arrowUp: UIImageView!
    
    @IBOutlet weak var settingsIcon: UIImageView!

    @IBOutlet weak var circleTick: SpringImageView!
    
    let instrument = Instrument()
    
    var answeredCorrectly = false
    
    @IBOutlet weak var moreArrow: UIImageView!
    
    //settings control
    @IBOutlet weak var chordEnableSegCont: UISegmentedControl!
    @IBOutlet weak var inversionsSegCont: UISegmentedControl!
    @IBOutlet weak var octRangeSegCont: UISegmentedControl!
    
    @IBOutlet weak var difficultySegCont: UISegmentedControl!
    @IBOutlet weak var unlockImageFooter: UIImageView!
    //experience
    @IBOutlet weak var expProgressWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var expLevelLabel: SpringLabel!
    @IBOutlet weak var experienceContainerView: UIView!
    @IBOutlet weak var progressBaseView: UIView!
    @IBOutlet weak var progressTrackView: UIView!
    
    let presets = [
        [0,0,0],
        [0,1,0],
        [0,2,0],
        [0,0,1],
        [1,0,0],
        [1,2,0],
        [1,0,1],
        [1,2,1],
        [2,0,1],
        [2,2,1],
        [2,3,1],
    ] // 0: chord, 1: inversion, 2: octave
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //reset
        //UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        
        //UI
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = ColorManager.themeBlue
        mainView.clipsToBounds = false
        mainView.layer.shadowOpacity = 1
        mainView.layer.shadowRadius = 3
        mainView.layer.shadowOffset = CGSize(width: 0, height: 4)

        for button in quizButtons
        {
            button.addTarget(self, action: #selector(Button_TouchUpInside(sender:)), for: .touchUpInside)
            
            button.layer.cornerRadius = 4
        }

        circleTick.image = circleTick.image?.withRenderingMode(.alwaysTemplate)
        circleTick.tintColor = ColorManager.themeGreen
        circleTick.force = 0.6
        
        arrowUp.image = arrowUp.image?.withRenderingMode(.alwaysTemplate)
        arrowUp.tintColor = ColorManager.themeGray
        
        settingsIcon.image = settingsIcon.image?.withRenderingMode(.alwaysTemplate)
        settingsIcon.tintColor = ColorManager.themeLightBlue
        
        moreArrow.image = moreArrow.image?.withRenderingMode(.alwaysTemplate)
        moreArrow.tintColor = ColorManager.themeLightBlue

        unlockImageFooter.image = unlockImageFooter.image?.withRenderingMode(.alwaysTemplate)
        unlockImageFooter.tintColor = ColorManager.themeGray
        
        //#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
        moreArrow.transform = moreArrow.transform.rotated(by: CGFloat(90*Double.pi/180))
        
        
        
        //experience
        progressTrackView.clipsToBounds = true
        progressBaseView.clipsToBounds = true
        experienceContainerView.clipsToBounds = true
        
        progressBaseView.layer.cornerRadius = 4
        progressTrackView.layer.cornerRadius = 4
        experienceContainerView.layer.cornerRadius = 4
        
        
        //delegates
        scrollView.delegate = self
        ProgressionManager.delegate = self
        UserManager.delegate = self
        UserManager.LoadUserInfo()
        
        RefreshAvailableFeatures()
        
        SettingsManager.RandomizeKey()
        RefreshButtonsForKey()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        RefreshButtonsForKey()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UpdateExpProgressBar()
        RefreshButtonsForKey()
    }
    
    @IBAction func StartStopPressed(_ sender: Any) {
        if !ProgressionManager.quizInProgress
        {
            ProgressionManager.BeginQuiz()
            
            beginQuizButton.setTitle("STOP", for: .normal)
            beginQuizButton.setTitleColor(ColorManager.themeRed, for: .normal)
            
            for button in quizButtons
            {
                if button.tag+1 == 1
                {
                    button.SetAnswwer()
                }
            }
        }
        else //stop
        {
            ProgressionManager.EndQuiz()
            
            //UI
            let noteTime = TimeInterval(240/SettingsManager.bpm) //60s/BPM * 4 (4 beats per bar)
            beginQuizButton.isEnabled = false
            beginQuizButton.setTitle("RESETTING...", for: .normal)            
            beginQuizButton.setTitleColor(ColorManager.themeGray, for: .normal)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + noteTime, execute: {

                //reset message labels
                UIView.animate(withDuration: 0.5, animations: {
                    self.messageLabel.alpha = 0
                    self.messageSubLabel.alpha = 0
                }, completion: { (success) in
                    self.messageLabel.text = "HELLO"
                    self.messageSubLabel.text = ""
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.messageLabel.alpha = 1
                        self.messageSubLabel.alpha = 1
                    })
                })
                
                //reset all buttons
                for button in self.quizButtons
                {
                    button.SetNormal()
                }
                
                self.beginQuizButton.setTitle("START", for: .normal)
                self.beginQuizButton.setTitleColor(ColorManager.themeGreen, for: .normal)
                self.beginQuizButton.isEnabled = true
            })
            
        }
    }
    
    
    



    
    //=====================================================================================================================================================================================
    //
    //                                                                              ANSWERING BUTTON FUNCTIONS
    //
    //=====================================================================================================================================================================================
    func Button_TouchUpInside(sender: QuizButton)
    {
        if answeredCorrectly == true || !ProgressionManager.quizInProgress
        {
            return
        }
        
        //check if correct note
        let chosenNash = sender.tag + 1
        
        //ANSWERED CORRECTLY
        if chosenNash == ProgressionManager.currentNash
        {
            answeredCorrectly = true
            if messageLabel.text == "" //so that it wont override the past information
            {
                messageSubLabel.text = ""
                messageLabel.text = ""
                ShowTick()
            }
            
            //Button UI
            sender.SetCorrect()
            
            //experience
            OffsetExperience(negative: false)
        }
        else
        {
            
            //Button UI
            sender.SetIncorrect()
            
            if messageLabel.text == "" //so that it wont override the past information
            {
                messageSubLabel.text = ""
                messageLabel.text = ""
                ShowCross()
            }
            
            
            OffsetExperience(negative: true)
            
            //vibrate
            if SettingsManager.vibrationOn
            {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
    }
    
    func ChordChanged() {
        
        var prevNashButtonText = ""
        
        //Reset all buttons
        for button in quizButtons
        {
            if button.tag+1 == ProgressionManager.prevNash && !answeredCorrectly
            {
                prevNashButtonText = button.titleLabel!.text!
                button.SetAnswwer()
            }
            else
            {
                button.SetNormal()
            }
        }
        
        //IF ANSWER WAS NOT CORRECT
        if !answeredCorrectly
        {
            messageLabel.textColor = ColorManager.themeOrange
            messageSubLabel.text = "Oops that was..."
            messageLabel.text = "\(prevNashButtonText)"
            HideTickCrossImageView()
        }
        else
        {
            messageSubLabel.text = ""
            messageLabel.text = ""
        }
        
        //reset answer
        answeredCorrectly = false
    }
    
    //=====================================================================================================================================================================================
    //                                      
    //                                                                              ANSWER REVIEW FUNCTIONS
    //
    //=====================================================================================================================================================================================
    func ShowTick()
    {
        circleTick.image = #imageLiteral(resourceName: "CircleTick_0002_1x").withRenderingMode(.alwaysTemplate)
        circleTick.tintColor = ColorManager.themeGreen
        circleTick.alpha = 1
        
        circleTick.animationDuration = 0.5
        circleTick.animation = "pop"
        circleTick.animate()
        
        circleTick.delay = CGFloat(140/SettingsManager.bpm)
        circleTick.animation = "fadeOut"
        circleTick.animate()
        
    }
    
    func ShowCross()
    {
        circleTick.image = #imageLiteral(resourceName: "CircleCross_0002_1x").withRenderingMode(.alwaysTemplate)
        circleTick.tintColor = ColorManager.themeRed
        circleTick.alpha = 1
        
        circleTick.animation = "shake"
        circleTick.animationDuration = 0.3
        circleTick.animate()
        
        circleTick.delay = CGFloat(140/SettingsManager.bpm)
        circleTick.animation = "fadeOut"
        circleTick.animate()
        
    }
    
    func HideTickCrossImageView()
    {
        circleTick.alpha = 0
        circleTick.layer.removeAllAnimations()
    }
    
    //=====================================================================================================================================================================================
    //
    //                                                                              EXPERIENCE RELATED FUNCTIONS
    //
    //=====================================================================================================================================================================================
    func OffsetExperience(negative : Bool)
    {
        if !ProgressionManager.quizInProgress
        {
            return
        }
        
        var offsetValue = 25

        if negative
        {
            offsetValue = -offsetValue
        }
        
        UserManager.AddExperience(offsetValue)
        SpawnScoreAnimation(value: offsetValue)
        UpdateExpProgressBar()
    }
    
    func SpawnScoreAnimation(value : Int)
    {
        
        let spawnCoord = CGPoint(x: experienceContainerView.frame.origin.x  - 64, y: experienceContainerView.frame.origin.y)
        let label = SpringLabel(frame: CGRect(x: spawnCoord.x, y: spawnCoord.y, width: 100, height:40))
        label.font = UIFont(name: "Mohave-Bold", size: 35)
        
        if value > 0
        {
            label.text = "+\(value)"
            label.textColor = ColorManager.themeGreen
        }
        else
        {
            label.text = "\(value)"
            label.textColor = ColorManager.themeRed
        }
        
        mainView.addSubview(label)
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            label.frame.origin = CGPoint(x: spawnCoord.x, y: spawnCoord.y - 10)
            label.alpha = 0
        }) { (success) in
            label.removeFromSuperview()
        }
        
    }
    
    func UpdateExpProgressBar()
    {
        guard UserManager.currentLevel < UserManager.maxExpForLevel.count else {NSLog("ERROR: current lvl higher than max lvl");return}
        
        let currentExp = CGFloat(UserManager.experience)
        let maxExpForLevel = CGFloat(UserManager.maxExpForLevel[UserManager.currentLevel])
        let currentExpFraction = currentExp/maxExpForLevel
        
        let newWidth = CGFloat(currentExpFraction)*progressBaseView.frame.width
        
        //animate
        self.expProgressWidthConstraint.constant = newWidth
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.progressBaseView.layoutIfNeeded()
        }, completion: nil)
        
        expLevelLabel.text = "\(UserManager.currentLevel)"
    }
    
    
    func DidLevelUp() {
        
        //unlock ui
        RefreshAvailableFeatures()
        
        
        //Notify user that he leveled up
        expLevelLabel.animation = "zoomIn"
        expLevelLabel.duration = 1
        expLevelLabel.animate()
    }
    //=====================================================================================================================================================================================
    //
    //                                                                               UNLOCK FEATURE FUNCTIONS
    //
    //=====================================================================================================================================================================================
    func RefreshAvailableFeatures()
    {
        switch UserManager.currentLevel {
        case 0:
            inversionsSegCont.setEnabled(false, forSegmentAt: 1)
            inversionsSegCont.setEnabled(false, forSegmentAt: 2)
            inversionsSegCont.setEnabled(false, forSegmentAt: 3)
            chordEnableSegCont.setEnabled(false, forSegmentAt: 1)
            chordEnableSegCont.setEnabled(false, forSegmentAt: 2)
            octRangeSegCont.setEnabled(false, forSegmentAt: 1)
            SetDifficultySegContEnabledTillIndex(0)
        case 1:
            inversionsSegCont.setEnabled(true, forSegmentAt: 1)
            inversionsSegCont.setEnabled(false, forSegmentAt: 2)
            inversionsSegCont.setEnabled(false, forSegmentAt: 3)
            chordEnableSegCont.setEnabled(false, forSegmentAt: 1)
            chordEnableSegCont.setEnabled(false, forSegmentAt: 2)
            octRangeSegCont.setEnabled(false, forSegmentAt: 1)
            SetDifficultySegContEnabledTillIndex(1)
        case 2:
            inversionsSegCont.setEnabled(true, forSegmentAt: 1)
            inversionsSegCont.setEnabled(true, forSegmentAt: 2)
            inversionsSegCont.setEnabled(true, forSegmentAt: 3)
            chordEnableSegCont.setEnabled(false, forSegmentAt: 1)
            chordEnableSegCont.setEnabled(false, forSegmentAt: 2)
            octRangeSegCont.setEnabled(false, forSegmentAt: 1)
            SetDifficultySegContEnabledTillIndex(2)
        case 3:
            inversionsSegCont.setEnabled(true, forSegmentAt: 1)
            inversionsSegCont.setEnabled(true, forSegmentAt: 2)
            inversionsSegCont.setEnabled(true, forSegmentAt: 3)
            chordEnableSegCont.setEnabled(false, forSegmentAt: 1)
            chordEnableSegCont.setEnabled(false, forSegmentAt: 2)
            octRangeSegCont.setEnabled(true, forSegmentAt: 1)
            SetDifficultySegContEnabledTillIndex(3)
        case 4:
            inversionsSegCont.setEnabled(true, forSegmentAt: 1)
            inversionsSegCont.setEnabled(true, forSegmentAt: 2)
            inversionsSegCont.setEnabled(true, forSegmentAt: 3)
            chordEnableSegCont.setEnabled(true, forSegmentAt: 1)
            chordEnableSegCont.setEnabled(false, forSegmentAt: 2)
            octRangeSegCont.setEnabled(true, forSegmentAt: 1)
            SetDifficultySegContEnabledTillIndex(6)
        case 5:
            inversionsSegCont.setEnabled(true, forSegmentAt: 1)
            inversionsSegCont.setEnabled(true, forSegmentAt: 2)
            inversionsSegCont.setEnabled(true, forSegmentAt: 3)
            chordEnableSegCont.setEnabled(true, forSegmentAt: 1)
            chordEnableSegCont.setEnabled(true, forSegmentAt: 2)
            octRangeSegCont.setEnabled(true, forSegmentAt: 1)
            SetDifficultySegContEnabledTillIndex(9)
        case 6:
            inversionsSegCont.setEnabled(true, forSegmentAt: 1)
            inversionsSegCont.setEnabled(true, forSegmentAt: 2)
            inversionsSegCont.setEnabled(true, forSegmentAt: 3)
            chordEnableSegCont.setEnabled(true, forSegmentAt: 1)
            chordEnableSegCont.setEnabled(true, forSegmentAt: 2)
            octRangeSegCont.setEnabled(true, forSegmentAt: 1)
            SetDifficultySegContEnabledTillIndex(9)
        default:
            inversionsSegCont.setEnabled(false, forSegmentAt: 1)
            inversionsSegCont.setEnabled(false, forSegmentAt: 2)
            inversionsSegCont.setEnabled(false, forSegmentAt: 3)
            chordEnableSegCont.setEnabled(false, forSegmentAt: 1)
            chordEnableSegCont.setEnabled(false, forSegmentAt: 2)
            octRangeSegCont.setEnabled(false, forSegmentAt: 1)
            SetDifficultySegContEnabledTillIndex(0)
        }
        
        //available chords
        
        //inversions
        
        //octave
        
        //presets
        
        
        //reference
        /*
         
         lvl 1: unlock 1st inversion
         lvl 2: unlock 2nd inversion & random inversions
         lvl 3: unlock 2 octaves
         lvl 4: unlock all exp 7
         lvl 5: unlock all
 
 
        */
        
    }
    
    func SetDifficultySegContEnabledTillIndex(_ index : Int)
    {
        for i in 0...9
        {
            if i <= index
            {
                difficultySegCont.setEnabled(true, forSegmentAt: i)
            }
            else
            {
                difficultySegCont.setEnabled(false, forSegmentAt: i)
            }
        }
    }
    
    //=====================================================================================================================================================================================
    //
    //                                                                              SETTINGS RELATED FUNCTIONS
    //
    //=====================================================================================================================================================================================
    
    //SETTINGS UI IBACTIONS
    @IBAction func OpenSettingsButtonPressed(_ sender: Any) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 350), animated: true)
    }
    
    @IBAction func MoreButtonPressed(_ sender: Any) {
        self.navigationController?.pushViewController(SettingsDetailViewViewController.singleton, animated: true)
    }
    
    
    @IBAction func chordSegContChanged(_ sender: UISegmentedControl) {
        
        //set allowed chords
        SetChordMode(sender.selectedSegmentIndex)
    }
    
    @IBAction func inversionSegContChanged(_ sender: UISegmentedControl) {
        SetInversionMode(sender.selectedSegmentIndex)
    }
    
    @IBAction func octaveSegContChanged(_ sender: UISegmentedControl) {
        SetOctaveMode(sender.selectedSegmentIndex)
    }
    
    @IBAction func difficultyPresetChanged(_ sender: UISegmentedControl) {
        //set difficulty preset
        let thisDifficulty = presets[sender.selectedSegmentIndex]
        
        SetChordMode(thisDifficulty[0])
        SetInversionMode(thisDifficulty[1])
        SetOctaveMode(thisDifficulty[2])
    }
    
    //backend functions
    func SetChordMode(_ index : Int)
    {
        chordEnableSegCont.selectedSegmentIndex = index
        
        switch index
        {
        case 0:            
            ProgressionManager.SetNashvilleOptions(options: [1,4,5,6])
        case 1:
            ProgressionManager.SetNashvilleOptions(options: [1,2,3,4,5,6])
        case 2:
            ProgressionManager.SetNashvilleOptions(options: [1,2,3,4,5,6,7])            
        default:
            return
        }
        
        DidChangeSetting()
    }
    
    func SetInversionMode(_ index : Int)
    {
        ProgressionManager.inversionMode = index
        
        inversionsSegCont.selectedSegmentIndex = index
        
        DidChangeSetting()
    }
    
    func SetOctaveMode(_ index : Int)
    {
        ProgressionManager.upperChordRange = index + 1
        
        octRangeSegCont.selectedSegmentIndex = index
        
        DidChangeSetting()
    }
    
    func DidChangeSetting()
    {
        let currentSetting = [chordEnableSegCont.selectedSegmentIndex,inversionsSegCont.selectedSegmentIndex,octRangeSegCont.selectedSegmentIndex]
        
        var matchesPreset = false
        for i in 0...presets.count-1
        {
            let thisLevel = presets[i]
            if currentSetting == thisLevel //if theres a match
            {
                //set the difficulty segment UI
                difficultySegCont.selectedSegmentIndex = i
                
                matchesPreset = true
            }
        }
        
        if !matchesPreset
        {
            //deselect all
            difficultySegCont.selectedSegmentIndex = -1
        }
    }
    
    func RefreshButtonsForKey()
    {
        DispatchQueue.main.async {
            for button in self.quizButtons
            {
                let nash = button.tag + 1
                UIView.performWithoutAnimation {
                    button.setTitle("\(nash) (\(ProgressionManager.NashToChord(nash: nash)))", for: .normal)
                    button.layoutIfNeeded()
                }
                
            }
        }
    }
    
    
    //=====================================================================================================================================================================================
    //
    //                                                                              MISC FUNCTIONS
    //
    //=====================================================================================================================================================================================
    
    //DELEGATE FUNCTIONS
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool){
        if scrollView.contentOffset.y > 175
        {
            scrollView.setContentOffset(CGPoint(x: 0, y: 350), animated: true)
        }
        else
        {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
}

