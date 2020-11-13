//
//  AtlantisPlayerModel.swift
//  AtlantisPlayer
//
//  Created by MohammadAkbari on 12/11/2020.
//

import Foundation


class AtlantisPlayerModel {
    
    let album:String?
    let artist:String?
    let imageCover:String?
    let songUrl:String?
    let songName:String?
    let id:Int?
    let isVideo:Bool?
    
    init(isVideo:Bool,album:String,artist:String,imageCover:String,songUrl:String,songName:String,id:Int) {
        self.album = album
        self.artist = artist
        self.imageCover = imageCover
        self.songUrl = songUrl
        self.songName = songName
        self.id = id
        self.isVideo = isVideo
    }
    
}
