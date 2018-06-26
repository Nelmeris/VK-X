//
//  MainUITabBarController.swift
//  VK X
//
//  Created by Artem Kufaev on 02.06.2018.
//  Copyright © 2018 Artem Kufaev. All rights reserved.
//

import UIKit
import RealmSwift

class MainUITabBarController: UITabBarController {
  override func viewDidLoad() {
    VKService.shared.getUser { data in
      VKService.shared.user = data.user
    }
    
    VKMessageLongPollService.loadLongPollData() {
      let longPollData: Results<VKMessageLongPollServerModel> = RealmService.loadData()!
      VKMessageLongPollService.startLongPoll(ts: longPollData.first!.ts)
    }
    
    DispatchQueue.global().async {
      while true {
        VKService.shared.getFriends { data in
          RealmService.updateData(data)
        }
        
        VKService.shared.getGroups { data in
          RealmService.updateData(data)
        }
        
        sleep(30)
      }
    }
  }
}