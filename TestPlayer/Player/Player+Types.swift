//
//  Player+Types.swift
//  Client
//
//  Created by Shannon Wu on 12/24/15.
//  Copyright © 2015 36Kr. All rights reserved.
//

import UIKit

// MARK: - PlayerViewControllerDelegate

protocol PlayerViewControllerDelegate: class {
    // View
    func frameOfPlayerInViewState(state: PlayerViewState) -> CGRect
    func viewStateForPlayer() -> PlayerViewState
    func addPlayerView(view: UIView)
    func playerDidExit()
    
    // Error
    func handlePlayError(error: PlayerError)
    
    // Share
    func canShareContentInViewState(state: PlayerViewState) -> Bool
    func share(data: PlayerModel)
}

// MARK: - PlayerModel

struct PlayerModel {
    var videoURL: NSURL
    var title: String?
    
    init(title: String?, videoURL: NSURL) {
        self.title = title
        self.videoURL = videoURL
    }
}

// MAKR: - Player

enum PlayerViewState {
    case FullScreen
    case InCell
    case SmallMode
    case Hidden
}

enum PlayerError: ErrorType {
    case DataNotSet(des: String)
    case CannotPlay(des: String)
}
