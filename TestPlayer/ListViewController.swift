//
//  ListViewController.swift
//  TestPlayer
//
//  Created by Shannon Wu on 12/24/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    
    func configureCellWithListItem(data: PlayerModel) {
        title.text = data.title
    }
}

class ListViewController: UITableViewController {

    var playerIndexPath: NSIndexPath?
    
    lazy var playerViewController: PlayerViewController? = {
        if let vc = UIStoryboard(name: "Player", bundle: nil).instantiateInitialViewController() as? PlayerViewController {
            vc.delegate = self
            return vc
        } else {
            assertionFailure("")
        }
        return nil
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ListManager.fetchListWithCompletionHandler { error in
            if let error = error {
                assertionFailure("获取列表失败 \(error)")
            } else {
                self.tableView.reloadData()
            }
        }
        
        guard let playerVC = playerViewController else {
            return
        }
        
        addChildViewController(playerVC)
        view.addSubview(playerVC.view)
        playerVC.view.hidden = true
    }
}

extension ListViewController {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIScreen.mainScreen().bounds.width * 9 / 16
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = ListManager.list[indexPath.row]
        playVideoWithData(PlayerModel(title: item.title, videoURL: (item.videoSource360!.URL)!), indexpath: indexPath)
    }
}

extension ListViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ListManager.list.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? ListCell {
            let item = ListManager.list[indexPath.row]
            cell.configureCellWithListItem(PlayerModel(title: item.title, videoURL: item.videoSource360!.URL!))
            return cell
        } else {
            assertionFailure("不应该获取不到 Cell")
            return UITableViewCell()
        }
    }
}
