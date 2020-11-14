//
//  AtalnatisExtentions.swift
//  AtlantisPlayer
//
//  Created by MohammadAkbari on 12/11/2020.
//

import Foundation
import AVKit



extension URL {
    
    
    public func videoPreviewImage() -> UIImage? {
        let asset = AVAsset(url: self)
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        assetGenerator.appliesPreferredTrackTransform = true
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        var image: UIImage?
        do {
            let cgImage = try assetGenerator.copyCGImage(at: timestamp, actualTime: nil)
            image = UIImage(cgImage: cgImage)
        } catch {
            print("failed to generated image with error: \(error)")
        }
        return image
    }
    
    
    func hasInStorage(to directory: FileManager.SearchPathDirectory, using fileName: String? = nil, overwrite: Bool = false, completion: @escaping (URL?, String?) -> Void) throws {
        let directory = try FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
        let destination: URL
        if let fileName = fileName {
            destination = directory
                .appendingPathComponent(fileName)
                .appendingPathExtension(self.pathExtension)
        } else {
            destination = directory
                .appendingPathComponent(lastPathComponent)
        }
        
        if destination.checkFileExist() {
            completion(destination, nil)
        } else {
            completion(destination, "error")
        }
    }
    
    func deleateFile(to directory: FileManager.SearchPathDirectory, using fileName: String? = nil, overwrite: Bool = false) throws {
        let directory = try FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
        let destination: URL
        if let fileName = fileName {
            destination = directory
                .appendingPathComponent(fileName)
                .appendingPathExtension(self.pathExtension)
        } else {
            destination = directory
                .appendingPathComponent(lastPathComponent)
        }
        let fileManager = FileManager.default
        let docDir = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let filePath = docDir.appendingPathComponent(String(destination.description.dropFirst(9)))
        do {
            try FileManager.default.removeItem(at: filePath)
            print("File deleted")
        }
        catch {
            print("Error")
        }
        
    }
    
    
    func cach(to directory: FileManager.SearchPathDirectory, using fileName: String? = nil, overwrite: Bool = false, completion: @escaping (URL?, Error?,String) -> Void) throws {
        let directory = try FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
        let destination: URL
        
        if let fileName = fileName {
            destination = directory
                .appendingPathComponent(fileName)
                .appendingPathExtension(self.pathExtension)
        } else {
            destination = directory
                .appendingPathComponent(lastPathComponent)
        }
        
        if !overwrite, FileManager.default.fileExists(atPath: destination.path) {
            completion(destination, nil,"u")
            return
        }
        
        URLSession.shared.downloadTask(with: self) { location,_, error in
            guard let location = location else {
                completion(nil, error,"e")
                return
            }
            
            
            do {
                if overwrite, FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.moveItem(at: location, to: destination)
                completion(destination, nil,"n")
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func checkFileExist() -> Bool {
        let path = self.path
        if (FileManager.default.fileExists(atPath: path))   {
            log(type: .defult, "AVAILABLE")
            return true
        }else {
            log(type: .error, "NOT AVAILABLE")
            return false
        }
    }
}

public enum PrintType {
    case error
    case defult
}

public func log(type:PrintType,_ items: Any..., separator: String = " ", terminator: String = "\n") {
    
    items.forEach { item in
        switch type {
        case .error:
            print("❌ Service Debug: ",item,separator,terminator)
        case .defult:
            print("❎ Service Log: ",item,separator,terminator)
        }
    }
}

extension AVPlayer {
    
    var isPlaying: Bool {
        return ((rate != 0) && (error == nil))
    }
}
