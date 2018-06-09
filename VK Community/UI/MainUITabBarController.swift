//
//  MainUITabBarController.swift
//  VK Community
//
//  Created by Артем on 02.06.2018.
//  Copyright © 2018 NONE. All rights reserved.
//

import UIKit
import RealmSwift

class MainUITabBarController: UITabBarController {
    
    override func viewDidLoad() {
        VKService.request(method: "users.get", parameters: ["fields" : "photo_100"], queue: DispatchQueue.main) { (response: VKItemModel<VKUserModel>) in
            VKService.user = response.item
        }
        
        VKMessageLongPollService.loadLongPollData() {
            let longPollData: Results<VKMessageLongPollServerModel> = RealmService.loadData()!
            VKMessageLongPollService.startLongPoll(ts: longPollData[0].ts)
        }
        
        VKService.request(method: "friends.get", parameters: ["fields" : "id,photo_100,online", "order" : "hints"]) { (response: VKItemsModel<VKUserModel>) in
            RealmService.updateData(response.items)
        }
    }
    
}