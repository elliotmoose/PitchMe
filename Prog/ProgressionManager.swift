//
//  ProgressionManager.swift
//  Prog
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 2/9/17.
//  Copyright © 2017 Kohbroco. All rights reserved.
//

import Foundation

protocol ProgressionManagerDelegate : class {
    func ChordChanged()
}

public class ProgressionManager
{
    private static let keyOffsets = [0,2,4,5,7,9,11] //this is the number of halfsteps from the original key to get to the respective chords
    public static let instrument = Instrument()
    
    
    //notes
    public static var nashvilleRecency : [Double] = [1,1,1,1]//reflects the probability of the next note
    
    //settings
    public private(set) static var nashvilleOptions = [1,4,5,6]
    public static var inversionMode = 0
    public static var lowerChordRange = 0
    public static var upperChordRange = 0
    
    //state
    public static var currentChord = 0
    public static var currentNash = 0
    public static var prevChord = 0
    public static var prevNash = 0
    
    public static var quizInProgress = false
    public static var quizIntroPlaying = false
    
    //backend
    static weak var delegate : ProgressionManagerDelegate?
    
    public static func PlayNextChord()
    {
        if !quizInProgress
        {
            return
        }
        
        let nash = GetNextProbableNashville()
        let chordIndex = SettingsManager.key + keyOffsets[nash - 1]
        //inversion
        let inversions = [0,1,2,Int(arc4random_uniform(3))]
        let mode = inversionMode
        let thisInversion = inversions[mode]
        
        //major minor
        let isMins = [false,true,true,false,false,true,true]
        let isMin = isMins[nash-1]
        var isDim = false
        if nash == 7
        {
            isDim = true
        }
        //octave 
        let chordOctave = Int(arc4random_uniform(UInt32(upperChordRange - lowerChordRange+1))) + lowerChordRange
        
        //playback
        instrument.PlayChord(chordIndex: chordIndex, octave: chordOctave,min : isMin, dim: isDim, inversion: thisInversion, sus: 0, lastNoteModifier: 0)
        
        let recBef = nashvilleRecency //for debuggin purposes
        
        //recency
        for i in 0...nashvilleRecency.count-1
        {
            if nashvilleOptions[i] != nash //if just played
            {
                let factor : Double = (1/Double(nashvilleRecency.count))/3
                
                //drop the probability
                if nashvilleRecency[i] > 0.5
                {
                    nashvilleRecency[i] = nashvilleRecency[i] + factor*4
                }
                else if nashvilleRecency[i] > 0.4
                {
                    nashvilleRecency[i] = nashvilleRecency[i] + factor*3
                }
                else if nashvilleRecency[i] > 0.3
                {
                    nashvilleRecency[i] = nashvilleRecency[i] + factor*2
                }
                else
                {
                    nashvilleRecency[i] = nashvilleRecency[i] + factor
                }
            }
            else
            {
                nashvilleRecency[i] = (1/Double(nashvilleRecency.count))/3
            }

        }
        
        //normalize
        var sum = nashvilleRecency.reduce(0,+)
        for i in 0...nashvilleRecency.count-1
        {
            nashvilleRecency[i] = nashvilleRecency[i]/sum
        }
        
        
        for i in 0...nashvilleRecency.count-1
        {
            if nashvilleOptions[i] == nash
            {
                NSLog("\(recBef[i]) ==> \(nashvilleRecency[i])")
            }
            else
            {
                NSLog("\(recBef[i]) --> \(nashvilleRecency[i])")
            }
        }
        
        
        //notify played
        if let delegate = self.delegate
        {
            delegate.ChordChanged()
        }
        
        
        //recursive function
        let noteTime = TimeInterval(240/SettingsManager.bpm) //60s/BPM * 4 (4 beats per bar)
        DispatchQueue.main.asyncAfter(deadline: .now() + noteTime, execute: {
            self.PlayNextChord()
        })
    }
    
    
    
    public static func GetNextProbableNashville() -> Int
    {
        //step 1: based on the recency probabilities, find the index of nashvilleOptions that should be played
        var newNash = 0
        var newChord = 0
        
        newNash = nashvilleOptions[randomNumber(probabilities: nashvilleRecency)]
        newChord = SettingsManager.key + keyOffsets[newNash - 1]
        
        //step 2a: remove conflict w prev played (no repeats)
        while newChord == currentChord
        {
            newNash = nashvilleOptions[Int(arc4random_uniform(UInt32(nashvilleOptions.count)))]
            newChord = SettingsManager.key + keyOffsets[newNash - 1]
        }
        
        prevChord = currentChord
        prevNash = currentNash
        currentChord = newChord
        currentNash = newNash
        
        return newNash
    }
    
    private static func randomNumber(probabilities: [Double]) -> Int {
        
        // Sum of all probabilities (so that we don't have to require that the sum is 1.0):
        let sum = probabilities.reduce(0, +)
        // Random number in the range 0.0 <= rnd < sum :
        let rnd = sum * Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max)
        // Find the first interval of accumulated probabilities into which `rnd` falls:
        var accum = 0.0
        for (i, p) in probabilities.enumerated() {
            accum += p
            if rnd < accum {
                return i
            }
        }
        // This point might be reached due to floating point inaccuracies:
        return (probabilities.count - 1)
    }
    
    public static func BeginQuiz()
    {
        quizInProgress = true
        
        RefreshRecency()
        
        let noteTime = TimeInterval(240/SettingsManager.bpm) //60s/BPM * 4 (4 beats per bar)
        
        //play root twice
        PlayRoot()
        quizIntroPlaying = true
        DispatchQueue.main.asyncAfter(deadline: .now() + noteTime, execute: {
            quizIntroPlaying = false
            self.PlayNextChord()
        })
    }
    
    public static func EndQuiz()
    {
        quizInProgress = false
        instrument.Kill()
        
        currentNash = 0
        currentChord = 0
    }
    
    
    private static func PlayRoot()
    {
        if !quizInProgress
        {
            return
        }
        
        //playback
        currentNash = 1
        currentChord = SettingsManager.key
        instrument.PlayChord(chordIndex: SettingsManager.key, octave: 0, min: false, dim: false, inversion: 0, sus: 0, lastNoteModifier: 0)
    }
    
    public static func SetNashvilleOptions( options :[Int])
    {
        nashvilleOptions = options
        RefreshRecency()
    }
    
    private static func RefreshRecency()
    {
        nashvilleRecency.removeAll()
        for _ in 0...nashvilleOptions.count-1
        {
            nashvilleRecency.append(1)
        }
    }
    
    public static func NashToChord(nash : Int) -> String
    {
        let notes = ["A","A#","B","C","C#","D","D#","E","F","F#","G","G#"]
        
        var index = SettingsManager.key + keyOffsets[nash - 1]
        
        while index > 11
        {
            index = index - 12
        }
        
        while index < 0
        {
            index = index + 12
        }
        
        var output = notes[index]
        
        if nash == 2 || nash == 3 || nash == 6
        {
            output = "\(output)m"
        }
        else if nash == 7
        {
            output = "\(output)dim"
        }
        
        return output
    }
    
    
    
}
