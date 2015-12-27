//
//  PlayerView.swift
//  Player
//
//  Created by Shannon Wu on 12/7/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView {
    
    // MARK: Properties
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // MARK: Methods

    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
    
}
