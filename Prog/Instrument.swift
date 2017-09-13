//
//  Instrument.swift
//  Prog
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 2/9/17.
//  Copyright © 2017 Kohbroco. All rights reserved.
//

import Foundation
import AVFoundation

public class Instrument :NSObject,AVAudioPlayerDelegate
{
    let notes = ["A","A#","B","C","C#","D","D#","E","F","F#","G","G#"]
    let lowerOctaveLimit = 0
    let upperOctaveLimit = 2 //means it plays up to and inclusive of octave 1
    var instrumentName = "piano"
    var audioPlayers = [AVAudioPlayer]()
    
    
    func PlayNote(noteIndex:Int,octave:Int)
    {
        //normalize notes conform to limits
        var playbackNoteIndex = noteIndex
        var playbackOctave = octave
        while playbackNoteIndex > 11
        {
            playbackNoteIndex -= 12
            playbackOctave += 1
            
//            if playbackOctave > upperOctaveLimit
//            {
//                playbackOctave = upperOctaveLimit
//            }
        }
        
        while playbackNoteIndex < 0
        {
            playbackNoteIndex += 12
            playbackOctave -= 1
            
//            if playbackOctave < lowerOctaveLimit
//            {
//                playbackOctave = lowerOctaveLimit
//            }
        }
        
        //retrieve note
        let noteToPlay = notes[playbackNoteIndex]
        
        //playback
        
        
        if let path = Bundle.main.path(forResource: "Audio Files/\(instrumentName)/\(noteToPlay)\(playbackOctave)", ofType: "wav")
        {
            let noteUrl = URL(fileURLWithPath: path)
            
            do
            {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                
                let audioPlayer = try AVAudioPlayer(contentsOf: noteUrl)
                audioPlayers.append(audioPlayer)
                
                NSLog("playing note: \(noteToPlay)\(playbackOctave)")
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                audioPlayer.delegate = self
                
            }
            catch let error as Error
            {
                NSLog("\(error)")
            }
            
        }
        else
        {
            NSLog("could not find file: \(noteToPlay)\(playbackOctave)" )
        }

        
    }
    
    func PlayChord(chordIndex:Int,octave:Int,min : Bool,dim : Bool,inversion:Int,sus:Int,lastNoteModifier:Int)
    {
        //root note
        var rootOctave = octave
        if inversion > 0
        {
            rootOctave += 1
        }
        
        
        //center note
        var centerOctave = octave
        var centerNote = 0;
        
        if min || dim
        {
            centerNote = chordIndex + 3
        }
        else //maj chord
        {
            centerNote = chordIndex + 4
        }
        
        if inversion == 2
        {
            centerOctave += 1
        }
        
//        if sus == 2
//        {
//            if min
//            {
//                
//            }
//            else
//            {
//                
//            }
//        }
//        else if sus == 4
//        {
//            centerNote += 1
//        }
        
        
        //last note
        var lastNote = chordIndex + 7 //4 half steps
        if lastNoteModifier == 7
        {
            lastNote += 4
        }
        else if lastNoteModifier == 9
        {
            lastNote += 7
        }
        
        if dim
        {
            lastNote -= 1
        }
        
        
        //playback
        switch instrumentName {
        case "strings":
            PlayNote(noteIndex: chordIndex, octave: rootOctave)
            PlayNote(noteIndex: centerNote, octave: centerOctave)
            PlayNote(noteIndex: lastNote, octave: octave)
            
        case "piano":
            PlayNote(noteIndex: chordIndex, octave: rootOctave)
            PlayNote(noteIndex: centerNote, octave: centerOctave)
            PlayNote(noteIndex: lastNote, octave: octave)
        
        case "bass":
            PlayNote(noteIndex: chordIndex, octave: rootOctave)
            
            
        default:
            return
        }

        
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let index = audioPlayers.index(of: player)
        {
            audioPlayers.remove(at: index)
        }
        
    }
    
    public func Kill()
    {
        for audioPlayer in audioPlayers
        {
            audioPlayer.stop()
        }
        
        audioPlayers.removeAll()
    }
    
    public func SetInstrument(instrument : InstrumentType)
    {
        switch instrument {
        case .bass:
            instrumentName = "bass"
        case .strings:
            instrumentName = "strings"
        case .piano:
            instrumentName = "piano"
        }
    }
}

public enum InstrumentType
{
    case piano
    case strings
    case bass
}
