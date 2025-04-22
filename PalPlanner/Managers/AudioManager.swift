//
//  AudioManager.swift
//  PalPlanner
//
//  Created by Logan Leatherwood on 4/17/25.
//

import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    @Published var isMuted: Bool = false {
        didSet {
            if isMuted {
                pauseBackgroundMusic()
            } else {
                playBackgroundMusic()
            }
            // Save preference
            UserDefaults.standard.set(isMuted, forKey: "isMuted")
        }
    }
    
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        // Load saved preference
        isMuted = UserDefaults.standard.bool(forKey: "isMuted")
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func loadBackgroundMusic(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "ogg") else {
            print("Could not find \(fileName).ogg in the app bundle")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.prepareToPlay()
            
            if !isMuted {
                playBackgroundMusic()
            }
        } catch {
            print("Could not create audio player: \(error)")
        }
    }
    
    func playBackgroundMusic() {
        if audioPlayer?.isPlaying == false {
            audioPlayer?.play()
        }
    }
    
    func pauseBackgroundMusic() {
        audioPlayer?.pause()
    }
    
    func toggleMute() {
        isMuted.toggle()
    }
}
