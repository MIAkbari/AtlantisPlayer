//
//  AtlantisPlayer.swift
//  AtlantisPlayer
//
//  Created by MohammadAkbari on 12/11/2020.
//

import AVFoundation
import AVKit
import MediaPlayer


class AtlantisPlayerService:NSObject {
    
    var currentAudioIndex = 0
    var isPlaying = false
    var player:AVPlayer? = nil
    var playerItem:AVPlayerItem? = nil
    var avAsset:AVURLAsset? = nil
    var layer: AVPlayerLayer? = nil
    var timeObserver:Any?
    var isPLay:Bool = false
    var isShuffled:Bool = false
    var isAll:Bool = true
    var isFreeUser:Bool = true
    var urlString:String? = nil
    var id:Int? = nil
    var isVdeo = false
    var view:UIView = .init()
    var nowPlayingInfo = [String : Any]()
    var commandPlay: Any?
    var commandPause: Any?
    var commandPrev: Any?
    var commandNext: Any?
    var commandPosition: Any?
    
    var delegate:AtlantisPlayerDelegate!
    var dataManage:AtlantisPlayerDataManage?
    var videoDelegate:AtlantisVideoPlayerDelegate?
    let commandCenter = MPRemoteCommandCenter.shared()
    var items:[AtlantisPlayerModel] = []
    
    override init() {
        super.init()
        self.setupRemoteTransportControls()
        
    }
    
    deinit {
        self.remoteOff()
    }
    
    func setupNowPlaying(update:Bool) {
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player?.currentItem?.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = update ? 0 : 1 //player.rate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        
        if !self.isAll {
            self.playerStartObserver()
        } else {
            self.next()
            self.delegate.atlantisPlayerFinish(state: true)
        }
    }
    
    func play() {
        
        if player?.isPlaying ?? true {
            player?.pause()
            self.setupNowPlaying(update: false)
            self.delegate.atlantisPlayerStatus(isStart: false)
        } else {
            player?.play()
            self.setupNowPlaying(update: true)
            self.delegate.atlantisPlayerStatus(isStart: true)
        }
        
        isPlaying = !isPlaying
    }
    
    func playerRun() {
        if self.isShuffled {
            let itemShuffle = self.items.shuffled()
            urlString =  itemShuffle[currentAudioIndex].songUrl
            id = itemShuffle[currentAudioIndex].id
            self.shufflePlay(itemShuffle: itemShuffle)
        } else {
            self.deflutPlay(itemDefult: self.items)
        }
        
        self.startPlayer()
    }
    
