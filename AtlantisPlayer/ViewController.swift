//
//  ViewController.swift
//  AtlantisPlayer
//
//  Created by MohammadAkbari on 12/11/2020.
//

import UIKit
import AVKit
import LNPopupController

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
    var isLoading = true
    var playerService:AtlantisPlayerService!

    
    var song_id:Int? = nil
    var song_url:URL? = nil
    
    
    var firstVc:MainVC!
    let barButton = UIBarButtonItem(image: #imageLiteral(resourceName: "play-button-arrowhead").withRenderingMode(.alwaysTemplate).withTintColor(.white), style: .plain, target: self, action: #selector(selectedMov))
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barButton.target = self
        self.popupItem.barButtonItems = [barButton]
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("A")
    }
 
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("B")
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("D")
    }
    
    
    
    func start(player:AtlantisPlayerService?,items:[AtlantisPlayerModel]) {
        playerService = player
        playerService.items = items
        playerService.delegate = self
        playerService.dataManage = self
        playerService.videoDelegate = self
        playerService.isFreeUser = true
        playerService.isFromSync = true
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


    @objc
    func selectedMov() {
        self.playerService.play()
    }
    
    @IBAction func nextSong(_ sender:UIButton) {
        self.playerService.next()
    }
    
    @IBAction func prevSong(_ sender:UIButton) {
        self.playerService.prev()
    }
    
    @IBAction func donalodSong(_ sender:UIButton) {
        do {
            guard let url = self.song_url else {
                return
            }
            
            guard let id = self.song_id else {
                return
            }
            DispatchQueue.main.async {
                self.activity.startAnimating()
            }
            try url.cach(to: .documentDirectory,using: "D\(id)", completion: { (urls, err, text) in
                if err != nil {
                    log(type:.error,err?.localizedDescription ?? "")
//                    if urls?.checkFileExist() ?? true {
//
//                        let filemanager = FileManager.default
//                        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
//                        let destinationPath = documentsPath.appendingPathComponent("\(id).mp3")
//                        do {
//                            try filemanager.removeItem(atPath: destinationPath)
//                        } catch let err {
//                            print(err.localizedDescription)
//                        }
//
//                    }
                } else {
                    log(type:.defult,"finish download")
                }
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                }
            })
        } catch {
            print("err",error.localizedDescription)
        }
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
            self.barButton.image = isStart ? #imageLiteral(resourceName: "pause-button").withRenderingMode(.alwaysTemplate).withTintColor(.white) : #imageLiteral(resourceName: "play-button-arrowhead").withRenderingMode(.alwaysTemplate).withTintColor(.white)
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
        self.popupItem.progress = value
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
        self.song_id = item.id
        self.song_url = URL(string: item.songUrl ?? "")
        self.imageCover.image = UIImage(named: item.imageCover ?? "")
        popupItem.title = item.songName
        popupItem.subtitle = item.album
        popupItem.image = UIImage(named: item.imageCover ?? "")

    }
    
    func atlantisPlayerError(error: AtlantisPlayerError) {
        
    }
    
    
}
