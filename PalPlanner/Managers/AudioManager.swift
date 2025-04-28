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
    private var loopTimer: Timer?
    private var loopStartTime: TimeInterval = 0
    private var loopEndTime: TimeInterval = 0
    private var isCustomLooping: Bool = false
    
    init() {
        // Load saved preference
        isMuted = UserDefaults.standard.bool(forKey: "isMuted")
        
        // Set up audio session immediately
        setupAudioSession()
        
        // Register for audio session interruptions
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        
        print("AudioManager initialized, muted: \(isMuted)")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        loopTimer?.invalidate()
    }
    
    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Audio session was interrupted (e.g., phone call)
            pauseBackgroundMusic()
        case .ended:
            // Interruption ended
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            
            if options.contains(.shouldResume) && !isMuted {
                playBackgroundMusic()
            }
        @unknown default:
            break
        }
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Use .ambient for background music that can play while other apps' audio plays
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            print("Audio session set up successfully")
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func loadBackgroundMusic(fileName: String) {
        // If music is already loaded and playing, don't reload it
        if audioPlayer != nil {
            return
        }
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("Could not find \(fileName).mp3 in the app bundle")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = isCustomLooping ? 0 : -1 // Only use built-in looping if not custom looping
            audioPlayer?.prepareToPlay()
            
            print("Audio duration: \(audioPlayer?.duration ?? 0) seconds")
            
            if !isMuted {
                playBackgroundMusic()
            }
            
            // If custom loop points were set before loading, start monitoring
            if isCustomLooping {
                startLoopPointMonitoring()
            }
        } catch {
            print("Could not create audio player: \(error)")
        }
    }
    
    func playBackgroundMusic() {
        guard let player = audioPlayer else { return }
        
        if !player.isPlaying {
            // Don't restart from the beginning if already initialized
            player.volume = 0.5     // Set to 50% volume
            player.play()
            
            print("Background music started playing")
        }
    }
    
    func pauseBackgroundMusic() {
        audioPlayer?.pause()
        print("Background music paused")
    }
    
    func setupCustomLoopPoints(start: TimeInterval, end: TimeInterval) {
        guard let player = audioPlayer, end > start, end <= player.duration else {
            print("Invalid loop points or player not initialized")
            return
        }
        
        // Store loop points
        loopStartTime = start
        loopEndTime = end
        isCustomLooping = true
        
        // Start monitoring for loop point
        startLoopPointMonitoring()
        
        print("Custom loop points set: \(start)s to \(end)s")
    }
    
    private func startLoopPointMonitoring() {
        // Cancel any existing timer
        loopTimer?.invalidate()
        
        // Create a timer that checks if we need to loop back
        loopTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, 
                  let player = self.audioPlayer, 
                  player.isPlaying,
                  self.isCustomLooping else {
                return
            }
            
            // If we've reached the end point, jump back to start point
            if player.currentTime >= self.loopEndTime {
                player.currentTime = self.loopStartTime
                print("Looped back to \(self.loopStartTime)s")
            }
        }
    }
    
    func disableCustomLoopPoints() {
        isCustomLooping = false
        loopTimer?.invalidate()
        loopTimer = nil
        print("Custom loop points disabled")
    }
    
    func toggleMute() {
        isMuted.toggle()
    }
    
    func setupLoopPointsByPercentage(startPercent: Double, endPercent: Double) {
        guard let player = audioPlayer,
              startPercent >= 0, startPercent < endPercent, endPercent <= 100 else {
            print("Invalid percentage values or player not initialized")
            return
        }
        
        let duration = player.duration
        let startTime = duration * (startPercent / 100.0)
        let endTime = duration * (endPercent / 100.0)
        
        setupCustomLoopPoints(start: startTime, end: endTime)
    }
    
    // Get current playback information for debugging
    func getPlaybackInfo() -> String {
        guard let player = audioPlayer else {
            return "No audio player initialized"
        }
        
        return """
        Duration: \(player.duration)s
        Current position: \(player.currentTime)s
        Is playing: \(player.isPlaying)
        Volume: \(player.volume)
        Custom looping: \(isCustomLooping)
        Loop points: \(loopStartTime)s to \(loopEndTime)s
        """
    }
}
