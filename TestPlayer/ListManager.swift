//
//  ListManager.swift
//  TestPlayer
//
//  Created by Shannon Wu on 12/24/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import Foundation

struct ListItem {
    var title: String?
    var featureImage: String?
    var videoSource360: String?
    var videoSource480: String?
    var videoSource720: String?
}

struct ListManager {
    static var list = [ListItem]()
    static func fetchListWithCompletionHandler(completionHandler: (error: ErrorType?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            do {
                let listArray = try NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("VideoList", ofType: "json")!)!, options: [.AllowFragments]) as! NSArray
                
                var videoList = [ListItem]()
                listArray.enumerateObjectsUsingBlock { (item, index, stop) -> Void in
                    if let item = item as? NSDictionary {
                        var videoItem = ListItem()
                        videoItem.title = item["title"] as? String
                        videoItem.videoSource360 = item["videoSource360"] as? String
                        videoItem.videoSource480 = item["videoSource480"] as? String
                        videoItem.videoSource720 = item["videoSource720"] as? String
                        videoList.append(videoItem)
                    }
                }
                ListManager.list = videoList
                completionHandler(error: nil)
            }
            catch let error {
                completionHandler(error: error)
            }
        }
    }
}