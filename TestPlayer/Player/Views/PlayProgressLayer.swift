//
//  PlayProgressLayer.swift
//  Client
//
//  Created by Shannon Wu on 12/24/15.
//  Copyright © 2015 36Kr. All rights reserved.
//

import UIKit

// MARK: - PlayProgressLayer

class PlayProgressLayer: CALayer {
    // MARK: Properties
    
    var sliderHeight: CGFloat = 2.0 {
        didSet {
            sliderHeight = sliderHeight.valueBetweenZeroAndOne
            setNeedsDisplay()
        }
    }
    
    var currentValue: CGFloat = 0.0 {
        didSet {
            currentValue = currentValue.valueBetweenZeroAndOne
            setNeedsDisplay()
        }
    }
    
    var progressValue: CGFloat = 0.0 {
        didSet {
            progressValue = progressValue.valueBetweenZeroAndOne
            setNeedsDisplay()
        }
    }
    
    var progressColor: CGColor = UIColor.whiteColor().CGColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var leftoverColor: CGColor = UIColor.whiteColor().CGColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var thumbRadius: CGFloat = 10.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var thumbColor: CGColor = UIColor.whiteColor().CGColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: Draw
    
    override func drawInContext(ctx: CGContext) {
        super.drawInContext(ctx)
        
        let centerY = bounds.height / 2.0
        
        let progressY = (bounds.height - sliderHeight) / 2.0
        let progressRect = CGRect(x: 0, y: progressY, width: bounds.width * progressValue, height: sliderHeight)
        CGContextSetFillColorWithColor(ctx, progressColor)
        CGContextFillRect(ctx, progressRect)
        
        CGContextSetFillColorWithColor(ctx, leftoverColor)
        let leftoverRect = CGRect(x: bounds.width * progressValue, y: progressY, width: bounds.width * (1 - progressValue), height: sliderHeight)
        CGContextFillRect(ctx, leftoverRect)
        
        let thumbOrigin: CGPoint
        if currentValue != 1 {
            thumbOrigin = CGPoint(x: bounds.width * currentValue, y: centerY - thumbRadius / 2.0)
        } else {
            thumbOrigin = CGPoint(x: bounds.width * currentValue - thumbRadius / 2.0, y: centerY - thumbRadius / 2.0)
        }
        CGContextSetFillColorWithColor(ctx, thumbColor)
        CGContextAddEllipseInRect(ctx, CGRect(origin: thumbOrigin, size: CGSize(width: thumbRadius, height: thumbRadius)))
        CGContextFillPath(ctx)
    }
}
