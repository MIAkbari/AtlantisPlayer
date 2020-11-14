//
//  PlayerDelegate.swift
//  AtlantisPlayer
//
//  Created by MohammadAkbari on 12/11/2020.
//

import Foundation
import UIKit
import AVFoundation

protocol AtlantisPlayerDelegate {
    
    func atlantisPlayerNext(isFinish:Bool)
    func atlantisPlayerPrev(isStart:Bool)
    func atlantisPlayerReset(isStart:Bool)
    func atlantisPlayerStatus(isStart:Bool)
    func atlantisPlayerFree()->Bool
    func atlantisPlayerDownload(isDownload:Bool)
    func atlantisPlayerDurations(minutes:String,seconds:String)
    func atlantisPlayerCurrentTime(minutes:String,seconds:String)
    func atlantisPlayerSeek(value:Float)
    func atlantisPlayerFinish(state:Bool)
    func atlantisPlayerBuffring(state:Bool)
    func atlantisPlayerIsCash(state:Bool)
    func atlantisPlayerPositon(index:Int)


}

protocol AtlantisVideoPlayerDelegate {
    
    func atlantisPlayerVideo(isVideo:Bool, _ layer:AVPlayerLayer?,previewImage:UIImage?)
}

protocol AtlantisPlayerDataManage {
    
    func atlantisPlayerItems(item:AtlantisPlayerModel)
    func atlantisPlayerError(error:AtlantisPlayerError)
}

enum AtlantisPlayerError {
    case networkError
    case unavailable
    case Operation_Stopped
}
