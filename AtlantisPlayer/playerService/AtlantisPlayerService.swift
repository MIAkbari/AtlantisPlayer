//
//  AtlantisPlayer.swift
//  AtlantisPlayer
//
//  Created by MohammadAkbari on 12/11/2020.
//

import AVFoundation
import AVKit
import MediaPlayer


class AtlantisPlayer {
    
    var currentAudioIndex = 0
    var isPlaying = false
    var player:AVPlayer? = nil
    var playerItem:AVPlayerItem? = nil
    var avAsset:AVURLAsset? = nil
    var timeObserver:Any?
    var isPLay:Bool = false
    var isShuffled:Bool = false
    var isAll:Bool = true
    var nowPlayingInfo = [String : Any]()
    var commandPlay: Any?
    var commandPause: Any?
    var commandPrev: Any?
    var commandNext: Any?
    var commandPosition: Any?
    var delegate:AtlantisPlayerDelegate!
    let commandCenter = MPRemoteCommandCenter.shared()

    private init() {
        self.setupRemoteTransportControls()
        
        if delegate.atlantisPlayerStart!() {
            
        }
    }
    
    func setupNowPlaying(update:Bool) {
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player?.currentItem?.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = update ? 0 : 1 //player.rate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        
        if !self.isAll {
        } else {
            self.delegate.atlantisPlayerFinish!(state: true)
        }
    }
    
    func play() {
        
        if player?.isPlaying ?? true {
            player?.pause()
            self.delegate.atlantisPlayerPlay!(play: false)
            self.setupNowPlaying(update: false)
        } else {
            player?.play()
            self.delegate.atlantisPlayerPlay!(play: true)
            self.setupNowPlaying(update: true)
        }
        
        isPlaying = !isPlaying
    }
    
}


extension AtlantisPlayer {
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        // Add handler for Play Command
        commandPlay =  commandCenter.togglePlayPauseCommand.addTarget { [unowned self] event in
            return .success
        }
        // Add handler for Pause Command
        commandPrev =  commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            return .success
        }
        
        // Add handler for Pause Command
        commandPrev =  commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            return .success
        }
        
        
        if delegate.atlantisPlayerFree!() {
            commandPosition =  commandCenter.changePlaybackPositionCommand.addTarget { [unowned self](remoteEvent) -> MPRemoteCommandHandlerStatus in
                if let player = self.player {
                    let playerRate = player.rate
                    if let event = remoteEvent as? MPChangePlaybackPositionCommandEvent {
                        player.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: CMTimeScale(1000)), completionHandler: { [unowned self](success) in
                            if success {
                                self.player?.rate = playerRate
                            }
                        })
                        return .success
                    }
                }
                return .commandFailed
            }
        }
    }
    
    
        
}


