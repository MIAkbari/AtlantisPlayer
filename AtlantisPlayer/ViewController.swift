//
//  ViewController.swift
//  AtlantisPlayer
//
//  Created by MohammadAkbari on 12/11/2020.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var labelDurations:UILabel!
    @IBOutlet weak var labelCurrentTime:UILabel!
    @IBOutlet weak var imageCover:UIImageView! {
        didSet {
            imageCover.layer.cornerRadius = 10
            imageCover.contentMode = .scaleToFill
        }
    }
    @IBOutlet weak var slider:UISlider!
    @IBOutlet weak var btnPlay:UIButton!
    @IBOutlet weak var btnNext:UIButton!
    @IBOutlet weak var btnPrev:UIButton!
    @IBOutlet weak var btnDownload:UIButton!
    @IBOutlet weak var btnShuffle:UIButton! {
        didSet {
            btnShuffle.tintColor = .gray
        }
    }
    @IBOutlet weak var btnReapat:UIButton! {
        didSet {
            btnReapat.tintColor = .gray
        }
    }
    @IBOutlet weak var activity:UIActivityIndicatorView!

    var isShuffleState = false
    
    var playerService = AtlantisPlayerService()

    let items:[AtlantisPlayerModel] = [
        .init(isVideo:true,album: "AAAA", artist: "AAAAA", imageCover:
                "1", songUrl: "https://baarzesh.net/wp-content/uploads/2018/12/%D9%84%DB%8C%D8%B1%DB%8C%DA%A9%D8%B3-%D9%88%DB%8C%D8%AF%D8%A6%D9%88%DB%8C-%D8%A7%D9%87%D9%86%DA%AF-in-my-feelings-%D8%A7%D8%B2-drake.mp4?_=2", songName: "Speaicl", id: 10),
            
            .init(isVideo:false,album: "BBBB", artist: "BBBB", imageCover:
                    "2", songUrl: "https://baarzesh.net/wp-content/uploads/2018/10/Perfect-ED-SHEERAN.mp3", songName: "Speaicl", id: 11),
            .init(isVideo:false,album: "CCCC", artist: "CCCC", imageCover:
                    "3", songUrl: "https://baarzesh.net/wp-content/uploads/2018/12/Girls-Like-You-MAROON-5-ft-CARDI-B.mp3", songName: "Speaicl", id: 12),
            
            .init(isVideo:false,album: "DDDDD", artist: "DDDDD", imageCover:
                    "1", songUrl: "https://baarzesh.net/wp-content/uploads/2019/08/gods-plan.mp3", songName: "Speaicl", id: 13)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerService.items = items
        playerService.delegate = self
        playerService.dataManage = self
        playerService.videoDelegate = self
        playerService.isFreeUser = true
        playerService.playerRun()
    }
    
    func addVideoPlayer(layer: AVPlayerLayer? = nil,image:UIImage?) {
       
        DispatchQueue.main.async {
          //  self.imageCover.image = image
            layer?.backgroundColor = UIColor.white.cgColor
            layer?.frame = self.imageCover.bounds
            layer?.videoGravity = .resizeAspect
            self.imageCover.layer.sublayers?
                .filter { $0 is AVPlayerLayer }
                .forEach { $0.removeFromSuperlayer() }
            if layer != nil {
                self.imageCover.layer.addSublayer(layer!)
            }
        }
    }


    
    @IBAction func nextSong(_ sender:UIButton) {
        self.playerService.next()
    }
    
    @IBAction func prevSong(_ sender:UIButton) {
        self.playerService.prev()
    }
    
    @IBAction func donalodSong(_ sender:UIButton) {
    }
    
    @IBAction func shuffleSong(_ sender:UIButton) {
        if self.playerService.isShuffled {
            self.playerService.isShuffled = false
            self.btnShuffle.tintColor = .gray
        } else {
            self.playerService.isShuffled  = true
            self.btnShuffle.tintColor = .black
        }
    }
    
    @IBAction func repatSong(_ sender:UIButton) {
       
        if self.playerService.isAll {
            self.playerService.isAll = false
            self.btnReapat.tintColor = .gray
        } else {
            self.btnReapat.tintColor = .black
            self.playerService.isAll = true
        }
    }
    
    @IBAction func playSong(_ sender:UIButton) {
        self.playerService.play()
    }
    
    @IBAction func sliderSeek(_ sender:UISlider) {
        self.playerService.seekTo(Fvalue: sender.value)
    }
}


extension ViewController:AtlantisPlayerDelegate ,AtlantisPlayerDataManage ,AtlantisVideoPlayerDelegate{
    func atlantisPlayerVideo(isVideo: Bool, _ layer: AVPlayerLayer?, previewImage: UIImage?) {
        if isVideo {
            self.addVideoPlayer(layer: layer, image: previewImage)
        } else {
            self.addVideoPlayer(layer: layer, image: previewImage)
        }
    }
    

    
  
    
    
    func atlantisPlayerStatus(isStart: Bool) {
        DispatchQueue.main.async {
            self.btnPlay.setImage(isStart ? UIImage(named: "pause-button"):UIImage(named: "play-button-arrowhead"), for: .normal)
        }
    }
    
    
    
    
    func atlantisPlayerFinish(state: Bool) {
        
    }
    
    func atlantisPlayerBuffring(state: Bool) {
        
        if state {
            self.activity.stopAnimating()
            self.activity.isHidden = state
        } else {
            self.activity.isHidden = true
            self.activity.startAnimating()
        }
    }
    
    func atlantisPlayerIsCash(state: Bool) {
        
    }
    
    func atlantisPlayerPositon(index: Int) {
        
    }
    
    
    
    func atlantisPlayerNext(isFinish: Bool) {
        self.btnNext.isEnabled = isFinish
    }
    
    func atlantisPlayerPrev(isStart: Bool) {
        self.btnPrev.isEnabled = isStart
    }
    
    func atlantisPlayerReset(isStart: Bool) {
        self.labelDurations.text = "00:00"
        self.labelCurrentTime.text = "00:00"
        self.slider.value = 0
    }
    
    func atlantisPlayerFree() -> Bool {
        return false
    }
    
    func atlantisPlayerDownload(isDownload: Bool) {
        
    }
    
    
   
    
    func atlantisPlayerSeek(value: Float) {
        self.slider.value = value
    }
    
    
    
 
    
    func atlantisPlayerDurations(minutes: String, seconds: String) {
        self.labelDurations.text = "\(minutes):\(seconds)"
    }
    
    func atlantisPlayerCurrentTime(minutes: String, seconds: String) {
        self.labelCurrentTime.text = "\(minutes):\(seconds)"
    }
    
    func atlantisPlayerStart() -> Bool {
        return true
    }
    
    func atlantisPlayerItems(item: AtlantisPlayerModel) {
        self.imageCover.image = UIImage(named: item.imageCover ?? "")
    }
    
    func atlantisPlayerError(error: AtlantisPlayerError) {
        
    }
    
    
}
