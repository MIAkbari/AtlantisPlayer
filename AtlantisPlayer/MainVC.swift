//
//  MainVC.swift
//  AtlantisPlayer
//
//  Created by MohammadAkbari on 14/11/2020.
//

import UIKit
import LNPopupController

class MainVC: UIViewController {
    
    @IBOutlet weak var button:UIButton!
    var viewController:ViewController!
    
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
    
    let player = AtlantisPlayerService()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.config()
    }
    
    func config() {
        self.popupBar.imageView.layer.cornerRadius = 3
        self.popupBar.tintColor = .white
        self.popupBar.barTintColor = .darkGray
        self.popupBar.progressViewStyle = .bottom
        self.popupInteractionStyle = .drag
    }
    
    
    @IBAction func openPlayer(_ sender:UIButton) {
        
        if let vc = storyboard?.instantiateViewController(identifier: "ViewController") as? ViewController {
           self.presentPopupBar(withContentViewController: vc, openPopup: true, animated: true)
            player.remoteOff()
            vc.start(player:player,items: items)

        }
        
    }
    
 
    
}

