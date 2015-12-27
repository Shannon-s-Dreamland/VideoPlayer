//
//  PlayerViewController.swift
//  Player
//
//  Created by Shannon Wu on 12/7/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

// MARK: - PlayerViewController

class PlayerViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: Player
    
    lazy var player = AVPlayer()

    weak var delegate: PlayerViewControllerDelegate?

    // MARK: Player Item
    
    let playerItemQ = dispatch_queue_create("PlayerViewController.PlayerItem", DISPATCH_QUEUE_SERIAL)
    
    var playerViewControllerKVOContext = 0
    
    static let assetKeysRequiredToPlay = [
        "playable",
        "hasProtectedContent"
    ]
    
    var playerModel: PlayerModel? = nil {
        didSet {
            if let URL = playerModel?.videoURL {
                loadingIndicator.hidden = false
                titleLabel.text = playerModel?.title
                viewState = .InCell
                autoFadeOutControlBar()

                dispatch_async(playerItemQ) {
                    let asset = AVURLAsset(URL: URL, options: nil)
                    self.playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: PlayerViewController.assetKeysRequiredToPlay)
                }
            } else {
                assertionFailure()
                delegate?.handlePlayError(.DataNotSet(des: NSLocalizedString("没有获取到视频地址", comment: "")))
            }
        }
    }
    
    var playerItem: AVPlayerItem? = nil {
        didSet {
            player.replaceCurrentItemWithPlayerItem(playerItem)
            
            if playerItem == nil {
                cleanUpPlayerPeriodicTimeObserver()
            }
            else {
                setupPlayerPeriodicTimeObserver()
            }
        }
    }
    
    // MARK: View
    
    lazy var playWindow: UIWindow = {
        let window = UIWindow()
        window.windowLevel = UIWindowLevelStatusBar
        window.hidden = true
        window.userInteractionEnabled = true
        window.rootViewController = UIViewController()
        
        return window
    }()

    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playControlView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var timeSlider: PlayProgress!
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var elapseLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var shareTrailingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shareButton: UIButton!
    
    var shareButtonConstraints = [NSLayoutConstraint]()

    var viewState: PlayerViewState = .Hidden {
        didSet {
            guard let delegate = delegate else {
                assertionFailure("不应该在没有设置 Delegate 的时候调用到这里")
                return
            }
            
            func animateShareButton(visible: Bool) {
                if visible {
                    self.shareButton.hidden = false
                    self.shareTrailingSpaceConstraint.constant = 20
                    NSLayoutConstraint.deactivateConstraints([shareWidthConstraint, shareHeightConstraint])
                } else {
                    NSLayoutConstraint.activateConstraints([shareWidthConstraint, shareHeightConstraint])
                    self.shareTrailingSpaceConstraint.constant = 0
                    self.shareButton.hidden = true
                }
            }
            
            func animateToggleFullScreen() {
                let frame = delegate.frameOfPlayerInViewState(self.viewState)
                let duration = 0.25
                if viewState == .FullScreen {
                    removeFromParentViewController()
                    playWindow.rootViewController?.view.addSubview(view)
                    UIView.animateWithDuration(duration) {
                        self.playWindow.hidden = false
                        self.view.hidden = false
                        self.view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                        self.view.frame = frame
                    }
                } else if viewState == .Hidden {
                    // Nothing
                } else {
                    if playWindow.hidden == false {
                        UIView.animateWithDuration(duration) {
                            self.playWindow.hidden = true
                            delegate.addPlayerView(self.view)
                            self.view.hidden = false
                            self.view.transform = CGAffineTransformIdentity
                            self.view.frame = frame
                        }
                    } else {
                        view.frame.origin = frame.origin
                        view.frame.size = frame.size
                        UIView.animateWithDuration(duration) {
                            delegate.addPlayerView(self.view)
                            self.view.hidden = false
                            self.view.frame.size = frame.size
                        }
                    }
                }
            }
            
            switch viewState {
            case .SmallMode:
                animateHide()
            case .Hidden:
                if oldValue == .FullScreen {
                    playWindow.hidden = true
                    view.transform = CGAffineTransformIdentity
                } else {
                    view.hidden = true
                    removeFromParentViewController()
                }
            default:()
            }
            
            animateToggleFullScreen()
            
            let shareButtonVisible = delegate.canShareContentInViewState(viewState)
            if shareButtonVisible != !shareButton.hidden {
                animateShareButton(shareButtonVisible)
            }
        }
    }
    
    var playerLayer: AVPlayerLayer? {
        return playerView.playerLayer
    }
    
    var loadingState: Bool = false {
        didSet {
            if loadingState {
                loadingIndicator.hidden = false
                playPauseButton.hidden = true
            } else {
                loadingIndicator.hidden = true
                playPauseButton.hidden = false

            }
        }
    }

    // MARK: Time
    
    var timeObserverToken: AnyObject?

    var currentTime: Double {
        get {
            return CMTimeGetSeconds(player.currentTime())
        }
        
        set {
            let newTime = CMTimeMakeWithSeconds(Double(Int(newValue)), 1)
            loadingState = true
            player.seekToTime(newTime) { finished in
                self.loadingState = false
                self.player.play()
            }
        }
    }

    var duration: Double {
        guard let currentItem = player.currentItem else { return 0.0 }

        return CMTimeGetSeconds(currentItem.duration)
    }
    
    // MARK: - IBActions
    
    @IBAction func toggleFullscreen(sender: UIButton) {
        guard let delegate = delegate else {
            assertionFailure("你又在写 Bug!")
            return
        }
        if viewState != .FullScreen {
            viewState = .FullScreen
        } else {
            viewState = delegate.viewStateForPlayer()
        }
    }
    
    @IBAction func exit(sender: UIButton) {
        exit()
    }
    
    @IBAction func playPauseButtonWasPressed(sender: UIButton) {
        if player.rate != 1.0 {
            if currentTime == duration {
                currentTime = 0.0
            }
            player.play()
        }
        else {
            player.pause()
        }
    }
    
    @IBAction func timeSliderTouchDown(sender: PlayProgress) {
        player.pause()
        cancelAutoFadeOutControlBar()
    }
    
    @IBAction func touchSliderTouchUp(sender: PlayProgress) {
        currentTime = Double(sender.currentValue) * duration
        player.play()
        autoFadeOutControlBar()
    }
    
    @IBAction func share(sender: UIButton) {
        if let model = playerModel {
            delegate?.share(model)
        } else {
            assertionFailure()
            delegate?.handlePlayError(.DataNotSet(des: NSLocalizedString("无法获取当前播放的视频数据", comment: "")))
        }
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObserver(self, forKeyPath: "player.currentItem.duration", options: [.New, .Initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: "player.rate", options: [.New, .Initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: "player.currentItem.status", options: [.New, .Initial], context: &playerViewControllerKVOContext)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapGestureRecognized")
        view.addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: "pinchGestureRecognized:")
        view.addGestureRecognizer(pinchGesture)
        
        
        playerView.playerLayer.player = player
        playerLayer?.fillMode = AVLayerVideoGravityResize
    }
    
    deinit {
        removeObserver(self, forKeyPath: "player.currentItem.duration")
        removeObserver(self, forKeyPath: "player.rate")
        removeObserver(self, forKeyPath: "player.currentItem.status")
    }
    
    // MARK: KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &playerViewControllerKVOContext else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        if keyPath == "player.currentItem.duration" {
            let newDuration: CMTime
            if let newDurationAsValue = change?[NSKeyValueChangeNewKey] as? NSValue {
                newDuration = newDurationAsValue.CMTimeValue
            }
            else {
                newDuration = kCMTimeZero
            }
            let hasValidDuration = newDuration.isNumeric && newDuration.value != 0
            
            let currentTime = CMTimeGetSeconds(player.currentTime())
            timeSlider.currentValue = CGFloat(hasValidDuration ? currentTime / duration : 0.0)
            
            playPauseButton.enabled = hasValidDuration
            timeSlider.enabled = hasValidDuration
        }
        else if keyPath == "player.rate" {
            let newRate = (change?[NSKeyValueChangeNewKey] as! NSNumber).doubleValue
            
            if newRate == 0.0 {
                playPauseButton.setImage(UIImage(named: "news_krtv_play"), forState: .Normal)
                cancelAutoFadeOutControlBar()
            } else {
                playPauseButton.setImage(UIImage(named: "news_krtv_pause"), forState: .Normal)
                autoFadeOutControlBar()
            }
        }
        else if keyPath == "player.currentItem.status" {
            let newStatus: AVPlayerItemStatus
            if let newStatusAsNumber = change?[NSKeyValueChangeNewKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.integerValue)!
            }
            else {
                newStatus = .Unknown
            }
            
            if newStatus == .Failed {
                exit()
                loadingState = false
                delegate?.handlePlayError(.CannotPlay(des: NSLocalizedString("当前视频播放失败", comment: "")))
            }
            else if newStatus == .ReadyToPlay {
                loadingState = false
                if let asset = player.currentItem?.asset {
                    
                    for key in PlayerViewController.assetKeysRequiredToPlay {
                        var error: NSError?
                        if asset.statusOfValueForKey(key, error: &error) == .Failed {
                            delegate?.handlePlayError(.CannotPlay(des: NSLocalizedString("当前视频播放失败", comment: "")))
                            exit()
                            return
                        }
                    }
                    
                    if !asset.playable || asset.hasProtectedContent {
                        delegate?.handlePlayError(.CannotPlay(des: NSLocalizedString("当前视频播放失败", comment: "")))
                        exit()
                        return
                    }
                    
                    player.play()
                }
            }
            else {
                loadingState = true
            }
        }
    }
    
    // MARK: - Convenience Hanlder
    
    func exit() {
        playerItem = nil
        viewState = .Hidden
        
        delegate?.playerDidExit()
    }

    func updateTimelabel() {
        if currentTime < 1 || !currentTime.isFinite {
            elapseLabel.text = "00:00"
            totalTimeLabel.text = "00:00"
            return
        }
        let elapse = String(format: "%02d:", Int(currentTime) / 60) + String(format: "%02d", Int(currentTime) % 60)
        let totalTime = String(format: "%02d:", Int(duration) / 60) + String(format: "%02d", Int(duration) % 60)
        elapseLabel.text = elapse
        totalTimeLabel.text = totalTime
    }
    
    func togglePlayPause() {
        if player.rate == 0 {
            player.rate = 1
        } else {
            player.rate = 0
        }
    }
    
    func cleanUpPlayerPeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func setupPlayerPeriodicTimeObserver() {
        guard timeObserverToken == nil else { return }
        
        let time = CMTimeMake(1, 1)
        
        timeObserverToken = player.addPeriodicTimeObserverForInterval(time, queue:dispatch_get_main_queue()) {
            [weak self] time in
            if let weakSelf = self {
                if weakSelf.duration != 0 {
                    weakSelf.timeSlider.currentValue = CGFloat(CMTimeGetSeconds(time) / weakSelf.duration)
                    weakSelf.updateTimelabel()
                    weakSelf.timeSlider.progressValue = CGFloat(weakSelf.streamProgress())
                }
            }
        }
    }
    
    func tapGestureRecognized() {
        if viewState == .SmallMode {
            viewState = .FullScreen
        } else {
            animateShow()
        }
    }
    
    var initialPinchTransform: CGAffineTransform?
    func pinchGestureRecognized(pinchGesture: UIPinchGestureRecognizer) {
        func resetTransform(exitVideo: Bool = false) {
            view.transform = initialPinchTransform!
            initialPinchTransform = nil

            if exitVideo {
                exit()
            }
        }
        
        initialPinchTransform = initialPinchTransform ?? view.transform
        let scale = pinchGesture.scale
        if scale < 1 {
            view.transform = CGAffineTransformScale(initialPinchTransform!, scale, scale)
        }
        
        switch pinchGesture.state {
        case .Ended:
            if pinchGesture.velocity < 0 {
                resetTransform(true)
            } else {
                resetTransform()
            }
            
        case .Cancelled:
            resetTransform()
        default:()
        }
    }
    
    func streamProgress() -> Double {
        func availableDuration() -> Double
        {
            if let range = player.currentItem?.loadedTimeRanges.first {
                return CMTimeGetSeconds(CMTimeRangeGetEnd(range.CMTimeRangeValue))
            }
            return 0
        }
        
        return (duration == 0) ? (duration) : (availableDuration() / duration)
    }
    
}

// MARK: Control Bar Manipulation

extension PlayerViewController {
    func autoFadeOutControlBar() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: "animateHide", object: nil)
        self.performSelector("animateHide", withObject: nil, afterDelay: 5)
    }
    
    func cancelAutoFadeOutControlBar() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: "animateHide", object: nil)
    }
    
    func animateHide() {
        UIView.animateWithDuration(0.25, delay: 0.0, options: [.LayoutSubviews, .AllowUserInteraction],
            animations: { () -> Void in
            self.playControlView.alpha = 0.0
            })
            { (finished) -> Void in }
    }
    
    func animateShow() {
        if viewState == .SmallMode { return }

        UIView.animateWithDuration(0.25, delay: 0.0, options: [.LayoutSubviews, .AllowUserInteraction],
            animations: { () -> Void in
                self.playControlView.alpha = 1.0
            })
            { (finished) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    self.autoFadeOutControlBar()
                }
        }
    }
}
