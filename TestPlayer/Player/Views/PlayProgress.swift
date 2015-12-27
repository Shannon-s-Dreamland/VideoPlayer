//
//  PlayProgress.swift
//  TestPlayProgressControl
//
//  Created by Shannon Wu on 12/17/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import UIKit


// MARK: - PlayProgress

@IBDesignable class PlayProgress: UIControl {
    // MARK: - Type
    
    enum EndType {
        case Cancel
        case Finish
        case Progress
    }
    
    // MARK: - Properties

    // MARK: Outlook

    override class func layerClass() -> AnyClass {
        return PlayProgressLayer.self
    }
    
    override func didMoveToWindow() {
        if let window = window {
            contentScaleFactor = window.screen.scale
        }
    }
    
    var playProgressLayer: PlayProgressLayer {
        return layer as! PlayProgressLayer
    }
    
    @IBInspectable var sliderHeight: CGFloat {
        set {
            playProgressLayer.sliderHeight = newValue
        }
        
        get {
            return playProgressLayer.sliderHeight
        }
    }
    
    @IBInspectable var currentValue: CGFloat {
        set {
            playProgressLayer.currentValue = newValue
        }
        
        get {
            return playProgressLayer.currentValue
        }
    }
    
    @IBInspectable var progressValue: CGFloat {
        set {
            playProgressLayer.progressValue = newValue
        }
        
        get {
            return playProgressLayer.progressValue
        }
    }

    
    @IBInspectable var progressColor: UIColor {
        set {
            playProgressLayer.progressColor = newValue.CGColor
        }
        
        get {
            return UIColor(CGColor: playProgressLayer.progressColor)
        }
    }
    
    @IBInspectable var leftoverColor: UIColor {
        set {
            playProgressLayer.leftoverColor = newValue.CGColor
        }
        
        get {
            return UIColor(CGColor: playProgressLayer.leftoverColor)
        }
    }
    
    @IBInspectable var thumbRadius: CGFloat {
        set {
            playProgressLayer.thumbRadius = newValue
        }
        
        get {
            return playProgressLayer.thumbRadius
        }
    }
    
    @IBInspectable var thumbColor: UIColor {
        set {
            playProgressLayer.thumbColor = newValue.CGColor
        }
        
        get {
            return UIColor(CGColor: playProgressLayer.thumbColor)
        }
    }
    
    // MARK: State Track

    private var beginPoint: CGPoint?
    private var initialCurrentValue: CGFloat?

}

// MARK: - Track State

extension PlayProgress {
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        beginPoint = touch.locationInView(self)
        initialCurrentValue = CGFloat(currentValue)
        
        if CGRectContainsPoint(playProgressLayer.bounds, beginPoint!) {
            return true
        } else {
            return false
        }
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let middlePoint = touch.locationInView(self)
        changeToPoint(middlePoint, type: .Progress)
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if let endPoint = touch?.locationInView(self) {
            changeToPoint(endPoint, type: .Finish)
        } else {
            changeToPoint(CGPoint.zero, type: .Cancel)
        }
    }
    
    func changeToPoint(point: CGPoint, type: EndType) {
        func changeToPoint(point: CGPoint) {
            let delta: CGFloat
            if let beginPoint = beginPoint {
                delta = point.x - beginPoint.x
            } else {
                delta = 0.0
            }
            
            let deltaValue = delta / bounds.width
            currentValue = initialCurrentValue! + deltaValue
        }
        
        switch type {
        case .Cancel:
            return
        case .Progress:
            changeToPoint(point)
        case .Finish:
            changeToPoint(point)
            sendActionsForControlEvents(.TouchUpOutside)
        }
    }
}
