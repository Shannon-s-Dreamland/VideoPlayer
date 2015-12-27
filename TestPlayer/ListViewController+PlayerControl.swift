//
//  ListViewController+PlayerControl.swift
//  TestPlayer
//
//  Created by Shannon Wu on 12/24/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import UIKit

extension ListViewController: PlayerViewControllerDelegate {
    
    // MARK: Player Configuration
    
    struct PlayerConfiguration {
        static let smallSize: CGSize = CGSize(width: 200, height: 200 * 9 / 16)
        static let bottomOffset: CGFloat = 0
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath ?? "") == "contentOffset" && object === tableView {
            resetPlayerViewState()
        }
    }
    
    func playVideoWithData(data: PlayerModel, indexpath: NSIndexPath) {
        tableView.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)

        playerIndexPath = indexpath
        playerViewController?.viewState = .InCell
        playerViewController?.playerModel = data
    }
    
    func resetPlayerViewState() {
        if let indexPath = playerIndexPath,
            cell = tableView.cellForRowAtIndexPath (indexPath){
                var frame = view.convertRect(cell.bounds, fromView: cell)
                frame.origin.y = frame.y - tableView.contentOffset.y
                if frame.y < 0 || frame.y > view.bounds.height - PlayerConfiguration.smallSize.height {
                    playerViewController?.viewState = .SmallMode
                } else {
                    playerViewController?.viewState = .InCell
                }
        } else if playerIndexPath != nil {
            playerViewController?.viewState = .SmallMode
        }
    }
    
    func viewStateForPlayer() -> PlayerViewState {
        if let indexPath = playerIndexPath,
            cell = tableView.cellForRowAtIndexPath (indexPath){
                var frame = view.convertRect(cell.bounds, fromView: cell)
                frame.origin.y = frame.y - tableView.contentOffset.y
                if frame.y < 0 || frame.y > view.bounds.height - PlayerConfiguration.smallSize.height {
                    return .SmallMode
                } else {
                    return .InCell
                }
        }
        
        return .SmallMode
    }

    func frameOfPlayerInViewState(state: PlayerViewState) -> CGRect {
        switch state {
        case .FullScreen:
            return UIScreen.mainScreen().bounds
        case .InCell:
            if let indexPath = playerIndexPath,
                cell = tableView.cellForRowAtIndexPath (indexPath){
                return view.convertRect(cell.bounds, fromView: cell)
            } else {
                assertionFailure("好像状态设置写了个 Bug")
                return CGRect.zero
            }
        case .SmallMode:
             return CGRectMake(view.frame.width - PlayerConfiguration.smallSize.width, view.frame.height - PlayerConfiguration.smallSize.height - PlayerConfiguration.bottomOffset + tableView.contentOffset.y, PlayerConfiguration.smallSize.width, PlayerConfiguration.smallSize.height)
        case .Hidden: //Better to be as large as possible, or there will be constraints conflict
            return UIScreen.mainScreen().bounds
        }
    }
    
    func addPlayerView(view: UIView) {
        self.view.addSubview(view)
    }
    
    // MARK: Error

    
    func handlePlayError(error: PlayerError) {
        print(error)
    }
    
    // MARK: Share

    func share(data: PlayerModel) {
        // TODO: 不实现分享
    }
    
    func canShareContentInViewState(state: PlayerViewState) -> Bool {
        switch state {
        case .InCell:
            return true
        default:
            return false
        }
    }
    
    // MARK: Exit
    func playerDidExit() {
        tableView.removeObserver(self, forKeyPath: "contentOffset")
    }

}