    func startPlayer() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                self.chcekForFree(url: url)
            }
        }
        
    }
    
    
    
    func shufflePlay(itemShuffle:[AtlantisPlayerModel]) {
        nowPlayingInfo[MPMediaItemPropertyTitle] = itemShuffle[currentAudioIndex].songName
        nowPlayingInfo[MPMediaItemPropertyArtist] = itemShuffle[currentAudioIndex].artist
        guard let image = UIImage(named: itemShuffle[currentAudioIndex].imageCover ?? "") else {
            return
        }
        self.nowPlayingInfo[MPMediaItemPropertyArtwork] =
            MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
        }
        self.dataManage?.atlantisPlayerItems(item: itemShuffle[currentAudioIndex])
    }
    
    func deflutPlay(itemDefult:[AtlantisPlayerModel]) {
        urlString = itemDefult[currentAudioIndex].songUrl
        id = self.items[currentAudioIndex].id
        nowPlayingInfo[MPMediaItemPropertyTitle] = itemDefult[currentAudioIndex].songName
        nowPlayingInfo[MPMediaItemPropertyArtist] = itemDefult[currentAudioIndex].artist
        guard let image = UIImage(named: itemDefult[currentAudioIndex].imageCover ?? "") else {
            return
        }
        self.nowPlayingInfo[MPMediaItemPropertyArtwork] =
            MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
        }
        self.dataManage?.atlantisPlayerItems(item: itemDefult[currentAudioIndex])
    }
    
    
    func chcekForFree(url:URL) {
        // from cach is donwload on user music
        guard let id = self.id else {
            return
        }
        
        if delegate != nil {
            if !self.delegate.atlantisPlayerFree() {
                let item = self.items[currentAudioIndex]
                
                self.checkCach(url: url, id: item.id ?? 0, isVideo: item.isVideo ?? false) { urls, state in
                    //self.playerPlay(url: url )
                    if state {
                        guard let url = urls else {return}
                        print("service avilable")
                        print("service checkCach",url)
                        self.playerPlay(url: url)
                    } else {
                        print("service not avilable")
                        self.playerPlay(url: url)
                        do {
                            try url.cach(to: .documentDirectory,using: id.description, completion: { (urls, err, text) in
                                if err != nil {
                                    if urls?.checkFileExist() ?? true {
                                        
                                        let filemanager = FileManager.default
                                        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
                                        let destinationPath = documentsPath.appendingPathComponent("\(id).mp3")
                                        do {
                                            try filemanager.removeItem(atPath: destinationPath)
                                        } catch let err {
                                            print(err.localizedDescription)
                                        }
                                        
                                    }
                                } else {
                                    print("service finish download")
                                }
                            })
                        } catch {
                            print("err",error.localizedDescription)
                        }
                    }
                }
                
               
            } else {
                self.playerPlay(url: url)
            }
        }
        
    }
    
    private func playerPlay(url:URL) {
        let item = self.items[currentAudioIndex]
        DispatchQueue.main.async {
            self.avAsset = AVURLAsset(url: url)
            let playableKey = "playable"
            self.avAsset?.loadValuesAsynchronously(forKeys: [playableKey]) {
                var error: NSError? = nil
                
                let status = self.avAsset?.statusOfValue(forKey: playableKey, error: &error)
                switch status {
                case .loaded:
                    self.playerItem = AVPlayerItem(asset:self.avAsset!)
                    if self.player == nil {
                        self.player = AVPlayer(playerItem: self.playerItem)
                        if item.isVideo ?? true {
                            DispatchQueue.main.async {
                                self.layer = AVPlayerLayer(player: self.player)
                                
                                guard let customLayer = self.layer else {
                                    return
                                }
                                
                                guard let image = url.videoPreviewImage() else {
                                    return
                                }
                                self.videoDelegate?.atlantisPlayerVideo(isVideo:true,customLayer,previewImage:image)

                            }
                            
                        } else {
                            self.videoDelegate?.atlantisPlayerVideo(isVideo:false,nil,previewImage:nil)
                        }
                    } else {
                        self.player?.replaceCurrentItem(with: self.playerItem)
                        
                        if item.isVideo ?? true {
                            DispatchQueue.main.async {
                                self.layer = AVPlayerLayer(player: self.player)
                                
                                guard let customLayer = self.layer else {
                                    return
                                }
                                guard let image = url.videoPreviewImage() else {
                                    return
                                }
                                self.videoDelegate?.atlantisPlayerVideo(isVideo:true,customLayer,previewImage:image)
                            }
                            
                        } else {
                            self.videoDelegate?.atlantisPlayerVideo(isVideo:false,nil,previewImage:nil)
                        }
                    }
                    
                    
                    self.player?.play()
                    self.delegate.atlantisPlayerStatus(isStart: true)
                    self.player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: [.old, .new], context: nil)
                    self.player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.old,.new], context: nil)
                    self.player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options:[.old,.new], context: nil)

                    self.timeObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main) { [unowned self] time in
                        guard self == self else {
                            return
                        }
                        
                        if self.player?.currentItem?.status == AVPlayerItem.Status.readyToPlay {
                            
                            if let isPlaybackLikelyToKeepUp = self.player?.currentItem?.isPlaybackLikelyToKeepUp {
                                self.delegate.atlantisPlayerBuffring(state: isPlaybackLikelyToKeepUp)
                            }
                            
                            let seconds = CMTimeGetSeconds(time)
                            if !seconds.isNaN {
                                let secs = Int(seconds)
                                let minutes = (secs % 3600) / 60
                                let second = (secs % 3600) % 60
                                let secondsString = String(format: "%02d", second)
                                let minutesString = String(format: "%02d", minutes)
                                self.delegate.atlantisPlayerDurations(minutes: minutesString, seconds: secondsString)
                                if let duration = self.player?.currentItem?.duration {
                                    let durationSeconds = CMTimeGetSeconds(duration)
                                    self.delegate.atlantisPlayerSeek(value: Float(seconds / durationSeconds))
                                }
                                self.setupNowPlaying(update:true)
                            }
                        }
                        
                    }
                case .failed:
                    print("failed:----------************urlsongs*****************-------------")
                case .cancelled:
                    print("cancel:----------************urlsongs*****************-------------")
                default:
                    break
                }
            }
        }
    }
    
    
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        DispatchQueue.main.async {
            //State player current time
            if keyPath == "currentItem.loadedTimeRanges" {
                
                //    self.isPlaying = true
                if let duration = self.player?.currentItem?.duration {
                    let seconds = CMTimeGetSeconds(duration)
                    if !seconds.isNaN {
                        let secondsText = Int(seconds) % 60
                        let minutesText = String(format: "%02d", Int(seconds) / 60)
                        self.delegate.atlantisPlayerCurrentTime(minutes: minutesText, seconds: secondsText.description)
                    }
                    
                    self.delegate.atlantisPlayerPositon(index: self.currentAudioIndex)
                    
                    
                }
                
            }
        }
        
    }
    
    
    func setupVideoLayer() {
        self.layer?.frame = view.bounds
        self.layer?.videoGravity = .resizeAspectFill
        view.layer.sublayers?
                .filter { $0 is AVPlayerLayer }
                .forEach { $0.removeFromSuperlayer() }
        view.layer.addSublayer(layer ?? AVPlayerLayer())
    }
    
    func remoteOff() {
        
        if self.timeObserver != nil {
            self.player?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges")
            self.player?.removeTimeObserver(self.timeObserver as Any)
            self.player?.removeObserver(self, forKeyPath:  #keyPath(AVPlayer.status))
            self.player?.removeObserver(self, forKeyPath:  #keyPath(AVPlayer.currentItem.status))
            NotificationCenter.default.removeObserver(self)
            self.player = nil
            self.timeObserver = nil
        }
        
        if delegate != nil {
            if delegate.atlantisPlayerFree() {
                self.isShuffled = false
            } else {
                self.isShuffled = true
            }
        }
        
        self.timeObserver = nil
        self.playerItem = nil
        self.timeObserver = nil
        self.avAsset = nil
        self.layer = nil
        self.currentAudioIndex = 0
        self.isAll = true
    }
    
    
    func removeNotif()  {
        self.commandCenter.playCommand.removeTarget(commandPlay)
        self.commandCenter.pauseCommand.removeTarget(commandPause)
        self.commandCenter.previousTrackCommand.removeTarget(commandPrev)
        self.commandCenter.nextTrackCommand.removeTarget(commandNext)
        self.commandCenter.changePlaybackPositionCommand.removeTarget(commandPosition)
    }
    
    func next() {
        
        currentAudioIndex += 1
        if currentAudioIndex > items.count-1 {
            currentAudioIndex -= 1
            if self.items.count > 1 {
                currentAudioIndex = 0
                self.next()
                self.delegate.atlantisPlayerNext(isFinish: true)
            } else {
                self.delegate.atlantisPlayerNext(isFinish: false)
            }
            return
        } else {
            self.delegate.atlantisPlayerPositon(index: currentAudioIndex)
            self.delegate.atlantisPlayerNext(isFinish: true)
            self.delegate.atlantisPlayerPrev(isStart: true)
            self.playerStartObserver()
        }
        
       
    }
    
    func playerStartObserver() {
        
        
        DispatchQueue.main.async {
            if self.timeObserver != nil {
                self.player?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges")
                self.player?.removeTimeObserver(self.timeObserver as Any)
                self.player?.removeObserver(self, forKeyPath:  #keyPath(AVPlayer.status))
                self.player?.removeObserver(self, forKeyPath:  #keyPath(AVPlayer.currentItem.status))
                NotificationCenter.default.removeObserver(self)
                self.timeObserver = nil
            }
            self.avAsset = nil
            self.player = nil
            self.layer = nil
            self.timeObserver = nil
            self.delegate.atlantisPlayerReset(isStart: true)
            self.playerRun()
        }
    }
    
    func prev() {
        
        currentAudioIndex -= 1
        if currentAudioIndex < 0 {
            currentAudioIndex += 1
            self.delegate.atlantisPlayerPrev(isStart: false)
            return
        } else {
            self.delegate.atlantisPlayerPositon(index: currentAudioIndex)
            self.delegate.atlantisPlayerNext(isFinish: true)
            self.delegate.atlantisPlayerPrev(isStart: true)
            self.playerStartObserver()
        }
        
       
    }
    
    
    func seekTo(Fvalue:Float) {
        if self.player != nil {
            if let totalSeconds = player?.currentItem?.duration.seconds {
                if !totalSeconds.isNaN {
                    let value = Float64(Fvalue) * totalSeconds
                    let seekTime = CMTime(seconds: value, preferredTimescale: CMTimeScale(1000))
                    player?.seek(to: seekTime, completionHandler: { [weak self](success) in
                        guard let self = self else {return}
                        if success {
                            self.player?.rate = self.player?.rate ?? 0
                        }
                    })
                }
            }
        }
    }
    
    func checkCach(url:URL?,id:Int,isVideo:Bool,complation:@escaping(URL?,Bool)->Void) {
        
        do {
            try url?.hasInStorage(to: .documentDirectory,using: isVideo ? "\(id)":"\(id)", completion: { urls, error in
//                if urls?.checkFileExist() ?? true {
//                    complation(urls,true)
//                } else {
//                    let filemanager = FileManager.default
//                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
//                    let destinationPath = documentsPath.appendingPathComponent("\(id).mp3")
//                    do {
//                        try filemanager.removeItem(atPath: destinationPath)
//                    } catch let err {
//                        print(err.localizedDescription)
//                    }
//                    complation(url,false)
//                }
                if error != nil {
                    complation(urls,false)
                } else {
                    complation(urls,true)
                }
            })
            
        } catch let erorr {
            print(erorr.localizedDescription)
        }
    }
}


extension AtlantisPlayerService {
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        // Add handler for Play Command
        commandPlay =  commandCenter.togglePlayPauseCommand.addTarget { [unowned self] event in
            self.play()
            return .success
        }
        // Add handler for Pause Command
        commandPrev =  commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.next()
            return .success
        }
        
        // Add handler for Pause Command
        commandPrev =  commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.prev()
            return .success
        }
        
        if self.isFreeUser {
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
    
    
    static func setupAVAudioSession() {
          do {
              try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
              try AVAudioSession.sharedInstance().setActive(true)
              try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options:
              .init(rawValue: 0))
              debugPrint("AVAudioSession is Active and Category Playback is set")
              UIApplication.shared.beginReceivingRemoteControlEvents()
          } catch {
              debugPrint("Error: \(error)")
          }
      }

    
    
}


